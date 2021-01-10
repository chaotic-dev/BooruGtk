namespace Booru {

namespace Gui {
public class MainWindow : Gtk.ApplicationWindow {

	ApplicationHeader header;
	Gtk.Image image;
	Api.Query query = null;
	uint entry = 0;
	Api.Post current_post = null;
	Gtk.AccelGroup accels;
	Gtk.DrawingArea video;
	Gst.Element playbin;
	Gtk.Widget video_area;
	Gtk.EntryCompletion completion;

	internal MainWindow (BooruGtkApplication app) {
		Object (application: app, title: "BooruGtk");
		this.set_default_size (800, 600);
		
		accels = new Gtk.AccelGroup ();
		this.add_accel_group (accels);
		
		header = new ApplicationHeader ();
		header.save_button.clicked.connect (on_save_button_click);
		header.save_button.add_accelerator ("clicked", accels, Gdk.Key.S, Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE);
		header.search_bar.activate.connect (on_search_bar_activate);
		header.show ();
		this.set_titlebar (header);
		
		this.key_press_event.connect(this.on_key_press_event);
		
		var grid = new Gtk.Grid();
		var scroll_window = new Gtk.ScrolledWindow (null, null);
		
		playbin = Gst.ElementFactory.make ("playbin", "bin");
		var gtksink = Gst.ElementFactory.make ("gtksink", "sink");
		gtksink.get ("widget", out video_area);
		playbin["video-sink"] = gtksink;
		video_area.set_hexpand (true);
		video_area.set_vexpand (true);
		//video_area.show ();
		
		image = new Gtk.Image ();
		image.set_hexpand (true);
		image.set_vexpand (true);
		image.show ();
		
		// Automatically adds viewport
		scroll_window.add (image);
		scroll_window.show ();
		
		this.add(grid);
		grid.attach(scroll_window, 0, 1, 1, 1);
		grid.attach_next_to (video_area, scroll_window, Gtk.PositionType.TOP, 1, 1);
		grid.show ();
	}
	
	bool on_key_press_event (Gdk.EventKey event) {
		if (this.get_focus () == header.search_bar) {
			return false;
		}
		switch (event.keyval) {
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
		save_dialog.set_do_overwrite_confirmation (true);
		save_dialog.set_modal (true);
		save_dialog.set_default_response(Gtk.ResponseType.ACCEPT);
		save_dialog.response.connect (save_dialog_callback);
		save_dialog.run ();
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
	                stderr.printf ("Error saving file: %s\n", e.message);
	            }
			} else {
				var file = GLib.File.new_for_path (Cache.get_path (current_post.filename));
				try {
					file.copy (new_file, GLib.FileCopyFlags.OVERWRITE);
				} catch (GLib.Error e) {
	                stderr.printf ("Error copying file from cache: %s\n", e.message);
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
    	header.set_title ("BooruGtk - %s".printf (post.md5));
    	header.set_subtitle (post.tag_string);
    	
    	current_post = post;
    	
    	playbin["uri"] = "";
    	playbin.set_state (Gst.State.READY);
    	
    	if (post.sample_url.has_suffix (".mp4")) {
    		video_area.show ();
    		image.hide ();
    		playbin["uri"] = post.sample_url;
    		playbin.set_state (Gst.State.PLAYING);
    	} else {
    		image.show ();
    		video_area.hide ();
    		string image_path = Cache.get_file (post.sample_url);
    		image.set_from_file(image_path);
    	}
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
	Gst.init (ref args);
	Gtk.init (ref args);
	return new BooruGtkApplication ().run (args);
}

}
