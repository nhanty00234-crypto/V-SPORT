package org.example.service.payos;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.PayOSPaymentAttemptDAO;
import org.example.dao.impl.PayOSPaymentAttemptDAOImpl;
import org.example.dto.payment.PayOSFinalizeResult;
import org.example.dto.payment.PayOSPaymentAttemptStatus;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;

/**
 * Điểm DUY NHẤT được phép đánh dấu một hóa đơn PayOS là đã thanh toán. Gọi từ
 * PayOSWebhookServlet (sau khi verify chữ ký) và action getPayOSPaymentStatus (sau khi tự
 * gọi API PayOS lấy trạng thái) - không nơi nào khác được UPDATE các cột thanh toán này.
 * Idempotent: gọi nhiều lần với cùng orderCode chỉ áp dụng đúng một lần.
 */
public class PayOSPaymentFinalizationService {
    private static final Logger logger = LogManager.getLogger(PayOSPaymentFinalizationService.class);

    private final PayOSPaymentAttemptDAO attemptDAO = new PayOSPaymentAttemptDAOImpl();

    public PayOSFinalizeResult finalizePaidPayment(long orderCode, long paidAmountVnd, String paymentLinkId,
                                                     String transactionReference, String confirmSource) {
        try (Connection c = DBUtil.getConnection()) {
            c.setAutoCommit(false);
            try {
                PayOSPaymentAttemptDAO.Row attempt = attemptDAO.findByOrderCode(c, orderCode);
                if (attempt == null) {
                    c.rollback();
                    logger.warn("PAYOS_PAYMENT_NOT_FOUND orderCode={}", orderCode);
                    return PayOSFinalizeResult.fail("PAYOS_PAYMENT_NOT_FOUND", "Không tìm thấy giao dịch PayOS.");
                }
                if (attempt.status == PayOSPaymentAttemptStatus.PAID) {
                    c.commit();
                    return PayOSFinalizeResult.ok(attempt.hoaDonId, true);
                }
                if (attempt.status != PayOSPaymentAttemptStatus.PENDING && attempt.status != PayOSPaymentAttemptStatus.CREATING) {
                    c.rollback();
                    String code = attempt.status == PayOSPaymentAttemptStatus.CANCELLED ? "PAYOS_CANCELLED"
                            : attempt.status == PayOSPaymentAttemptStatus.EXPIRED ? "PAYOS_EXPIRED" : "PAYOS_STATUS_CHECK_FAILED";
                    logger.warn("Bỏ qua finalize orderCode={} vì trạng thái hiện tại={}", orderCode, attempt.status);
                    return PayOSFinalizeResult.fail(code, "Giao dịch không ở trạng thái có thể xác nhận.");
                }
                if (attempt.amount.compareTo(BigDecimal.valueOf(paidAmountVnd)) != 0) {
                    c.rollback();
                    logger.warn("PAYOS_AMOUNT_MISMATCH orderCode={} expected={} actual={}", orderCode, attempt.amount, paidAmountVnd);
                    return PayOSFinalizeResult.fail("PAYOS_AMOUNT_MISMATCH", "Số tiền xác nhận không khớp.");
                }

                try (PreparedStatement up = c.prepareStatement(
                        "UPDATE invoices SET payment_status = N'Đã thanh toán', payment_method = N'PayOS', " +
                        "issued_at = GETDATE() WHERE invoice_id = ? AND payment_status <> N'Đã thanh toán'")) {
                    up.setInt(1, attempt.hoaDonId);
                    if (up.executeUpdate() != 1) {
                        c.commit(); // hóa đơn đã được đánh dấu paid bởi đường khác (rất hiếm) - coi là idempotent, không lỗi
                        return PayOSFinalizeResult.ok(attempt.hoaDonId, true);
                    }
                }
                try (PreparedStatement up = c.prepareStatement(
                        "UPDATE bookings SET payment_method_confirmed = N'PayOS', transaction_code = ?, " +
                        "confirmed_at = GETDATE(), confirmed_by = NULL, confirm_source = ? WHERE booking_id = ?")) {
                    up.setString(1, (transactionReference == null || transactionReference.isBlank())
                            ? paymentLinkId : transactionReference.trim());
                    up.setNString(2, confirmSource);
                    up.setInt(3, attempt.datSanId);
                    up.executeUpdate();
                }
                try (PreparedStatement up = c.prepareStatement(
                        "UPDATE bookings SET status = N'Đã hoàn thành' WHERE booking_id = ? AND status = N'Đang sử dụng'")) {
                    up.setInt(1, attempt.datSanId);
                    up.executeUpdate();
                }
                try (PreparedStatement up = c.prepareStatement(
                        "UPDATE courts SET status = N'Sẵn sàng' WHERE court_id = (SELECT court_id FROM bookings WHERE booking_id = ?) AND status = N'Đang sử dụng'")) {
                    up.setInt(1, attempt.datSanId);
                    up.executeUpdate();
                }

                attemptDAO.markPaid(c, orderCode);
                c.commit();
                logger.info("PayOS finalize thành công orderCode={} hoaDonId={} source={}", orderCode, attempt.hoaDonId, confirmSource);
                return PayOSFinalizeResult.ok(attempt.hoaDonId, false);
            } catch (Exception e) {
                c.rollback();
                logger.error("PAYOS_FINALIZE_FAILED orderCode={}", orderCode, e);
                return PayOSFinalizeResult.fail("DATABASE_ERROR", "Không thể xác nhận thanh toán PayOS.");
            } finally {
                c.setAutoCommit(true);
            }
        } catch (Exception connEx) {
            logger.error("PAYOS_FINALIZE_FAILED (kết nối DB) orderCode={}", orderCode, connEx);
            return PayOSFinalizeResult.fail("DATABASE_ERROR", "Không thể kết nối cơ sở dữ liệu.");
        }
    }
}
