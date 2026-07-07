import java.sql.*;

public class TestQuery {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://14.225.217.109:1433;databaseName=QuanLiSport;encrypt=true;trustServerCertificate=true;sendStringParametersAsUnicode=true;";
        try (Connection conn = DriverManager.getConnection(url, "sa", "TOP1@iyounguru!")) {
            System.out.println("Connected to DB!");
            String sql = "SELECT s.SanID, s.TenSan, s.LoaiSanID, s.CoSoID, s.TrangThai, s.MoTa, s.HinhAnh, " +
                         "ls.TenLoai AS TenLoaiSan, ls.GiaKhongDen, ls.GiaCoDen, ls.GioBatDauLenDen, ls.GioKetThucLenDen, " +
                         "(SELECT TOP 1 lds.DatSanID FROM LichDatSan lds WHERE lds.SanID = s.SanID AND lds.TrangThai = N'Đang sử dụng') AS DatSanIDActive, " +
                         "(SELECT TOP 1 CONVERT(VARCHAR(5), COALESCE(lds.actual_start_time, lds.GioBatDau), 108) FROM LichDatSan lds WHERE lds.SanID = s.SanID AND lds.TrangThai = N'Đang sử dụng') AS GioBatDauActive " +
                         "FROM San s " +
                         "LEFT JOIN LoaiSan ls ON s.LoaiSanID = ls.LoaiSanID " +
                         "ORDER BY s.SanID";
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(sql)) {
                int count = 0;
                while (rs.next()) {
                    System.out.println("SanID: " + rs.getInt("SanID") + 
                                       " | TenSan: " + rs.getString("TenSan") + 
                                       " | CoSoID: " + rs.getInt("CoSoID") + 
                                       " | TrangThai: " + rs.getString("TrangThai") +
                                       " | TenLoaiSan: " + rs.getString("TenLoaiSan") +
                                       " | GiaKhongDen: " + rs.getDouble("GiaKhongDen"));
                    count++;
                }
                System.out.println("Total San returned by query: " + count);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
