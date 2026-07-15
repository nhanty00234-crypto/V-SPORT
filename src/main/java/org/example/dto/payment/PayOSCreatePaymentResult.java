package org.example.dto.payment;

public final class PayOSCreatePaymentResult {
    private final boolean success;
    private final int httpStatus;
    private final String code;
    private final String message;
    private final PayOSPaymentAttemptView payment;

    private PayOSCreatePaymentResult(boolean success, int httpStatus, String code, String message,
                                      PayOSPaymentAttemptView payment) {
        this.success = success;
        this.httpStatus = httpStatus;
        this.code = code;
        this.message = message;
        this.payment = payment;
    }

    public static PayOSCreatePaymentResult ok(PayOSPaymentAttemptView payment) {
        return new PayOSCreatePaymentResult(true, 200, null, null, payment);
    }

    public static PayOSCreatePaymentResult fail(int httpStatus, String code, String message) {
        return new PayOSCreatePaymentResult(false, httpStatus, code, message, null);
    }

    public boolean isSuccess() { return success; }
    public int getHttpStatus() { return httpStatus; }
    public String getCode() { return code; }
    public String getMessage() { return message; }
    public PayOSPaymentAttemptView getPayment() { return payment; }
}
