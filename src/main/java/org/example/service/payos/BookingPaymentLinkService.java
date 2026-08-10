package org.example.service.payos;

import jakarta.servlet.http.HttpSession;
import org.example.dto.payment.PayOSCheckoutSession;
import org.example.dto.payment.PayOSCredentials;
import org.example.dto.payment.PayosQrData;
import org.example.service.PayOSConfigurationService;
import org.example.util.DBUtil;
import org.example.util.TimeUtil;
import vn.payos.PayOS;
import vn.payos.exception.APIException;
import vn.payos.exception.ConnectionException;
import vn.payos.exception.ConnectionTimeoutException;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkRequest;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkResponse;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.time.Instant;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Tạo/tái tạo payment link PayOS cho một booking (orderCode = DatSanID) và lưu snapshot QR.
 *
 * Trước đây logic này nằm trong {@code DatSanServlet} (private methods createFacilityPayOSLink /
 * stashAndPersistQr). Đã hạ xuống Service để Web JSP và REST API mobile dùng CHUNG — mobile
 * KHÔNG có bản sao logic PayOS riêng và KHÔNG bao giờ nhận được secret key (client ID / API key /
 * checksum key chỉ tồn tại phía server, đọc từ DB qua PayOSConfigurationService theo từng cơ sở).
 */
public class BookingPaymentLinkService {

    private static final Logger LOGGER = Logger.getLogger(BookingPaymentLinkService.class.getName());

    public static final String MSG_NOT_CONFIGURED =
            "Thanh toán trực tuyến hiện chưa khả dụng tại cơ sở này. Bạn có thể chọn thanh toán tại quầy.";
    public static final String MSG_PROVIDER_ERROR =
            "PayOS đang tạm thời không phản hồi. Vui lòng thử lại sau hoặc chọn thanh toán tại quầy.";
    public static final String MSG_NETWORK_ERROR =
            "Không thể kết nối đến cổng thanh toán PayOS. Vui lòng thử lại hoặc chọn thanh toán tại quầy.";
    public static final String MSG_EXPIRED =
            "Phiên thanh toán đã hết hạn. Vui lòng tạo lại yêu cầu thanh toán.";
    public static final String MSG_UNKNOWN =
            "Không thể tạo liên kết thanh toán lúc này. Vui lòng thử lại hoặc chọn thanh toán tại quầy.";

    private final PayOSConfigurationService configurationService = new PayOSConfigurationService();

    public static final class LinkResult {
        public final boolean success;
        public final PayOSCheckoutSession session;
        public final String errorCode;
        public final String message;
        public final boolean retryable;

        private LinkResult(boolean success, PayOSCheckoutSession session, String errorCode,
                           String message, boolean retryable) {
            this.success = success;
            this.session = session;
            this.errorCode = errorCode;
            this.message = message;
            this.retryable = retryable;
        }

        public static LinkResult ok(PayOSCheckoutSession session) {
            return new LinkResult(true, session, null, null, false);
        }

        public static LinkResult fail(String errorCode, String message, boolean retryable) {
            return new LinkResult(false, null, errorCode, message, retryable);
        }
    }

    /**
     * Tạo (hoặc hủy link cũ rồi tạo lại) payment link PayOS bằng credentials RIÊNG của cơ sở.
     * Không bao giờ log Client ID / API Key / Checksum Key — chỉ log mã lỗi và trạng thái.
     */
    public LinkResult createLink(int coSoId, long orderCode, long amount, String description,
                                 String returnUrl, String cancelUrl, boolean cancelExistingFirst) {
        PayOSCredentials credentials = configurationService.getCredentialsForPayment(coSoId);
        if (credentials == null) {
            LOGGER.warning(String.format("PAYOS_NOT_CONFIGURED facilityId=%d orderCode=%d", coSoId, orderCode));
            return LinkResult.fail("PAYOS_NOT_CONFIGURED", MSG_NOT_CONFIGURED, false);
        }

        PayOS client = PayOSClientFactory.create(credentials);
        try {
            if (cancelExistingFirst) {
                try {
                    client.paymentRequests().cancel(orderCode, "Khách yêu cầu tạo lại liên kết thanh toán");
                } catch (Exception ignoredNoExistingLink) {
                    // Không có link cũ để hủy - bỏ qua, tiếp tục tạo mới.
                }
            }
            CreatePaymentLinkRequest request = CreatePaymentLinkRequest.builder()
                    .orderCode(orderCode)
                    .amount(amount)
                    .description(description)
                    .returnUrl(returnUrl)
                    .cancelUrl(cancelUrl)
                    .build();
            CreatePaymentLinkResponse result = client.paymentRequests().create(request);
            return LinkResult.ok(new PayOSCheckoutSession(
                    result.getCheckoutUrl(), result.getQrCode(), result.getExpiredAt(), result.getAmount(),
                    result.getBin(), result.getAccountNumber(), result.getAccountName(),
                    result.getDescription(), result.getOrderCode(), result.getPaymentLinkId()));
        } catch (ConnectionTimeoutException | ConnectionException e) {
            logFailure("PAYOS_NETWORK_ERROR", coSoId, orderCode, amount, e, null);
            return LinkResult.fail("PAYOS_NETWORK_ERROR", MSG_NETWORK_ERROR, true);
        } catch (APIException e) {
            Integer status = e.getStatusCode().orElse(null);
            String payosCode = e.getErrorCode().orElse(null);
            String payosDesc = e.getErrorDesc().orElse(null);
            String bucket;
            String customerMsg;
            boolean retryable;
            if (status != null && (status == 401 || status == 403)) {
                bucket = "PAYOS_INVALID_CREDENTIAL"; customerMsg = MSG_PROVIDER_ERROR; retryable = true;
            } else if (status != null && status == 400) {
                boolean looksLikeDuplicateOrderCode = payosDesc != null
                        && (payosDesc.toLowerCase().contains("order") || payosDesc.toLowerCase().contains("code"));
                bucket = looksLikeDuplicateOrderCode ? "PAYOS_DUPLICATE_ORDER_CODE" : "PAYOS_REQUEST_INVALID";
                customerMsg = looksLikeDuplicateOrderCode ? MSG_EXPIRED : MSG_UNKNOWN;
                retryable = !looksLikeDuplicateOrderCode;
            } else if (status != null && (status == 429 || status >= 500)) {
                bucket = "PAYOS_PROVIDER_ERROR"; customerMsg = MSG_PROVIDER_ERROR; retryable = true;
            } else {
                bucket = "PAYOS_PROVIDER_ERROR"; customerMsg = MSG_PROVIDER_ERROR; retryable = true;
            }
            logFailure(bucket, coSoId, orderCode, amount, e,
                    String.format("httpStatus=%s payosErrorCode=%s payosErrorDesc=%s", status, payosCode, payosDesc));
            return LinkResult.fail(bucket, customerMsg, retryable);
        } catch (Exception e) {
            logFailure("PAYOS_UNKNOWN_ERROR", coSoId, orderCode, amount, e, null);
            return LinkResult.fail("PAYOS_UNKNOWN_ERROR", MSG_UNKNOWN, true);
        } finally {
            client.close();
        }
    }

    /** Hủy payment link PayOS còn treo (best-effort); không ném lỗi ra ngoài. */
    public void cancelLinkQuietly(int coSoId, long orderCode, String reason) {
        try {
            PayOSCredentials credentials = configurationService.getCredentialsForPayment(coSoId);
            if (credentials == null) return;
            PayOS client = PayOSClientFactory.create(credentials);
            try {
                client.paymentRequests().cancel(orderCode, reason);
            } finally {
                client.close();
            }
        } catch (Exception ignored) {
            // Không có link treo / PayOS lỗi — state nội bộ vẫn được caller xử lý an toàn.
        }
    }

    /**
     * Lưu snapshot QR cho một booking: (1) HttpSession nếu có (luồng Web, dùng ngay không phụ
     * thuộc migration); (2) best-effort các cột cache trên LichDatSan (bền vững, cũng là nguồn để
     * mobile đọc lại QR khi mở lại app). Bỏ qua êm nếu cột chưa tồn tại. Không bao giờ log payload.
     *
     * @param session có thể null (luồng REST API mobile không có HttpSession).
     */
    public PayosQrData persistQr(HttpSession session, int datSanId, PayOSCheckoutSession s,
                                 long amount, String description) {
        Long orderCode = s.orderCode != null ? s.orderCode : (long) datSanId;
        PayosQrData data = new PayosQrData(datSanId, orderCode, s.paymentLinkId, s.qrCode, s.checkoutUrl,
                s.bin, s.accountNumber, s.accountName, amount, description, s.expiredAt);
        if (session != null) {
            session.setAttribute(PayosQrData.sessionKey(datSanId), data);
        }

        String sql = "UPDATE bookings SET payos_order_code=?, payos_payment_link_id=?, payos_qr_payload=?, "
                + "payos_checkout_url=?, payos_bin=?, payos_account_number=?, payos_account_name=?, payos_amount=?, "
                + "payos_description=?, payos_expires_at=? WHERE booking_id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, orderCode);
            ps.setString(2, s.paymentLinkId);
            ps.setString(3, s.qrCode);
            ps.setString(4, s.checkoutUrl);
            ps.setString(5, s.bin);
            ps.setString(6, s.accountNumber);
            ps.setString(7, s.accountName);
            ps.setBigDecimal(8, BigDecimal.valueOf(amount));
            ps.setString(9, description);
            ps.setTimestamp(10, s.expiredAt != null ? TimeUtil.toDb(Instant.ofEpochSecond(s.expiredAt)) : null);
            ps.setInt(11, datSanId);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.fine("QR cache persist bỏ qua (có thể chưa chạy migration) datSanId=" + datSanId);
        }
        return data;
    }

    private void logFailure(String errorCode, int coSoId, long orderCode, long amount,
                            Exception e, String payosDetail) {
        LOGGER.log(Level.SEVERE, String.format(
                "PAYOS_CREATE_FAILED errorCode=%s facilityId=%d orderCode=%d amount=%d exceptionType=%s%s",
                errorCode, coSoId, orderCode, amount, e.getClass().getSimpleName(),
                payosDetail != null ? " " + payosDetail : ""));
    }
}
