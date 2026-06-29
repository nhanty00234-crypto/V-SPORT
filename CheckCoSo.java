import java.sql.*;

public class CheckCoSo {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://14.225.217.109:1433;databaseName=QuanLiSport;encrypt=true;trustServerCertificate=true;sendStringParametersAsUnicode=true;";
        try (Connection conn = DriverManager.getConnection(url, "sa", "TOP1@iyounguru!")) {
            System.out.println("Connected to DB!");
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM CoSo");
            int count = 0;
            while (rs.next()) {
                System.out.println("CoSoID: " + rs.getInt("CoSoID") + " | TenCoSo: " + rs.getString("TenCoSo"));
                count++;
            }
            System.out.println("Total CoSo in DB: " + count);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
