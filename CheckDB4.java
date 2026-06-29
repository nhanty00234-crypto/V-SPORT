import java.sql.*;

public class CheckDB4 {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://14.225.217.109:1433;databaseName=QuanLiSport4;encrypt=true;trustServerCertificate=true;sendStringParametersAsUnicode=true;";
        try (Connection conn = DriverManager.getConnection(url, "sa", "TOP1@iyounguru!")) {
            System.out.println("Connected to QuanLiSport4!");
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM San");
            int count = 0;
            while (rs.next()) {
                System.out.println("SanID: " + rs.getInt("SanID") + " | TenSan: " + rs.getString("TenSan"));
                count++;
            }
            System.out.println("Total San in DB: " + count);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
