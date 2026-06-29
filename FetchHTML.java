import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

public class FetchHTML {
    public static void main(String[] args) {
        try {
            URL url = new URL("http://localhost:8080/Backend_java/customer/dat-san");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            InputStream in = conn.getInputStream();
            String html = new String(in.readAllBytes(), StandardCharsets.UTF_8);
            Files.writeString(Paths.get("C:\\Users\\Admin\\Documents\\GitHub\\DATN_TheBigSize\\debug_html.txt"), html);
            System.out.println("Saved to debug_html.txt!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
