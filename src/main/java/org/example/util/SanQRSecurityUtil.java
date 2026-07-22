package org.example.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.UUID;

/**
 * Tiện ích thuần (pure) cho bảo mật QR sân (QR-01B): băm token cũ để lưu lịch
 * sử (không giữ plaintext), sinh short code dự phòng khi Customer không quét
 * được QR bằng camera. Cùng phong cách với ResetSecurityUtil (OTP đặt lại mật
 * khẩu) - SecureRandom cho sinh giá trị ngẫu nhiên, SHA-256 cho băm, so sánh
 * constant-time khi đối chiếu hash.
 */
public final class SanQRSecurityUtil {

    private static final SecureRandom RANDOM = new SecureRandom();

    // Bỏ 0/O, 1/I/L khỏi bảng ký tự - đây là nguồn nhầm lẫn phổ biến nhất khi
    // khách đọc mã trên giấy/màn hình rồi gõ tay. 31 ký tự còn lại vẫn cho
    // entropy đủ lớn: 31^6 ≈ 887 triệu tổ hợp cho phần thân 6 ký tự.
    private static final char[] SHORT_CODE_ALPHABET =
            "ABCDEFGHJKMNPQRSTUVWXYZ23456789".toCharArray();
    private static final int SHORT_CODE_BODY_LENGTH = 6;
    private static final String SHORT_CODE_PREFIX = "VS-";

    private SanQRSecurityUtil() {
    }

    /**
     * Sinh short code dạng "VS-7K9P2M" bằng SecureRandom. KHÔNG dùng SanID/thời
     * gian/token - đây là giá trị độc lập hoàn toàn với các định danh khác của
     * sân, để không thể suy ra sân từ mã và ngược lại. Caller (Service layer)
     * chịu trách nhiệm kiểm tra unique trong DB và retry nếu trùng.
     */
    public static String generateShortCode() {
        StringBuilder sb = new StringBuilder(SHORT_CODE_PREFIX.length() + SHORT_CODE_BODY_LENGTH);
        sb.append(SHORT_CODE_PREFIX);
        for (int i = 0; i < SHORT_CODE_BODY_LENGTH; i++) {
            sb.append(SHORT_CODE_ALPHABET[RANDOM.nextInt(SHORT_CODE_ALPHABET.length)]);
        }
        return sb.toString();
    }

    /**
     * Chuẩn hoá short code người dùng nhập trước khi so khớp: không phân biệt
     * hoa/thường, bỏ khoảng trắng thừa. Không tự thêm/bớt prefix "VS-" - caller
     * quyết định chấp nhận nhập có/không có prefix tuỳ UI (task sau).
     */
    public static String normalizeShortCode(String raw) {
        if (raw == null) return null;
        return raw.trim().toUpperCase();
    }

    /** SHA-256(token) dạng hex, không salt - token đã có 122 bit entropy ngẫu nhiên (UUID v4), không cần salt chống rainbow-table như OTP 6 số. */
    public static String hashToken(UUID token) {
        if (token == null) return null;
        return sha256Hex(token.toString());
    }

    /** SHA-256(shortCode đã chuẩn hoá) dạng hex - dùng khi lưu lịch sử short code cũ. */
    public static String hashShortCode(String shortCode) {
        if (shortCode == null) return null;
        return sha256Hex(normalizeShortCode(shortCode));
    }

    /** So sánh constant-time hai chuỗi hex hash - tránh timing attack khi đối chiếu token/short code cũ trong lịch sử. */
    public static boolean hashEquals(String expectedHash, String actualHash) {
        if (expectedHash == null || actualHash == null) return false;
        return MessageDigest.isEqual(
                expectedHash.getBytes(StandardCharsets.UTF_8),
                actualHash.getBytes(StandardCharsets.UTF_8));
    }

    private static String sha256Hex(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(digest.length * 2);
            for (byte b : digest) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 không khả dụng", e);
        }
    }
}
