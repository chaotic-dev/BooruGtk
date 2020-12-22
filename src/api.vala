namespace Booru.Api {

private const string base_query_url = "https://gelbooru.com/index.php?page=dapi&s=post&q=index";

struct Size {
    public uint width;
    public uint height;
}

// Size s = {x, y};

public class Query {
    private const string base_query_url = "https://gelbooru.com/index.php?page=dapi&s=post&q=index";
    private List<Post> posts;
    private string tags;
    
    public Query (string tags) {
        posts = new List<Post>();
        var session = new Soup.Session ();
        this.tags = tags;
        var request = session.request ("%s&tags=%s&limit=%u".printf(base_query_url, tags, 1000));
        var results = new GXml.XDocument.from_stream (request.send ());
        var root = results.document_element;
        total_results = int.parse (root.get_attribute ("count"));
        var children = root.get_elements_by_tag_name ("post");
        foreach (GXml.DomElement post in children.to_array ()) {
            posts.append (new Post (post));
        }
    }
    
    public int update() {
        var latest_id = posts.first ().data.id;
        var latest_change = posts.first ().data.change;
        var session = new Soup.Session ();
        var request = session.request ("%s&tags=%s&cid=%u".printf(base_query_url, tags, latest_change + 1));
        var results = new GXml.XDocument.from_stream (request.send ());
        var root = results.document_element;
        var new_posts = int.parse (root.get_attribute ("count"));
        if (new_posts > 100) {
            stderr.printf("Too many new posts! Refresh instead.\n");
            return 0;
        }
        new_posts = 0;
        var children = root.get_elements_by_tag_name ("post");
        for (int i = children.length - 1; i >=0; i--) {
            var post = new Post (children.item (i));
            
            // Filter old posts with changes
            if (post.id > latest_id) {
                posts.prepend (post);
                new_posts++;
            }
        }
        
        total_results += new_posts;
        return new_posts;
    }
    
    public uint total_results { get; private set; }
    
    public Post get_post (uint index) {
        if (index >= total_results) {
            return posts.nth_data(total_results - 1);
        }
        if (index >= posts.length ()) {
            return posts.last ().data;
        }
        return posts.nth_data(index);
    }
}

public class Post {
    
    public enum Rating {
        SAFE,
        QUESTIONABLE,
        EXPLICIT
    }

    public uint id { get; private set; }
    public uint parent_id { get; private set; }
    public uint creator_id { get; private set; }
    public uint width { get; private set; }
    public uint height { get; private set; }
    public uint sample_width { get; private set; }
    public uint sample_height { get; private set; }
    public uint preview_width { get; private set; }
    public uint preview_height { get; private set; }
    public uint score { get; private set; }
    public uint change { get; private set; }
    public bool has_children { get; private set; }
    public bool has_notes { get; private set; }
    public bool has_comments { get; private set; }
    public string filename { get; private set; }
    public string file_url { get; private set; }
    public string sample_url { get; private set; }
    public string preview_url { get; private set; }
    public string md5 { get; private set; }
    public string created_at { get; private set; }
    public string tag_string { get; private set; }
    public string[] tags { get; private set; }
    public Rating rating { get; private set; }
    
    public string to_string () {
        return @"{id: $id, parent_id: $parent_id}";
    }
    
    public Post (GXml.DomElement post) {
    
        file_url = post.get_attribute ("file_url");
        filename = GLib.Path.get_basename (file_url);
        sample_url = post.get_attribute ("sample_url");
        preview_url = post.get_attribute ("preview_url");
        md5 = post.get_attribute ("md5");
        created_at = post.get_attribute ("created_at");
        tag_string = post.get_attribute ("tags");
        tags = tag_string.split (" ");
        
        id = int.parse (post.get_attribute ("id"));
        parent_id = int.parse (post.get_attribute ("parent_id"));
        creator_id = int.parse (post.get_attribute ("creator_id"));
        width = int.parse (post.get_attribute ("width"));
        height = int.parse (post.get_attribute ("height"));
        sample_width = int.parse (post.get_attribute ("sample_width"));
        sample_height = int.parse (post.get_attribute ("sample_height"));
        preview_width = int.parse (post.get_attribute ("preview_width"));
        preview_height = int.parse (post.get_attribute ("preview_height"));
        score = int.parse (post.get_attribute ("score"));
        change = int.parse (post.get_attribute ("change"));
        
        bool temp = false;
        bool.try_parse (post.get_attribute ("has_children"), out temp);
        has_children = temp;
        bool.try_parse (post.get_attribute ("has_notes"), out temp);
        has_notes = temp;
        bool.try_parse (post.get_attribute ("has_comments"), out temp);
        has_comments = temp;
        
        switch (post.get_attribute ("rating")) {
            case "s":
                rating = Rating.SAFE;
                break;
            case "q":
                rating = Rating.QUESTIONABLE;
                break;
            case "e":
                rating = Rating.EXPLICIT;
                break;
        }
        
    }
}

}
