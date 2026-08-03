package org.example.util;

import org.junit.jupiter.api.Test;
import java.math.BigDecimal;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Khoá lại công thức lương của spec §4:
 *   TongPhuCap    = PhuCapMoiCa × SoCaLamViec
 *   TongLuongThuc = LuongCoBan + TongPhuCap − TongKhauTru
 * Tiền VND: luôn là số nguyên, không âm.
 */
class LuongCalculatorTest {

    @Test
    void phuCap_nhanDungSoCa() {
        assertEquals(new BigDecimal("600000"),
                LuongCalculator.tongPhuCap(new BigDecimal("50000"), 12));
    }

    @Test
    void phuCap_khongCoCa_traVeZero() {
        assertEquals(BigDecimal.ZERO, LuongCalculator.tongPhuCap(new BigDecimal("50000"), 0));
    }

    @Test
    void phuCap_phuCapNull_traVeZero() {
        assertEquals(BigDecimal.ZERO, LuongCalculator.tongPhuCap(null, 12));
    }

    @Test
    void phuCap_soCaAm_bikhongChapNhan() {
        assertThrows(IllegalArgumentException.class,
                () -> LuongCalculator.tongPhuCap(new BigDecimal("50000"), -1));
    }

    @Test
    void luongThuc_congPhuCapTruKhauTru() {
        assertEquals(new BigDecimal("5600000"),
                LuongCalculator.tongLuongThuc(
                        new BigDecimal("5000000"), new BigDecimal("1000000"), new BigDecimal("400000")));
    }

    /** Ứng nhiều hơn lương: thực nhận kẹp về 0, KHÔNG trả số âm (manager không chuyển tiền âm). */
    @Test
    void luongThuc_khauTruVuotLuong_kepVeZero() {
        assertEquals(BigDecimal.ZERO,
                LuongCalculator.tongLuongThuc(
                        new BigDecimal("2000000"), BigDecimal.ZERO, new BigDecimal("3000000")));
    }

    @Test
    void luongThuc_thamSoNull_coiNhuZero() {
        assertEquals(new BigDecimal("1000000"),
                LuongCalculator.tongLuongThuc(new BigDecimal("1000000"), null, null));
    }

    /** VND không có phần lẻ — chuẩn hoá về số nguyên. */
    @Test
    void chuanHoa_lamTronVeSoNguyen() {
        assertEquals(new BigDecimal("1235"), LuongCalculator.chuanHoa(new BigDecimal("1234.6")));
        assertEquals(BigDecimal.ZERO, LuongCalculator.chuanHoa(null));
    }
}
