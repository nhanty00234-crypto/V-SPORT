package org.example.service.checkin;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

import static org.junit.jupiter.api.Assertions.*;

class NoShowEligibilityTest {

    private static final LocalDate TODAY = LocalDate.of(2026, 7, 15);
    private static final LocalTime START = LocalTime.of(10, 0);
    private static final int GRACE = 15;

    @Test void wrongStatus_rejected() {
        var r = NoShowEligibility.check("Chờ xác nhận", TODAY, START, LocalDateTime.of(TODAY, START.plusMinutes(20)), GRACE);
        assertFalse(r.eligible());
        assertEquals(NoShowEligibility.Reason.WRONG_STATUS, r.reason());
    }

    @Test void inUseStatus_rejected_notReusableForCheckedInBooking() {
        var r = NoShowEligibility.check("Đang sử dụng", TODAY, START, LocalDateTime.of(TODAY, START.plusMinutes(20)), GRACE);
        assertFalse(r.eligible());
        assertEquals(NoShowEligibility.Reason.WRONG_STATUS, r.reason());
    }

    @Test void differentDate_rejected() {
        var r = NoShowEligibility.check("Đã xác nhận", TODAY, START,
                LocalDateTime.of(TODAY.plusDays(1), START.plusMinutes(20)), GRACE);
        assertFalse(r.eligible());
        assertEquals(NoShowEligibility.Reason.WRONG_DATE, r.reason());
    }

    @Test void beforeGracePeriodElapsed_rejected() {
        var r = NoShowEligibility.check("Đã xác nhận", TODAY, START, LocalDateTime.of(TODAY, START.plusMinutes(14)), GRACE);
        assertFalse(r.eligible());
        assertEquals(NoShowEligibility.Reason.GRACE_NOT_ELAPSED, r.reason());
    }

    @Test void exactlyAtGraceDeadline_allowed() {
        var r = NoShowEligibility.check("Đã xác nhận", TODAY, START, LocalDateTime.of(TODAY, START.plusMinutes(15)), GRACE);
        assertTrue(r.eligible());
    }

    @Test void afterGracePeriodElapsed_allowed() {
        var r = NoShowEligibility.check("Đã xác nhận", TODAY, START, LocalDateTime.of(TODAY, START.plusMinutes(30)), GRACE);
        assertTrue(r.eligible());
        assertEquals(NoShowEligibility.Reason.OK, r.reason());
        assertNull(r.message());
    }
}
