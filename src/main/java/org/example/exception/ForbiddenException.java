package org.example.exception;

/**
 * Tên tiếng Việt: Ngoại lệ bị cấm truy cập / không có quyền hành động.
 *
 * Ý nghĩa:
 * - Được ném ra khi tài khoản đã xác thực nhưng không có quyền thực hiện hành động trên dữ liệu yêu cầu (ví dụ: quản lý cơ sở A cố gắng chỉnh sửa nhân viên của cơ sở B).
 *
 * Ánh xạ HTTP Status:
 * - 403 Forbidden
 */
public class ForbiddenException extends RuntimeException {
    /**
     * Khởi tạo ngoại lệ không có quyền truy cập với thông điệp chi tiết.
     *
     * @param message Thông điệp mô tả lý do từ chối truy cập
     */
    public ForbiddenException(String message) {
        super(message);
    }
}
