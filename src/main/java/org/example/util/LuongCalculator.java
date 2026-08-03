package org.example.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Công thức tính lương (spec §4). Thuần tuý, không chạm DB — mọi thay đổi về cách tính
 * tiền phải đi qua đây để test khoá lại được.
 */
public final class LuongCalculator {

    private LuongCalculator() {}

    /** VND không có phần lẻ: null → 0, số lẻ → làm tròn nửa lên. */
    public static BigDecimal chuanHoa(BigDecimal v) {
        if (v == null) return BigDecimal.ZERO;
        return v.setScale(0, RoundingMode.HALF_UP);
    }

    /** TongPhuCap = PhuCapMoiCa × SoCaLamViec. */
    public static BigDecimal tongPhuCap(BigDecimal phuCapMoiCa, int soCaLamViec) {
        if (soCaLamViec < 0) {
            throw new IllegalArgumentException("Số ca làm việc không thể âm: " + soCaLamViec);
        }
        return chuanHoa(chuanHoa(phuCapMoiCa).multiply(BigDecimal.valueOf(soCaLamViec)));
    }

    /**
     * TongLuongThuc = LuongCoBan + TongPhuCap − TongKhauTru, kẹp sàn tại 0.
     * Ứng vượt lương không tạo ra số tiền âm — phần vượt coi như treo sang kỳ sau (ngoài phạm vi).
     */
    public static BigDecimal tongLuongThuc(BigDecimal luongCoBan, BigDecimal tongPhuCap, BigDecimal tongKhauTru) {
        BigDecimal thuc = chuanHoa(luongCoBan)
                .add(chuanHoa(tongPhuCap))
                .subtract(chuanHoa(tongKhauTru));
        return thuc.signum() < 0 ? BigDecimal.ZERO : thuc;
    }
}
