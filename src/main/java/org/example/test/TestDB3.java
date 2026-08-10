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
            String sanSql = "SELECT court_id, court_name, court_type_id, facility_id, status, description, image_path FROM courts WHERE is_deleted = 0 OR is_deleted IS NULL ORDER BY facility_id, court_id";
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

            try (PreparedStatement ps2 = conn.prepareStatement("SELECT TOP 1 * FROM courts");
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
