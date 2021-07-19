/* query.vala
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

namespace Booru.Api {

public class Query {
    private const string base_query_url = "https://gelbooru.com/index.php?page=dapi&s=post&q=index";
    private List<Post> posts;
    private string tags;

    public Query (string tags) {
        posts = new List<Post>();
        var session = new Soup.Session ();
        this.tags = tags;
        GXml.XDocument results = null;
        try {
	        var request = session.request ("%s&tags=%s&limit=%u".printf(base_query_url, tags, 1000));

	        // Workaround to remove unsupported named HTML entities
	        uint8[] buffer = new uint8[4096];
	        GLib.Regex regex = /&(?!(amp|apos|quot|gt);)\w+;/;

	        GLib.InputStream response = request.send ();
	        GLib.StringBuilder response_builder = new GLib.StringBuilder ();
	        size_t read = 1;
	        while (read > 0) {
	            if (!response.read_all(buffer, out read)) {
	                stderr.printf("Failed to read response to API query");
	                break;
	            }
	            if (read < buffer.length) {
	                buffer[read] = 0;
	            }
	            response_builder.append ((string) buffer);
	        }

	        string filtered = regex.replace (response_builder.str, response_builder.len, 0, "");
	        // results = new GXml.XDocument.from_stream (request.send ());
	        results = new GXml.XDocument.from_string (filtered);
	    } catch (GLib.Error e) {
	        stderr.printf ("%s\n", e.message);
	        return;
	    }
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
        GXml.XDocument results = null;
        try {
            var request = session.request ("%s&tags=%s&cid=%u".printf(base_query_url, tags, latest_change + 1));
            results = new GXml.XDocument.from_stream (request.send ());
        } catch (GLib.Error e) {
	        stderr.printf ("%s\n", e.message);
	        return 0;
	    }
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

}
