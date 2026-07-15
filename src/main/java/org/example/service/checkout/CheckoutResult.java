package org.example.service.checkout;

import org.example.service.pricing.CourtPriceSegment;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * depositAmount/remainingAmount dùng chung công thức PaymentCalculator.remainingAmount
 * (tongThanhToan - depositAmount) - nguồn duy nhất cho "còn phải trả" trên mọi phương thức.
 */
public record CheckoutResult(int datSanId, int hoaDonId, LocalDateTime actualEndAt,
                             BigDecimal tongTienSan, BigDecimal tongTienDichVu,
                             BigDecimal phiGuiXe, BigDecimal giamGia, BigDecimal tongThanhToan,
                             BigDecimal depositAmount, BigDecimal remainingAmount,
                             List<CourtPriceSegment> segments, boolean alreadyPaid) {
}