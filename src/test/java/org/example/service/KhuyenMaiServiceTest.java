package org.example.service;

import org.example.dao.KhuyenMaiDAO;
import org.example.model.KhuyenMai;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class KhuyenMaiServiceTest {

    private KhuyenMaiDAO dao;
    private KhuyenMaiService service;

    private static final int MY_COSO = 10;
    private static final int OTHER_COSO = 99;

    @BeforeEach
    void setUp() {
        dao = Mockito.mock(KhuyenMaiDAO.class);
        service = new KhuyenMaiService(dao);
    }

    // --- Update: wrong facility blocked ---
    @Test
    void update_wrongFacilityBlocked() {
        KhuyenMai km = km(1, OTHER_COSO, 0);
        when(dao.findById(1)).thenReturn(km);
        var r = service.update(1, MY_COSO, "ABC", null, "PhanTram", 10,
                today(), today().plusDays(10), null, "Hoạt động");
        assertFalse(r.success);
        verify(dao, never()).update(any());
    }

    // --- Delete: wrong facility blocked ---
    @Test
    void delete_wrongFacilityBlocked() {
        KhuyenMai km = km(1, OTHER_COSO, 0);
        when(dao.findById(1)).thenReturn(km);
        var r = service.delete(1, MY_COSO);
        assertFalse(r.success);
        verify(dao, never()).delete(anyInt(), anyInt());
    }

    // --- Delete: used code cannot be deleted ---
    @Test
    void delete_usedCodeBlocked() {
        KhuyenMai km = km(1, MY_COSO, 3); // soLanDaDung = 3
        when(dao.findById(1)).thenReturn(km);
        var r = service.delete(1, MY_COSO);
        assertFalse(r.success);
        assertTrue(r.errors.get(0).contains("đã được sử dụng") || r.message.contains("đã được sử dụng"));
        verify(dao, never()).delete(anyInt(), anyInt());
    }

    // --- Delete: unused code of own facility succeeds ---
    @Test
    void delete_unusedCodeSucceeds() {
        KhuyenMai km = km(1, MY_COSO, 0);
        when(dao.findById(1)).thenReturn(km);
        when(dao.delete(1, MY_COSO)).thenReturn(true);
        var r = service.delete(1, MY_COSO);
        assertTrue(r.success);
        verify(dao).delete(1, MY_COSO);
    }

    // --- Validate: PhanTram must be 1–100 ---
    @Test
    void create_phanTramOver100Rejected() {
        when(dao.existsByCode(anyString())).thenReturn(false);
        var r = service.create(MY_COSO, "XMAS", null, "PhanTram", 101,
                today(), today().plusDays(5), null);
        assertFalse(r.success);
        assertTrue(r.errors.stream().anyMatch(e -> e.contains("100") || e.contains("phần trăm") || e.contains("1–100")));
    }

    // --- Validate: SoTien must be > 0 ---
    @Test
    void create_soTienZeroRejected() {
        when(dao.existsByCode(anyString())).thenReturn(false);
        var r = service.create(MY_COSO, "SALE", null, "SoTien", 0,
                today(), today().plusDays(5), null);
        assertFalse(r.success);
    }

    // --- tinhGiamGia: PhanTram correct ---
    @Test
    void tinhGiamGia_phanTramCalculationCorrect() {
        KhuyenMai km = new KhuyenMai();
        km.setLoaiGiam("PhanTram");
        km.setGiaTriGiam(20); // 20%
        double giam = service.tinhGiamGia(km, 100_000);
        assertEquals(20_000, giam, 0.01);
    }

    // --- tinhGiamGia: SoTien correct ---
    @Test
    void tinhGiamGia_soTienCorrect() {
        KhuyenMai km = new KhuyenMai();
        km.setLoaiGiam("SoTien");
        km.setGiaTriGiam(50_000);
        double giam = service.tinhGiamGia(km, 200_000);
        assertEquals(50_000, giam, 0.01);
    }

    // --- tinhGiamGia: discount capped at tongTienGoc, never negative ---
    @Test
    void tinhGiamGia_soTienCappedToTongTienGoc() {
        KhuyenMai km = new KhuyenMai();
        km.setLoaiGiam("SoTien");
        km.setGiaTriGiam(500_000); // bigger than order total
        double giam = service.tinhGiamGia(km, 100_000);
        assertEquals(100_000, giam, 0.01, "Discount capped at original total");
        double afterDiscount = 100_000 - giam;
        assertEquals(0, afterDiscount, 0.01, "Total should not go negative");
    }

    // --- validateCode: null/blank returns null ---
    @Test
    void validateCode_blankCodeReturnsNull() {
        assertNull(service.validateCode(null, MY_COSO));
        assertNull(service.validateCode("  ", MY_COSO));
        verify(dao, never()).findApplicable(any(), anyInt(), any());
    }

    // --- validateCode: expired code (dao returns null) → returns null ---
    @Test
    void validateCode_expiredCodeReturnsNull() {
        when(dao.findApplicable(anyString(), anyInt(), any(LocalDate.class))).thenReturn(null);
        assertNull(service.validateCode("EXPIRED", MY_COSO));
    }

    // --- validateCode: valid code returns KhuyenMai ---
    @Test
    void validateCode_validCodeReturnsKhuyenMai() {
        KhuyenMai km = km(1, MY_COSO, 0);
        when(dao.findApplicable(eq("VALID"), eq(MY_COSO), any(LocalDate.class))).thenReturn(km);
        assertNotNull(service.validateCode("VALID", MY_COSO));
    }

    // --- Duplicate code (same system) rejected ---
    @Test
    void create_duplicateCodeRejected() {
        when(dao.existsByCode("DUP")).thenReturn(true);
        var r = service.create(MY_COSO, "DUP", null, "SoTien", 50_000,
                today(), today().plusDays(5), null);
        assertFalse(r.success);
        assertTrue(r.errors.stream().anyMatch(e -> e.contains("tồn tại") || e.contains("Mã code")));
        verify(dao, never()).insert(any());
    }

    private KhuyenMai km(int id, int coSoId, int soLanDaDung) {
        KhuyenMai km = new KhuyenMai();
        km.setKhuyenMaiID(id);
        km.setCoSoID(coSoId);
        km.setSoLanDaDung(soLanDaDung);
        km.setMaCode("TEST");
        km.setLoaiGiam("SoTien");
        km.setGiaTriGiam(10_000);
        km.setNgayBatDau(today().minusDays(1));
        km.setNgayKetThuc(today().plusDays(30));
        km.setTrangThai("Hoạt động");
        return km;
    }

    private LocalDate today() { return LocalDate.now(); }
}
