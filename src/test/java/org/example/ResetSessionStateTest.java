package org.example;

import org.example.util.DBUtil;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;

import static org.junit.jupiter.api.Assertions.assertNotNull;

class ResetSessionStateTest {

    @Test
    void resetSession() throws Exception {
        int datSanId = 129; // We can change this as needed
        System.out.println("=== RESETTING SESSION ID " + datSanId + " TO ACTIVE STATE ===");
        
        // Reset the booking status and make sure it has an unpaid state
        String sqlLich = "UPDATE dbo.LichDatSan SET TrangThai = N'Đang sử dụng' WHERE DatSanID = ?;";
        String sqlHoaDon = "UPDATE dbo.HoaDon SET TrangThai = N'Chờ thanh toán', PhieuGiamGiaID = NULL WHERE DatSanID = ?;";

        try (Connection conn = DBUtil.getConnection()) {
            assertNotNull(conn);
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(sqlLich)) {
                    ps.setInt(1, datSanId);
                    int r1 = ps.executeUpdate();
                    System.out.println("Updated LichDatSan: " + r1 + " rows");
                }
                try (PreparedStatement ps = conn.prepareStatement(sqlHoaDon)) {
                    ps.setInt(1, datSanId);
                    int r2 = ps.executeUpdate();
                    System.out.println("Updated HoaDon: " + r2 + " rows");
                }
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
        System.out.println("=== SESSION RESET COMPLETED ===");
    }
}
