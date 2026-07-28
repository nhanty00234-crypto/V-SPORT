package org.example.service.customer;

import org.example.model.KhuyenMai;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

class PromotionServiceTest {
    private final PromotionService service = new PromotionService();

    @Test
    @DisplayName("1. Percentage discount calculation (20% off 200,000 = 40,000 discount, 160,000 final)")
    void testPercentageDiscount() {
        KhuyenMai km = new KhuyenMai();
        km.setMaCode("SALE20");
        km.setTrangThai("Hoạt động");
        km.setLoaiGiam("PHAN_TRAM");
        km.setGiaTriGiam(20.0);
        km.setNgayBatDau(LocalDate.now().minusDays(5));
        km.setNgayKetThuc(LocalDate.now().plusDays(5));

        var res = service.calculateDiscount(km, new BigDecimal("200000"), 1, LocalDate.now());
        assertTrue(res.isValid());
        assertEquals(new BigDecimal("40000"), res.getDiscountAmount());
        assertEquals(new BigDecimal("160000"), res.getFinalAmount());
    }

    @Test
    @DisplayName("2. Fixed amount discount calculation (50,000 off 200,000 = 50,000 discount, 150,000 final)")
    void testFixedDiscount() {
        KhuyenMai km = new KhuyenMai();
        km.setMaCode("FIXED50");
        km.setTrangThai("Hoạt động");
        km.setLoaiGiam("CO_DINH");
        km.setGiaTriGiam(50000.0);
        km.setNgayBatDau(LocalDate.now().minusDays(5));
        km.setNgayKetThuc(LocalDate.now().plusDays(5));

        var res = service.calculateDiscount(km, new BigDecimal("200000"), 1, LocalDate.now());
        assertTrue(res.isValid());
        assertEquals(new BigDecimal("50000"), res.getDiscountAmount());
        assertEquals(new BigDecimal("150000"), res.getFinalAmount());
    }

    @Test
    @DisplayName("3. Expired code is rejected")
    void testExpiredCode() {
        KhuyenMai km = new KhuyenMai();
        km.setMaCode("EXPIRED");
        km.setTrangThai("Hoạt động");
        km.setLoaiGiam("PHAN_TRAM");
        km.setGiaTriGiam(10.0);
        km.setNgayBatDau(LocalDate.now().minusDays(10));
        km.setNgayKetThuc(LocalDate.now().minusDays(1));

        var res = service.calculateDiscount(km, new BigDecimal("100000"), 1, LocalDate.now());
        assertFalse(res.isValid());
        assertEquals("Mã khuyến mãi đã hết hạn sử dụng.", res.getMessage());
    }

    @Test
    @DisplayName("4. Code exceeding max usage limit is rejected")
    void testMaxUsageExceeded() {
        KhuyenMai km = new KhuyenMai();
        km.setMaCode("LIMITED");
        km.setTrangThai("Hoạt động");
        km.setLoaiGiam("PHAN_TRAM");
        km.setGiaTriGiam(10.0);
        km.setSoLanToiDa(5);
        km.setSoLanDaDung(5);

        var res = service.calculateDiscount(km, new BigDecimal("100000"), 1, LocalDate.now());
        assertFalse(res.isValid());
        assertEquals("Mã khuyến mãi đã hết lượt sử dụng.", res.getMessage());
    }

    @Test
    @DisplayName("5. Facility mismatch is rejected")
    void testFacilityMismatch() {
        KhuyenMai km = new KhuyenMai();
        km.setMaCode("BRANCH1ONLY");
        km.setTrangThai("Hoạt động");
        km.setLoaiGiam("PHAN_TRAM");
        km.setGiaTriGiam(10.0);
        km.setCoSoID(1);

        var res = service.calculateDiscount(km, new BigDecimal("100000"), 2, LocalDate.now());
        assertFalse(res.isValid());
        assertEquals("Mã khuyến mãi không áp dụng cho cơ sở này.", res.getMessage());
    }
}
