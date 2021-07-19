/* window.vala
 *
 * Copyright 2021 ChaoticDev
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Booru {
	[GtkTemplate (ui = "/io/github/chaoticdev/BooruGtk/window.ui")]
	public class Window : Gtk.ApplicationWindow {
        [GtkChild]
        Gtk.Stack media_stack;
        [GtkChild]
        Gtk.Button save_button;
        [GtkChild]
        Gtk.AppChooserButton app_chooser_button;
        [GtkChild]
        Gtk.ToggleButton info_toggle_button;
        [GtkChild]
        Gtk.SearchEntry search_entry;
        [GtkChild]
        Gtk.DrawingArea video_display;
        [GtkChild]
        Hdy.Deck image_display_deck;
        [GtkChild]
        Gtk.Revealer side_panel_revealer;

        Api.Query query = null;
	    uint entry = 0;
	    Api.Post current_post = null;
	    Gtk.AccelGroup accels;
	    string save_dialog_folder = null;

		public Window (Gtk.Application app) {
			Object (application: app);

			accels = new Gtk.AccelGroup ();
		    this.add_accel_group (accels);
			save_button.add_accelerator ("clicked", accels, Gdk.Key.S, Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE);
		}

	    [GtkCallback]
	    void on_save_button_clicked () {
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
		    if (save_dialog_folder != null)
			    save_dialog.set_current_folder (save_dialog_folder);
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
		    save_dialog_folder = file_dialog.get_current_folder ();
		    file_dialog.destroy ();
	    }

	    [GtkCallback]
	    private void on_info_toggle_button_toggled (Gtk.ToggleButton source) {
            side_panel_revealer.set_reveal_child (source.get_active ());
	    }

	    [GtkCallback]
	    private void on_search_entry_activate (Gtk.Entry search) {
            search.sensitive = false;
            stderr.printf ("Search: %s\n", search.text);
            query = new Api.Query (search.text);
            load_entry (0);
            search.sensitive = true;
	    }

	    private void load_entry (uint index) {
            if (query == null) {
	            query = new Api.Query ("");
	        }
	        var post = query.get_post(index);
	        if (post != null)
	            current_post = post;

            string uri = post.sample_url;
            Gtk.Widget media = null;
            Gst.Element playbin = null;
            if (uri.has_suffix (".mp4")) {
                playbin = Gst.ElementFactory.make ("playbin", "bin");
                Gtk.Widget video_area;
                var gtksink = Gst.ElementFactory.make ("gtksink", "sink");
		        gtksink.get ("widget", out media);
		        playbin["video-sink"] = gtksink;
                playbin["uri"] = uri;
            } else {
                string image_path = Cache.get_file (uri);
    		    uint8 retries = 5;
    		    while (image_path == "" && retries-- > 0) {
    			    image_path = Cache.get_file (uri);
    		    }
    		    media = new Gtk.Image.from_file (image_path);
            }
            if (media != null) {
                media_stack.add_named (media, post.md5);
		        media.show ();
		        media_stack.set_visible_child (media);
		        if (playbin != null) {
		            stderr.printf ("Playing media: %s\n", uri);
		            playbin.set_state (Gst.State.READY);
		            playbin.set_state (Gst.State.PLAYING);
		        }
		    }
	    }
	}
}
