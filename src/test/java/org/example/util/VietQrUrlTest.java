package org.example.util;

import org.junit.jupiter.api.Test;
import java.math.BigDecimal;
import static org.junit.jupiter.api.Assertions.*;

class VietQrUrlTest {

    @Test
    void dungDinhDangCompact2VaEncodeThamSo() {
        String url = VietQrUrl.compact2("970436", "1234567890",
                new BigDecimal("5600000"), "Luong thang 7", "NGUYEN VAN A");

        assertTrue(url.startsWith("https://img.vietqr.io/image/970436-1234567890-compact2.png?"), url);
        assertTrue(url.contains("amount=5600000"), url);
        assertTrue(url.contains("addInfo=Luong+thang+7"), url);
        assertTrue(url.contains("accountName=NGUYEN+VAN+A"), url);
    }

    /** Chưa khai báo tài khoản ngân hàng → không dựng được QR, trả null để UI hiện cảnh báo. */
    @Test
    void thieuThongTinNganHang_traVeNull() {
        assertNull(VietQrUrl.compact2(null, "123", BigDecimal.TEN, "x", "A"));
        assertNull(VietQrUrl.compact2("970436", "  ", BigDecimal.TEN, "x", "A"));
    }

    /** Số tiền 0/null vẫn dựng QR được (QR không có sẵn số tiền), chỉ là không kèm amount. */
    @Test
    void soTienNull_khongKemAmount() {
        String url = VietQrUrl.compact2("970436", "123", null, "x", "A");
        assertNotNull(url);
        assertFalse(url.contains("amount="), url);
    }

    /** Ký tự có dấu trong nội dung/tên phải được URL-encode, không làm vỡ URL. */
    @Test
    void noiDungCoDau_duocEncode() {
        String url = VietQrUrl.compact2("970436", "123", BigDecimal.ONE, "Lương tháng 7", "Nguyễn Văn A");
        assertFalse(url.contains(" "), url);
        assertTrue(url.contains("addInfo=L%C6%B0%C6%A1ng"), url);
    }
}
