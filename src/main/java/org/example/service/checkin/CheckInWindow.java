package org.example.service.checkin;

import org.example.util.Constants;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * Cửa sổ thời gian hợp lệ để check-in một đơn đặt trước, tách riêng thành logic thuần
 * để kiểm thử không cần DB. Tối đa 30 phút trước giờ bắt đầu; trễ tối đa theo policy no-show
 * (NO_SHOW_GRACE_MINUTES) — sau mốc đó, đơn nên được xử lý bằng no-show thay vì check-in.
 */
public final class CheckInWindow {

    public static final int MAX_EARLY_MINUTES = 30;

    private CheckInWindow() {
    }

    public record Result(boolean allowed, String message) {
        public static Result ok() {
            return new Result(true, null);
        }

        public static Result reject(String message) {
            return new Result(false, message);
        }
    }

    public static Result check(LocalDate bookingDate, LocalTime gioBatDau, LocalDateTime now) {
        return check(bookingDate, gioBatDau, now, MAX_EARLY_MINUTES, Constants.NO_SHOW_GRACE_MINUTES);
    }

    public static Result check(LocalDate bookingDate, LocalTime gioBatDau, LocalDateTime now,
                                int maxEarlyMinutes, int maxLateMinutes) {
        LocalDateTime start = LocalDateTime.of(bookingDate, gioBatDau);
        LocalDateTime earliestAllowed = start.minusMinutes(maxEarlyMinutes);
        LocalDateTime latestAllowed = start.plusMinutes(maxLateMinutes);
        if (now.isBefore(earliestAllowed)) {
            long minutesUntilWindow = Duration.between(now, earliestAllowed).toMinutes();
            return Result.reject("Chưa đến giờ check-in. Chỉ được check-in tối đa " + maxEarlyMinutes +
                    " phút trước giờ bắt đầu (còn " + minutesUntilWindow + " phút nữa).");
        }
        if (now.isAfter(latestAllowed)) {
            return Result.reject("Đã quá " + maxLateMinutes +
                    " phút kể từ giờ bắt đầu. Đơn đủ điều kiện xử lý khách bùng thay vì check-in.");
        }
        return Result.ok();
    }
}
