package org.example.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import vn.payos.PayOS;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkRequest;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkResponse;

/**
 * Dịch vụ gọi payOS để tạo link thanh toán online cho đơn đặt sân "Chờ thanh toán".
 * PAYOS_CLIENT_ID / PAYOS_API_KEY / PAYOS_CHECKSUM_KEY được PayOS.fromEnv() tự đọc
 * trực tiếp từ biến môi trường — class này không bao giờ đọc/giữ/log giá trị 3 key đó.
 */
public class PayOSService {

    private static final Logger logger = LoggerFactory.getLogger(PayOSService.class);

    private PayOSService() {
    }

    /** Kết quả tạo link thanh toán thành công. */
    public static class PaymentLinkResult {
        public final String checkoutUrl;
        public final String paymentLinkId;
        public final long orderCode;

        public PaymentLinkResult(String checkoutUrl, String paymentLinkId, long orderCode) {
            this.checkoutUrl = checkoutUrl;
            this.paymentLinkId = paymentLinkId;
            this.orderCode = orderCode;
        }
    }

    /** Ném ra khi không thể tạo link thanh toán (thiếu cấu hình PAYOS_*, lỗi mạng, payOS từ chối...). */
    public static class PayOSLinkCreationException extends Exception {
        public PayOSLinkCreationException(String message, Throwable cause) {
            super(message, cause);
        }
    }

    /**
     * Gọi payOS tạo link thanh toán cho 1 đơn đặt sân.
     * amountVnd phải là số nguyên VND (payOS không chấp nhận số thập phân).
     */
    public static PaymentLinkResult createPaymentLink(long orderCode, long amountVnd, String description,
                                                        String returnUrl, String cancelUrl)
            throws PayOSLinkCreationException {
        try {
            PayOS client = PayOS.fromEnv();
            CreatePaymentLinkRequest request = CreatePaymentLinkRequest.builder()
                    .orderCode(orderCode)
                    .amount(amountVnd)
                    .description(description)
                    .returnUrl(returnUrl)
                    .cancelUrl(cancelUrl)
                    .build();
            CreatePaymentLinkResponse response = client.paymentRequests().create(request);
            return new PaymentLinkResult(response.getCheckoutUrl(), response.getPaymentLinkId(), orderCode);
        } catch (Exception e) {
            logger.error("Tạo link thanh toán payOS thất bại (orderCode={}): {}", orderCode, e.getMessage());
            throw new PayOSLinkCreationException("Không thể tạo link thanh toán payOS", e);
        }
    }
}
