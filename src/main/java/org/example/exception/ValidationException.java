package org.example.exception;

/**
 * Tên tiếng Việt: Ngoại lệ kiểm tra tính hợp lệ của dữ liệu.
 *
 * Ý nghĩa:
 * - Được ném ra khi dữ liệu đầu vào vi phạm các quy tắc nghiệp vụ hoặc định dạng (ví dụ: ngày sinh ở tương lai, số điện thoại sai định dạng, thiếu lý do thay đổi ca làm việc).
 *
 * Ánh xạ HTTP Status:
 * - 400 Bad Request
 */
public class ValidationException extends RuntimeException {
    /**
     * Khởi tạo ngoại lệ kiểm tra dữ liệu với thông điệp chi tiết.
     *
     * @param message Thông điệp mô tả chi tiết lỗi nghiệp vụ hoặc định dạng dữ liệu đầu vào
     */
    public ValidationException(String message) {
        super(message);
    }
}
