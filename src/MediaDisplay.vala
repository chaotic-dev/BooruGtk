namespace Booru.Gui {

class MediaDisplay {
    public Gtk.Overlay widget {get; private set; }
    private Gtk.Image image;
    private Gtk.Video video;
	
	public MediaDisplay () {
	    widget = new Gtk.Overlay ();
            widget.set_hexpand (true);
	    widget.set_vexpand (true);
	    widget.show ();
	    image = new Gtk.Image ();
	    video = new Gtk.Video ();
		image.show ();
		video.show ();
	}
	
	public void set_media (string uri) {
	    reset_video ();
	    if (uri.has_suffix (".mp4")) {
	        //show_video ();
		widget.set_child (video);
		var session = new Soup.Session ();
		var request = session.request (uri);
		Gtk.MediaFile media_file = Gtk.MediaFile.for_input_stream (request.send ());
		video.media_stream = media_file;
	    } else {
	        //show_image ();
		widget.set_child (image);
	        string image_path = Cache.get_file (uri);
    		uint8 retries = 5;
    		while (image_path == "" && retries-- > 0) {
    			image_path = Cache.get_file (uri);
    		}
    		image.set_from_file(image_path);
	    }
	}
	/*
	private void show_video () {
	    if (this.get_child () != video_area) {
	    	this.remove (this.get_child ());
	    	this.child = video_area;
	    }
	}
	
	private void show_image () {
	    if (this.get_child () != image) {
	    	this.remove (this.get_child ());
	    	this.child = image;
	    }
	}
	*/
	private void reset_video () {
	    video.media_stream = null;
	}
}

}
