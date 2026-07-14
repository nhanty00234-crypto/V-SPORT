package org.example.exception;

/**
 * Tên tiếng Việt: Ngoại lệ không tìm thấy tài nguyên.
 *
 * Ý nghĩa:
 * - Được ném ra khi tài nguyên yêu cầu không tồn tại trong hệ thống (ví dụ: truy vấn ca làm việc, nhân viên hoặc sân thi đấu với ID không tồn tại).
 *
 * Ánh xạ HTTP Status:
 * - 404 Not Found
 */
public class NotFoundException extends RuntimeException {
    /**
     * Khởi tạo ngoại lệ không tìm thấy tài nguyên với thông điệp chi tiết.
     *
     * @param message Thông điệp mô tả tài nguyên không tìm thấy
     */
    public NotFoundException(String message) {
        super(message);
    }
}
