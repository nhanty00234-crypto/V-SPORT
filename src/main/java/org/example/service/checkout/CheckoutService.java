package org.example.service.checkout;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.service.pricing.*;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.time.*;
import java.util.*;

/** Transaction boundary duy nhất cho chốt giờ và thanh toán MAIN invoice. */
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
                if (result.alreadyPaid()) { c.commit(); return result; }
                try (PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM HoaDon WITH (UPDLOCK, ROWLOCK) WHERE DatSanID=? AND LoaiHoaDon=N'SPLIT' AND TrangThaiThanhToan<>N'Đã thanh toán'")) {
                    ps.setInt(1, datSanId); try (ResultSet rs = ps.executeQuery()) { rs.next(); if (rs.getInt(1) > 0) throw new IllegalStateException("Còn hóa đơn SPLIT chưa thanh toán."); }
                }
                try (PreparedStatement ps = c.prepareStatement("UPDATE HoaDon SET TrangThaiThanhToan=N'Đã thanh toán', PhuongThucThanhToan=?, AccountID_NhanVien=?, NgayLap=GETDATE() WHERE HoaDonID=? AND TrangThaiThanhToan<>N'Đã thanh toán'")) {
                    ps.setNString(1, method); ps.setInt(2, staffId); ps.setInt(3, result.hoaDonId());
                    if (ps.executeUpdate() != 1) throw new IllegalStateException("Hóa đơn đã được xử lý bởi giao dịch khác.");
                }
                try (PreparedStatement ps = c.prepareStatement("UPDATE LichDatSan SET TrangThai=N'Đã hoàn thành' WHERE DatSanID=? AND TrangThai=N'Đang sử dụng'")) {
                    ps.setInt(1, datSanId); if (ps.executeUpdate() != 1) throw new IllegalStateException("Không thể hoàn thành ca chơi.");
                }
                try (PreparedStatement ps = c.prepareStatement("UPDATE San SET TrangThai=N'Sẵn sàng' WHERE SanID=(SELECT SanID FROM LichDatSan WHERE DatSanID=?) AND TrangThai=N'Đang sử dụng'")) {
                    ps.setInt(1, datSanId); if (ps.executeUpdate() != 1) throw new IllegalStateException("Không thể giải phóng sân.");
                }
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

                String status; String reference; BigDecimal paidAmount;
                try (PreparedStatement ps = c.prepareStatement(
                        "SELECT h.TrangThaiThanhToan, h.PaymentReference, ISNULL(l.DepositAmount,0) AS DepositAmount " +
                        "FROM HoaDon h WITH (UPDLOCK, ROWLOCK) JOIN LichDatSan l ON l.DatSanID=h.DatSanID WHERE h.HoaDonID=?")) {
                    ps.setInt(1, result.hoaDonId());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) throw new IllegalStateException("Không tìm thấy hóa đơn.");
                        status = rs.getNString("TrangThaiThanhToan");
                        reference = rs.getString("PaymentReference");
                        paidAmount = nz(rs.getBigDecimal("DepositAmount"));
                    }
                }
                if ("Đã thanh toán".equals(status)) throw new IllegalStateException("Hóa đơn đã được thanh toán trước đó.");

                BigDecimal remaining = result.tongThanhToan().subtract(paidAmount).max(BigDecimal.ZERO).setScale(0, RoundingMode.HALF_UP);

                if ("Chờ xác nhận chuyển khoản".equals(status) && reference != null && !reference.isBlank()) {
                    c.commit();
                    return new BankTransferInit(datSanId, result.hoaDonId(), remaining, paidAmount, reference);
                }

                String newReference = "VSPORT HD" + result.hoaDonId();
                try (PreparedStatement up = c.prepareStatement(
                        "UPDATE HoaDon SET TrangThaiThanhToan=N'Chờ xác nhận chuyển khoản', PaymentReference=? " +
                        "WHERE HoaDonID=? AND TrangThaiThanhToan<>N'Đã thanh toán'")) {
                    up.setString(1, newReference);
                    up.setInt(2, result.hoaDonId());
                    if (up.executeUpdate() != 1) throw new IllegalStateException("Hóa đơn đã được xử lý bởi giao dịch khác.");
                }
                c.commit();
                logger.info("Khởi tạo chuyển khoản datSanId={}, hoaDonId={}, amount={}", datSanId, result.hoaDonId(), remaining);
                return new BankTransferInit(datSanId, result.hoaDonId(), remaining, paidAmount, newReference);
            } catch (Exception e) { c.rollback(); logger.error("Rollback initBankTransfer datSanId={}: {}", datSanId, e.getMessage()); throw e; }
            finally { c.setAutoCommit(true); }
        }
    }

    /**
     * Xác nhận đã nhận tiền chuyển khoản (thao tác thủ công của nhân viên). Idempotent: nếu hóa đơn
     * đã "Đã thanh toán" (double-click, hai nhân viên xác nhận cùng lúc), không xử lý lại. Chặn nếu
     * paymentReference gửi lên không khớp giá trị đã lưu (chống submit lệch dữ liệu/hóa đơn cũ).
     */
    public BankTransferConfirm confirmBankTransfer(int datSanId, int coSoId, int staffId,
                                                     String paymentReference, String transactionCode) throws Exception {
        try (Connection c = DBUtil.getConnection()) {
            c.setAutoCommit(false);
            try {
                String sql = "SELECT h.HoaDonID,h.TrangThaiThanhToan,h.PaymentReference,s.CoSoID " +
                        "FROM LichDatSan l WITH (UPDLOCK,ROWLOCK) JOIN San s ON s.SanID=l.SanID " +
                        "JOIN HoaDon h WITH (UPDLOCK,ROWLOCK) ON h.DatSanID=l.DatSanID AND h.LoaiHoaDon=N'MAIN' WHERE l.DatSanID=?";
                int hoaDonId; String status; String storedRef;
                try (PreparedStatement ps = c.prepareStatement(sql)) {
                    ps.setInt(1, datSanId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) throw new IllegalArgumentException("Không tìm thấy ca chơi hoặc MAIN invoice.");
                        if (rs.getInt("CoSoID") != coSoId) throw new SecurityException("Ca chơi không thuộc cơ sở của bạn.");
                        hoaDonId = rs.getInt("HoaDonID");
                        status = rs.getNString("TrangThaiThanhToan");
                        storedRef = rs.getString("PaymentReference");
                    }
                }
                if ("Đã thanh toán".equals(status)) { c.commit(); return new BankTransferConfirm(datSanId, hoaDonId, true); }
                if (!"Chờ xác nhận chuyển khoản".equals(status)) throw new IllegalStateException("Hóa đơn chưa ở trạng thái chờ xác nhận chuyển khoản.");
                if (storedRef == null || !storedRef.equals(paymentReference)) throw new IllegalArgumentException("Nội dung chuyển khoản không khớp, vui lòng tải lại hóa đơn.");

                try (PreparedStatement up = c.prepareStatement(
                        "UPDATE HoaDon SET TrangThaiThanhToan=N'Đã thanh toán', PhuongThucThanhToan=N'Chuyển khoản', " +
                        "AccountID_NhanVien=?, NgayLap=GETDATE() WHERE HoaDonID=? AND TrangThaiThanhToan=N'Chờ xác nhận chuyển khoản'")) {
                    up.setInt(1, staffId); up.setInt(2, hoaDonId);
                    if (up.executeUpdate() != 1) throw new IllegalStateException("Hóa đơn đã được xử lý bởi giao dịch khác.");
                }
                try (PreparedStatement up = c.prepareStatement(
                        "UPDATE LichDatSan SET PaymentMethodConfirmed=N'Chuyển khoản', TransactionCode=?, ConfirmedAt=GETDATE(), " +
                        "ConfirmedBy=?, ConfirmSource=N'STAFF_MANUAL' WHERE DatSanID=?")) {
                    up.setString(1, (transactionCode == null || transactionCode.isBlank()) ? null : transactionCode.trim());
                    up.setInt(2, staffId); up.setInt(3, datSanId);
                    up.executeUpdate();
                }
                try (PreparedStatement up = c.prepareStatement("UPDATE LichDatSan SET TrangThai=N'Đã hoàn thành' WHERE DatSanID=? AND TrangThai=N'Đang sử dụng'")) {
                    up.setInt(1, datSanId); if (up.executeUpdate() != 1) throw new IllegalStateException("Không thể hoàn thành ca chơi.");
                }
                try (PreparedStatement up = c.prepareStatement("UPDATE San SET TrangThai=N'Sẵn sàng' WHERE SanID=(SELECT SanID FROM LichDatSan WHERE DatSanID=?) AND TrangThai=N'Đang sử dụng'")) {
                    up.setInt(1, datSanId); if (up.executeUpdate() != 1) throw new IllegalStateException("Không thể giải phóng sân.");
                }
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
                        "SELECT s.CoSoID FROM LichDatSan l JOIN San s ON s.SanID=l.SanID WHERE l.DatSanID=?")) {
                    check.setInt(1, datSanId);
                    try (ResultSet rs = check.executeQuery()) {
                        if (!rs.next()) throw new IllegalArgumentException("Không tìm thấy ca chơi.");
                        if (rs.getInt("CoSoID") != coSoId) throw new SecurityException("Ca chơi không thuộc cơ sở của bạn.");
                    }
                }
                try (PreparedStatement up = c.prepareStatement(
                        "UPDATE HoaDon SET TrangThaiThanhToan=N'Chưa thanh toán' WHERE DatSanID=? AND TrangThaiThanhToan=N'Chờ xác nhận chuyển khoản'")) {
                    up.setInt(1, datSanId);
                    up.executeUpdate();
                }
                c.commit();
            } catch (Exception e) { c.rollback(); throw e; }
            finally { c.setAutoCommit(true); }
        }
    }

    private CheckoutResult finalizeLocked(Connection c, int datSanId, int coSoId, LocalDateTime now) throws Exception {
        String sql = "SELECT l.DatSanID,l.NgayDat,l.GioBatDau,l.GioKetThuc,l.TimeMode,l.ActualStartAt,l.ActualEndAt,l.actual_start_time,l.TrangThai," +
                "s.CoSoID,ls.GiaKhongDen,ls.GiaCoDen,ls.GioBatDauLenDen,ls.GioKetThucLenDen," +
                "h.HoaDonID,h.TrangThaiThanhToan,h.TongTienDichVu,h.PhiGuiXe,h.GiamGia " +
                "FROM LichDatSan l WITH (UPDLOCK,ROWLOCK) JOIN San s ON s.SanID=l.SanID JOIN LoaiSan ls ON ls.LoaiSanID=s.LoaiSanID " +
                "JOIN HoaDon h WITH (UPDLOCK,ROWLOCK) ON h.DatSanID=l.DatSanID AND h.LoaiHoaDon=N'MAIN' WHERE l.DatSanID=?";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) throw new IllegalArgumentException("Không tìm thấy ca chơi hoặc MAIN invoice.");
                if (rs.getInt("CoSoID") != coSoId) throw new SecurityException("Ca chơi không thuộc cơ sở của bạn.");
                int invoiceId = rs.getInt("HoaDonID");
                boolean paid = "Đã thanh toán".equals(rs.getNString("TrangThaiThanhToan"));
                LocalDateTime finalizedEnd = timestamp(rs, "ActualEndAt");
                if (paid || finalizedEnd != null) return loadResult(c, datSanId, invoiceId, finalizedEnd, paid);
                if (!"Đang sử dụng".equals(rs.getNString("TrangThai"))) throw new IllegalStateException("Ca chơi không ở trạng thái Đang sử dụng.");

                LocalDate date = rs.getDate("NgayDat").toLocalDate();
                LocalDateTime start = timestamp(rs, "ActualStartAt");
                if (start == null) { Time legacy = rs.getTime("actual_start_time"); start = LocalDateTime.of(date, legacy != null ? legacy.toLocalTime() : rs.getTime("GioBatDau").toLocalTime()); }
                String mode = rs.getNString("TimeMode");
                LocalDateTime plannedEnd = date.atTime(rs.getTime("GioKetThuc").toLocalTime());
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
                BigDecimal service = nz(rs.getBigDecimal("TongTienDichVu")), parking = nz(rs.getBigDecimal("PhiGuiXe")), discount = nz(rs.getBigDecimal("GiamGia"));
                BigDecimal total = court.add(service).add(parking).subtract(discount).max(BigDecimal.ZERO).setScale(0, RoundingMode.HALF_UP);
                try (PreparedStatement del = c.prepareStatement("DELETE FROM CourtChargeSegment WHERE HoaDonID=?")) { del.setInt(1, invoiceId); del.executeUpdate(); }
                try (PreparedStatement ins = c.prepareStatement("INSERT INTO CourtChargeSegment(HoaDonID,DatSanID,SegmentOrder,StartAt,EndAt,DurationMinutes,RateType,HourlyRate,Amount) VALUES(?,?,?,?,?,?,?,?,?)")) {
                    int order=1; for (CourtPriceSegment s : segments) { ins.setInt(1,invoiceId);ins.setInt(2,datSanId);ins.setInt(3,order++);ins.setTimestamp(4,Timestamp.valueOf(s.segmentStart()));ins.setTimestamp(5,Timestamp.valueOf(s.segmentEnd()));ins.setLong(6,s.durationMinutes());ins.setNString(7,s.rateType().name());ins.setBigDecimal(8,s.hourlyRate());ins.setBigDecimal(9,s.amount());ins.addBatch(); } ins.executeBatch();
                }
                try (PreparedStatement up = c.prepareStatement("UPDATE LichDatSan SET ActualEndAt=?,actual_end_time=?,PricingFinalizedAt=GETDATE(),TongTienDuKien=? WHERE DatSanID=? AND ActualEndAt IS NULL")) { up.setTimestamp(1,Timestamp.valueOf(now));up.setTime(2,Time.valueOf(now.toLocalTime()));up.setBigDecimal(3,court);up.setInt(4,datSanId);if(up.executeUpdate()!=1)throw new IllegalStateException("Ca chơi đã được chốt đồng thời."); }
                try (PreparedStatement up = c.prepareStatement("UPDATE HoaDon SET TongTienSan=?,TongThanhToan=? WHERE HoaDonID=? AND TrangThaiThanhToan<>N'Đã thanh toán'")) { up.setBigDecimal(1,court);up.setBigDecimal(2,total);up.setInt(3,invoiceId);if(up.executeUpdate()!=1)throw new IllegalStateException("Hóa đơn đã thanh toán."); }
                return new CheckoutResult(datSanId,invoiceId,now,court,service,parking,discount,total,segments,false);
            }
        }
    }

    private CourtPriceResult calculate(ResultSet rs, LocalDateTime start, LocalDateTime end) throws SQLException {
        Time a=rs.getTime("GioBatDauLenDen"), b=rs.getTime("GioKetThucLenDen");
        return pricing.calculate(start,end,a==null?null:a.toLocalTime(),b==null?null:b.toLocalTime(),rs.getBigDecimal("GiaKhongDen"),rs.getBigDecimal("GiaCoDen"));
    }
    private CheckoutResult loadResult(Connection c,int datSanId,int invoiceId,LocalDateTime end,boolean paid)throws SQLException{
        List<CourtPriceSegment> ss=new ArrayList<>();try(PreparedStatement p=c.prepareStatement("SELECT * FROM CourtChargeSegment WHERE HoaDonID=? ORDER BY SegmentOrder")){p.setInt(1,invoiceId);try(ResultSet r=p.executeQuery()){while(r.next())ss.add(new CourtPriceSegment(r.getTimestamp("StartAt").toLocalDateTime(),r.getTimestamp("EndAt").toLocalDateTime(),r.getLong("DurationMinutes"),CourtRateType.valueOf(r.getNString("RateType")),r.getBigDecimal("HourlyRate"),r.getBigDecimal("Amount")));}}
        try(PreparedStatement p=c.prepareStatement("SELECT TongTienSan,TongTienDichVu,PhiGuiXe,GiamGia,TongThanhToan FROM HoaDon WHERE HoaDonID=?")){p.setInt(1,invoiceId);try(ResultSet r=p.executeQuery()){r.next();return new CheckoutResult(datSanId,invoiceId,end,nz(r.getBigDecimal(1)),nz(r.getBigDecimal(2)),nz(r.getBigDecimal(3)),nz(r.getBigDecimal(4)),nz(r.getBigDecimal(5)),ss,paid);}}
    }
    private static LocalDateTime timestamp(ResultSet rs,String name)throws SQLException{Timestamp t=rs.getTimestamp(name);return t==null?null:t.toLocalDateTime();}
    private static BigDecimal nz(BigDecimal n){return n==null?BigDecimal.ZERO:n;}
}