namespace Booru.Gui {

public class ApplicationHeader {

    public Gtk.HeaderBar widget { get; private set; }
    public Gtk.ToggleButton info_toggle_button { get; private set; }
    public Gtk.Button save_button { get; private set; }
    public Gtk.Entry search_bar { get; private set; }
    public Gtk.Spinner spinner { get; private set; }

    public ApplicationHeader () {
	widget = new Gtk.HeaderBar ();
        widget.show_title_buttons = true;
	widget.title_widget = new Gtk.Label ("BooruGtk");
		//this.set_title ("BooruGtk");
		//this.set_subtitle ("tags");
		
		save_button = new Gtk.Button.with_label ("Save");
		save_button.set_icon_name ("document-save");
		//save_button.set_image (new Gtk.Image.from_icon_name( "document-save",
                //                              Gtk.IconSize.SMALL_TOOLBAR
                //                              ));
	save_button.add_binding_action (Gdk.Key.S, Gdk.ModifierType.CONTROL_MASK, "clicked", null);
		save_button.show ();
		widget.pack_start (save_button);
		
		info_toggle_button = new Gtk.ToggleButton ();
		info_toggle_button.set_icon_name ("dialog-information");
		//info_toggle_button.set_image (new Gtk.Image.from_icon_name( "dialog-information",
                //                              Gtk.IconSize.SMALL_TOOLBAR
                //                              ));
        info_toggle_button.show ();
        widget.pack_end (info_toggle_button);
        
        search_bar = new Gtk.Entry ();
		search_bar.primary_icon_name = "edit-find";
		search_bar.editable = true;
		search_bar.show ();
		widget.pack_end (search_bar);
        
        spinner = new Gtk.Spinner ();
		spinner.show ();
		widget.pack_end (spinner);
	widget.show ();
    }
}

}
