package org.example.service;

import org.example.util.Constants;
import org.example.util.DBUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * Tên tiếng Việt: Dịch vụ xử lý vòng đời đặt sân.
 *
 * Nhiệm vụ:
 * - Quét lịch đặt sân quá hạn giữ chỗ thanh toán.
 * - Chuyển trạng thái từ "Chờ thanh toán" sang "Quá hạn".
 *
 * Được gọi bởi:
 * - CheckInDAO.java
 * - LichDatSanDAOImpl.java
 *
 * Lưu ý:
 * - Hiện tại lớp này còn sử dụng câu lệnh SQL trực tiếp và tự quản lý JDBC connection.
 * - TODO(sau-đánh-giá): Tách SQL này xuống DAO để Service chỉ xử lý nghiệp vụ.
 */
public class BookingLifecycleService {

    private static final Logger logger = LoggerFactory.getLogger(BookingLifecycleService.class);

    private BookingLifecycleService() {
    }

    /**
     * Nghĩa tiếng Việt: Chạy quét các đơn giữ chỗ hết hạn.
     *
     * Mục đích:
     * - Tự động chuyển các đơn đặt sân đang giữ chỗ "Chờ thanh toán" nhưng đã quá thời hạn thanh toán sang trạng thái "Quá hạn".
     *
     * Input:
     * - Không có (Sử dụng thời gian hệ thống của SQL Server làm chuẩn)
     *
     * Output:
     * - Không có (Cập nhật trực tiếp xuống Database)
     *
     * Rủi ro:
     * - Thấp. Chỉ tác động tới những bản ghi thỏa mãn điều kiện quá hạn.
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
