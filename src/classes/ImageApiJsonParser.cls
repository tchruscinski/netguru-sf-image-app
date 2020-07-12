public class ImageApiJsonParser {

    public String albumId;
    public String id;
    public String title;
    public String url;
    public String thumbnailUrl;


    public static List<ImageApiJsonParser> parse(String json) {
        return (List<ImageApiJsonParser>) System.JSON.deserialize(json, List<ImageApiJsonParser>.class);
    }
}