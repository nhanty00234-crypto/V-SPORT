package org.example.service.checkout;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.service.payment.PaymentCalculator;
import org.example.service.pricing.*;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.time.*;
import java.util.*;

/** Transaction boundary duy nhất cho chốt giờ và thanh toán MAIN invoice.
 *
 * Ba khái niệm tách biệt, không được gộp lẫn (xem finalizeLocked/pay/confirmBankTransfer):
 *   - Finalize: chốt ActualEndAt + tính tiền sân theo segment (CourtPricingService).
 *   - Settle: đánh dấu HoaDon.TrangThaiThanhToan = Đã thanh toán.
 *   - Complete/release: LichDatSan -> Đã hoàn thành, San -> Sẵn sàng.
 * Một hóa đơn có thể đã Settle (thu tiền mặt lúc check-in) trước khi Finalize (ca vẫn đang
 * chơi) - finalizeLocked() phải luôn chạy phần chốt giờ bất kể đã thanh toán hay chưa, chỉ
 * bỏ qua việc ghi đè số tiền trên hóa đơn nếu đã thanh toán. pay()/confirmBankTransfer() luôn
 * gọi completeBookingAndReleaseCourtIfNeeded() sau khi cả hai điều kiện (finalize + settle) đã
 * đúng, kể cả khi bước settle đã xảy ra từ trước (không return sớm bỏ qua bước hoàn thành).
 */
public class CheckoutService {
    private static final Logger logger = LogManager.getLogger(CheckoutService.class);
    private static final Set<String> PAYMENT_METHODS = Set.of("Tiền mặt", "Chuyển khoản", "Ví điện tử", "Thẻ", "QR");
    private final CourtPricingService pricing = new CourtPricingService();

    public CheckoutResult finalizeSession(int datSanId, int coSoId) throws Exception {
        try (Connection c = DBUtil.getConnection()) {
            c.setAutoCommit(false);
            try { CheckoutResult result = finalizeLocked(c, datSanId, coSoId, LocalDateTime.now()); c.commit(); return result; }
            catch (Exception e) { c.rollback(); throw e; }
            finally { c.setAutoCommit(true); }
        }
    }

    public CheckoutResult pay(int datSanId, int coSoId, int staffId, String method) throws Exception {
        if (!PAYMENT_METHODS.contains(method)) throw new IllegalArgumentException("Phương thức thanh toán không hợp lệ.");
        try (Connection c = DBUtil.getConnection()) {
            c.setAutoCommit(false);
            try {
                CheckoutResult result = finalizeLocked(c, datSanId, coSoId, LocalDateTime.now());
                assertNoUnpaidSplitBills(c, datSanId);
                if (!result.alreadyPaid()) {
                    try (PreparedStatement ps = c.prepareStatement("UPDATE invoices SET payment_status=N'Đã thanh toán', payment_method=?, staff_account_id=?, issued_at=GETDATE() WHERE invoice_id=? AND payment_status<>N'Đã thanh toán'")) {
                        ps.setNString(1, method); ps.setInt(2, staffId); ps.setInt(3, result.hoaDonId());
                        if (ps.executeUpdate() != 1) throw new IllegalStateException("Hóa đơn đã được xử lý bởi giao dịch khác.");
                    }
                    result = new CheckoutResult(result.datSanId(), result.hoaDonId(), result.actualEndAt(),
                            result.tongTienSan(), result.tongTienDichVu(), result.phiGuiXe(), result.giamGia(),
                            result.tongThanhToan(), result.depositAmount(), BigDecimal.ZERO, result.segments(), true);
                }
                // Dù invoice đã Settle từ trước (vd thu tiền mặt lúc check-in) hay vừa Settle ở trên,
                // luôn đảm bảo Complete/release chạy - không return sớm chỉ vì alreadyPaid.
                completeBookingAndReleaseCourtIfNeeded(c, datSanId);
                c.commit();
                logger.info("Thanh toán checkout thành công datSanId={}, hoaDonId={}", datSanId, result.hoaDonId());
                return result;
            } catch (Exception e) { c.rollback(); logger.error("Rollback checkout datSanId={}: {}", datSanId, e.getMessage()); throw e; }
            finally { c.setAutoCommit(true); }
        }
    }

    /**
     * Khóa + chốt tiền sân (idempotent) cho một transaction do CALLER quản lý - dùng bởi
     * PayOSPaymentService để tạo/tái sử dụng payment link trong CÙNG transaction với việc
     * kiểm tra/khóa PayOSPaymentAttempt, tránh race giữa hai bước.
     */
    public CheckoutResult finalizeLockedForPayment(Connection c, int datSanId, int coSoId) throws Exception {
        return finalizeLocked(c, datSanId, coSoId, LocalDateTime.now());
    }

    /**
     * Chốt tiền sân (idempotent, dùng chung finalizeLocked) rồi chuyển hóa đơn sang trạng thái
     * chờ xác nhận chuyển khoản. KHÔNG đánh dấu đã thanh toán, KHÔNG giải phóng sân. Nếu hóa đơn
     * đang chờ chuyển khoản sẵn (mở lại modal), tái sử dụng nguyên PaymentReference/amount hiện có.
     */
    public BankTransferInit initBankTransfer(int datSanId, int coSoId) throws Exception {
        try (Connection c = DBUtil.getConnection()) {
            c.setAutoCommit(false);
            try {
                CheckoutResult result = finalizeLocked(c, datSanId, coSoId, LocalDateTime.now());
                if (result.alreadyPaid()) throw new IllegalStateException("Hóa đơn đã được thanh toán trước đó.");

                String status; String reference;
                try (PreparedStatement ps = c.prepareStatement(
                        "SELECT payment_status, payment_reference FROM invoices WITH (UPDLOCK, ROWLOCK) WHERE invoice_id=?")) {
                    ps.setInt(1, result.hoaDonId());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) throw new IllegalStateException("Không tìm thấy hóa đơn.");
                        status = rs.getNString("payment_status");
                        reference = rs.getString("payment_reference");
                    }
                }
                if ("Đã thanh toán".equals(status)) throw new IllegalStateException("Hóa đơn đã được thanh toán trước đó.");

                BigDecimal remaining = result.remainingAmount();

                if ("Chờ xác nhận chuyển khoản".equals(status) && reference != null && !reference.isBlank()) {
                    c.commit();
                    return new BankTransferInit(datSanId, result.hoaDonId(), remaining, result.depositAmount(), reference);
                }

                String newReference = "VSPORT HD" + result.hoaDonId();
                try (PreparedStatement up = c.prepareStatement(
                        "UPDATE invoices SET payment_status=N'Chờ xác nhận chuyển khoản', payment_reference=? " +
                        "WHERE invoice_id=? AND payment_status<>N'Đã thanh toán'")) {
                    up.setString(1, newReference);
                    up.setInt(2, result.hoaDonId());
                    if (up.executeUpdate() != 1) throw new IllegalStateException("Hóa đơn đã được xử lý bởi giao dịch khác.");
                }
                c.commit();
                logger.info("Khởi tạo chuyển khoản datSanId={}, hoaDonId={}, amount={}", datSanId, result.hoaDonId(), remaining);
                return new BankTransferInit(datSanId, result.hoaDonId(), remaining, result.depositAmount(), newReference);
            } catch (Exception e) { c.rollback(); logger.error("Rollback initBankTransfer datSanId={}: {}", datSanId, e.getMessage()); throw e; }
            finally { c.setAutoCommit(true); }
        }
    }

    /**
     * Xác nhận đã nhận tiền chuyển khoản (thao tác thủ công của nhân viên). Idempotent: nếu hóa đơn
     * đã "Đã thanh toán" (double-click, hai nhân viên xác nhận cùng lúc), không xử lý lại tiền nhưng
     * vẫn đảm bảo booking/sân đã Complete/release (không return sớm bỏ dở). Chặn nếu paymentReference
     * gửi lên không khớp giá trị đã lưu, và chặn nếu còn hóa đơn SPLIT chưa thanh toán.
     */
    public BankTransferConfirm confirmBankTransfer(int datSanId, int coSoId, int staffId,
                                                     String paymentReference, String transactionCode) throws Exception {
        try (Connection c = DBUtil.getConnection()) {
            c.setAutoCommit(false);
            try {
                String sql = "SELECT h.invoice_id,h.payment_status,h.payment_reference,s.facility_id " +
                        "FROM bookings l WITH (UPDLOCK,ROWLOCK) JOIN courts s ON s.court_id=l.court_id " +
                        "JOIN invoices h WITH (UPDLOCK,ROWLOCK) ON h.booking_id=l.booking_id AND h.invoice_type=N'MAIN' WHERE l.booking_id=?";
                int hoaDonId; String status; String storedRef;
                try (PreparedStatement ps = c.prepareStatement(sql)) {
                    ps.setInt(1, datSanId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) throw new IllegalArgumentException("Không tìm thấy ca chơi hoặc MAIN invoice.");
                        if (rs.getInt("facility_id") != coSoId) throw new SecurityException("Ca chơi không thuộc cơ sở của bạn.");
                        hoaDonId = rs.getInt("invoice_id");
                        status = rs.getNString("payment_status");
                        storedRef = rs.getString("payment_reference");
                    }
                }
                if ("Đã thanh toán".equals(status)) {
                    completeBookingAndReleaseCourtIfNeeded(c, datSanId);
                    c.commit();
                    return new BankTransferConfirm(datSanId, hoaDonId, true);
                }
                if (!"Chờ xác nhận chuyển khoản".equals(status)) throw new IllegalStateException("Hóa đơn chưa ở trạng thái chờ xác nhận chuyển khoản.");
                if (storedRef == null || !storedRef.equals(paymentReference)) throw new IllegalArgumentException("Nội dung chuyển khoản không khớp, vui lòng tải lại hóa đơn.");
                assertNoUnpaidSplitBills(c, datSanId);

                try (PreparedStatement up = c.prepareStatement(
                        "UPDATE invoices SET payment_status=N'Đã thanh toán', payment_method=N'Chuyển khoản', " +
                        "staff_account_id=?, issued_at=GETDATE() WHERE invoice_id=? AND payment_status=N'Chờ xác nhận chuyển khoản'")) {
                    up.setInt(1, staffId); up.setInt(2, hoaDonId);
                    if (up.executeUpdate() != 1) throw new IllegalStateException("Hóa đơn đã được xử lý bởi giao dịch khác.");
                }
                try (PreparedStatement up = c.prepareStatement(
                        "UPDATE bookings SET payment_method_confirmed=N'Chuyển khoản', transaction_code=?, confirmed_at=GETDATE(), " +
                        "confirmed_by=?, confirm_source=N'STAFF_MANUAL' WHERE booking_id=?")) {
                    up.setString(1, (transactionCode == null || transactionCode.isBlank()) ? null : transactionCode.trim());
                    up.setInt(2, staffId); up.setInt(3, datSanId);
                    up.executeUpdate();
                }
                completeBookingAndReleaseCourtIfNeeded(c, datSanId);
                c.commit();
                logger.info("Xác nhận chuyển khoản thành công datSanId={}, hoaDonId={}", datSanId, hoaDonId);
                return new BankTransferConfirm(datSanId, hoaDonId, false);
            } catch (Exception e) { c.rollback(); logger.error("Rollback confirmBankTransfer datSanId={}: {}", datSanId, e.getMessage()); throw e; }
            finally { c.setAutoCommit(true); }
        }
    }

    /**
     * "Đổi phương thức" khi đang chờ chuyển khoản: đưa hóa đơn về Chưa thanh toán để nhân viên chọn
     * lại Tiền mặt. Không đụng amount/PaymentReference (giữ lại để tái dùng nếu chọn lại Chuyển khoản),
     * không đụng booking/sân. Không có tác dụng nếu hóa đơn không còn ở trạng thái chờ chuyển khoản.
     */
    public void cancelAwaitingTransfer(int datSanId, int coSoId) throws Exception {
        try (Connection c = DBUtil.getConnection()) {
            c.setAutoCommit(false);
            try {
                try (PreparedStatement check = c.prepareStatement(
                        "SELECT s.facility_id FROM bookings l JOIN courts s ON s.court_id=l.court_id WHERE l.booking_id=?")) {
                    check.setInt(1, datSanId);
                    try (ResultSet rs = check.executeQuery()) {
                        if (!rs.next()) throw new IllegalArgumentException("Không tìm thấy ca chơi.");
                        if (rs.getInt("facility_id") != coSoId) throw new SecurityException("Ca chơi không thuộc cơ sở của bạn.");
                    }
                }
                try (PreparedStatement up = c.prepareStatement(
                        "UPDATE invoices SET payment_status=N'Chưa thanh toán' WHERE booking_id=? AND payment_status=N'Chờ xác nhận chuyển khoản'")) {
                    up.setInt(1, datSanId);
                    up.executeUpdate();
                }
                c.commit();
            } catch (Exception e) { c.rollback(); throw e; }
            finally { c.setAutoCommit(true); }
        }
    }

    /** Chặn Complete/release khi còn hóa đơn SPLIT chưa thanh toán (loại trừ SPLIT đã hủy hợp lệ). */
    private void assertNoUnpaidSplitBills(Connection c, int datSanId) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement(
                "SELECT COUNT(*) FROM invoices WITH (UPDLOCK, ROWLOCK) WHERE booking_id=? AND invoice_type=N'SPLIT' " +
                "AND payment_status NOT IN (N'Đã thanh toán', N'Đã hủy')")) {
            ps.setInt(1, datSanId);
            try (ResultSet rs = ps.executeQuery()) { rs.next(); if (rs.getInt(1) > 0) throw new IllegalStateException("Còn hóa đơn SPLIT chưa thanh toán."); }
        }
    }

    /** Idempotent: 0 dòng bị ảnh hưởng nghĩa là đã Complete/release từ trước, KHÔNG phải lỗi. */
    private void completeBookingAndReleaseCourtIfNeeded(Connection c, int datSanId) throws SQLException {
        Integer accountId = null;
        try (PreparedStatement ps = c.prepareStatement("SELECT account_id FROM bookings WHERE booking_id = ?")) {
            ps.setInt(1, datSanId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int acc = rs.getInt("account_id");
                    if (!rs.wasNull()) accountId = acc;
                }
            }
        }

        int rowsUpdated;
        try (PreparedStatement ps = c.prepareStatement(
                "UPDATE bookings SET status=N'Đã hoàn thành' WHERE booking_id=? AND status=N'Đang sử dụng'")) {
            ps.setInt(1, datSanId);
            rowsUpdated = ps.executeUpdate();
        }
        try (PreparedStatement ps = c.prepareStatement(
                "UPDATE courts SET status=N'Sẵn sàng' WHERE court_id=(SELECT court_id FROM bookings WHERE booking_id=?) AND status=N'Đang sử dụng'")) {
            ps.setInt(1, datSanId);
            ps.executeUpdate();
        }

        // Cộng điểm uy tín hoàn thành booking - CHỈ khi UPDATE ở trên vừa thực sự chuyển trạng thái
        // (idempotent: nếu đã "Đã hoàn thành" từ trước, rowsUpdated=0, không cộng điểm lần hai).
        if (rowsUpdated > 0 && accountId != null) {
            org.example.service.reputation.CustomerReputationService.applyDelta(c, accountId, datSanId,
                    org.example.util.Constants.REPUTATION_ACTION_COMPLETED_BOOKING,
                    org.example.util.Constants.COMPLETED_BOOKING_REWARD,
                    "Hoàn thành booking thành công", null, null);
        }
    }

    private CheckoutResult finalizeLocked(Connection c, int datSanId, int coSoId, LocalDateTime now) throws Exception {
        String sql = "SELECT l.booking_id,l.booking_date,l.start_time,l.end_time,l.time_mode,l.actual_started_at,l.actual_ended_at,l.actual_start_time_of_day,l.status,l.deposit_amount," +
                "s.facility_id,ls.price_without_light,ls.price_with_light,ls.light_start_time,ls.light_end_time," +
                "h.invoice_id,h.payment_status,h.court_total,h.service_total,h.parking_fee,h.discount_amount,h.grand_total " +
                "FROM bookings l WITH (UPDLOCK,ROWLOCK) JOIN courts s ON s.court_id=l.court_id JOIN court_types ls ON ls.court_type_id=s.court_type_id " +
                "JOIN invoices h WITH (UPDLOCK,ROWLOCK) ON h.booking_id=l.booking_id AND h.invoice_type=N'MAIN' WHERE l.booking_id=?";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) throw new IllegalArgumentException("Không tìm thấy ca chơi hoặc MAIN invoice.");
                if (rs.getInt("facility_id") != coSoId) throw new SecurityException("Ca chơi không thuộc cơ sở của bạn.");
                int invoiceId = rs.getInt("invoice_id");
                boolean paid = "Đã thanh toán".equals(rs.getNString("payment_status"));
                BigDecimal deposit = nz(rs.getBigDecimal("deposit_amount"));
                LocalDateTime finalizedEnd = timestamp(rs, "actual_ended_at");
                String trangThai = rs.getNString("status");

                // Đã chốt giờ trước đó (idempotent, double-click/hai nhân viên checkout đồng thời) -
                // trả lại đúng kết quả đã lưu, không tính lại, không đụng tiền lần hai.
                if (finalizedEnd != null) return loadResult(c, datSanId, invoiceId, finalizedEnd, paid, deposit);

                // Chưa chốt giờ và ca không còn "Đang sử dụng": nếu đã Complete/paid từ một luồng cũ
                // không ghi ActualEndAt (dữ liệu lịch sử), trả nguyên trạng thay vì lỗi; ngược lại báo lỗi rõ.
                if (!"Đang sử dụng".equals(trangThai)) {
                    if (paid || "Đã hoàn thành".equals(trangThai)) return loadResult(c, datSanId, invoiceId, null, paid, deposit);
                    throw new IllegalStateException("Ca chơi không ở trạng thái Đang sử dụng.");
                }

                // Finalize: chốt ActualEndAt + tính tiền sân - PHẢI chạy dù hóa đơn đã Settle (paid=true)
                // hay chưa, vì Finalize (chốt giờ chơi thực tế) và Settle (đã thu tiền) là hai việc khác nhau.
                LocalDate date = rs.getDate("booking_date").toLocalDate();
                LocalDateTime start = timestamp(rs, "actual_started_at");
                if (start == null) { Time legacy = rs.getTime("actual_start_time_of_day"); start = LocalDateTime.of(date, legacy != null ? legacy.toLocalTime() : rs.getTime("start_time").toLocalTime()); }
                String mode = rs.getNString("time_mode");
                LocalDateTime plannedEnd = date.atTime(rs.getTime("end_time").toLocalTime());
                if (!plannedEnd.isAfter(start)) plannedEnd = plannedEnd.plusDays(1);
                List<CourtPriceSegment> segments = new ArrayList<>();
                if ("OPEN_ENDED".equals(mode)) {
                    LocalDateTime effectiveEnd = now.isBefore(start.plusMinutes(15)) ? start.plusMinutes(15) : now;
                    segments.addAll(calculate(rs, start, effectiveEnd).segments());
                } else {
                    segments.addAll(calculate(rs, start, plannedEnd).segments());
                    LocalDateTime surchargeStart = plannedEnd.plusMinutes(10);
                    if (now.isAfter(surchargeStart)) segments.addAll(calculate(rs, surchargeStart, now).segments());
                }
                BigDecimal court = segments.stream().map(CourtPriceSegment::amount).reduce(BigDecimal.ZERO, BigDecimal::add).setScale(0, RoundingMode.HALF_UP);
                BigDecimal service = nz(rs.getBigDecimal("service_total")), parking = nz(rs.getBigDecimal("parking_fee")), discount = nz(rs.getBigDecimal("discount_amount"));
                BigDecimal total = court.add(service).add(parking).subtract(discount).max(BigDecimal.ZERO).setScale(0, RoundingMode.HALF_UP);
                try (PreparedStatement del = c.prepareStatement("DELETE FROM court_charge_segments WHERE invoice_id=?")) { del.setInt(1, invoiceId); del.executeUpdate(); }
                try (PreparedStatement ins = c.prepareStatement("INSERT INTO court_charge_segments(invoice_id,booking_id,segment_order,start_at,end_at,duration_minutes,rate_type,hourly_rate,amount) VALUES(?,?,?,?,?,?,?,?,?)")) {
                    int order=1; for (CourtPriceSegment s : segments) { ins.setInt(1,invoiceId);ins.setInt(2,datSanId);ins.setInt(3,order++);ins.setTimestamp(4,Timestamp.valueOf(s.segmentStart()));ins.setTimestamp(5,Timestamp.valueOf(s.segmentEnd()));ins.setLong(6,s.durationMinutes());ins.setNString(7,s.rateType().name());ins.setBigDecimal(8,s.hourlyRate());ins.setBigDecimal(9,s.amount());ins.addBatch(); } ins.executeBatch();
                }
                try (PreparedStatement up = c.prepareStatement("UPDATE bookings SET actual_ended_at=?,actual_end_time_of_day=?,pricing_finalized_at=GETDATE(),estimated_total=? WHERE booking_id=? AND actual_ended_at IS NULL")) { up.setTimestamp(1,Timestamp.valueOf(now));up.setTime(2,Time.valueOf(now.toLocalTime()));up.setBigDecimal(3,court);up.setInt(4,datSanId);if(up.executeUpdate()!=1)throw new IllegalStateException("Ca chơi đã được chốt đồng thời."); }

                // Settle đã xảy ra trước đó (vd thu tiền mặt lúc check-in): KHÔNG được ghi đè số tiền
                // hóa đơn đã thanh toán - trả lại đúng số tiền đã lưu, không phải số vừa tính lại.
                if (paid) {
                    BigDecimal storedCourt = nz(rs.getBigDecimal("court_total"));
                    BigDecimal storedTotal = nz(rs.getBigDecimal("grand_total"));
                    return new CheckoutResult(datSanId, invoiceId, now, storedCourt, service, parking, discount, storedTotal,
                            deposit, PaymentCalculator.remainingAmount(storedTotal, deposit), segments, true);
                }
                try (PreparedStatement up = c.prepareStatement("UPDATE invoices SET court_total=?,grand_total=? WHERE invoice_id=? AND payment_status<>N'Đã thanh toán'")) { up.setBigDecimal(1,court);up.setBigDecimal(2,total);up.setInt(3,invoiceId);up.executeUpdate(); }
                return new CheckoutResult(datSanId, invoiceId, now, court, service, parking, discount, total,
                        deposit, PaymentCalculator.remainingAmount(total, deposit), segments, false);
            }
        }
    }

    private CourtPriceResult calculate(ResultSet rs, LocalDateTime start, LocalDateTime end) throws SQLException {
        Time a=rs.getTime("light_start_time"), b=rs.getTime("light_end_time");
        return pricing.calculate(start,end,a==null?null:a.toLocalTime(),b==null?null:b.toLocalTime(),rs.getBigDecimal("price_without_light"),rs.getBigDecimal("price_with_light"));
    }

    private CheckoutResult loadResult(Connection c, int datSanId, int invoiceId, LocalDateTime end, boolean paid, BigDecimal deposit) throws SQLException {
        List<CourtPriceSegment> ss=new ArrayList<>();
        try(PreparedStatement p=c.prepareStatement("SELECT * FROM court_charge_segments WHERE invoice_id=? ORDER BY segment_order")){
            p.setInt(1, invoiceId);
            try(ResultSet r=p.executeQuery()){
                while(r.next()) ss.add(new CourtPriceSegment(r.getTimestamp("start_at").toLocalDateTime(),r.getTimestamp("end_at").toLocalDateTime(),r.getLong("duration_minutes"),CourtRateType.valueOf(r.getNString("rate_type")),r.getBigDecimal("hourly_rate"),r.getBigDecimal("amount")));
            }
        }
        try(PreparedStatement p=c.prepareStatement("SELECT court_total,service_total,parking_fee,discount_amount,grand_total FROM invoices WHERE invoice_id=?")){
            p.setInt(1, invoiceId);
            try(ResultSet r=p.executeQuery()){
                r.next();
                BigDecimal total = nz(r.getBigDecimal(5));
                return new CheckoutResult(datSanId, invoiceId, end, nz(r.getBigDecimal(1)), nz(r.getBigDecimal(2)), nz(r.getBigDecimal(3)), nz(r.getBigDecimal(4)),
                        total, nz(deposit), PaymentCalculator.remainingAmount(total, deposit), ss, paid);
            }
        }
    }

    private static LocalDateTime timestamp(ResultSet rs,String name)throws SQLException{Timestamp t=rs.getTimestamp(name);return t==null?null:t.toLocalDateTime();}
    private static BigDecimal nz(BigDecimal n){return n==null?BigDecimal.ZERO:n;}
}
