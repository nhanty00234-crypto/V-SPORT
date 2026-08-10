package org.example.service.payos;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;

/**
 * Điểm DUY NHẤT được phép xác nhận thanh toán PayOS cho luồng đặt sân trực tiếp của khách hàng
 * (KHÁC với PayOSPaymentFinalizationService - luồng đó dành cho manager/staff checkout qua
 * PayOSPaymentAttempt). Gọi từ PayOSWebhookServlet SAU KHI đã xác thực chữ ký webhook.
 *
 * Transaction idempotent: khóa LichDatSan (UPDLOCK, ROWLOCK), tạo-hoặc-lấy đúng một MAIN
 * HoaDon, ghi DepositAmount/PaymentMethodConfirmed/TransactionCode/ConfirmedAt/ConfirmSource,
 * chuyển booking sang Đã xác nhận. Webhook gọi lại nhiều lần (PayOS retry) không tạo hóa đơn
 * trùng và không xử lý tiền hai lần - trạng thái Đã xác nhận là điều kiện dừng idempotent.
 * Nếu booking đã bị sweep sang Quá hạn nhưng thanh toán đến ngay sau đó (race), vẫn xác nhận
 * bình thường thay vì để mất dấu tiền đã nhận - không được vừa nhận tiền vừa để booking Quá hạn.
 */
public class PayOSLegacyBookingFinalizationService {

    private static final Logger logger = LogManager.getLogger(PayOSLegacyBookingFinalizationService.class);

    public enum ResultCode { CONFIRMED, ALREADY_CONFIRMED, NOT_FOUND, CANCELLED, AMOUNT_MISMATCH, UNEXPECTED_STATUS, DATABASE_ERROR }

    public record Result(ResultCode code, Integer hoaDonId, Integer accountId) {
        public boolean isSuccess() {
            return code == ResultCode.CONFIRMED || code == ResultCode.ALREADY_CONFIRMED;
        }
    }

    /** Phân loại thuần (không chạm DB) cho trạng thái booking hiện tại - tách riêng để kiểm thử. */
    enum StatusOutcome { ALREADY_CONFIRMED, CANCELLED, UNEXPECTED, ELIGIBLE }

    static StatusOutcome classifyStatus(String trangThai) {
        if ("Đã xác nhận".equals(trangThai)) return StatusOutcome.ALREADY_CONFIRMED;
        if ("Đã hủy".equals(trangThai)) return StatusOutcome.CANCELLED;
        if ("Chờ thanh toán".equals(trangThai) || "Quá hạn".equals(trangThai)) return StatusOutcome.ELIGIBLE;
        return StatusOutcome.UNEXPECTED;
    }

    public Result confirmPaid(int datSanId, BigDecimal amountPaid, String transactionCode) {
        try (Connection c = DBUtil.getConnection()) {
            c.setAutoCommit(false);
            try {
                String status;
                BigDecimal expected;
                int khachHangAccountId;
                try (PreparedStatement ps = c.prepareStatement(
                        "SELECT status, estimated_total, account_id FROM bookings WITH (UPDLOCK, ROWLOCK) WHERE booking_id = ?")) {
                    ps.setInt(1, datSanId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            c.rollback();
                            return new Result(ResultCode.NOT_FOUND, null, null);
                        }
                        status = rs.getNString("status");
                        expected = rs.getBigDecimal("estimated_total");
                        khachHangAccountId = rs.getInt("account_id");
                    }
                }

                StatusOutcome outcome = classifyStatus(status);
                switch (outcome) {
                    case ALREADY_CONFIRMED -> {
                        Integer existingId = findMainInvoiceId(c, datSanId);
                        c.commit();
                        return new Result(ResultCode.ALREADY_CONFIRMED, existingId, khachHangAccountId);
                    }
                    case CANCELLED -> {
                        // Booking đã bị hủy tường minh (khách/staff) - KHÔNG tự xác nhận lại. Tiền
                        // đã nhận cần xử lý hoàn tiền thủ công - race hiếm, log để vận hành theo dõi.
                        c.rollback();
                        logger.warn("PAYOS_LEGACY_CONFIRM_CANCELLED datSanId={} amountPaid={} - booking da bi huy nhung thanh toan van den, can hoan tien thu cong", datSanId, amountPaid);
                        return new Result(ResultCode.CANCELLED, null, null);
                    }
                    case UNEXPECTED -> {
                        c.rollback();
                        logger.warn("PAYOS_LEGACY_CONFIRM_UNEXPECTED_STATUS datSanId={} status={}", datSanId, status);
                        return new Result(ResultCode.UNEXPECTED_STATUS, null, null);
                    }
                    case ELIGIBLE -> { /* "Chờ thanh toán" hoặc "Quá hạn" (race: sweep vừa hết hạn
                                          nhưng thanh toán đến đồng thời) - tiếp tục xác nhận bên dưới,
                                          không để mất dấu tiền đã nhận. */ }
                }
                if (expected == null || amountPaid.compareTo(expected) != 0) {
                    c.rollback();
                    logger.warn("PAYOS_LEGACY_AMOUNT_MISMATCH datSanId={} expected={} actual={}", datSanId, expected, amountPaid);
                    return new Result(ResultCode.AMOUNT_MISMATCH, null, null);
                }

                Integer hoaDonId = findMainInvoiceId(c, datSanId);
                // Khách PayOS hiện luôn thanh toán đủ TongTienDuKien (DatSanServlet tạo checkout
                // session cho toàn bộ số tiền, không hỗ trợ đặt cọc một phần) nên nhánh "Đã cọc"
                // hiện không xảy ra trong thực tế, nhưng giữ đúng công thức theo policy chung.
                boolean fullyPaid = amountPaid.compareTo(expected) >= 0;
                String invoiceStatus = fullyPaid ? "Đã thanh toán" : "Đã cọc";

                if (hoaDonId == null) {
                    boolean hasLoaiHoaDon = columnExists(c, "invoices", "invoice_type");
                    String sqlInsert = "INSERT INTO invoices (booking_id, customer_account_id, issued_at, court_total, service_total, parking_fee, discount_amount, grand_total, payment_method, payment_status" +
                            (hasLoaiHoaDon ? ", invoice_type" : "") + ") VALUES (?, ?, GETDATE(), ?, 0, 0, 0, ?, N'PayOS', ?" +
                            (hasLoaiHoaDon ? ", N'MAIN'" : "") + ")";
                    try (PreparedStatement ins = c.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS)) {
                        ins.setInt(1, datSanId);
                        ins.setInt(2, khachHangAccountId);
                        ins.setBigDecimal(3, expected);
                        ins.setBigDecimal(4, expected);
                        ins.setNString(5, invoiceStatus);
                        ins.executeUpdate();
                        try (ResultSet gk = ins.getGeneratedKeys()) {
                            if (gk.next()) hoaDonId = gk.getInt(1);
                        }
                    }
                } else {
                    try (PreparedStatement up = c.prepareStatement(
                            "UPDATE invoices SET payment_status=?, payment_method=N'PayOS', issued_at=GETDATE() " +
                            "WHERE invoice_id=? AND payment_status<>N'Đã thanh toán'")) {
                        up.setNString(1, invoiceStatus);
                        up.setInt(2, hoaDonId);
                        up.executeUpdate();
                    }
                }

                try (PreparedStatement up = c.prepareStatement(
                        "UPDATE bookings SET status=N'Đã xác nhận', deposit_amount=?, payment_method_confirmed=N'PayOS', " +
                        "transaction_code=?, confirmed_at=GETDATE(), confirmed_by=NULL, confirm_source=N'PAYOS_WEBHOOK', " +
                        "note=CONCAT(ISNULL(note,N''), N' [PayOS webhook xác nhận thanh toán thành công]') " +
                        "WHERE booking_id=? AND status IN (N'Chờ thanh toán', N'Quá hạn')")) {
                    up.setBigDecimal(1, amountPaid);
                    up.setString(2, (transactionCode == null || transactionCode.isBlank()) ? null : transactionCode.trim());
                    up.setInt(3, datSanId);
                    if (up.executeUpdate() != 1) {
                        throw new IllegalStateException("Trạng thái booking vừa thay đổi bởi giao dịch khác.");
                    }
                }

                c.commit();
                logger.info("PAYOS_LEGACY_CONFIRMED datSanId={} hoaDonId={} amountPaid={}", datSanId, hoaDonId, amountPaid);
                return new Result(ResultCode.CONFIRMED, hoaDonId, khachHangAccountId);
            } catch (Exception e) {
                c.rollback();
                logger.error("PAYOS_LEGACY_CONFIRM_FAILED datSanId={}", datSanId, e);
                return new Result(ResultCode.DATABASE_ERROR, null, null);
            } finally {
                c.setAutoCommit(true);
            }
        } catch (Exception connEx) {
            logger.error("PAYOS_LEGACY_CONFIRM_FAILED (ket noi DB) datSanId={}", datSanId, connEx);
            return new Result(ResultCode.DATABASE_ERROR, null, null);
        }
    }

    private Integer findMainInvoiceId(Connection c, int datSanId) throws SQLException {
        boolean hasLoaiHoaDon = columnExists(c, "invoices", "invoice_type");
        String sql = "SELECT TOP 1 invoice_id FROM invoices WITH (UPDLOCK, ROWLOCK) WHERE booking_id=?" +
                (hasLoaiHoaDon ? " AND (invoice_type=N'MAIN' OR invoice_type IS NULL)" : "");
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : null;
            }
        }
    }

    private boolean columnExists(Connection conn, String tableName, String columnName) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(?) AND name = ?")) {
            ps.setNString(1, tableName);
            ps.setNString(2, columnName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}
