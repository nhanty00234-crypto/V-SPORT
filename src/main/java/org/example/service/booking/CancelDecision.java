package org.example.service.booking;

import java.time.LocalDateTime;

/**
 * Phân loại hủy booking theo 3 mốc thời gian:
 * - Hủy trước >= 24h: EARLY_CANCEL (Trừ 0 điểm)
 * - Hủy từ 6h đến < 24h: MID_CANCEL (Trừ 5 điểm)
 * - Hủy dưới < 6h: LATE_CANCEL (Trừ 10 điểm)
 */
public final class CancelDecision {

    private CancelDecision() {
    }

    public enum CancelType {
        EARLY_CANCEL,
        MID_CANCEL,
        LATE_CANCEL
    }

    public static CancelType decide(LocalDateTime now, LocalDateTime bookingStart, int lateCancelHours, int midCancelHours) {
        if (!now.plusHours(lateCancelHours).isBefore(bookingStart)) {
            return CancelType.LATE_CANCEL;
        } else if (!now.plusHours(midCancelHours).isBefore(bookingStart)) {
            return CancelType.MID_CANCEL;
        } else {
            return CancelType.EARLY_CANCEL;
        }
    }

    public static CancelType decide(LocalDateTime now, LocalDateTime bookingStart, int lateCancelHours) {
        return decide(now, bookingStart, lateCancelHours, 24);
    }

    public static CancelType decide(LocalDateTime now, LocalDateTime bookingStart) {
        return decide(now, bookingStart, 6, 24);
    }
}
