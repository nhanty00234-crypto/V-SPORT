package org.example.service.pricing;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record CourtPriceSegment(LocalDateTime segmentStart, LocalDateTime segmentEnd,
                                long durationMinutes, CourtRateType rateType,
                                BigDecimal hourlyRate, BigDecimal amount) {
    // JSP EL (Tomcat's BeanELResolver/java.beans.Introspector) không nhận diện accessor
    // theo tên component của record (vd. segmentStart()) làm property - nó chỉ tìm getXxx()/isXxx().
    // Thiếu các getter này khiến ${seg.segmentStart}... trong HoaDonPrint.jsp ném
    // PropertyNotFoundException giữa lúc render <body>, làm trang hóa đơn trắng sau khi <head> đã flush.
    public LocalDateTime getSegmentStart() { return segmentStart; }
    public LocalDateTime getSegmentEnd() { return segmentEnd; }
    public long getDurationMinutes() { return durationMinutes; }
    public CourtRateType getRateType() { return rateType; }
    public BigDecimal getHourlyRate() { return hourlyRate; }
    public BigDecimal getAmount() { return amount; }
}