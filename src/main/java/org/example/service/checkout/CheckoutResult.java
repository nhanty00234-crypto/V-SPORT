package org.example.service.checkout;

import org.example.service.pricing.CourtPriceSegment;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public record CheckoutResult(int datSanId, int hoaDonId, LocalDateTime actualEndAt,
                             BigDecimal tongTienSan, BigDecimal tongTienDichVu,
                             BigDecimal phiGuiXe, BigDecimal giamGia, BigDecimal tongThanhToan,
                             List<CourtPriceSegment> segments, boolean alreadyPaid) {
}