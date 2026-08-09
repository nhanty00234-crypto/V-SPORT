package org.example.security;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * JWT HS256 tối giản, tự hiện thực bằng javax.crypto — KHÔNG thêm dependency mới vào pom.
 *
 * Chỉ dùng cho REST API mobile (/api/v1/*). Web JSP tiếp tục dùng HttpSession/JSESSIONID
 * như cũ — không đụng gì tới authentication của Web.
 *
 * Secret đọc theo thứ tự: env JWT_SECRET → system property jwt.secret. Nếu thiếu, sinh
 * ngẫu nhiên trong bộ nhớ (token mất hiệu lực sau mỗi lần restart Tomcat) và ghi WARN —
 * đủ chạy local dev, nhưng production BẮT BUỘC phải set JWT_SECRET.
 *
 * Không lưu token vào database: access token và refresh token đều stateless (mục XVII
 * spec — không tạo bảng mới nếu không thực sự bắt buộc).
 */
public final class JwtService {

    private static final Logger logger = LogManager.getLogger(JwtService.class);

    public static final String TYPE_ACCESS = "access";
    public static final String TYPE_REFRESH = "refresh";

    /** Access token sống ngắn — mobile tự refresh khi hết hạn. */
    public static final long ACCESS_TTL_SECONDS = 60L * 60;          // 1 giờ
    /** Refresh token sống dài để khách không phải đăng nhập lại mỗi ngày. */
    public static final long REFRESH_TTL_SECONDS = 60L * 60 * 24 * 30; // 30 ngày

    private static final byte[] SECRET = resolveSecret();
    private static final Base64.Encoder B64 = Base64.getUrlEncoder().withoutPadding();
    private static final Base64.Decoder B64D = Base64.getUrlDecoder();

    private JwtService() {}

    private static byte[] resolveSecret() {
        String s = System.getenv("JWT_SECRET");
        if (s == null || s.isBlank()) s = System.getProperty("jwt.secret");
        if (s != null && !s.isBlank()) {
            return s.getBytes(StandardCharsets.UTF_8);
        }
        byte[] random = new byte[64];
        new SecureRandom().nextBytes(random);
        logger.warn("JWT_SECRET chưa được cấu hình — dùng secret ngẫu nhiên trong bộ nhớ. "
                + "Mọi token mobile sẽ mất hiệu lực khi restart. Hãy set env JWT_SECRET ở môi trường thật.");
        return random;
    }

    /** Payload đã xác thực của một token hợp lệ. */
    public static final class Claims {
        public final int accountId;
        public final int roleId;
        public final String type;
        public final long expiresAt; // epoch seconds

        Claims(int accountId, int roleId, String type, long expiresAt) {
            this.accountId = accountId;
            this.roleId = roleId;
            this.type = type;
            this.expiresAt = expiresAt;
        }
    }

    /** Lỗi xác thực token — phân biệt hết hạn với sai chữ ký để mobile biết có nên refresh không. */
    public static class JwtException extends RuntimeException {
        public final boolean expired;
        public JwtException(String message, boolean expired) {
            super(message);
            this.expired = expired;
        }
    }

    public static String issueAccessToken(int accountId, int roleId) {
        return issue(accountId, roleId, TYPE_ACCESS, ACCESS_TTL_SECONDS);
    }

    public static String issueRefreshToken(int accountId, int roleId) {
        return issue(accountId, roleId, TYPE_REFRESH, REFRESH_TTL_SECONDS);
    }

    private static String issue(int accountId, int roleId, String type, long ttlSeconds) {
        long now = System.currentTimeMillis() / 1000L;
        String header = "{\"alg\":\"HS256\",\"typ\":\"JWT\"}";
        JsonObject payload = new JsonObject();
        payload.addProperty("sub", accountId);
        payload.addProperty("role", roleId);
        payload.addProperty("typ", type);
        payload.addProperty("iat", now);
        payload.addProperty("exp", now + ttlSeconds);

        String h = B64.encodeToString(header.getBytes(StandardCharsets.UTF_8));
        String p = B64.encodeToString(payload.toString().getBytes(StandardCharsets.UTF_8));
        String signingInput = h + "." + p;
        return signingInput + "." + B64.encodeToString(hmac(signingInput));
    }

    /**
     * Xác thực chữ ký + hạn dùng và trả claims.
     *
     * @throws JwtException nếu token sai định dạng, sai chữ ký hoặc đã hết hạn.
     */
    public static Claims verify(String token) {
        if (token == null || token.isBlank()) {
            throw new JwtException("Thiếu token.", false);
        }
        String[] parts = token.split("\\.");
        if (parts.length != 3) {
            throw new JwtException("Token không hợp lệ.", false);
        }
        String signingInput = parts[0] + "." + parts[1];
        byte[] expected = hmac(signingInput);
        byte[] actual;
        try {
            actual = B64D.decode(parts[2]);
        } catch (IllegalArgumentException e) {
            throw new JwtException("Token không hợp lệ.", false);
        }
        // MessageDigest.isEqual so sánh constant-time — không rò rỉ thông tin qua timing.
        if (!MessageDigest.isEqual(expected, actual)) {
            throw new JwtException("Token không hợp lệ.", false);
        }

        JsonObject payload;
        try {
            payload = JsonParser.parseString(
                    new String(B64D.decode(parts[1]), StandardCharsets.UTF_8)).getAsJsonObject();
        } catch (RuntimeException e) {
            throw new JwtException("Token không hợp lệ.", false);
        }

        long exp = payload.has("exp") ? payload.get("exp").getAsLong() : 0L;
        if (exp <= System.currentTimeMillis() / 1000L) {
            throw new JwtException("Token đã hết hạn.", true);
        }
        return new Claims(
                payload.get("sub").getAsInt(),
                payload.has("role") ? payload.get("role").getAsInt() : 0,
                payload.has("typ") ? payload.get("typ").getAsString() : TYPE_ACCESS,
                exp);
    }

    private static byte[] hmac(String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(SECRET, "HmacSHA256"));
            return mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
        } catch (Exception e) {
            throw new IllegalStateException("Không thể ký JWT.", e);
        }
    }
}
