package org.example.test;

import org.example.util.DBUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;

public class TestDB3 {
    public static void main(String[] args) {
        try (Connection conn = DBUtil.getConnection()) {
            System.out.println("Connected to DB!");
            String sanSql = "SELECT SanID, TenSan, LoaiSanID, CoSoID, TrangThai, MoTa, HinhAnh FROM San WHERE IsDeleted = 0 OR IsDeleted IS NULL ORDER BY CoSoID, SanID";
            try (PreparedStatement ps = conn.prepareStatement(sanSql);
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

            try (PreparedStatement ps2 = conn.prepareStatement("SELECT TOP 1 * FROM San");
                 ResultSet rs2 = ps2.executeQuery()) {
                ResultSetMetaData meta = rs2.getMetaData();
                for (int i = 1; i <= meta.getColumnCount(); i++) {
                    System.out.println(meta.getColumnName(i) + " : " + meta.getColumnTypeName(i));
                }
            } catch (Exception e) {
                System.out.println("Query 2 Failed: " + e.getMessage());
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
