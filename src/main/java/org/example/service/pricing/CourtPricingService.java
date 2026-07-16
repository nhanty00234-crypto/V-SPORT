package org.example.service.pricing;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

/** Nguồn sự thật duy nhất cho phép tính tiền sân theo khung giờ thực tế. */
public class CourtPricingService {
    private static final Logger logger = LogManager.getLogger(CourtPricingService.class);
    private static final BigDecimal MINUTES_PER_HOUR = BigDecimal.valueOf(60);

    public CourtPriceResult calculate(LocalDateTime startAt, LocalDateTime endAt,
                                      LocalTime lightingStart, LocalTime lightingEnd,
                                      BigDecimal rateWithoutLight, BigDecimal rateWithLight) {
        if (startAt == null || endAt == null) throw new IllegalArgumentException("Thời gian bắt đầu/kết thúc không được để trống.");
        if (!startAt.isBefore(endAt)) throw new IllegalArgumentException("Thời gian bắt đầu phải nhỏ hơn thời gian kết thúc.");
        validateRate(rateWithoutLight, "Giá không đèn");
        validateRate(rateWithLight, "Giá có đèn");

        boolean fallback = lightingStart == null || lightingEnd == null;
        if (fallback) logger.warn("Thiếu cấu hình giờ bật/tắt đèn; áp dụng giá không đèn cho khoảng {} - {}", startAt, endAt);

        List<CourtPriceSegment> segments = new ArrayList<>();
        LocalDateTime cursor = startAt;
        while (cursor.isBefore(endAt)) {
            CourtRateType type = fallback || !isLighting(cursor.toLocalTime(), lightingStart, lightingEnd)
                    ? CourtRateType.WITHOUT_LIGHT : CourtRateType.WITH_LIGHT;
            LocalDateTime boundary = nextBoundary(cursor, lightingStart, lightingEnd, fallback);
            LocalDateTime segmentEnd = boundary.isBefore(endAt) ? boundary : endAt;
            long minutes = Duration.between(cursor, segmentEnd).toMinutes();
            if (minutes <= 0) throw new IllegalArgumentException("Khoảng tính giá phải có số phút nguyên dương.");
            BigDecimal rate = type == CourtRateType.WITH_LIGHT ? rateWithLight : rateWithoutLight;
            BigDecimal amount = rate.multiply(BigDecimal.valueOf(minutes))
                    .divide(MINUTES_PER_HOUR, 0, RoundingMode.HALF_UP);
            appendOrMerge(segments, new CourtPriceSegment(cursor, segmentEnd, minutes, type, rate, amount));
            cursor = segmentEnd;
        }

        long withoutMinutes = segments.stream().filter(s -> s.rateType() == CourtRateType.WITHOUT_LIGHT).mapToLong(CourtPriceSegment::durationMinutes).sum();
        long withMinutes = segments.stream().filter(s -> s.rateType() == CourtRateType.WITH_LIGHT).mapToLong(CourtPriceSegment::durationMinutes).sum();
        BigDecimal withoutAmount = sum(segments, CourtRateType.WITHOUT_LIGHT);
        BigDecimal withAmount = sum(segments, CourtRateType.WITH_LIGHT);
        return new CourtPriceResult(withoutMinutes + withMinutes, withoutMinutes, withMinutes,
                withoutAmount, withAmount, withoutAmount.add(withAmount).setScale(0, RoundingMode.HALF_UP), segments);
    }

    private static void validateRate(BigDecimal rate, String name) {
        if (rate == null || rate.signum() < 0) throw new IllegalArgumentException(name + " không được null hoặc âm.");
    }

    private static boolean isLighting(LocalTime time, LocalTime start, LocalTime end) {
        if (start.equals(end)) return true; // cấu hình 24 giờ
        if (start.isBefore(end)) return !time.isBefore(start) && time.isBefore(end);
        return !time.isBefore(start) || time.isBefore(end); // qua đêm
    }

    private static LocalDateTime nextBoundary(LocalDateTime cursor, LocalTime start, LocalTime end, boolean fallback) {
        if (fallback || start.equals(end)) return cursor.toLocalDate().plusDays(1).atStartOfDay();
        LocalDate date = cursor.toLocalDate();
        LocalDateTime a = LocalDateTime.of(date, start);
        LocalDateTime b = LocalDateTime.of(date, end);
        LocalDateTime next = null;
        if (a.isAfter(cursor)) next = a;
        if (b.isAfter(cursor) && (next == null || b.isBefore(next))) next = b;
        return next != null ? next : date.plusDays(1).atTime(start.isBefore(end) ? start : end);
    }

    private static void appendOrMerge(List<CourtPriceSegment> list, CourtPriceSegment current) {
        if (!list.isEmpty()) {
            CourtPriceSegment previous = list.get(list.size() - 1);
            if (previous.rateType() == current.rateType() && previous.hourlyRate().compareTo(current.hourlyRate()) == 0
                    && previous.segmentEnd().equals(current.segmentStart())) {
                list.set(list.size() - 1, new CourtPriceSegment(previous.segmentStart(), current.segmentEnd(),
                        previous.durationMinutes() + current.durationMinutes(), previous.rateType(), previous.hourlyRate(),
                        previous.amount().add(current.amount())));
                return;
            }
        }
        list.add(current);
    }

    private static BigDecimal sum(List<CourtPriceSegment> segments, CourtRateType type) {
        return segments.stream().filter(s -> s.rateType() == type).map(CourtPriceSegment::amount)
                .reduce(BigDecimal.ZERO, BigDecimal::add).setScale(0, RoundingMode.HALF_UP);
    }
}