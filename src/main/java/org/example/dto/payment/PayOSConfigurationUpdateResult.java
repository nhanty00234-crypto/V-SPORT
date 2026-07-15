package org.example.dto.payment;

import java.util.Collections;
import java.util.List;

public final class PayOSConfigurationUpdateResult {
    private final boolean success;
    private final int httpStatus;
    private final String message;
    private final PayOSConfigurationStatus status;
    private final List<String> fieldsChanged;

    private PayOSConfigurationUpdateResult(boolean success, int httpStatus, String message,
                                            PayOSConfigurationStatus status, List<String> fieldsChanged) {
        this.success = success;
        this.httpStatus = httpStatus;
        this.message = message;
        this.status = status;
        this.fieldsChanged = fieldsChanged;
    }

    public static PayOSConfigurationUpdateResult ok(PayOSConfigurationStatus status, List<String> fieldsChanged) {
        return new PayOSConfigurationUpdateResult(true, 200, "Đã cập nhật cấu hình PayOS.", status, fieldsChanged);
    }

    public static PayOSConfigurationUpdateResult fail(int httpStatus, String message) {
        return new PayOSConfigurationUpdateResult(false, httpStatus, message, null, Collections.emptyList());
    }

    public boolean isSuccess() { return success; }
    public int getHttpStatus() { return httpStatus; }
    public String getMessage() { return message; }
    public PayOSConfigurationStatus getStatus() { return status; }
    public List<String> getFieldsChanged() { return fieldsChanged; }
}
