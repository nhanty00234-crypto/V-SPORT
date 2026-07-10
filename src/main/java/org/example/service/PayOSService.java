package org.example.service;

import vn.payos.PayOS;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkRequest;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkResponse;
import vn.payos.model.webhooks.WebhookData;

public class PayOSService {

    private static volatile PayOSService instance;
    private final PayOS payOS;

    private PayOSService() {
        String clientId = System.getenv("PAYOS_CLIENT_ID");
        String apiKey = System.getenv("PAYOS_API_KEY");
        String checksumKey = System.getenv("PAYOS_CHECKSUM_KEY");
        if (clientId == null || apiKey == null || checksumKey == null) {
            throw new IllegalStateException(
                "Thiếu cấu hình PayOS. Cần đặt biến môi trường: PAYOS_CLIENT_ID, PAYOS_API_KEY, PAYOS_CHECKSUM_KEY");
        }
        this.payOS = new PayOS(clientId, apiKey, checksumKey);
    }

    public static PayOSService getInstance() {
        if (instance == null) {
            synchronized (PayOSService.class) {
                if (instance == null) {
                    instance = new PayOSService();
                }
            }
        }
        return instance;
    }

    /**
     * Tạo payment link PayOS và trả về checkoutUrl để redirect customer.
     *
     * @param datSanId  ID booking (dùng làm orderCode)
     * @param amount    Tổng tiền (VND, nguyên)
     * @param description Mô tả ngắn tối đa 25 ký tự
     * @param returnUrl URL trả về sau khi thanh toán thành công
     * @param cancelUrl URL trả về nếu khách hủy thanh toán
     * @return checkoutUrl PayOS để redirect
     */
    public String createCheckoutUrl(int datSanId, long amount, String description,
                                    String returnUrl, String cancelUrl) throws Exception {
        CreatePaymentLinkRequest request = CreatePaymentLinkRequest.builder()
                .orderCode((long) datSanId)
                .amount(amount)
                .description(description)
                .returnUrl(returnUrl)
                .cancelUrl(cancelUrl)
                .build();
        CreatePaymentLinkResponse result = payOS.paymentRequests().create(request);
        return result.getCheckoutUrl();
    }

    /**
     * Xác thực webhook PayOS bằng SDK (kiểm tra chữ ký HMAC nội bộ).
     * Ném vn.payos.exception.PayOSException (unchecked) nếu chữ ký không hợp lệ.
     *
     * @param rawBody raw JSON body của request webhook
     * @return WebhookData đã được xác thực (orderCode, amount, code, ...)
     */
    public WebhookData verifyWebhook(String rawBody) {
        return payOS.webhooks().verify(rawBody);
    }
}
