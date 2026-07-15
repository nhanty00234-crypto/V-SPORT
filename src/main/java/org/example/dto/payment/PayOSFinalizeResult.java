package org.example.dto.payment;

public final class PayOSFinalizeResult {
    private final boolean success;
    private final boolean alreadyPaid;
    private final String code;
    private final String message;
    private final Integer hoaDonId;

    private PayOSFinalizeResult(boolean success, boolean alreadyPaid, String code, String message, Integer hoaDonId) {
        this.success = success;
        this.alreadyPaid = alreadyPaid;
        this.code = code;
        this.message = message;
        this.hoaDonId = hoaDonId;
    }

    public static PayOSFinalizeResult ok(int hoaDonId, boolean alreadyPaid) {
        return new PayOSFinalizeResult(true, alreadyPaid, null, null, hoaDonId);
    }

    public static PayOSFinalizeResult fail(String code, String message) {
        return new PayOSFinalizeResult(false, false, code, message, null);
    }

    public boolean isSuccess() { return success; }
    public boolean isAlreadyPaid() { return alreadyPaid; }
    public String getCode() { return code; }
    public String getMessage() { return message; }
    public Integer getHoaDonId() { return hoaDonId; }
}
