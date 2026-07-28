package org.example.service.booking;

import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.example.service.booking.CancelDecision.CancelType.EARLY_CANCEL;
import static org.example.service.booking.CancelDecision.CancelType.MID_CANCEL;
import static org.example.service.booking.CancelDecision.CancelType.LATE_CANCEL;
import static org.junit.jupiter.api.Assertions.assertEquals;

class CancelDecisionTest {

    private static final LocalDateTime START = LocalDateTime.of(2026, 7, 20, 18, 0);

    @Test
    void moreThan24HoursRemaining_isEarly() {
        LocalDateTime now = START.minusHours(25);
        assertEquals(EARLY_CANCEL, CancelDecision.decide(now, START));
    }

    @Test
    void between6And24HoursRemaining_isMid() {
        LocalDateTime now = START.minusHours(7);
        assertEquals(MID_CANCEL, CancelDecision.decide(now, START));
    }

    @Test
    void exactlyThresholdHoursRemaining_isLate() {
        LocalDateTime now = START.minusHours(6);
        assertEquals(LATE_CANCEL, CancelDecision.decide(now, START));
    }

    @Test
    void oneMinuteInsideThreshold_isLate() {
        LocalDateTime now = START.minusHours(6).plusMinutes(1);
        assertEquals(LATE_CANCEL, CancelDecision.decide(now, START));
    }

    @Test
    void afterBookingStart_isLate() {
        LocalDateTime now = START.plusHours(1);
        assertEquals(LATE_CANCEL, CancelDecision.decide(now, START));
    }
}
