import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Scanner;

public class FetchDatSan {
    public static void main(String[] args) {
        try {
            URL url = new URL("http://localhost:8080/Backend_java/customer/dat-san");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.connect();

            int responseCode = conn.getResponseCode();
            System.out.println("Response Code: " + responseCode);
            
            if (responseCode == 200) {
                InputStream is = conn.getInputStream();
                Scanner scanner = new Scanner(is, StandardCharsets.UTF_8.name());
                String responseBody = scanner.useDelimiter("\\A").next();
                scanner.close();
                Files.write(Paths.get("DatSan_output.html"), responseBody.getBytes(StandardCharsets.UTF_8));
                System.out.println("Saved to DatSan_output.html");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
