package org.example.service.invoice;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** Một khung giờ tính tiền sân (có đèn/không đèn) đã CHỐT trên hóa  đơn, dùng chung cho bill in và modal thanh toán. */
public class InvoiceCourtSegmentView {
    private final LocalDateTime startAt;
    private final LocalDateTime endAt;
    private final long durationMinutes;
    private final String rateType;
    private final String rateLabel;
    private final BigDecimal hourlyRate;
    private final BigDecimal amount;

    public InvoiceCourtSegmentView(LocalDateTime startAt, LocalDateTime endAt, long durationMinutes,
                                    String rateType, String rateLabel, BigDecimal hourlyRate, BigDecimal amount) {
        this.startAt = startAt;
        this.endAt = endAt;
        this.durationMinutes = durationMinutes;
        this.rateType = rateType;
        this.rateLabel = rateLabel;
        this.hourlyRate = hourlyRate;
        this.amount = amount;
    }

    public LocalDateTime getStartAt() { return startAt; }
    public LocalDateTime getEndAt() { return endAt; }
    public long getDurationMinutes() { return durationMinutes; }
    public String getRateType() { return rateType; }
    public String getRateLabel() { return rateLabel; }
    public BigDecimal getHourlyRate() { return hourlyRate; }
    public BigDecimal getAmount() { return amount; }
}
