package org.example.service;

import vn.payos.PayOS;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkRequest;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkResponse;
import vn.payos.model.webhooks.WebhookData;
import org.example.dto.payment.PayOSCheckoutSession;

/**
 * Tên tiếng Việt: Dịch vụ tích hợp thanh toán PayOS.
 *
 * Nhiệm vụ:
 * - Khởi tạo kết nối với PayOS SDK sử dụng Client ID, API Key và Checksum Key từ biến môi trường.
 * - Tạo đường dẫn thanh toán (checkoutUrl) hoặc tạo phiên thanh toán đầy đủ chứa QR Code.
 * - Xác thực tính hợp lệ của Webhook gửi từ hệ thống PayOS.
 *
 * Được gọi bởi:
 * - DatSanServlet.java
 * - PayOSWebhookServlet.java
 *
 * Lưu ý:
 * - Không được log thông tin bảo mật (checksum key, api key).
 * - Không thay đổi logic xác thực chữ ký của cổng thanh toán.
 */
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

    /**
     * Nghĩa tiếng Việt: Lấy thể hiện duy nhất (Singleton Instance).
     *
     * Mục đích:
     * - Cung cấp một điểm truy cập duy nhất cho lớp PayOSService trong toàn bộ ứng dụng (Thread-safe Singleton).
     *
     * Input:
     * - Không có
     *
     * Output:
     * - Thể hiện duy nhất của PayOSService
     *
     * Rủi ro:
     * - Thấp. Sử dụng cơ chế Double-Checked Locking đảm bảo an toàn đa luồng.
     */
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
     * Nghĩa tiếng Việt: Tạo đường dẫn thanh toán trực tuyến.
     *
     * Mục đích:
     * - Tạo một đường link thanh toán PayOS đơn giản và lấy URL điều hướng người dùng.
     *
     * Input:
     * - datSanId: ID của đơn đặt sân (sử dụng làm orderCode cho PayOS)
     * - amount: Số tiền cần thanh toán (VND)
     * - description: Nội dung chuyển khoản (tối đa 25 ký tự)
     * - returnUrl: URL quay lại khi khách thanh toán thành công
     * - cancelUrl: URL quay lại khi khách hủy thanh toán
     *
     * Output:
     * - checkoutUrl: Chuỗi đường dẫn để redirect khách sang cổng PayOS
     *
     * Rủi ro:
     * - Trung bình. Lỗi nếu mất kết nối mạng hoặc sai lệch khóa cấu hình API.
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
     * Nghĩa tiếng Việt: Tạo phiên giao dịch thanh toán đầy đủ.
     *
     * Mục đích:
     * - Tạo liên kết thanh toán chi tiết kèm theo thông tin mã QR tĩnh, số tiền và hạn dùng của link QR đó.
     *
     * Input:
     * - datSanId: ID của đơn đặt sân
     * - amount: Số tiền cần thanh toán
     * - description: Nội dung chuyển khoản
     * - returnUrl: URL khi thành công
     * - cancelUrl: URL khi hủy bỏ
     *
     * Output:
     * - PayOSCheckoutSession: DTO chứa checkoutUrl, qrCode, expiredAt, amount
     *
     * Rủi ro:
     * - Trung bình. Cần đảm bảo dữ liệu số tiền lớn hơn 0 và không vượt quá giới hạn giao dịch.
     */
    public PayOSCheckoutSession createCheckoutSession(int datSanId, long amount, String description,
                                                       String returnUrl, String cancelUrl) throws Exception {
        CreatePaymentLinkRequest request = CreatePaymentLinkRequest.builder()
                .orderCode((long) datSanId)
                .amount(amount)
                .description(description)
                .returnUrl(returnUrl)
                .cancelUrl(cancelUrl)
                .build();
        CreatePaymentLinkResponse result = payOS.paymentRequests().create(request);
        return new PayOSCheckoutSession(
                result.getCheckoutUrl(),
                result.getQrCode(),
                result.getExpiredAt(),
                result.getAmount()
        );
    }

    /**
     * Nghĩa tiếng Việt: Xác thực phản hồi giao dịch tự động (Webhook).
     *
     * Mục đích:
     * - Đọc và xác thực tính toàn vẹn của dữ liệu webhook gửi tự động từ PayOS bằng chữ ký HMAC.
     *
     * Input:
     * - rawBody: Chuỗi JSON thô nhận được từ request body của webhook
     *
     * Output:
     * - WebhookData: Dữ liệu giao dịch đã được giải mã và kiểm tra chữ ký thành công
     *
     * Rủi ro:
     * - Cao. Sẽ ném PayOSException nếu dữ liệu bị giả mạo hoặc cấu hình sai CHECKSUM_KEY.
     */
    public WebhookData verifyWebhook(String rawBody) {
        return payOS.webhooks().verify(rawBody);
    }
}
