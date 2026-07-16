package org.example.service.pricing;

import java.math.BigDecimal;
import java.util.List;

public record CourtPriceResult(long totalMinutes, long minutesWithoutLight, long minutesWithLight,
                               BigDecimal amountWithoutLight, BigDecimal amountWithLight,
                               BigDecimal totalCourtAmount, List<CourtPriceSegment> segments) {
    public CourtPriceResult {
        segments = List.copyOf(segments);
    }
}