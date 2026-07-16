package org.example.service.checkin;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

import static org.junit.jupiter.api.Assertions.*;

class CheckInWindowTest {

    private static final LocalDate DATE = LocalDate.of(2026, 7, 15);
    private static final LocalTime START = LocalTime.of(10, 0);
    private static final int MAX_EARLY = 30;
    private static final int MAX_LATE = 15;

    @Test void tooEarly_rejected() {
        var r = CheckInWindow.check(DATE, START, LocalDateTime.of(DATE, START.minusMinutes(31)), MAX_EARLY, MAX_LATE);
        assertFalse(r.allowed());
        assertTrue(r.message().contains("Chưa đến giờ"));
    }

    @Test void exactlyAtEarliestAllowed_allowed() {
        var r = CheckInWindow.check(DATE, START, LocalDateTime.of(DATE, START.minusMinutes(30)), MAX_EARLY, MAX_LATE);
        assertTrue(r.allowed());
    }

    @Test void onTime_allowed() {
        var r = CheckInWindow.check(DATE, START, LocalDateTime.of(DATE, START), MAX_EARLY, MAX_LATE);
        assertTrue(r.allowed());
    }

    @Test void exactlyAtLatestAllowed_allowed() {
        var r = CheckInWindow.check(DATE, START, LocalDateTime.of(DATE, START.plusMinutes(15)), MAX_EARLY, MAX_LATE);
        assertTrue(r.allowed());
    }

    @Test void tooLate_rejected_shouldUseNoShowInstead() {
        var r = CheckInWindow.check(DATE, START, LocalDateTime.of(DATE, START.plusMinutes(16)), MAX_EARLY, MAX_LATE);
        assertFalse(r.allowed());
        assertTrue(r.message().contains("khách bùng"));
    }

    @Test void defaultOverload_usesThirtyMinuteEarlyWindow() {
        var r = CheckInWindow.check(DATE, START, LocalDateTime.of(DATE, START.minusMinutes(29)));
        assertTrue(r.allowed());
    }
}
