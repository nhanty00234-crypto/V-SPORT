package org.example.util;

import org.example.model.CaLamViec;

/**
 * Quy tắc ca làm việc nào được hiển thị cho nhân viên.
 *
 * Trước đây lớp này còn giữ khung giờ điểm danh vào ca; từ khi bỏ điểm danh
 * khuôn mặt, nhân viên chỉ xem lịch ca của mình nên phần đó không còn dùng tới.
 */
public final class AttendanceWindow {

    private AttendanceWindow() {}

    /**
     * Ca có hiện cho nhân viên (Lễ tân) thấy không.
     *
     * Không dùng riêng cột IsPublished: trong dữ liệu thực tế nó lệch với TrangThai
     * — có ca TrangThai='Published' nhưng IsPublished=0, khiến nhân viên không thấy
     * ca dù quản lý đã chọn "Đã gửi (Nhân viên thấy)". TrangThai mới là thứ màn hình
     * quản lý điều khiển, nên lấy nó làm chuẩn và coi IsPublished là tín hiệu phụ.
     */
    public static boolean visibleToStaff(CaLamViec ca) {
        return ca != null && (ca.isPublished() || !"Draft".equals(ca.getTrangThai()));
    }
}
