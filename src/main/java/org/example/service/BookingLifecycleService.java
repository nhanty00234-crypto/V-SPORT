package org.example.service;

import org.example.util.Constants;
import org.example.util.DBUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * Dịch vụ xử lý vòng đời đơn đặt sân (reservation-hold lifecycle).
 * Hiện tại phụ trách auto-expire booking "Chờ thanh toán" đã quá HoldExpiresAt.
 * Được gọi lại tại các entry-point đọc dữ liệu đặt sân (lưới an toàn "on-read"),
 * theo đúng cách LichDatSanDAOImpl.updateExpiredBookingsAndFields() đã làm —
 * dự án chưa có scheduler/background thread nào.
 */
public class BookingLifecycleService {

    private static final Logger logger = LoggerFactory.getLogger(BookingLifecycleService.class);

    private BookingLifecycleService() {
    }

    /**
     * Quét và tự động chuyển các booking "Chờ thanh toán" đã quá HoldExpiresAt sang "Quá hạn".
     * An toàn khi gọi nhiều lần: chỉ UPDATE các row đang thật sự "Chờ thanh toán" VÀ đã quá hạn,
     * không đụng "Đã xác nhận"/"Đã hoàn thành"/"Đã hủy"/booking COD (HoldExpiresAt NULL).
     * Dùng GETDATE() phía SQL Server làm nguồn thời gian duy nhất — không nhận giờ từ caller.
     */
    public static void runExpirySweep() {
        String sql = "UPDATE LichDatSan " +
                "SET TrangThai = ?, " +
                "    GhiChu = CONCAT(ISNULL(GhiChu, N''), N' [Tự động: Quá hạn giữ chỗ thanh toán]') " +
                "WHERE TrangThai = ? " +
                "AND HoldExpiresAt IS NOT NULL " +
                "AND HoldExpiresAt < GETDATE()";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, Constants.TRANG_THAI_DAT_SAN_QUA_HAN);
            ps.setNString(2, Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                logger.info("runExpirySweep: đã chuyển {} booking 'Chờ thanh toán' quá hạn sang 'Quá hạn'.", affected);
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi chạy BookingLifecycleService.runExpirySweep(): {}", e.getMessage(), e);
        }
    }
}
