package org.example.service.pricing;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.LocalTime;
import static org.junit.jupiter.api.Assertions.*;

class CourtPricingServiceTest {
    private final CourtPricingService service = new CourtPricingService();
    private static final BigDecimal DAY_100K = new BigDecimal("100000");
    private static final BigDecimal NIGHT_150K = new BigDecimal("150000");
    private static final LocalTime LIGHT_START_18 = LocalTime.of(18, 0);
    private static final LocalTime LIGHT_END_23 = LocalTime.of(23, 0);

    private CourtPriceResult price100k150k(String start, String end) {
        return service.calculate(
                LocalDateTime.parse(start),
                LocalDateTime.parse(end),
                LIGHT_START_18,
                LIGHT_END_23,
                DAY_100K,
                NIGHT_150K
        );
    }

    @Test
    @DisplayName("1. 17:00–18:00 (không đèn) = 100.000đ")
    void test1_SeventeenToEighteen_WithoutLight() {
        var r = price100k150k("2026-07-15T17:00", "2026-07-15T18:00");
        assertEquals(new BigDecimal("100000"), r.totalCourtAmount());
        assertEquals(60, r.minutesWithoutLight());
        assertEquals(0, r.minutesWithLight());
    }

    @Test
    @DisplayName("2. 18:00–19:00 (có đèn) = 150.000đ")
    void test2_EighteenToNineteen_WithLight() {
        var r = price100k150k("2026-07-15T18:00", "2026-07-15T19:00");
        assertEquals(new BigDecimal("150000"), r.totalCourtAmount());
        assertEquals(0, r.minutesWithoutLight());
        assertEquals(60, r.minutesWithLight());
    }

    @Test
    @DisplayName("3. 17:30–18:30 (30 phút không đèn + 30 phút có đèn) = 125.000đ")
    void test3_SeventeenThirtyToEighteenThirty_Split() {
        var r = price100k150k("2026-07-15T17:30", "2026-07-15T18:30");
        assertEquals(new BigDecimal("50000"), r.amountWithoutLight());
        assertEquals(new BigDecimal("75000"), r.amountWithLight());
        assertEquals(new BigDecimal("125000"), r.totalCourtAmount());
    }

    @Test
    @DisplayName("4. 17:45–18:15 (15 phút không đèn + 15 phút có đèn) = 62.500đ")
    void test4_SeventeenFortyFiveToEighteenFifteen_Split() {
        var r = price100k150k("2026-07-15T17:45", "2026-07-15T18:15");
        assertEquals(new BigDecimal("25000"), r.amountWithoutLight());                                // 25,000
        assertEquals(new BigDecimal("37500"), r.amountWithLight());                                   // 37,500
        assertEquals(new BigDecimal("62500"), r.totalCourtAmount());                                  // 62,500
    }

    @Test
    @DisplayName("5. 17:00–17:30 (30 phút không đèn) = 50.000đ")
    void test5_SeventeenToSeventeenThirty_WithoutLight() {
        var r = price100k150k("2026-07-15T17:00", "2026-07-15T17:30");
        assertEquals(new BigDecimal("50000"), r.totalCourtAmount());
        assertEquals(30, r.minutesWithoutLight());
        assertEquals(0, r.minutesWithLight());
    }

    @Test
    @DisplayName("6. End <= start bị từ chối")
    void test6_EndBeforeOrEqualStart_Rejects() {
        assertThrows(IllegalArgumentException.class, () -> price100k150k("2026-07-15T18:00", "2026-07-15T18:00"));
        assertThrows(IllegalArgumentException.class, () -> price100k150k("2026-07-15T19:00", "2026-07-15T18:00"));
    }

    @Test
    @DisplayName("7. Thiếu bảng giá bị từ chối rõ ràng")
    void test7_MissingRate_Rejects() {
        assertThrows(IllegalArgumentException.class, () ->
                service.calculate(LocalDateTime.parse("2026-07-15T17:00"), LocalDateTime.parse("2026-07-15T18:00"),
                        LIGHT_START_18, LIGHT_END_23, null, NIGHT_150K));
        assertThrows(IllegalArgumentException.class, () ->
                service.calculate(LocalDateTime.parse("2026-07-15T17:00"), LocalDateTime.parse("2026-07-15T18:00"),
                        LIGHT_START_18, LIGHT_END_23, DAY_100K, null));
    }

    @Test
    @DisplayName("8. Kết quả breakdown cộng lại bằng grand total")
    void test8_BreakdownSumEqualsGrandTotal() {
        var r = price100k150k("2026-07-15T16:15", "2026-07-15T19:45");
        assertEquals(r.totalCourtAmount(), r.amountWithoutLight().add(r.amountWithLight()));
        assertEquals(r.totalMinutes(), r.minutesWithoutLight() + r.minutesWithLight());
    }
}