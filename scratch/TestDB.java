package scratch;

import org.example.util.DBUtil;
import java.sql.*;

public class TestDB {
    public static void main(String[] args) throws Exception {
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT * FROM KhuyenMaiHinhAnh")) {
            boolean hasData = false;
            while (rs.next()) {
                hasData = true;
                System.out.println("ID: " + rs.getInt("HinhAnhID") + ", KMid: " + rs.getInt("KhuyenMaiID") + ", Path: " + rs.getString("DuongDan"));
            }
            if (!hasData) System.out.println("No images found.");
        }
    }
}
