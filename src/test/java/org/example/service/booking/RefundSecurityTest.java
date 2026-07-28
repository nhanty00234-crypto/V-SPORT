package org.example.service.booking;

import org.example.util.Constants;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class RefundSecurityTest {

    @Test
    @DisplayName("1. Unpaid pending booking is cancellable by customer")
    void testUnpaidPendingIsCancellable() {
        assertTrue(BookingCancellationService.isCancellableStatus(Constants.TRANG_THAI_DAT_SAN_CHO_XAC_NHAN));
        assertTrue(BookingCancellationService.isCancellableStatus(Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN));
    }

    @Test
    @DisplayName("2. Confirmed booking is cancellable (unless online paid, which is blocked at service level)")
    void testConfirmedIsCancellableStatus() {
        assertTrue(BookingCancellationService.isCancellableStatus(Constants.TRANG_THAI_DAT_SAN_DA_XAC_NHAN));
    }

    @Test
    @DisplayName("3. Active or completed booking cannot be cancelled for refund")
    void testActiveOrCompletedCannotBeCancelled() {
        assertFalse(BookingCancellationService.isCancellableStatus(Constants.TRANG_THAI_DAT_SAN_DANG_SU_DUNG));
        assertFalse(BookingCancellationService.isCancellableStatus(Constants.TRANG_THAI_DAT_SAN_DA_HOAN_THANH));
        assertFalse(BookingCancellationService.isCancellableStatus(Constants.TRANG_THAI_DAT_SAN_KHONG_DEN));
    }

    @Test
    @DisplayName("4. Early, Mid, and Late cancellation thresholds are correctly calculated")
    void testCancellationTypeDecision() {
        var now = java.time.LocalDateTime.of(2026, 7, 28, 10, 0);
        var earlyBooking = java.time.LocalDateTime.of(2026, 7, 29, 16, 0); // 30 hrs away (> 24 hrs)
        var midBooking = java.time.LocalDateTime.of(2026, 7, 28, 20, 0);   // 10 hrs away (6 to 24 hrs)
        var lateBooking = java.time.LocalDateTime.of(2026, 7, 28, 12, 0);  // 2 hrs away (< 6 hrs)

        assertEquals(CancelDecision.CancelType.EARLY_CANCEL, CancelDecision.decide(now, earlyBooking, 6, 24));
        assertEquals(CancelDecision.CancelType.MID_CANCEL, CancelDecision.decide(now, midBooking, 6, 24));
        assertEquals(CancelDecision.CancelType.LATE_CANCEL, CancelDecision.decide(now, lateBooking, 6, 24));
    }
}
