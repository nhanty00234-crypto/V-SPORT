package org.example.dto.payment;

/**
 * Tên tiếng Việt: Đối tượng chứa thông tin phiên thanh toán PayOS.
 *
 * Nhiệm vụ:
 * - Lưu trữ thông tin kết quả trả về từ PayOS (URL thanh toán, mã QR, thời gian hết hạn, số tiền).
 * - File này đóng vai trò là một DTO (Data Transfer Object) để chuyển dữ liệu từ Service sang Controller.
 *
 * Được gọi bởi:
 * - DatSanServlet.java (createFacilityPayOSLink, per-CoSo credentials)
 *
 * Lưu ý:
 * - Đây là một DTO thuần túy, không chứa logic nghiệp vụ hay truy cập cơ sở dữ liệu.
 */

public class PayOSCheckoutSession {
    public final String checkoutUrl;
    public final String qrCode;
    public final Long expiredAt;
    public final long amount;

    public PayOSCheckoutSession(String checkoutUrl, String qrCode, Long expiredAt, long amount) {
        this.checkoutUrl = checkoutUrl;
        this.qrCode = qrCode;
        this.expiredAt = expiredAt;
        this.amount = amount;
    }
}
