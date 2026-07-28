package org.example.service.customer;

import org.example.model.KhuyenMai;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

class PromotionServiceTest {

    private PromotionService promotionService;
    private KhuyenMai activePercentKM;
    private KhuyenMai activeFixedKM;

    @BeforeEach
    void setUp() {
        promotionService = new PromotionService();

        activePercentKM = new KhuyenMai();
        activePercentKM.setKhuyenMaiID(10);
        activePercentKM.setMaCode("SUMMER20");
        activePercentKM.setLoaiGiam("PERCENT");
        activePercentKM.setGiaTriGiam(20.0); // 20%
        activePercentKM.setNgayBatDau(LocalDate.of(2026, 1, 1));
        activePercentKM.setNgayKetThuc(LocalDate.of(2026, 12, 31));
        activePercentKM.setSoLanToiDa(100);
        activePercentKM.setSoLanDaDung(10);
        activePercentKM.setTrangThai("Hoạt động");
        activePercentKM.setCoSoID(1);

        activeFixedKM = new KhuyenMai();
        activeFixedKM.setKhuyenMaiID(20);
        activeFixedKM.setMaCode("GIAM50K");
        activeFixedKM.setLoaiGiam("FIXED");
        activeFixedKM.setGiaTriGiam(50000.0); // 50,000 VND
        activeFixedKM.setNgayBatDau(LocalDate.of(2026, 1, 1));
        activeFixedKM.setNgayKetThuc(LocalDate.of(2026, 12, 31));
        activeFixedKM.setSoLanToiDa(50);
        activeFixedKM.setSoLanDaDung(5);
        activeFixedKM.setTrangThai("Hoạt động");
    }

    @Test
    void testCalculateDiscountPercentageSuccess() {
        BigDecimal original = new BigDecimal("200000");
        PromotionService.PromotionResult result = promotionService.calculateDiscount(
                activePercentKM, original, 1, LocalDate.of(2026, 7, 28)
        );

        assertTrue(result.isValid());
        assertEquals(new BigDecimal("40000"), result.getDiscountAmount()); // 20% of 200,000 = 40,000
        assertEquals(new BigDecimal("160000"), result.getFinalAmount());
    }

    @Test
    void testCalculateDiscountFixedSuccess() {
        BigDecimal original = new BigDecimal("150000");
        PromotionService.PromotionResult result = promotionService.calculateDiscount(
                activeFixedKM, original, null, LocalDate.of(2026, 7, 28)
        );

        assertTrue(result.isValid());
        assertEquals(new BigDecimal("50000"), result.getDiscountAmount());
        assertEquals(new BigDecimal("100000"), result.getFinalAmount());
    }

    @Test
    void testExpiredPromotionFails() {
        activePercentKM.setNgayKetThuc(LocalDate.of(2026, 5, 1));
        BigDecimal original = new BigDecimal("200000");
        PromotionService.PromotionResult result = promotionService.calculateDiscount(
                activePercentKM, original, 1, LocalDate.of(2026, 7, 28)
        );

        assertFalse(result.isValid());
        assertTrue(result.getMessage().contains("hết hạn"));
        assertEquals(BigDecimal.ZERO, result.getDiscountAmount());
    }

    @Test
    void testFacilityMismatchFails() {
        BigDecimal original = new BigDecimal("200000");
        PromotionService.PromotionResult result = promotionService.calculateDiscount(
                activePercentKM, original, 2, LocalDate.of(2026, 7, 28) // CoSoID 2 != 1
        );

        assertFalse(result.isValid());
        assertTrue(result.getMessage().contains("cơ sở"));
    }

    @Test
    void testMinimumOrderAmountNotMet() {
        BigDecimal original = new BigDecimal("50000");
        BigDecimal minOrder = new BigDecimal("100000");
        PromotionService.PromotionResult result = promotionService.calculateDiscount(
                activePercentKM, original, 1, LocalDate.of(2026, 7, 28), minOrder, null, 0, 1
        );

        assertFalse(result.isValid());
        assertTrue(result.getMessage().contains("100,000"));
    }

    @Test
    void testDiscountCapGiamToiDaApplied() {
        BigDecimal original = new BigDecimal("1000000"); // 20% of 1,000,000 is 200,000
        BigDecimal maxDiscount = new BigDecimal("100000"); // Cap at 100,000
        PromotionService.PromotionResult result = promotionService.calculateDiscount(
                activePercentKM, original, 1, LocalDate.of(2026, 7, 28), null, maxDiscount, 0, 1
        );

        assertTrue(result.isValid());
        assertEquals(new BigDecimal("100000"), result.getDiscountAmount());
        assertEquals(new BigDecimal("900000"), result.getFinalAmount());
    }

    @Test
    void testUserUsageLimitExceeded() {
        BigDecimal original = new BigDecimal("200000");
        PromotionService.PromotionResult result = promotionService.calculateDiscount(
                activePercentKM, original, 1, LocalDate.of(2026, 7, 28), null, null, 1, 1 // User has used 1, max is 1
        );

        assertFalse(result.isValid());
        assertTrue(result.getMessage().contains("hết số lần"));
    }
}
