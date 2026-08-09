package org.example.api;

/**
 * Envelope JSON thống nhất cho mọi endpoint /api/v1/*.
 *
 * Thành công: {"success":true,"message":"...","data":{...}}
 * Thất bại:   {"success":false,"message":"...","errorCode":"..."}
 *
 * Field name khớp trực tiếp key JSON (Gson serialize theo field).
 */
public class ApiResponse {

    private final boolean success;
    private final String message;
    private final Object data;
    private final String errorCode;

    private ApiResponse(boolean success, String message, Object data, String errorCode) {
        this.success = success;
        this.message = message;
        this.data = data;
        this.errorCode = errorCode;
    }

    public static ApiResponse ok(Object data) {
        return new ApiResponse(true, null, data, null);
    }

    public static ApiResponse ok(String message, Object data) {
        return new ApiResponse(true, message, data, null);
    }

    public static ApiResponse error(String errorCode, String message) {
        return new ApiResponse(false, message, null, errorCode);
    }

    public boolean isSuccess() { return success; }
    public String getMessage() { return message; }
    public Object getData() { return data; }
    public String getErrorCode() { return errorCode; }
}
