package org.example.service.customer;

import jakarta.persistence.EntityManager;
import org.example.model.KhuyenMai;
import org.example.util.JPAUtil;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;

public class PromotionService {

    public static class PromotionResult {
        private final boolean valid;
        private final String message;
        private final BigDecimal discountAmount;
        private final BigDecimal finalAmount;
        private final KhuyenMai khuyenMai;

        public PromotionResult(boolean valid, String message, BigDecimal discountAmount, BigDecimal finalAmount, KhuyenMai khuyenMai) {
            this.valid = valid;
            this.message = message;
            this.discountAmount = discountAmount;
            this.finalAmount = finalAmount;
            this.khuyenMai = khuyenMai;
        }

        public boolean isValid() { return valid; }
        public String getMessage() { return message; }
        public BigDecimal getDiscountAmount() { return discountAmount; }
        public BigDecimal getFinalAmount() { return finalAmount; }
        public KhuyenMai getKhuyenMai() { return khuyenMai; }
    }

    /**
     * Calc promo discount pure logic (without DB dependency for easy unit testing)
     */
    public PromotionResult calculateDiscount(KhuyenMai km, BigDecimal originalAmount, Integer coSoId, LocalDate bookingDate) {
        if (km == null) {
            return new PromotionResult(false, "Mã khuyến mãi không tồn tại.", BigDecimal.ZERO, originalAmount, null);
        }
        if (!"Hoạt động".equalsIgnoreCase(km.getTrangThai()) && !"ACTIVE".equalsIgnoreCase(km.getTrangThai())) {
            return new PromotionResult(false, "Mã khuyến mãi hiện không khả dụng.", BigDecimal.ZERO, originalAmount, km);
        }
        if (bookingDate != null) {
            if (km.getNgayBatDau() != null && bookingDate.isBefore(km.getNgayBatDau())) {
                return new PromotionResult(false, "Mã khuyến mãi chưa đến thời gian áp dụng.", BigDecimal.ZERO, originalAmount, km);
            }
            if (km.getNgayKetThuc() != null && bookingDate.isAfter(km.getNgayKetThuc())) {
                return new PromotionResult(false, "Mã khuyến mãi đã hết hạn sử dụng.", BigDecimal.ZERO, originalAmount, km);
            }
        }
        if (km.getCoSoID() != null && coSoId != null && !km.getCoSoID().equals(coSoId)) {
            return new PromotionResult(false, "Mã khuyến mãi không áp dụng cho cơ sở này.", BigDecimal.ZERO, originalAmount, km);
        }
        if (km.getSoLanToiDa() != null && km.getSoLanDaDung() >= km.getSoLanToiDa()) {
            return new PromotionResult(false, "Mã khuyến mãi đã hết lượt sử dụng.", BigDecimal.ZERO, originalAmount, km);
        }

        BigDecimal discount = BigDecimal.ZERO;
        String loaiGiam = km.getLoaiGiam() != null ? km.getLoaiGiam().trim().toUpperCase() : "";

        if (loaiGiam.contains("PERCENT") || loaiGiam.contains("PHAN_TRAM") || loaiGiam.contains("%")) {
            BigDecimal rate = BigDecimal.valueOf(km.getGiaTriGiam()).divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
            discount = originalAmount.multiply(rate).setScale(0, RoundingMode.HALF_UP);
        } else {
            discount = BigDecimal.valueOf(km.getGiaTriGiam()).setScale(0, RoundingMode.HALF_UP);
        }

        if (discount.compareTo(originalAmount) > 0) {
            discount = originalAmount;
        }

        BigDecimal finalAmount = originalAmount.subtract(discount);
        return new PromotionResult(true, "Áp dụng mã khuyến mãi thành công!", discount, finalAmount, km);
    }

    public PromotionResult validateAndCalculate(String maCode, BigDecimal originalAmount, Integer coSoId, LocalDate bookingDate) {
        if (maCode == null || maCode.trim().isEmpty()) {
            return new PromotionResult(false, "Mã khuyến mãi rỗng.", BigDecimal.ZERO, originalAmount, null);
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<KhuyenMai> list = em.createQuery("SELECT k FROM KhuyenMai k WHERE LOWER(k.MaCode) = :code", KhuyenMai.class)
                    .setParameter("code", maCode.trim().toLowerCase())
                    .getResultList();

            if (list.isEmpty()) {
                return new PromotionResult(false, "Mã khuyến mãi không hợp lệ.", BigDecimal.ZERO, originalAmount, null);
            }

            KhuyenMai km = list.get(0);
            return calculateDiscount(km, originalAmount, coSoId, bookingDate);
        } finally {
            em.close();
        }
    }
}
