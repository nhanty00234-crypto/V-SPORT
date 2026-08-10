package org.example.service.checkin;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.service.pricing.CourtPricingService;
import org.example.service.pricing.CourtPriceResult;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

public class BookingExtensionService {
    private static final Logger logger = LogManager.getLogger(BookingExtensionService.class);
    private final CourtPricingService courtPricingService = new CourtPricingService();

    public static class ExtensionPreview {
        public int datSanId;
        public int sanId;
        public String tenSan;
        public LocalTime oldGioKetThuc;
        public LocalTime newGioKetThuc;
        public LocalDateTime oldPlannedEnd;
        public LocalDateTime newPlannedEnd;
        public BigDecimal oldTotalCourtAmount;
        public BigDecimal newTotalCourtAmount;
        public BigDecimal additionalAmount;
        public LocalDateTime limitDateTime;
        public long maxExtendableMinutes;
        public boolean canExtend;
        public String message;
    }

    public static class ExtensionResult {
        public boolean success;
        public String message;
        public BigDecimal additionalAmount;
        public LocalTime newGioKetThuc;
    }

    public ExtensionPreview previewExtension(int datSanId, Integer extendMinutes, LocalTime proposedNewEndTime, int coSoId) {
        ExtensionPreview preview = new ExtensionPreview();
        preview.datSanId = datSanId;
        preview.canExtend = false;

        String sqlBooking = "SELECT l.booking_id, l.court_id, l.booking_date, l.start_time, l.end_time, l.status, l.time_mode, " +
                "l.actual_start_time_of_day, l.actual_started_at, l.reserved_duration_minutes, " +
                "s.court_name, s.facility_id, s.status AS SanTrangThai, ls.price_without_light, ls.price_with_light, ls.light_start_time, ls.light_end_time " +
                "FROM bookings l " +
                "JOIN courts s ON l.court_id = s.court_id " +
                "JOIN court_types ls ON s.court_type_id = ls.court_type_id " +
                "WHERE l.booking_id = ? AND l.is_deleted = 0";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlBooking)) {
            ps.setInt(1, datSanId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    preview.message = "Không tìm thấy thông tin đơn đặt sân.";
                    return preview;
                }

                int bookingCoSoId = rs.getInt("facility_id");
                if (bookingCoSoId != coSoId) {
                    preview.message = "Đơn đặt sân không thuộc cơ sở của bạn.";
                    return preview;
                }

                String bookingTrangThai = rs.getString("status");
                if (!"Đang sử dụng".equals(bookingTrangThai)) {
                    preview.message = "Chỉ ca chơi ở trạng thái 'Đang sử dụng' mới có thể gia hạn.";
                    return preview;
                }

                String timeMode = rs.getString("time_mode");
                if ("OPEN_ENDED".equals(timeMode)) {
                    preview.message = "Walk-in không cố định chạy đến khi dừng, không cần gia hạn.";
                    return preview;
                }

                int sanId = rs.getInt("court_id");
                preview.sanId = sanId;
                preview.tenSan = rs.getString("court_name");
                LocalDate date = rs.getDate("booking_date").toLocalDate();
                LocalTime oldGioKetThuc = rs.getTime("end_time").toLocalTime();
                preview.oldGioKetThuc = oldGioKetThuc;

                // 1. Xác định startAt
                LocalDateTime startAt = null;
                Timestamp ts = rs.getTimestamp("actual_started_at");
                if (ts != null) {
                    startAt = ts.toLocalDateTime();
                }
                if (startAt == null) {
                    Time t = rs.getTime("actual_start_time_of_day");
                    if (t != null) {
                        startAt = date.atTime(t.toLocalTime());
                    }
                }
                if (startAt == null) {
                    startAt = date.atTime(rs.getTime("start_time").toLocalTime());
                }

                // 2. Xác định oldPlannedEnd
                LocalDateTime oldPlannedEnd = date.atTime(oldGioKetThuc);
                if (!oldPlannedEnd.isAfter(startAt)) {
                    oldPlannedEnd = oldPlannedEnd.plusDays(1);
                }
                preview.oldPlannedEnd = oldPlannedEnd;

                // 3. Tìm limitDateTime (booking tiếp theo hoặc đóng cửa)
                LocalDateTime nextBookingStart = null;
                String sqlNext = "SELECT booking_id, booking_date, start_time, end_time, status, hold_expires_at FROM bookings " +
                        "WHERE court_id = ? AND is_deleted = 0 AND booking_id <> ? " +
                        "AND (booking_date = ? OR booking_date = ?) " +
                        "AND (status IN (N'Đã xác nhận', N'Chờ xác nhận', N'Đang sử dụng') " +
                        "     OR (status = N'Chờ thanh toán' AND hold_expires_at > SYSUTCDATETIME()))";
                try (PreparedStatement psNext = conn.prepareStatement(sqlNext)) {
                    psNext.setInt(1, sanId);
                    psNext.setInt(2, datSanId);
                    psNext.setDate(3, Date.valueOf(date));
                    psNext.setDate(4, Date.valueOf(date.plusDays(1)));
                    try (ResultSet rsNext = psNext.executeQuery()) {
                        while (rsNext.next()) {
                            LocalDate nextDate = rsNext.getDate("booking_date").toLocalDate();
                            LocalTime nextStartTime = rsNext.getTime("start_time").toLocalTime();
                            LocalDateTime startTemp = nextDate.atTime(nextStartTime);
                            if (!startTemp.isBefore(oldPlannedEnd)) {
                                if (nextBookingStart == null || startTemp.isBefore(nextBookingStart)) {
                                    nextBookingStart = startTemp;
                                }
                            }
                        }
                    }
                }

                LocalDateTime closeTime = null;
                String sqlCoSo = "SELECT closing_time FROM facilities WHERE facility_id = ?";
                try (PreparedStatement psCoSo = conn.prepareStatement(sqlCoSo)) {
                    psCoSo.setInt(1, coSoId);
                    try (ResultSet rsCoSo = psCoSo.executeQuery()) {
                        if (rsCoSo.next()) {
                            Time dbClose = rsCoSo.getTime("closing_time");
                            if (dbClose != null) {
                                closeTime = date.atTime(dbClose.toLocalTime());
                                if (dbClose.toLocalTime().isBefore(startAt.toLocalTime())) {
                                    closeTime = closeTime.plusDays(1);
                                }
                            }
                        }
                    }
                }

                LocalDateTime limitDateTime = null;
                if (nextBookingStart != null && closeTime != null) {
                    limitDateTime = nextBookingStart.isBefore(closeTime) ? nextBookingStart : closeTime;
                } else if (nextBookingStart != null) {
                    limitDateTime = nextBookingStart;
                } else if (closeTime != null) {
                    limitDateTime = closeTime;
                } else {
                    limitDateTime = oldPlannedEnd.plusHours(6); // Fallback limit
                }
                preview.limitDateTime = limitDateTime;

                // 4. Xác định baseEnd cho gia hạn (overtime check)
                LocalDateTime nowDateTime = LocalDateTime.now();
                LocalDateTime baseEnd = oldPlannedEnd;
                if (nowDateTime.isAfter(oldPlannedEnd)) {
                    baseEnd = nowDateTime;
                }

                // 5. Tính maxExtendableMinutes
                long maxExtendableMinutes = 0;
                if (limitDateTime.isAfter(baseEnd)) {
                    maxExtendableMinutes = Duration.between(baseEnd, limitDateTime).toMinutes();
                }
                preview.maxExtendableMinutes = maxExtendableMinutes;

                if (extendMinutes == null && proposedNewEndTime == null) {
                    preview.canExtend = maxExtendableMinutes > 0;
                    preview.message = preview.canExtend ? "Có thể gia hạn chơi thêm." : "Sân đã có lịch đặt tiếp theo hoặc đã đóng cửa.";
                    return preview;
                }

                // 6. Tính newPlannedEnd
                LocalDateTime newPlannedEnd = null;
                if (extendMinutes != null) {
                    newPlannedEnd = baseEnd.plusMinutes(extendMinutes);
                } else {
                    newPlannedEnd = date.atTime(proposedNewEndTime);
                    if (!newPlannedEnd.isAfter(baseEnd)) {
                        newPlannedEnd = newPlannedEnd.plusDays(1);
                    }
                }
                preview.newPlannedEnd = newPlannedEnd;
                preview.newGioKetThuc = newPlannedEnd.toLocalTime();

                // 7. Validations
                if (!newPlannedEnd.isAfter(baseEnd)) {
                    preview.message = "Giờ kết thúc mới phải sau thời điểm hiện tại và giờ kết thúc cũ.";
                    return preview;
                }
                if (newPlannedEnd.isAfter(limitDateTime)) {
                    preview.message = "Gia hạn thất bại: Vượt quá giới hạn cho phép (Giới hạn tối đa đến: " +
                            limitDateTime.toLocalTime().toString().substring(0, 5) + ").";
                    return preview;
                }

                // 8. Tính tiền
                LocalTime lightingStart = rs.getTime("light_start_time") != null ? rs.getTime("light_start_time").toLocalTime() : null;
                LocalTime lightingEnd = rs.getTime("light_end_time") != null ? rs.getTime("light_end_time").toLocalTime() : null;
                BigDecimal rateWithoutLight = rs.getBigDecimal("price_without_light");
                BigDecimal rateWithLight = rs.getBigDecimal("price_with_light");

                CourtPriceResult oldPricing = courtPricingService.calculate(startAt, oldPlannedEnd, lightingStart, lightingEnd, rateWithoutLight, rateWithLight);
                CourtPriceResult newPricing = courtPricingService.calculate(startAt, newPlannedEnd, lightingStart, lightingEnd, rateWithoutLight, rateWithLight);

                preview.oldTotalCourtAmount = oldPricing.totalCourtAmount();
                preview.newTotalCourtAmount = newPricing.totalCourtAmount();
                preview.additionalAmount = newPricing.totalCourtAmount().subtract(oldPricing.totalCourtAmount());

                preview.canExtend = true;
                preview.message = "Hợp lệ";
                return preview;
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi xem trước gia hạn ca chơi ID {}: {}", datSanId, e.getMessage(), e);
            preview.message = "Lỗi hệ thống khi tính toán gia hạn: " + e.getMessage();
            return preview;
        }
    }

    public ExtensionResult extendSession(int datSanId, Integer extendMinutes, LocalTime proposedNewEndTime, int operatorAccountId, int coSoId) {
        ExtensionResult result = new ExtensionResult();
        result.success = false;

        // Bắt đầu transaction
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. Khóa hàng LichDatSan
            String sqlLockBooking = "SELECT l.booking_id, l.court_id, l.booking_date, l.start_time, l.end_time, l.status, l.time_mode, " +
                    "l.actual_start_time_of_day, l.actual_started_at, l.reserved_duration_minutes, " +
                    "s.court_name, s.facility_id, s.status AS SanTrangThai, ls.price_without_light, ls.price_with_light, ls.light_start_time, ls.light_end_time " +
                    "FROM bookings l WITH (UPDLOCK, ROWLOCK) " +
                    "JOIN courts s ON l.court_id = s.court_id " +
                    "JOIN court_types ls ON s.court_type_id = ls.court_type_id " +
                    "WHERE l.booking_id = ? AND l.is_deleted = 0";

            int sanId;
            LocalDate date;
            LocalTime oldGioKetThuc;
            LocalDateTime startAt = null;
            LocalDateTime oldPlannedEnd;
            LocalTime lightingStart;
            LocalTime lightingEnd;
            BigDecimal rateWithoutLight;
            BigDecimal rateWithLight;
            Integer oldReservedMinutes = null;

            try (PreparedStatement ps = conn.prepareStatement(sqlLockBooking)) {
                ps.setInt(1, datSanId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        result.message = "Không tìm thấy thông tin đơn đặt sân.";
                        conn.rollback();
                        return result;
                    }

                    int bookingCoSoId = rs.getInt("facility_id");
                    if (bookingCoSoId != coSoId) {
                        result.message = "Đơn đặt sân không thuộc cơ sở của bạn.";
                        conn.rollback();
                        return result;
                    }

                    String bookingTrangThai = rs.getString("status");
                    if (!"Đang sử dụng".equals(bookingTrangThai)) {
                        result.message = "Chỉ ca chơi ở trạng thái 'Đang sử dụng' mới có thể gia hạn.";
                        conn.rollback();
                        return result;
                    }

                    String timeMode = rs.getString("time_mode");
                    if ("OPEN_ENDED".equals(timeMode)) {
                        result.message = "Walk-in không cố định chạy đến khi dừng, không cần gia hạn.";
                        conn.rollback();
                        return result;
                    }

                    sanId = rs.getInt("court_id");
                    date = rs.getDate("booking_date").toLocalDate();
                    oldGioKetThuc = rs.getTime("end_time").toLocalTime();

                    Timestamp ts = rs.getTimestamp("actual_started_at");
                    if (ts != null) {
                        startAt = ts.toLocalDateTime();
                    }
                    if (startAt == null) {
                        Time t = rs.getTime("actual_start_time_of_day");
                        if (t != null) {
                            startAt = date.atTime(t.toLocalTime());
                        }
                    }
                    if (startAt == null) {
                        startAt = date.atTime(rs.getTime("start_time").toLocalTime());
                    }

                    oldPlannedEnd = date.atTime(oldGioKetThuc);
                    if (!oldPlannedEnd.isAfter(startAt)) {
                        oldPlannedEnd = oldPlannedEnd.plusDays(1);
                    }

                    lightingStart = rs.getTime("light_start_time") != null ? rs.getTime("light_start_time").toLocalTime() : null;
                    lightingEnd = rs.getTime("light_end_time") != null ? rs.getTime("light_end_time").toLocalTime() : null;
                    rateWithoutLight = rs.getBigDecimal("price_without_light");
                    rateWithLight = rs.getBigDecimal("price_with_light");

                    int resMin = rs.getInt("reserved_duration_minutes");
                    if (!rs.wasNull()) {
                        oldReservedMinutes = resMin;
                    }
                }
            }

            // 2. Khóa hàng Sân
            String sqlLockSan = "SELECT status FROM courts WITH (UPDLOCK, ROWLOCK) WHERE court_id = ?";
            try (PreparedStatement psSan = conn.prepareStatement(sqlLockSan)) {
                psSan.setInt(1, sanId);
                try (ResultSet rsSan = psSan.executeQuery()) {
                    if (rsSan.next()) {
                        String sanStatus = rsSan.getString("status");
                        if ("Bảo trì".equals(sanStatus) || "Tạm đóng".equals(sanStatus)) {
                            result.message = "Không thể gia hạn chơi vì sân đang ở trạng thái: " + sanStatus;
                            conn.rollback();
                            return result;
                        }
                    }
                }
            }

            // 3. Tìm limitDateTime
            LocalDateTime nextBookingStart = null;
            String sqlNext = "SELECT booking_id, booking_date, start_time, end_time, status, hold_expires_at FROM bookings " +
                    "WHERE court_id = ? AND is_deleted = 0 AND booking_id <> ? " +
                    "AND (booking_date = ? OR booking_date = ?) " +
                    "AND (status IN (N'Đã xác nhận', N'Chờ xác nhận', N'Đang sử dụng') " +
                    "     OR (status = N'Chờ thanh toán' AND hold_expires_at > SYSUTCDATETIME()))";
            try (PreparedStatement psNext = conn.prepareStatement(sqlNext)) {
                psNext.setInt(1, sanId);
                psNext.setInt(2, datSanId);
                psNext.setDate(3, Date.valueOf(date));
                psNext.setDate(4, Date.valueOf(date.plusDays(1)));
                try (ResultSet rsNext = psNext.executeQuery()) {
                    while (rsNext.next()) {
                        LocalDate nextDate = rsNext.getDate("booking_date").toLocalDate();
                        LocalTime nextStartTime = rsNext.getTime("start_time").toLocalTime();
                        LocalDateTime startTemp = nextDate.atTime(nextStartTime);
                        if (!startTemp.isBefore(oldPlannedEnd)) {
                            if (nextBookingStart == null || startTemp.isBefore(nextBookingStart)) {
                                nextBookingStart = startTemp;
                            }
                        }
                    }
                }
            }

            LocalDateTime closeTime = null;
            String sqlCoSo = "SELECT closing_time FROM facilities WHERE facility_id = ?";
            try (PreparedStatement psCoSo = conn.prepareStatement(sqlCoSo)) {
                psCoSo.setInt(1, coSoId);
                try (ResultSet rsCoSo = psCoSo.executeQuery()) {
                    if (rsCoSo.next()) {
                        Time dbClose = rsCoSo.getTime("closing_time");
                        if (dbClose != null) {
                            closeTime = date.atTime(dbClose.toLocalTime());
                            if (dbClose.toLocalTime().isBefore(startAt.toLocalTime())) {
                                closeTime = closeTime.plusDays(1);
                            }
                        }
                    }
                }
            }

            LocalDateTime limitDateTime = null;
            if (nextBookingStart != null && closeTime != null) {
                limitDateTime = nextBookingStart.isBefore(closeTime) ? nextBookingStart : closeTime;
            } else if (nextBookingStart != null) {
                limitDateTime = nextBookingStart;
            } else if (closeTime != null) {
                limitDateTime = closeTime;
            } else {
                limitDateTime = oldPlannedEnd.plusHours(6);
            }

            LocalDateTime nowDateTime = LocalDateTime.now();
            LocalDateTime baseEnd = oldPlannedEnd;
            if (nowDateTime.isAfter(oldPlannedEnd)) {
                baseEnd = nowDateTime;
            }

            // 4. Tính newPlannedEnd
            LocalDateTime newPlannedEnd = null;
            if (extendMinutes != null) {
                newPlannedEnd = baseEnd.plusMinutes(extendMinutes);
            } else {
                newPlannedEnd = date.atTime(proposedNewEndTime);
                if (!newPlannedEnd.isAfter(baseEnd)) {
                    newPlannedEnd = newPlannedEnd.plusDays(1);
                }
            }

            // 5. Validations
            if (!newPlannedEnd.isAfter(baseEnd)) {
                result.message = "Giờ kết thúc mới phải sau thời điểm hiện tại và giờ kết thúc cũ.";
                conn.rollback();
                return result;
            }
            if (newPlannedEnd.isAfter(limitDateTime)) {
                result.message = "Gia hạn thất bại: Vượt quá giới hạn cho phép do trùng lịch hoặc vượt quá giờ đóng cửa.";
                conn.rollback();
                return result;
            }

            // 6. Tính tiền
            CourtPriceResult oldPricing = courtPricingService.calculate(startAt, oldPlannedEnd, lightingStart, lightingEnd, rateWithoutLight, rateWithLight);
            CourtPriceResult newPricing = courtPricingService.calculate(startAt, newPlannedEnd, lightingStart, lightingEnd, rateWithoutLight, rateWithLight);

            BigDecimal oldTotalCourtAmount = oldPricing.totalCourtAmount();
            BigDecimal newTotalCourtAmount = newPricing.totalCourtAmount();
            BigDecimal additionalAmount = newTotalCourtAmount.subtract(oldTotalCourtAmount);

            // 7. Cập nhật booking
            long extendDurationMin = Duration.between(oldPlannedEnd, newPlannedEnd).toMinutes();
            Integer newReservedMinutes = null;
            if (oldReservedMinutes != null) {
                newReservedMinutes = oldReservedMinutes + (int) extendDurationMin;
            }

            String sqlUpdateBooking = "UPDATE bookings SET end_time = ?, estimated_total = ?" +
                    (newReservedMinutes != null ? ", reserved_duration_minutes = ?" : "") +
                    " WHERE booking_id = ?";
            try (PreparedStatement psUpdateB = conn.prepareStatement(sqlUpdateBooking)) {
                psUpdateB.setTime(1, Time.valueOf(newPlannedEnd.toLocalTime()));
                psUpdateB.setBigDecimal(2, newTotalCourtAmount);
                if (newReservedMinutes != null) {
                    psUpdateB.setInt(3, newReservedMinutes);
                    psUpdateB.setInt(4, datSanId);
                } else {
                    psUpdateB.setInt(3, datSanId);
                }
                psUpdateB.executeUpdate();
            }

            // 8. Cập nhật hóa đơn chính (MAIN)
            String sqlSelectInvoice = "SELECT invoice_id, court_total, service_total, parking_fee, discount_amount, grand_total, payment_status FROM invoices WITH (UPDLOCK, ROWLOCK) " +
                    "WHERE booking_id = ? AND (invoice_type = N'MAIN' OR invoice_type IS NULL)";
            try (PreparedStatement psSelInv = conn.prepareStatement(sqlSelectInvoice)) {
                psSelInv.setInt(1, datSanId);
                try (ResultSet rsInv = psSelInv.executeQuery()) {
                    if (rsInv.next()) {
                        int hoaDonId = rsInv.getInt("invoice_id");
                        BigDecimal serviceAmt = rsInv.getBigDecimal("service_total");
                        BigDecimal parkingAmt = rsInv.getBigDecimal("parking_fee");
                        BigDecimal discountAmt = rsInv.getBigDecimal("discount_amount");

                        BigDecimal newTotalInvoice = newTotalCourtAmount.add(serviceAmt != null ? serviceAmt : BigDecimal.ZERO)
                                .add(parkingAmt != null ? parkingAmt : BigDecimal.ZERO)
                                .subtract(discountAmt != null ? discountAmt : BigDecimal.ZERO);
                        if (newTotalInvoice.compareTo(BigDecimal.ZERO) < 0) {
                            newTotalInvoice = BigDecimal.ZERO;
                        }

                        // Cập nhật hóa đơn và chuyển về Chưa thanh toán
                        String sqlUpdateInvoice = "UPDATE invoices SET court_total = ?, grand_total = ?, payment_status = N'Chưa thanh toán' WHERE invoice_id = ?";
                        try (PreparedStatement psUpInv = conn.prepareStatement(sqlUpdateInvoice)) {
                            psUpInv.setBigDecimal(1, newTotalCourtAmount);
                            psUpInv.setBigDecimal(2, newTotalInvoice);
                            psUpInv.setInt(3, hoaDonId);
                            psUpInv.executeUpdate();
                        }
                    }
                }
            }

            // 9. Ghi lịch sử gia hạn
            String sqlHistory = "INSERT INTO booking_extensions (booking_id, old_end_time, new_end_time, old_end_at, new_end_at, additional_amount, operator_account_id, created_at) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())";
            try (PreparedStatement psHist = conn.prepareStatement(sqlHistory)) {
                psHist.setInt(1, datSanId);
                psHist.setTime(2, Time.valueOf(oldPlannedEnd.toLocalTime()));
                psHist.setTime(3, Time.valueOf(newPlannedEnd.toLocalTime()));
                psHist.setTimestamp(4, Timestamp.valueOf(oldPlannedEnd));
                psHist.setTimestamp(5, Timestamp.valueOf(newPlannedEnd));
                psHist.setBigDecimal(6, additionalAmount);
                psHist.setInt(7, operatorAccountId);
                psHist.executeUpdate();
            }

            conn.commit();
            result.success = true;
            result.additionalAmount = additionalAmount;
            result.newGioKetThuc = newPlannedEnd.toLocalTime();
            result.message = "Gia hạn chơi thành công thêm " + extendDurationMin + " phút.";
            return result;

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    logger.error("Lỗi rollback transaction: {}", ex.getMessage(), ex);
                }
            }
            logger.error("Lỗi khi gia hạn ca chơi ID {}: {}", datSanId, e.getMessage(), e);
            result.message = "Lỗi hệ thống: " + e.getMessage();
            return result;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ex) {
                    logger.error("Lỗi đóng kết nối database: {}", ex.getMessage(), ex);
                }
            }
        }
    }
}
