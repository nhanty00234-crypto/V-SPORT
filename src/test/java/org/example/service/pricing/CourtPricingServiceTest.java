package org.example.service.pricing;

import org.junit.jupiter.api.Test;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.LocalTime;
import static org.junit.jupiter.api.Assertions.*;

class CourtPricingServiceTest {
    private final CourtPricingService service = new CourtPricingService();
    private static final BigDecimal DAY = new BigDecimal("75000");
    private static final BigDecimal NIGHT = new BigDecimal("100000");

    private CourtPriceResult price(String start, String end, String lightStart, String lightEnd) {
        return service.calculate(LocalDateTime.parse(start), LocalDateTime.parse(end),
                LocalTime.parse(lightStart), LocalTime.parse(lightEnd), DAY, NIGHT);
    }

    @Test void splitsSixteenToNineteen() {
        var r = price("2026-07-15T16:00", "2026-07-15T19:00", "18:00", "23:00");
        assertEquals(new BigDecimal("250000"), r.totalCourtAmount());
        assertEquals(120, r.minutesWithoutLight()); assertEquals(60, r.minutesWithLight()); assertEquals(2, r.segments().size());
    }

    @Test void splitsHalfHourEach() {
        var r = price("2026-07-15T17:30", "2026-07-15T18:30", "18:00", "23:00");
        assertEquals(new BigDecimal("37500"), r.amountWithoutLight());
        assertEquals(new BigDecimal("50000"), r.amountWithLight());
        assertEquals(new BigDecimal("87500"), r.totalCourtAmount());
    }

    @Test void splitsFifteenMinutesEach() {
        assertEquals(new BigDecimal("43750"), price("2026-07-15T17:45", "2026-07-15T18:15", "18:00", "23:00").totalCourtAmount());
    }

    @Test void overnightLightingEndsAtSix() {
        var r = price("2026-07-15T05:00", "2026-07-15T07:00", "18:00", "06:00");
        assertEquals(60, r.minutesWithLight()); assertEquals(60, r.minutesWithoutLight());
    }

    @Test void sessionAcrossMidnightIsAllLit() {
        var r = price("2026-07-15T23:00", "2026-07-16T02:00", "18:00", "06:00");
        assertEquals(180, r.minutesWithLight()); assertEquals(0, r.minutesWithoutLight());
    }

    @Test void missingLightingConfigFallsBackToDayRate() {
        var r = service.calculate(LocalDateTime.parse("2026-07-15T18:00"), LocalDateTime.parse("2026-07-15T19:00"), null, null, DAY, NIGHT);
        assertEquals(new BigDecimal("75000"), r.totalCourtAmount()); assertEquals(60, r.minutesWithoutLight());
    }

    @Test void rejectsInvalidIntervalAndRates() {
        assertThrows(IllegalArgumentException.class, () -> price("2026-07-15T19:00", "2026-07-15T19:00", "18:00", "23:00"));
        assertThrows(IllegalArgumentException.class, () -> service.calculate(LocalDateTime.now(), LocalDateTime.now().plusHours(1), LocalTime.NOON, LocalTime.MIDNIGHT, null, NIGHT));
    }
}