package org.example.service.checkin;

import org.example.util.Constants;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * Điều kiện đánh dấu "khách bùng" (no-show), tách riêng thành logic thuần để kiểm thử
 * không cần DB. Áp dụng cho cả thao tác thủ công của lễ tân (CheckInDAO.huyLichKhachBung)
 * và sweep tự động (nếu Constants.NO_SHOW_AUTO_MODE bật).
 */
public final class NoShowEligibility {

    private NoShowEligibility() {
    }

    public enum Reason { OK, WRONG_STATUS, WRONG_DATE, GRACE_NOT_ELAPSED }

    public record Result(boolean eligible, Reason reason, String message) {
        public static Result ok() {
            return new Result(true, Reason.OK, null);
        }

        public static Result reject(Reason reason, String message) {
            return new Result(false, reason, message);
        }
    }

    public static Result check(String trangThai, LocalDate bookingDate, LocalTime gioBatDau, LocalDateTime now) {
        return check(trangThai, bookingDate, gioBatDau, now, Constants.NO_SHOW_GRACE_MINUTES);
    }

    public static Result check(String trangThai, LocalDate bookingDate, LocalTime gioBatDau,
                                LocalDateTime now, int graceMinutes) {
        if (!Constants.TRANG_THAI_DAT_SAN_DA_XAC_NHAN.equals(trangThai)) {
            return Result.reject(Reason.WRONG_STATUS,
                    "Chỉ được đánh dấu khách bùng khi đơn ở trạng thái 'Đã xác nhận' (hiện tại: " + trangThai + ").");
        }
        if (!bookingDate.equals(now.toLocalDate())) {
            return Result.reject(Reason.WRONG_DATE, "Chỉ được đánh dấu khách bùng cho đơn của ngày hôm nay.");
        }
        LocalDateTime graceDeadline = LocalDateTime.of(bookingDate, gioBatDau).plusMinutes(graceMinutes);
        if (now.isBefore(graceDeadline)) {
            return Result.reject(Reason.GRACE_NOT_ELAPSED,
                    "Chưa hết thời gian ân hạn (" + graceMinutes + " phút sau giờ bắt đầu) để đánh dấu khách bùng.");
        }
        return Result.ok();
    }
}
