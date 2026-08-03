package org.example.util;

import org.example.model.CaLamViec;

import java.time.LocalDate;
import java.time.LocalTime;

/**
 * Khung giờ hợp lệ để điểm danh vào ca, dùng chung cho mọi đường vào
 * (điểm danh khuôn mặt, điểm danh thủ công của Lễ tân và Bảo vệ).
 *
 * Giữ ở một chỗ để client và server không lệch nhau — client chỉ ẩn/hiện nút
 * cho dễ nhìn, còn đây mới là chốt chặn thật.
 */
public final class AttendanceWindow {

    /** Điểm danh mở sớm bao nhiêu phút trước giờ bắt đầu ca. */
    public static final int OPEN_BEFORE_MINUTES = 15;

    /**
     * Điểm danh đóng bao nhiêu phút sau giờ bắt đầu ca. Để rộng 60 phút vì chặn
     * quá sớm sẽ khiến người đi muộn do sự cố không thể vào ca, ca bị ghi nhận
     * như vắng mặt dù họ có mặt thật.
     */
    public static final int CLOSE_AFTER_MINUTES = 60;

    private AttendanceWindow() {}

    /**
     * Ca có hiện cho nhân viên (Lễ tân / Bảo vệ) thấy không.
     *
     * Không dùng riêng cột IsPublished: trong dữ liệu thực tế nó lệch với TrangThai
     * — có ca TrangThai='Published' nhưng IsPublished=0, khiến nhân viên không thấy
     * ca dù quản lý đã chọn "Đã gửi (Nhân viên thấy)". TrangThai mới là thứ màn hình
     * quản lý điều khiển, nên lấy nó làm chuẩn và coi IsPublished là tín hiệu phụ.
     */
    public static boolean visibleToStaff(CaLamViec ca) {
        return ca != null && (ca.isPublished() || !"Draft".equals(ca.getTrangThai()));
    }

    /**
     * Kiểm tra ca có đang trong khung giờ điểm danh vào ca không.
     *
     * @return null nếu hợp lệ, ngược lại là thông báo lỗi hiển thị cho người dùng.
     */
    public static String validateCheckIn(CaLamViec ca) {
        if (ca == null) return "Ca làm việc không tồn tại.";
        if (ca.getNgayLam() == null || ca.getGioBatDau() == null) {
            return "Ca làm việc thiếu thông tin thời gian.";
        }

        if (!LocalDate.now().equals(ca.getNgayLam())) {
            return "Chưa đến ngày làm việc của bạn — ca này vào ngày " + ca.getNgayLam() + ".";
        }

        LocalTime open = ca.getGioBatDau().minusMinutes(OPEN_BEFORE_MINUTES);
        LocalTime close = ca.getGioBatDau().plusMinutes(CLOSE_AFTER_MINUTES);
        LocalTime now = LocalTime.now();

        if (now.isBefore(open)) {
            return "Chưa đến giờ điểm danh — mở lúc " + hhmm(open)
                    + " (trước giờ vào ca " + OPEN_BEFORE_MINUTES + " phút).";
        }
        if (now.isAfter(close)) {
            return "Đã quá giờ điểm danh — hạn cuối là " + hhmm(close)
                    + ". Liên hệ quản lý để được điểm danh thủ công.";
        }
        return null;
    }

    private static String hhmm(LocalTime t) {
        return String.format("%02d:%02d", t.getHour(), t.getMinute());
    }
}
