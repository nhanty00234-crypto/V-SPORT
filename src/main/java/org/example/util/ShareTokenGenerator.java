package org.example.util;

import java.security.SecureRandom;
import java.util.Base64;

/**
 * Sinh ShareToken cho NhomChiaTienChiTiet — token phải khó đoán (không dùng ID tăng dần làm
 * link công khai theo yêu cầu spec). Dùng SecureRandom 32 bytes (256 bit entropy) + base64url
 * không padding -> chuỗi 43 ký tự, khớp cột ShareToken CHAR(43) trong migration.
 */
public final class ShareTokenGenerator {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final Base64.Encoder ENCODER = Base64.getUrlEncoder().withoutPadding();

    private ShareTokenGenerator() {
    }

    public static String generate() {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        return ENCODER.encodeToString(bytes);
    }

    /** Rút gọn token khi log — không bao giờ log đầy đủ token (spec mục 13). */
    public static String maskForLog(String token) {
        if (token == null || token.length() < 8) return "***";
        return token.substring(0, 6) + "...";
    }
}
