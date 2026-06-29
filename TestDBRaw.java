import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;

public class TestDBRaw {
    public static void main(String[] args) {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            // Raw connection
            String url = "jdbc:sqlserver://14.225.217.109:1433;databaseName=QuanLiSport;encrypt=true;trustServerCertificate=true;sendStringParametersAsUnicode=true;";
            Connection conn = DriverManager.getConnection(url, "sa", "Thebigsize@2024");
            
            System.out.println("Connected!");
            
            try (PreparedStatement ps2 = conn.prepareStatement("SELECT TOP 1 * FROM San");
                 ResultSet rs2 = ps2.executeQuery()) {
                ResultSetMetaData meta = rs2.getMetaData();
                for (int i = 1; i <= meta.getColumnCount(); i++) {
                    System.out.println(meta.getColumnName(i) + " : " + meta.getColumnTypeName(i));
                }
            } catch (Exception e) {
                System.out.println("Query 2 Failed: " + e.getMessage());
            }

            try (PreparedStatement ps = conn.prepareStatement("SELECT SanID, TenSan, LoaiSanID, CoSoID, TrangThai, MoTa, HinhAnh FROM San WHERE IsDeleted = 0 OR IsDeleted IS NULL ORDER BY CoSoID, SanID");
                 ResultSet rs = ps.executeQuery()) {
                int count = 0;
                while (rs.next()) {
                    count++;
                }
                System.out.println("Query 1 count: " + count);
            } catch (Exception e) {
                System.out.println("Query 1 Failed: " + e.getMessage());
                e.printStackTrace();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
