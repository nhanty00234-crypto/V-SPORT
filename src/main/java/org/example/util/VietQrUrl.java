package org.example.util;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Dựng URL ảnh VietQR động (img.vietqr.io) — cùng định dạng compact2 mà luồng thu tiền
 * tại quầy (CheckInServlet) và hoàn tiền đang dùng, để app ngân hàng quét ra sẵn số tiền
 * và nội dung chuyển khoản.
 */
public final class VietQrUrl {

    private VietQrUrl() {}

    /**
     * @param maNganHang BIN/short code ngân hàng (cột Accounts.MaNganHang), bắt buộc.
     * @param soTaiKhoan số tài khoản (cột Accounts.SoTaiKhoan), bắt buộc.
     * @param soTien     số tiền; null hoặc ≤ 0 thì bỏ tham số amount.
     * @param noiDung    nội dung chuyển khoản, có thể null.
     * @param tenChuTk   tên chủ tài khoản hiển thị, có thể null.
     * @return URL ảnh PNG, hoặc null nếu chưa đủ thông tin ngân hàng.
     */
    public static String compact2(String maNganHang, String soTaiKhoan,
                                  BigDecimal soTien, String noiDung, String tenChuTk) {
        if (isBlank(maNganHang) || isBlank(soTaiKhoan)) return null;

        StringBuilder sb = new StringBuilder("https://img.vietqr.io/image/")
                .append(maNganHang.trim()).append('-')
                .append(soTaiKhoan.trim()).append("-compact2.png?");

        boolean first = true;
        if (soTien != null && soTien.signum() > 0) {
            sb.append("amount=").append(soTien.setScale(0, RoundingMode.HALF_UP).toPlainString());
            first = false;
        }
        if (!isBlank(noiDung)) {
            if (!first) sb.append('&');
            sb.append("addInfo=").append(enc(noiDung));
            first = false;
        }
        if (!isBlank(tenChuTk)) {
            if (!first) sb.append('&');
            sb.append("accountName=").append(enc(tenChuTk));
        }
        return sb.toString();
    }

    private static String enc(String v) {
        return URLEncoder.encode(v, StandardCharsets.UTF_8);
    }

    private static boolean isBlank(String v) {
        return v == null || v.isBlank();
    }
}
