package org.example;

import org.example.util.DBUtil;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import static org.junit.jupiter.api.Assertions.assertNotNull;

class FindActiveCheckinsTest {

    @Test
    void findSessions() throws Exception {
        System.out.println("=== SEARCHING FOR ACTIVE OR PENDING SESSIONS ===");
        String sql = "SELECT l.DatSanID, l.TrangThai, l.NgayDat, l.GioBatDau, l.GioKetThuc, s.TenSan, s.SanID " +
                "FROM dbo.LichDatSan l " +
                "JOIN dbo.San s ON l.SanID = s.SanID " +
                "WHERE s.CoSoID = 7 " +
                "ORDER BY l.NgayDat DESC, l.GioBatDau DESC;";

        try (Connection conn = DBUtil.getConnection()) {
            assertNotNull(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                int count = 0;
                while (rs.next() && count < 20) {
                    count++;
                    int datSanId = rs.getInt("DatSanID");
                    String status = rs.getString("TrangThai");
                    java.sql.Date date = rs.getDate("NgayDat");
                    java.sql.Time start = rs.getTime("GioBatDau");
                    java.sql.Time end = rs.getTime("GioKetThuc");
                    String sanName = rs.getString("TenSan");
                    int sanId = rs.getInt("SanID");

                    System.out.printf("DatSanID: %d | San: %s (ID=%d) | Status: %s | Date: %s | Start: %s | End: %s%n",
                            datSanId, sanName, sanId, status, date, start, end);
                }
            }
        }
        System.out.println("=== SEARCH COMPLETED ===");
    }
}
