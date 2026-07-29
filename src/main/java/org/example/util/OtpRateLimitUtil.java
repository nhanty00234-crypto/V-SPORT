package org.example.util;

import java.util.concurrent.ConcurrentHashMap;

/**
 * Utility to manage OTP rate limits, resend counts, and email lockout after multiple failed attempts.
 */
public class OtpRateLimitUtil {

    // Lockout map: Email (lowercase) -> Expiration epoch millis (15 minutes)
    private static final ConcurrentHashMap<String, Long> EMAIL_LOCKOUT_MAP = new ConcurrentHashMap<>();

    public static final long LOCKOUT_DURATION_MS = 15 * 60 * 1000L; // 15 minutes
    public static final int MAX_FAILED_ATTEMPTS = 5;
    public static final int MAX_RESENDS = 5;

    /**
     * Lockout an email address for 15 minutes.
     */
    public static void lockoutEmail(String email) {
        if (email != null && !email.trim().isEmpty()) {
            EMAIL_LOCKOUT_MAP.put(email.trim().toLowerCase(), System.currentTimeMillis() + LOCKOUT_DURATION_MS);
        }
    }

    /**
     * Check if an email is currently locked out due to >5 failed OTP entries.
     */
    public static boolean isEmailLockedOut(String email) {
        if (email == null || email.trim().isEmpty()) return false;
        String key = email.trim().toLowerCase();
        Long expiry = EMAIL_LOCKOUT_MAP.get(key);
        if (expiry == null) return false;
        if (System.currentTimeMillis() > expiry) {
            EMAIL_LOCKOUT_MAP.remove(key);
            return false;
        }
        return true;
    }

    /**
     * Get remaining lockout duration in minutes (rounded up).
     */
    public static long getLockoutRemainingMinutes(String email) {
        if (email == null || email.trim().isEmpty()) return 0;
        Long expiry = EMAIL_LOCKOUT_MAP.get(email.trim().toLowerCase());
        if (expiry == null) return 0;
        long diff = expiry - System.currentTimeMillis();
        if (diff <= 0) return 0;
        return (diff + 59999L) / 60000L;
    }
}
