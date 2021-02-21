#!/bin/bash

valac --pkg gtk4 --pkg libsoup-2.4 --pkg gxml-0.20 --pkg gio-2.0 ../src/*.vala -d ../bin -C
cd ../bin
# Fix an issue with valac not using the correct add_controller method for widgets
sed -i "328s/.*/gtk_widget_add_controller ((GtkWidget*) self, G_TYPE_CHECK_INSTANCE_CAST (_tmp12_, gtk_event_controller_get_type (), GtkEventController));/" main.c
gcc *.c $(pkg-config --cflags glib-2.0 libsoup-2.4 pango gdk-pixbuf-2.0 gee-0.8 graphene-1.0) -I /usr/include/gtk-4.0/ -I /usr/include/cairo -I /usr/local/include/gxml-0.20/ -lgtk-4 -lglib-2.0 -lgobject-2.0 -lgio-2.0 -lsoup-2.4 -lxml2 -lgxml-0.20 -o com.github.chaoticdev.booru
