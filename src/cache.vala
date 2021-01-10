namespace Booru {

public abstract class Cache {
    private static string cache_dir = null;
    
    private Cache();
    
    private static string get_cache_dir() {
        if (cache_dir == null) {
            string tmp_dir_path = GLib.Environment.get_tmp_dir ();
	        cache_dir = GLib.Path.build_filename(tmp_dir_path, "booru-cache");
	        GLib.DirUtils.create (cache_dir, 0777);
        }
        return cache_dir;
    }
    
    public static string get_file(string url, bool ignore_cached = false) {
        string filename = GLib.Path.get_basename (url);
        string file_path = GLib.Path.build_filename (get_cache_dir (), filename);
        var file = File.new_for_path (file_path);
	    if (!file.query_exists () || ignore_cached) {
	        var session = new Soup.Session ();
	        try {
	            var request = session.request (url);
	            var file_stream = file.create (FileCreateFlags.NONE);
	            file_stream.splice (request.send (), OutputStreamSpliceFlags.CLOSE_SOURCE);
	            file_stream.close ();
	        } catch (GLib.Error e) {
	            stderr.printf ("Error saving file: %s\n", e.message);
	            if (file.query_exists ()) {
	                file.delete ();
	            }
	            return "";
	        }
	    }
	    return file_path;
	    
    }
    
    public static bool file_exists (string filename) {
        string file_path = GLib.Path.build_filename (get_cache_dir (), filename);
        var file = File.new_for_path (file_path);
	    return file.query_exists ();
    }
    
    public static string get_path (string filename) {
        return GLib.Path.build_filename (get_cache_dir (), filename);
    }
    
    public static uint64 get_cache_size () {
        return 0;
    } 
    
}

}
