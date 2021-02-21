namespace Booru.Gui {

class MediaDisplay : Gtk.Overlay {
    public Gtk.Image image;
    public Gst.Element playbin;
	public Gtk.Widget video_area;
	
	public MediaDisplay () {
	    image = new Gtk.Image ();
	    playbin = Gst.ElementFactory.make ("playbin", "bin");
		var gtksink = Gst.ElementFactory.make ("gtksink", "sink");
		gtksink.get ("widget", out video_area);
		playbin["video-sink"] = gtksink;
		image.show ();
		video_area.show ();
	}
	
	public void set_media (string uri) {
	    reset_video ();
	    if (uri.has_suffix (".mp4")) {
	        show_video ();
	        playbin["uri"] = uri;
	        playbin.set_state (Gst.State.PLAYING);
	    } else {
	        show_image ();
	        string image_path = Cache.get_file (uri);
    		uint8 retries = 5;
    		while (image_path == "" && retries-- > 0) {
    			image_path = Cache.get_file (uri);
    		}
    		image.set_from_file(image_path);
	    }
	}
	
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
	
	private void reset_video () {
	    playbin["uri"] = "";
    	playbin.set_state (Gst.State.READY);
	}
}

}
