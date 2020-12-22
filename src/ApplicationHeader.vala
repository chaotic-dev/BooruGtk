namespace Booru.Gui {

public class ApplicationHeader : Gtk.HeaderBar {

    public Gtk.ToggleButton info_toggle_button { get; private set; }
    public Gtk.Button save_button { get; private set; }
    public Gtk.Entry search_bar { get; private set; }
    public Gtk.Spinner spinner { get; private set; }

    public ApplicationHeader () {
        this.set_show_close_button (true);
		this.set_title ("Booru");
		this.set_subtitle ("tags");
		
		save_button = new Gtk.Button.with_label ("Save");
		save_button.set_image (new Gtk.Image.from_icon_name( "document-save",
                                              Gtk.IconSize.SMALL_TOOLBAR
                                              ));
        save_button.always_show_image = true;
		save_button.show ();
		this.pack_start (save_button);
		
		info_toggle_button = new Gtk.ToggleButton ();
		info_toggle_button.set_image (new Gtk.Image.from_icon_name( "dialog-information",
                                              Gtk.IconSize.SMALL_TOOLBAR
                                              ));
        info_toggle_button.show ();
        this.pack_end (info_toggle_button);
        
        search_bar = new Gtk.Entry ();
		search_bar.primary_icon_name = "edit-find";
		search_bar.editable = true;
		search_bar.show ();
		this.pack_end (search_bar);
        
        spinner = new Gtk.Spinner ();
		spinner.show ();
		this.pack_end (spinner);
    }
}

}
