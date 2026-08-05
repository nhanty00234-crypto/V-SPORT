package org.example.service.reset;

public class PasswordResetChallenge {

    public static final long TTL_MS = 10 * 60 * 1000L;
    private static final long RESEND_COOLDOWN_MS = 60_000L;
    private static final int MAX_ATTEMPTS = 5;
    private static final int MAX_SENDS = 5;

    public enum VerifyResult { OK, INVALID, EXPIRED, USED, LOCKED }

    private final String accountEmail;
    private final String maskedEmail;
    private final String role;
    private final boolean decoy;

    private String otp;
    private long issuedAt;
    private long lastSentAt;
    private int attemptCount;
    private int sendCount;
    private boolean used;

    private PasswordResetChallenge(String accountEmail, String maskedEmail, String role,
                                   String otp, long issuedAt, boolean decoy) {
        this.accountEmail = accountEmail;
        this.maskedEmail = maskedEmail;
        this.role = role;
        this.otp = otp;
        this.issuedAt = issuedAt;
        this.lastSentAt = issuedAt;
        this.decoy = decoy;
        this.sendCount = 1;
    }

    public static PasswordResetChallenge create(String accountEmail, String maskedEmail,
                                                 String role, String otp, long nowMs) {
        boolean decoy = (accountEmail == null);
        return new PasswordResetChallenge(accountEmail, maskedEmail, role, otp, nowMs, decoy);
    }

    public VerifyResult verify(String input, long nowMs) {
        if (decoy) return VerifyResult.INVALID;
        if (used) return VerifyResult.USED;
        if (attemptCount >= MAX_ATTEMPTS) return VerifyResult.LOCKED;
        if (nowMs - issuedAt > TTL_MS) return VerifyResult.EXPIRED;
        if (!isValid6Digit(input)) {
            attemptCount++;
            if (attemptCount >= MAX_ATTEMPTS) return VerifyResult.LOCKED;
            return VerifyResult.INVALID;
        }
        if (!otp.equals(input)) {
            attemptCount++;
            if (attemptCount >= MAX_ATTEMPTS) return VerifyResult.LOCKED;
            return VerifyResult.INVALID;
        }
        used = true;
        return VerifyResult.OK;
    }

    public boolean canResend(long nowMs) {
        return sendCount < MAX_SENDS && (nowMs - lastSentAt) >= RESEND_COOLDOWN_MS;
    }

    public long resendWaitSeconds(long nowMs) {
        long waited = nowMs - lastSentAt;
        long remaining = RESEND_COOLDOWN_MS - waited;
        return remaining > 0 ? remaining / 1000 : 0;
    }

    public void applyResend(String newOtp, long nowMs) {
        if (!canResend(nowMs)) throw new IllegalStateException("Resend not allowed yet");
        this.otp = newOtp;
        this.issuedAt = nowMs;
        this.lastSentAt = nowMs;
        this.attemptCount = 0;
        this.used = false;
        this.sendCount++;
    }

    public boolean isUsed() { return used; }
    public boolean isDecoy() { return decoy; }
    public String getAccountEmail() { return accountEmail; }
    public String getMaskedEmail() { return maskedEmail; }
    public String getRole() { return role; }
    public int getAttemptCount() { return attemptCount; }
    public int getSendCount() { return sendCount; }

    private static boolean isValid6Digit(String s) {
        if (s == null || s.length() != 6) return false;
        for (char ch : s.toCharArray()) {
            if (ch < '0' || ch > '9') return false;
        }
        return true;
    }
}
