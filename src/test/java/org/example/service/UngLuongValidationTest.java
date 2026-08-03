package org.example.service;

import org.example.service.manager.UngLuongValidator;
import org.junit.jupiter.api.Test;
import java.math.BigDecimal;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Quy tắc ứng lương (spec §6): số tiền ứng phải > 0 và tổng đã ứng chưa khấu trừ
 * cộng lần ứng này không được vượt HanMucUng trong cấu hình lương.
 */
class UngLuongValidationTest {

    @Test
    void trongHanMuc_hopLe() {
        assertNull(UngLuongValidator.kiemTra(
                new BigDecimal("500000"), new BigDecimal("2000000"), new BigDecimal("1000000")));
    }

    @Test
    void dungBangHanMuc_hopLe() {
        assertNull(UngLuongValidator.kiemTra(
                new BigDecimal("1000000"), new BigDecimal("2000000"), new BigDecimal("1000000")));
    }

    @Test
    void vuotHanMuc_baoLoi() {
        String loi = UngLuongValidator.kiemTra(
                new BigDecimal("1500000"), new BigDecimal("2000000"), new BigDecimal("1000000"));
        assertNotNull(loi);
        assertTrue(loi.contains("hạn mức"), loi);
    }

    @Test
    void soTienKhongDuong_baoLoi() {
        assertNotNull(UngLuongValidator.kiemTra(BigDecimal.ZERO, new BigDecimal("2000000"), BigDecimal.ZERO));
        assertNotNull(UngLuongValidator.kiemTra(new BigDecimal("-1"), new BigDecimal("2000000"), BigDecimal.ZERO));
        assertNotNull(UngLuongValidator.kiemTra(null, new BigDecimal("2000000"), BigDecimal.ZERO));
    }

    /** Manager chưa cấu hình hạn mức (= 0) thì nhân viên chưa được phép ứng. */
    @Test
    void hanMucChuaCauHinh_baoLoi() {
        String loi = UngLuongValidator.kiemTra(new BigDecimal("100000"), BigDecimal.ZERO, BigDecimal.ZERO);
        assertNotNull(loi);
        assertTrue(loi.contains("chưa được cấu hình"), loi);
    }

    @Test
    void hanMucNull_coiNhuChuaCauHinh() {
        assertNotNull(UngLuongValidator.kiemTra(new BigDecimal("100000"), null, BigDecimal.ZERO));
    }
}
