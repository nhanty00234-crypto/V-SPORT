package org.example.api;

/** Mã lỗi ổn định cho client mobile — không đổi giá trị chuỗi sau khi app đã phát hành. */
public final class ApiErrorCode {

    public static final String VALIDATION_ERROR   = "VALIDATION_ERROR";
    public static final String UNAUTHORIZED       = "UNAUTHORIZED";
    public static final String TOKEN_EXPIRED      = "TOKEN_EXPIRED";
    public static final String INVALID_TOKEN      = "INVALID_TOKEN";
    public static final String FORBIDDEN          = "FORBIDDEN";
    public static final String NOT_FOUND          = "NOT_FOUND";
    public static final String CONFLICT           = "CONFLICT";
    public static final String INTERNAL_ERROR     = "INTERNAL_ERROR";

    // Nghiệp vụ
    public static final String INVALID_CREDENTIALS = "INVALID_CREDENTIALS";
    public static final String ACCOUNT_LOCKED      = "ACCOUNT_LOCKED";
    public static final String NOT_CUSTOMER        = "NOT_CUSTOMER";
    public static final String COURT_UNAVAILABLE   = "COURT_UNAVAILABLE";
    public static final String SLOT_TAKEN          = "SLOT_TAKEN";
    public static final String BOOKING_LIMIT       = "BOOKING_LIMIT";
    public static final String REPUTATION_BLOCKED  = "REPUTATION_BLOCKED";
    public static final String PAYMENT_ERROR       = "PAYMENT_ERROR";
    public static final String PAYMENT_CONFLICT    = "PAYMENT_CONFLICT";
    public static final String PROMOTION_INVALID   = "PROMOTION_INVALID";
    public static final String QR_INVALID          = "QR_INVALID";
    public static final String DUPLICATE           = "DUPLICATE";

    private ApiErrorCode() {}
}
