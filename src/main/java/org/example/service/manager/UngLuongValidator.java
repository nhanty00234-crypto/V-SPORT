package org.example.service.manager;

import org.example.util.LuongCalculator;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.Locale;

/**
 * Quy tắc chấp nhận một yêu cầu ứng lương. Tách riêng khỏi service để test được
 * không cần DB — service chỉ có nhiệm vụ nạp số liệu rồi gọi vào đây.
 */
public final class UngLuongValidator {

    private UngLuongValidator() {}

    /**
     * @param soTienUng          số tiền nhân viên muốn ứng lần này
     * @param hanMucUng          CauHinhLuong.HanMucUng của nhân viên; 0/null = chưa cấu hình
     * @param daUngChuaKhauTru   tổng đã ứng (chờ duyệt + đã duyệt) chưa bị khấu trừ vào kỳ đã phát
     * @return null nếu hợp lệ; ngược lại là thông báo lỗi tiếng Việt hiển thị được cho nhân viên
     */
    public static String kiemTra(BigDecimal soTienUng, BigDecimal hanMucUng, BigDecimal daUngChuaKhauTru) {
        if (soTienUng == null || soTienUng.signum() <= 0) {
            return "Số tiền ứng phải lớn hơn 0.";
        }
        BigDecimal hanMuc = LuongCalculator.chuanHoa(hanMucUng);
        if (hanMuc.signum() <= 0) {
            return "Hạn mức ứng lương của bạn chưa được cấu hình. Vui lòng liên hệ quản lý.";
        }
        BigDecimal daUng = LuongCalculator.chuanHoa(daUngChuaKhauTru);
        BigDecimal conLai = hanMuc.subtract(daUng);
        if (LuongCalculator.chuanHoa(soTienUng).compareTo(conLai) > 0) {
            return "Số tiền vượt hạn mức ứng còn lại (" + dinhDang(conLai) + " đ).";
        }
        return null;
    }

    private static String dinhDang(BigDecimal v) {
        if (v.signum() < 0) v = BigDecimal.ZERO;
        return NumberFormat.getInstance(new Locale("vi", "VN")).format(v);
    }
}
