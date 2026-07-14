package org.example.exception;

/**
 * Tên tiếng Việt: Ngoại lệ xung đột dữ liệu.
 *
 * Ý nghĩa:
 * - Được ném ra khi có sự xung đột về trạng thái dữ liệu (ví dụ: trùng lịch ca làm việc, ca làm đã hoàn thành/hủy không được phép sửa đổi).
 *
 * Ánh xạ HTTP Status:
 * - 409 Conflict
 */
public class ConflictException extends RuntimeException {
    /**
     * Khởi tạo ngoại lệ xung đột với thông điệp chi tiết.
     *
     * @param message Thông điệp mô tả lỗi xung đột dữ liệu
     */
    public ConflictException(String message) {
        super(message);
    }
}
