namespace Booru.Api {

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
