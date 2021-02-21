namespace Booru {

namespace Gui {
public class MainWindow : Gtk.ApplicationWindow {

	ApplicationHeader header;
	Api.Query query = null;
	uint entry = 0;
	Api.Post current_post = null;
	Gtk.EntryCompletion completion;
	MediaDisplay media_display;
	Gtk.EventControllerKey key_event_controller;

	internal MainWindow (BooruGtkApplication app) {
		Object (application: app, title: "BooruGtk");
		this.set_default_size (800, 600);
		
		header = new ApplicationHeader ();
		header.save_button.clicked.connect (on_save_button_click);
		header.search_bar.activate.connect (on_search_bar_activate);
		this.set_titlebar (header.widget);
		
		key_event_controller = new Gtk.EventControllerKey ();
		key_event_controller.key_pressed.connect (this.on_key_press_event);
		this.add_controller ((Gtk.ShortcutController) key_event_controller);
		//this.key_press_event.connect(this.on_key_press_event);
		
		var grid = new Gtk.Grid();
		var scroll_window = new Gtk.ScrolledWindow ();
		
		media_display = new MediaDisplay ();
		
		scroll_window.set_child (media_display.widget);
		scroll_window.show ();
		
		this.set_child(grid);
		grid.attach(scroll_window, 0, 1, 1, 1);
		grid.show ();
	}
	
	bool on_key_press_event (Gtk.EventControllerKey event, uint keyval, uint keycode, Gdk.ModifierType modifier) {
		if (this.get_focus () == header.search_bar) {
			return false;
		}
		switch (keyval) {
			case Gdk.Key.Right:
				if (entry < 999) {
				    load_entry (++entry);
				}
				break;
			case Gdk.Key.Left:
				if (entry > 0) {
				    load_entry(--entry);
				} else {
					uint new_posts = query.update ();
					if (new_posts > 0) {
						stdout.printf ("Loaded %u new post(s)\n", new_posts);
				    	entry += new_posts;
				        load_entry(--entry);
				    }
				}
				break;
		}
		return false;
	}
	
	void on_save_button_click (Gtk.Button button) {
		if (current_post == null) {
			return;
		}
		var save_dialog = new Gtk.FileChooserDialog ("Save File", 
													this, 
													Gtk.FileChooserAction.SAVE,
													"Cancel",
													Gtk.ResponseType.CANCEL,
													"Save",
													Gtk.ResponseType.ACCEPT);
		save_dialog.set_current_name (current_post.filename);
		//save_dialog.set_do_overwrite_confirmation (true);
		save_dialog.set_modal (true);
		save_dialog.set_default_response(Gtk.ResponseType.ACCEPT);
		save_dialog.response.connect (save_dialog_callback);
		save_dialog.present ();
	}
	
	private void save_dialog_callback (Gtk.Dialog dialog, int response_id) {
		var file_dialog = (Gtk.FileChooserDialog) dialog;
		if (response_id == Gtk.ResponseType.ACCEPT) {
			var new_file = file_dialog.get_file ();
			if (!Cache.file_exists (current_post.filename)) {
			    var session = new Soup.Session ();
			    try {
	                var request = session.request (current_post.file_url);
	                var write_stream = new_file.replace (null, false, FileCreateFlags.NONE);
	                write_stream.splice (request.send (), OutputStreamSpliceFlags.CLOSE_SOURCE);
	                write_stream.close ();
	            } catch (GLib.Error e) {
	                stderr.printf ("Error saving file: %s\nURL: %s\n", e.message, current_post.file_url);
	            }
			} else {
				var fname = Cache.get_path (current_post.filename);
				var file = GLib.File.new_for_path (fname);
				try {
					file.copy (new_file, GLib.FileCopyFlags.OVERWRITE);
				} catch (GLib.Error e) {
	                stderr.printf ("Error copying %s from cache: %s\n", fname, e.message);
	            }
			}
		}
		file_dialog.destroy ();
	}

	void on_search_bar_activate (Gtk.Entry search) {
		header.spinner.start ();

    	query = new Api.Query (search.text);
        load_entry (0);
        entry = 0;
    	
    	header.spinner.stop ();
	}
	
	void load_entry(uint index) {
	    if (query == null) {
	        query = new Api.Query ("");
	    }
    	var post = query.get_post(index);
	((Gtk.Label) header.widget.title_widget).label = "BooruGtk - %s".printf (post.md5);
    	//header.set_title ("BooruGtk - %s".printf (post.md5));
    	//header.set_subtitle (post.tag_string);
    	
    	current_post = post;
    	
    	media_display.set_media (post.sample_url);
	}
}
}

/* This is the application. */
public class BooruGtkApplication : Gtk.Application {
	public BooruGtkApplication() {
		Object (application_id: "com.github.chaoticdev.boorugtk");
	}
	/* Override the 'activate' signal of GLib.Application. */
	protected override void activate () {
		/* Create the window of this application and show it. */
		var window = new Gui.MainWindow (this);
		window.show ();
	}
}

/* main creates and runs the application. */
public int main (string[] args) {

	// Load GUI
	Gtk.init ();
	return new BooruGtkApplication ().run (args);
}

}
