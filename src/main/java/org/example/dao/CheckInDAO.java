package org.example.dao;

import org.example.util.DBUtil;
import org.example.model.San;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.Duration;
import java.util.List;
import java.util.ArrayList;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Data Access Object (DAO) xử lý nghiệp vụ Mở Sân và Check-in.
 * Sử dụng JDBC thuần, kiểm soát Transaction thủ công và khóa bi quan để chống tranh chấp dữ liệu.
 */
public class CheckInDAO {
    private static final Logger logger = LogManager.getLogger(CheckInDAO.class);

    // Định nghĩa các hằng số trạng thái
    public static final String FIELD_STATUS_AVAILABLE = "Sẵn sàng";
    public static final String FIELD_STATUS_OCCUPIED = "Đang sử dụng";
    
    public static final String BOOKING_STATUS_CONFIRMED = "Đã xác nhận";
    public static final String BOOKING_STATUS_IN_USE = "Đang sử dụng";
    
    public static final String PAYMENT_STATUS_UNPAID = "Chưa thanh toán";
    public static final String PAYMENT_STATUS_PAID = "Đã thanh toán";
    
    // Quy định thời gian đến trễ tối đa (phút)
    private static final int LATE_THRESHOLD_MINUTES = 15;
    // Quy định thời gian đến sớm tối thiểu để bắt đầu tính phí phụ thu (phút)
    private static final int EARLY_THRESHOLD_MINUTES = 10;
    // Đơn giá phụ thu đến sớm mỗi phút (VND)
    private static final double EARLY_SURCHARGE_PER_MINUTE = 2000.0; 

    // Các exception nội bộ phục vụ báo lỗi chi tiết cho Servlet
    public static class CheckInException extends Exception {
        public CheckInException(String message) { super(message); }
    }
    
    public static class FieldOccupiedException extends CheckInException {
        public FieldOccupiedException(String message) { super(message); }
    }
    
    public static class BookingConflictException extends CheckInException {
        public BookingConflictException(String message) { super(message); }
    }
    
    public static class PaymentRequiredException extends CheckInException {
        public PaymentRequiredException(String message) { super(message); }
    }
    
    public static class ConcurrencyConflictException extends CheckInException {
        public ConcurrencyConflictException(String message) { super(message); }
    }

    /**
     * Nghiệp vụ 1: Check-in cho khách hàng ĐÃ ĐẶT TRƯỚC (Pre-booked Check-in)
     * 
     * @param datSanId ID đơn đặt sân
     * @param staffAccountId ID nhân viên thực hiện check-in
     * @param forcePaymentCheck Bắt buộc kiểm tra thanh toán (Nếu chưa thanh toán/chưa cọc thì cảnh báo/chặn)
     * @param daThuTienMat Lễ tân xác nhận đã thu tiền mặt tại quầy (dành cho đơn chưa thanh toán)
     * @throws CheckInException nếu có lỗi nghiệp vụ xảy ra
     */
    public void checkInKhachDatTruoc(int datSanId, int staffAccountId, boolean forcePaymentCheck, boolean daThuTienMat) throws CheckInException {
        Connection conn = null;
        PreparedStatement psSelectBooking = null;
        PreparedStatement psSelectField = null;
        PreparedStatement psCheckPayment = null;
        PreparedStatement psUpdateBooking = null;
        PreparedStatement psUpdateField = null;
        PreparedStatement psUpdateInvoice = null;
        ResultSet rsBooking = null;
        ResultSet rsField = null;
        ResultSet rsPayment = null;

        try {
            conn = DBUtil.getConnection();
            // BẮT BUỘC: Tắt auto-commit để quản lý Transaction thủ công
            conn.setAutoCommit(false);

            // 1. Lấy thông tin đơn đặt lịch
            String sqlSelectBooking = "SELECT SanID, NgayDat, GioBatDau, GioKetThuc, TrangThai, TongTienDuKien, GhiChu FROM LichDatSan WITH (UPDLOCK, ROWLOCK) WHERE DatSanID = ?";
            psSelectBooking = conn.prepareStatement(sqlSelectBooking);
            psSelectBooking.setInt(1, datSanId);
            rsBooking = psSelectBooking.executeQuery();

            if (!rsBooking.next()) {
                throw new CheckInException("Không tìm thấy thông tin đơn đặt sân có ID: " + datSanId);
            }

            int sanId = rsBooking.getInt("SanID");
            Date ngayDat = rsBooking.getDate("NgayDat");
            Time gioBatDau = rsBooking.getTime("GioBatDau");
            Time gioKetThuc = rsBooking.getTime("GioKetThuc");
            String trangThaiBooking = rsBooking.getString("TrangThai");
            BigDecimal tongTienDuKien = rsBooking.getBigDecimal("TongTienDuKien");
            String ghiChu = rsBooking.getString("GhiChu");

            LocalDate localNgayDat = ngayDat.toLocalDate();
            LocalTime localGioBatDau = gioBatDau.toLocalTime();
            LocalTime localGioKetThuc = gioKetThuc.toLocalTime();
            
            LocalDate today = LocalDate.now();
            LocalTime now = LocalTime.now();

            // Kiểm tra ngày đặt có trùng ngày hôm nay không
            if (!localNgayDat.equals(today)) {
                throw new CheckInException("Không thể check-in cho đơn đặt sân của ngày khác (Ngày đặt: " + localNgayDat + ")");
            }

            // Kiểm tra trạng thái đơn đặt sân
            if (BOOKING_STATUS_IN_USE.equals(trangThaiBooking)) {
                throw new CheckInException("Đơn đặt sân này đã được check-in và đang sử dụng.");
            }
            if (!BOOKING_STATUS_CONFIRMED.equals(trangThaiBooking) && !"Chờ xác nhận".equals(trangThaiBooking)) {
                throw new CheckInException("Đơn đặt sân có trạng thái không hợp lệ để check-in: " + trangThaiBooking);
            }

            // 2. Kiểm tra trạng thái thanh toán (Payment Lock)
            String sqlCheckPayment = "SELECT HoaDonID, TrangThaiThanhToan, TongThanhToan FROM HoaDon WHERE DatSanID = ?";
            psCheckPayment = conn.prepareStatement(sqlCheckPayment);
            psCheckPayment.setInt(1, datSanId);
            rsPayment = psCheckPayment.executeQuery();

            int hoaDonId = -1;
            String trangThaiThanhToan = PAYMENT_STATUS_UNPAID;
            BigDecimal tongThanhToan = BigDecimal.ZERO;
            
            if (rsPayment.next()) {
                hoaDonId = rsPayment.getInt("HoaDonID");
                trangThaiThanhToan = rsPayment.getString("TrangThaiThanhToan");
                tongThanhToan = rsPayment.getBigDecimal("TongThanhToan");
            }

            // Nếu đơn chưa thanh toán hoặc chưa cọc
            if (forcePaymentCheck && (trangThaiThanhToan == null || PAYMENT_STATUS_UNPAID.equals(trangThaiThanhToan) || "Chưa cọc".equals(trangThaiThanhToan))) {
                if (!daThuTienMat) {
                    throw new PaymentRequiredException("Đơn đặt sân này yêu cầu thanh toán/cọc nhưng chưa hoàn tất. Lễ tân phải thu tiền mặt trước khi mở sân.");
                } else {
                    // Nếu lễ tân tích chọn đã thu tiền mặt, cập nhật trạng thái hóa đơn ngay lập tức
                    String sqlUpdateInvoiceStatus = "UPDATE HoaDon SET TrangThaiThanhToan = ?, AccountID_NhanVien = ?, NgayLap = GETDATE() WHERE HoaDonID = ?";
                    psUpdateInvoice = conn.prepareStatement(sqlUpdateInvoiceStatus);
                    psUpdateInvoice.setString(1, PAYMENT_STATUS_PAID);
                    psUpdateInvoice.setInt(2, staffAccountId);
                    psUpdateInvoice.setInt(3, hoaDonId);
                    psUpdateInvoice.executeUpdate();
                    logger.info("Đã cập nhật trạng thái hóa đơn ID " + hoaDonId + " thành Đã thanh toán (Thu tiền mặt tại quầy).");
                    trangThaiThanhToan = PAYMENT_STATUS_PAID;
                }
            }

            // 3. Kiểm tra trạng thái sân bãi thực tế
            String sqlSelectField = "SELECT TenSan, TrangThai FROM San WHERE SanID = ?";
            psSelectField = conn.prepareStatement(sqlSelectField);
            psSelectField.setInt(1, sanId);
            rsField = psSelectField.executeQuery();

            if (!rsField.next()) {
                throw new CheckInException("Không tìm thấy thông tin sân có ID: " + sanId);
            }
            
            String tenSan = rsField.getString("TenSan");
            String trangThaiSan = rsField.getString("TrangThai");

            // Kiểm tra xem sân có đang bị chiếm dụng không
            if (!FIELD_STATUS_AVAILABLE.equals(trangThaiSan)) {
                throw new FieldOccupiedException("Sân '" + tenSan + "' hiện tại không sẵn sàng (Trạng thái: " + trangThaiSan + "). Không thể mở sân!");
            }

            // 4. Xử lý logic thời gian (Đến sớm / Đến trễ)
            Duration durationToStart = Duration.between(now, localGioBatDau);
            long minutesEarly = durationToStart.toMinutes(); // Dương: Đến sớm, Âm: Đến trễ
            
            String logGhiChu = ghiChu != null ? ghiChu : "";
            BigDecimal phuThu = BigDecimal.ZERO;

            if (minutesEarly > EARLY_THRESHOLD_MINUTES) {
                // Kịch bản Khách đến sớm (Early Check-in): Khách đến sớm hơn 10 phút
                logger.info("Khách đến sớm " + minutesEarly + " phút. Tiến hành mở sân sớm.");
                // Tính toán phụ thu thêm tiền giờ (nếu đến sớm hơn 10 phút)
                double surchargeVal = minutesEarly * EARLY_SURCHARGE_PER_MINUTE;
                phuThu = BigDecimal.valueOf(surchargeVal);
                logGhiChu += " [Check-in sớm " + minutesEarly + " phút, Phụ thu: " + phuThu + "đ]";
            } else if (minutesEarly < -LATE_THRESHOLD_MINUTES) {
                // Kịch bản Khách đến trễ (Late Check-in): Khách đến trễ quá 15 phút
                long minutesLate = -minutesEarly;
                logger.info("Khách đến trễ " + minutesLate + " phút. Vẫn cho phép nhận sân nhưng giữ nguyên giờ kết thúc.");
                logGhiChu += " [Check-in trễ " + minutesLate + " phút, giữ nguyên giờ kết thúc lúc " + localGioKetThuc + "]";
            } else {
                logGhiChu += " [Check-in đúng giờ]";
            }

            // 5. Thực hiện cập nhật trạng thái đơn đặt sân
            String sqlUpdateBooking = "UPDATE LichDatSan SET TrangThai = ?, actual_start_time = ?, TongTienDuKien = TongTienDuKien + ?, GhiChu = ? WHERE DatSanID = ?";
            psUpdateBooking = conn.prepareStatement(sqlUpdateBooking);
            psUpdateBooking.setString(1, BOOKING_STATUS_IN_USE);
            psUpdateBooking.setTime(2, Time.valueOf(now));
            psUpdateBooking.setBigDecimal(3, phuThu);
            psUpdateBooking.setString(4, logGhiChu.trim());
            psUpdateBooking.setInt(5, datSanId);
            psUpdateBooking.executeUpdate();

            // Cập nhật lại số tiền trên hóa đơn (nếu có phụ thu đến sớm)
            if (phuThu.compareTo(BigDecimal.ZERO) > 0 && hoaDonId != -1) {
                String sqlUpdateInvoiceAmount = "UPDATE HoaDon SET TongTienSan = TongTienSan + ?, TongThanhToan = TongThanhToan + ? WHERE HoaDonID = ?";
                try (PreparedStatement psUpdateInvAmt = conn.prepareStatement(sqlUpdateInvoiceAmount)) {
                    psUpdateInvAmt.setBigDecimal(1, phuThu);
                    psUpdateInvAmt.setBigDecimal(2, phuThu);
                    psUpdateInvAmt.setInt(3, hoaDonId);
                    psUpdateInvAmt.executeUpdate();
                }
            }

            // 6. Cập nhật trạng thái sân (Điều kiện UPDATE ngặt nghèo - Optimistic/Pessimistic Concurrency Check)
            // Câu lệnh cập nhật trạng thái Sân phải có điều kiện WHERE TrangThai = 'Sẵn sàng'
            String sqlUpdateField = "UPDATE San SET TrangThai = ? WHERE SanID = ? AND TrangThai = ?";
            psUpdateField = conn.prepareStatement(sqlUpdateField);
            psUpdateField.setString(1, FIELD_STATUS_OCCUPIED);
            psUpdateField.setInt(2, sanId);
            psUpdateField.setString(3, FIELD_STATUS_AVAILABLE);
            
            int affectedRows = psUpdateField.executeUpdate();
            if (affectedRows == 0) {
                // Nếu số dòng bị ảnh hưởng = 0, tức là trạng thái sân đã bị thay đổi bởi luồng khác ngay trước đó
                throw new ConcurrencyConflictException("Sân vừa bị thay đổi trạng thái bởi một giao dịch khác. Vui lòng làm tươi giao diện và thử lại.");
            }

            // 7. Commit Transaction thành công
            conn.commit();
            logger.info("Check-in cho đơn đặt sân ID " + datSanId + " hoàn thành thành công.");

        } catch (Exception e) {
            // Rollback toàn bộ nếu có bất kỳ lỗi nào xảy ra
            if (conn != null) {
                try {
                    conn.rollback();
                    logger.warn("Transaction rolled back due to error: " + e.getMessage());
                } catch (SQLException ex) {
                    logger.error("Failed to rollback transaction", ex);
                }
            }
            if (e instanceof CheckInException) {
                throw (CheckInException) e;
            } else {
                throw new CheckInException("Lỗi hệ thống trong quá trình check-in: " + e.getMessage());
            }
        } finally {
            // Đóng toàn bộ resource đúng chuẩn JDBC thuần
            closeResource(rsBooking);
            closeResource(rsField);
            closeResource(rsPayment);
            closeResource(psSelectBooking);
            closeResource(psSelectField);
            closeResource(psCheckPayment);
            closeResource(psUpdateBooking);
            closeResource(psUpdateField);
            closeResource(psUpdateInvoice);
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Trả lại trạng thái mặc định
                    conn.close();
                } catch (SQLException e) {
                    logger.error("Failed to close connection", e);
                }
            }
        }
    }

    /**
     * Nghiệp vụ 2: Mở sân cho KHÁCH VÃNG LAI (Walk-in Customer)
     * 
     * @param sanId ID sân cần mở
     * @param durationMinutes Thời lượng chơi định trước (phút)
     * @param staffAccountId ID nhân viên tiếp đón mở sân
     * @param donGiaSan Đơn giá tính theo giờ cho loại sân này
     * @throws CheckInException nếu có lỗi nghiệp vụ xảy ra (như kẹt lịch đặt online)
     */
    public void checkInKhachVangLai(int sanId, int durationMinutes, int staffAccountId, double donGiaSan) throws CheckInException {
        Connection conn = null;
        PreparedStatement psCheckConflict = null;
        PreparedStatement psSelectField = null;
        PreparedStatement psInsertBooking = null;
        PreparedStatement psInsertInvoice = null;
        PreparedStatement psUpdateField = null;
        ResultSet rsConflict = null;
        ResultSet rsField = null;

        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false); // Quản lý Transaction thủ công

            LocalDate today = LocalDate.now();
            LocalTime now = LocalTime.now();
            LocalTime endTime = now.plusMinutes(durationMinutes);

            // 1. Kiểm tra trạng thái sân bãi thực tế trước
            String sqlSelectField = "SELECT TenSan, TrangThai FROM San WITH (UPDLOCK, ROWLOCK) WHERE SanID = ?";
            psSelectField = conn.prepareStatement(sqlSelectField);
            psSelectField.setInt(1, sanId);
            rsField = psSelectField.executeQuery();

            if (!rsField.next()) {
                throw new CheckInException("Không tìm thấy thông tin sân có ID: " + sanId);
            }
            
            String tenSan = rsField.getString("TenSan");
            String trangThaiSan = rsField.getString("TrangThai");

            if (!FIELD_STATUS_AVAILABLE.equals(trangThaiSan)) {
                throw new FieldOccupiedException("Sân '" + tenSan + "' đang bận hoặc bảo trì (Trạng thái: " + trangThaiSan + "). Không thể mở cho khách vãng lai.");
            }

            // 2. Kịch bản Khách vãng lai bị kẹt lịch sắp tới (Walk-in Conflict Check)
            // Hệ thống kiểm tra xem trong khoảng thời gian khách chơi [now, endTime] có lịch đặt nào đã xác nhận không.
            // Công thức: GioBatDau < endTime AND GioKetThuc > now
            String sqlCheckConflict = "SELECT DatSanID, GioBatDau, GioKetThuc, TrangThai FROM LichDatSan " +
                                      "WHERE SanID = ? AND NgayDat = ? " +
                                      "AND (TrangThai IN (?, ?) OR (TrangThai = ? AND DATEDIFF(minute, CreatedTime, GETDATE()) <= " + org.example.util.Constants.PENDING_PAYMENT_TIMEOUT_MINUTES + ")) " +
                                      "AND GioBatDau < CAST(? AS time) AND GioKetThuc > CAST(? AS time)";
            psCheckConflict = conn.prepareStatement(sqlCheckConflict);
            psCheckConflict.setInt(1, sanId);
            psCheckConflict.setDate(2, Date.valueOf(today));
            psCheckConflict.setString(3, BOOKING_STATUS_CONFIRMED);
            psCheckConflict.setString(4, "Chờ xác nhận");
            psCheckConflict.setString(5, "Chờ thanh toán");
            psCheckConflict.setString(6, endTime.toString());
            psCheckConflict.setString(7, now.toString());

            rsConflict = psCheckConflict.executeQuery();
            if (rsConflict.next()) {
                Time conflictStart = rsConflict.getTime("GioBatDau");
                Time conflictEnd = rsConflict.getTime("GioKetThuc");
                throw new BookingConflictException("Sân '" + tenSan + "' đã có khách đặt online từ " + 
                        conflictStart.toLocalTime().toString().substring(0, 5) + " đến " + 
                        conflictEnd.toLocalTime().toString().substring(0, 5) + ". Không thể mở cho khách vãng lai lúc này!");
            }

            // Tính tiền dự kiến cho thời lượng chơi (durationMinutes)
            double hours = (double) durationMinutes / 60.0;
            BigDecimal totalAmount = BigDecimal.valueOf(hours * donGiaSan);

            // 3. Tạo mới lịch đặt sân cho khách vãng lai
            String sqlInsertBooking = "INSERT INTO LichDatSan (AccountID, SanID, NgayDat, GioBatDau, GioKetThuc, actual_start_time, TrangThai, GhiChu, NguonDatSan, TongTienDuKien) " +
                                      "VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            psInsertBooking = conn.prepareStatement(sqlInsertBooking, Statement.RETURN_GENERATED_KEYS);
            psInsertBooking.setInt(1, sanId);
            psInsertBooking.setDate(2, Date.valueOf(today));
            psInsertBooking.setTime(3, Time.valueOf(now));
            psInsertBooking.setTime(4, Time.valueOf(endTime));
            psInsertBooking.setTime(5, Time.valueOf(now));
            psInsertBooking.setString(6, BOOKING_STATUS_IN_USE);
            psInsertBooking.setString(7, "Khách vãng lai chơi " + durationMinutes + " phút");
            psInsertBooking.setString(8, "Walk-in");
            psInsertBooking.setBigDecimal(9, totalAmount);
            psInsertBooking.executeUpdate();

            // Lấy ID tự sinh của đơn đặt sân
            ResultSet rsKeys = psInsertBooking.getGeneratedKeys();
            int newDatSanId = -1;
            if (rsKeys.next()) {
                newDatSanId = rsKeys.getInt(1);
            } else {
                throw new CheckInException("Lỗi hệ thống: Không thể khởi tạo đơn đặt sân vãng lai.");
            }

            // 4. Khởi tạo Hóa đơn ngay tại quầy cho khách vãng lai
            String sqlInsertInvoice = "INSERT INTO HoaDon (DatSanID, AccountID_KhachHang, AccountID_NhanVien, NgayLap, TongTienSan, TongTienDichVu, PhiGuiXe, GiamGia, TongThanhToan, TrangThaiThanhToan, PhuongThucThanhToan) " +
                                      "VALUES (?, NULL, ?, GETDATE(), ?, 0, 0, 0, ?, ?, NULL)";
            psInsertInvoice = conn.prepareStatement(sqlInsertInvoice);
            psInsertInvoice.setInt(1, newDatSanId);
            psInsertInvoice.setInt(2, staffAccountId);
            psInsertInvoice.setBigDecimal(3, totalAmount);
            psInsertInvoice.setBigDecimal(4, totalAmount);
            psInsertInvoice.setString(5, PAYMENT_STATUS_UNPAID); // Sẽ thanh toán khi check-out trả sân
            psInsertInvoice.executeUpdate();

            // 5. Cập nhật trạng thái sân (Điều kiện UPDATE ngặt nghèo chống Race Conditions)
            String sqlUpdateField = "UPDATE San SET TrangThai = ? WHERE SanID = ? AND TrangThai = ?";
            psUpdateField = conn.prepareStatement(sqlUpdateField);
            psUpdateField.setString(1, FIELD_STATUS_OCCUPIED);
            psUpdateField.setInt(2, sanId);
            psUpdateField.setString(3, FIELD_STATUS_AVAILABLE);

            int affectedRows = psUpdateField.executeUpdate();
            if (affectedRows == 0) {
                throw new ConcurrencyConflictException("Sân vừa bị thay đổi trạng thái bởi một giao dịch khác. Vui lòng làm tươi trang.");
            }

            // 6. Commit Transaction thành công
            conn.commit();
            logger.info("Đã mở sân thành công cho khách vãng lai tại sân ID: " + sanId);

        } catch (Exception e) {
            // Rollback nếu gặp bất cứ sự cố nào
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    logger.error("Failed to rollback walk-in transaction", ex);
                }
            }
            if (e instanceof CheckInException) {
                throw (CheckInException) e;
            } else {
                throw new CheckInException("Lỗi hệ thống khi mở sân cho khách vãng lai: " + e.getMessage());
            }
        } finally {
            closeResource(rsConflict);
            closeResource(rsField);
            closeResource(psCheckConflict);
            closeResource(psSelectField);
            closeResource(psInsertBooking);
            closeResource(psInsertInvoice);
            closeResource(psUpdateField);
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    logger.error("Failed to close connection", e);
                }
            }
        }
    }

    /**
     * Nghiệp vụ 3: Hủy đơn đặt sân do khách bùng / không đến sân (No-show Cancel)
     * 
     * @param datSanId ID đơn đặt sân cần hủy
     * @param staffAccountId ID nhân viên thực hiện hủy đơn
     * @throws CheckInException nếu có lỗi nghiệp vụ xảy ra
     */
    public void huyLichKhachBung(int datSanId, int staffAccountId) throws CheckInException {
        Connection conn = null;
        PreparedStatement psSelect = null;
        PreparedStatement psUpdateBooking = null;
        PreparedStatement psUpdateField = null;
        PreparedStatement psUpdateInvoice = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false); // Quản lý Transaction thủ công

            // 1. Lấy thông tin đơn đặt lịch
            String sqlSelect = "SELECT SanID, TrangThai, GhiChu FROM LichDatSan WHERE DatSanID = ?";
            psSelect = conn.prepareStatement(sqlSelect);
            psSelect.setInt(1, datSanId);
            rs = psSelect.executeQuery();

            if (!rs.next()) {
                throw new CheckInException("Không tìm thấy thông tin đơn đặt sân có ID: " + datSanId);
            }

            int sanId = rs.getInt("SanID");
            String trangThaiBooking = rs.getString("TrangThai");
            String ghiChu = rs.getString("GhiChu");

            if ("Đã hủy".equals(trangThaiBooking)) {
                throw new CheckInException("Đơn đặt sân này đã ở trạng thái Hủy.");
            }

            String logGhiChu = (ghiChu != null ? ghiChu.trim() : "") + " [Lễ tân hủy lịch do khách không đến]";

            // 2. Cập nhật đơn đặt sân thành 'Đã hủy'
            String sqlUpdateBooking = "UPDATE LichDatSan SET TrangThai = ?, GhiChu = ? WHERE DatSanID = ?";
            psUpdateBooking = conn.prepareStatement(sqlUpdateBooking);
            psUpdateBooking.setString(1, "Đã hủy");
            psUpdateBooking.setString(2, logGhiChu.trim());
            psUpdateBooking.setInt(3, datSanId);
            psUpdateBooking.executeUpdate();

            // 3. Cập nhật hóa đơn liên quan thành 'Đã hủy'
            String sqlUpdateInvoice = "UPDATE HoaDon SET TrangThaiThanhToan = N'Đã hủy', AccountID_NhanVien = ?, NgayLap = GETDATE() WHERE DatSanID = ?";
            psUpdateInvoice = conn.prepareStatement(sqlUpdateInvoice);
            psUpdateInvoice.setInt(1, staffAccountId);
            psUpdateInvoice.setInt(2, datSanId);
            psUpdateInvoice.executeUpdate();

            // 4. Giải phóng sân (Nếu sân đang ghi nhận bận do đơn này)
            // Chỉ giải phóng nếu sân đang ở trạng thái 'Đang sử dụng'
            String sqlUpdateField = "UPDATE San SET TrangThai = ? WHERE SanID = ? AND TrangThai = ?";
            psUpdateField = conn.prepareStatement(sqlUpdateField);
            psUpdateField.setString(1, FIELD_STATUS_AVAILABLE);
            psUpdateField.setInt(2, sanId);
            psUpdateField.setString(3, FIELD_STATUS_OCCUPIED);
            psUpdateField.executeUpdate();

            conn.commit();
            logger.info("Đã hủy thành công đơn đặt sân ID " + datSanId + " do khách bùng.");
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    logger.error("Failed to rollback cancellation transaction", ex);
                }
            }
            if (e instanceof CheckInException) {
                throw (CheckInException) e;
            } else {
                throw new CheckInException("Lỗi hệ thống khi hủy ca đặt sân: " + e.getMessage());
            }
        } finally {
            closeResource(rs);
            closeResource(psSelect);
            closeResource(psUpdateBooking);
            closeResource(psUpdateField);
            closeResource(psUpdateInvoice);
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    logger.error("Failed to close connection", e);
                }
            }
        }
    }

    /**
     * Lấy danh sách toàn bộ sân để hiển thị trên giao diện Lễ tân
     */
    public List<San> getDanhSachSan() {
        org.example.dao.impl.LichDatSanDAOImpl.updateExpiredBookingsAndFields();
        List<San> list = new ArrayList<>();
        String sql = "SELECT SanID, TenSan, LoaiSanID, CoSoID, TrangThai, MoTa, HinhAnh FROM San ORDER BY SanID";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                San s = new San();
                s.setSanID(rs.getInt("SanID"));
                s.setTenSan(rs.getString("TenSan"));
                s.setLoaiSanID(rs.getInt("LoaiSanID"));
                s.setCoSoID(rs.getInt("CoSoID"));
                s.setTrangThai(rs.getString("TrangThai"));
                s.setMoTa(rs.getString("MoTa"));
                s.setHinhAnh(rs.getString("HinhAnh"));
                list.add(s);
            }
        } catch (Exception e) {
            logger.error("Error in getDanhSachSan: ", e);
        }
        return list;
    }

    /**
     * Lấy danh sách lịch đặt sân trong ngày hôm nay phục vụ check-in
     */
    public List<BookingViewDTO> getDanhSachLichCheckInHomNay() {
        org.example.dao.impl.LichDatSanDAOImpl.updateExpiredBookingsAndFields();
        List<BookingViewDTO> list = new ArrayList<>();
        String sql = "SELECT lds.DatSanID, s.SanID, s.TenSan, acc.FullName AS TenKhachHang, " +
                     "lds.NgayDat, lds.GioBatDau, lds.GioKetThuc, lds.TongTienDuKien, " +
                     "lds.TrangThai, lds.GhiChu, hd.TrangThaiThanhToan, lds.NguonDatSan " +
                     "FROM LichDatSan lds " +
                     "INNER JOIN San s ON lds.SanID = s.SanID " +
                     "LEFT JOIN Accounts acc ON lds.AccountID = acc.AccountID " +
                     "LEFT JOIN HoaDon hd ON lds.DatSanID = hd.DatSanID " +
                     "WHERE lds.NgayDat = CAST(GETDATE() AS DATE) " +
                     "ORDER BY lds.GioBatDau ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                BookingViewDTO dto = new BookingViewDTO();
                dto.setDatSanId(rs.getInt("DatSanID"));
                dto.setSanId(rs.getInt("SanID"));
                dto.setTenSan(rs.getString("TenSan"));
                String guestName = rs.getString("TenKhachHang");
                dto.setTenKhachHang(guestName != null ? guestName : "Khách vãng lai");
                dto.setNgayDat(rs.getDate("NgayDat").toLocalDate());
                dto.setGioBatDau(rs.getTime("GioBatDau").toLocalTime());
                dto.setGioKetThuc(rs.getTime("GioKetThuc").toLocalTime());
                dto.setTongTien(rs.getBigDecimal("TongTienDuKien"));
                dto.setTrangThai(rs.getString("TrangThai"));
                dto.setGhiChu(rs.getString("GhiChu"));
                String paymentStatus = rs.getString("TrangThaiThanhToan");
                dto.setTrangThaiThanhToan(paymentStatus != null ? paymentStatus : PAYMENT_STATUS_UNPAID);
                String nguonDat = rs.getString("NguonDatSan");
                dto.setNguonDatSan(nguonDat != null ? nguonDat : "Walk-in");
                list.add(dto);
            }
        } catch (Exception e) {
            logger.error("Error in getDanhSachLichCheckInHomNay: ", e);
        }
        return list;
    }

    /**
     * DTO hiển thị danh sách lịch đặt trên giao diện lễ tân
     */
    public static class BookingViewDTO {
        private int datSanId;
        private int sanId;
        private String tenSan;
        private String tenKhachHang;
        private LocalDate ngayDat;
        private LocalTime gioBatDau;
        private LocalTime gioKetThuc;
        private BigDecimal tongTien;
        private String trangThai;
        private String ghiChu;
        private String trangThaiThanhToan;
        private String nguonDatSan;

        public int getDatSanId() { return datSanId; }
        public void setDatSanId(int datSanId) { this.datSanId = datSanId; }

        public int getSanId() { return sanId; }
        public void setSanId(int sanId) { this.sanId = sanId; }

        public String getTenSan() { return tenSan; }
        public void setTenSan(String tenSan) { this.tenSan = tenSan; }

        public String getTenKhachHang() { return tenKhachHang; }
        public void setTenKhachHang(String tenKhachHang) { this.tenKhachHang = tenKhachHang; }

        public LocalDate getNgayDat() { return ngayDat; }
        public void setNgayDat(LocalDate ngayDat) { this.ngayDat = ngayDat; }

        public LocalTime getGioBatDau() { return gioBatDau; }
        public void setGioBatDau(LocalTime gioBatDau) { this.gioBatDau = gioBatDau; }

        public LocalTime getGioKetThuc() { return gioKetThuc; }
        public void setGioKetThuc(LocalTime gioKetThuc) { this.gioKetThuc = gioKetThuc; }

        public BigDecimal getTongTien() { return tongTien; }
        public void setTongTien(BigDecimal tongTien) { this.tongTien = tongTien; }

        public String getTrangThai() { return trangThai; }
        public void setTrangThai(String trangThai) { this.trangThai = trangThai; }

        public String getGhiChu() { return ghiChu; }
        public void setGhiChu(String ghiChu) { this.ghiChu = ghiChu; }

        public String getTrangThaiThanhToan() { return trangThaiThanhToan; }
        public void setTrangThaiThanhToan(String trangThaiThanhToan) { this.trangThaiThanhToan = trangThaiThanhToan; }

        public String getNguonDatSan() { return nguonDatSan; }
        public void setNguonDatSan(String nguonDatSan) { this.nguonDatSan = nguonDatSan; }
    }

    /**
     * Phương thức phụ trợ đóng Resource JDBC
     */
    private void closeResource(AutoCloseable resource) {
        if (resource != null) {
            try {
                resource.close();
            } catch (Exception e) {
                logger.error("Error closing JDBC resource", e);
            }
        }
    }
}
