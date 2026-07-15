package org.example.dao;

import org.example.dto.payment.PayOSPaymentAttemptStatus;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;

public interface PayOSPaymentAttemptDAO {

    final class Row {
        public long attemptId;
        public int hoaDonId;
        public int datSanId;
        public int coSoId;
        public long orderCode;
        public String paymentLinkId;
        public String checkoutUrl;
        public String qrCode;
        public PayOSPaymentAttemptStatus status;
        public BigDecimal amount;
        public String description;
    }

    /** Khóa (UPDLOCK, ROWLOCK) và trả về attempt CREATING/PENDING đang sống cho hóa đơn này, null nếu không có. */
    Row findActiveByHoaDonId(Connection c, int hoaDonId) throws SQLException;

    /** Tạo attempt mới ở trạng thái CREATING, orderCode sinh từ AttemptID (IDENTITY) → duy nhất, truy ngược được. Trả về orderCode. */
    long insertCreating(Connection c, int hoaDonId, int datSanId, int coSoId, BigDecimal amount, String description) throws SQLException;

    /** Sau khi PayOS tạo link thành công: gắn paymentLinkId/checkoutUrl/qrCode, chuyển CREATING -> PENDING. */
    void markPending(Connection c, long orderCode, String paymentLinkId, String checkoutUrl, String qrCode) throws SQLException;

    /** Khóa (UPDLOCK, ROWLOCK) và đọc attempt theo orderCode - dùng bởi finalize/polling/webhook. Null nếu không tồn tại. */
    Row findByOrderCode(Connection c, long orderCode) throws SQLException;

    /** Idempotent: CREATING/PENDING -> PAID. Trả về false nếu đã PAID từ trước (không update lại). */
    boolean markPaid(Connection c, long orderCode) throws SQLException;

    /** CREATING/PENDING -> CANCELLED hoặc EXPIRED (không đụng nếu đã PAID). */
    void markCancelledOrExpired(Connection c, long orderCode, PayOSPaymentAttemptStatus status) throws SQLException;

    void touchLastChecked(Connection c, long orderCode) throws SQLException;
}
