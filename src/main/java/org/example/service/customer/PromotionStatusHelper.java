package org.example.service.customer;

import org.example.model.KhuyenMai;
import org.example.util.Constants;

import java.time.LocalDate;

/**
 * Nhãn trạng thái hiển thị cho Manager (khác TrangThai lưu trong DB, vốn chỉ có
 * Hoạt động/Tạm dừng do Manager bật-tắt thủ công). Trạng thái hiển thị được suy ra
 * thêm từ ngày bắt đầu/kết thúc và số lượt đã dùng — logic hiển thị thuần, không
 * đụng vào PromotionService.calculateDiscount.
 */
public final class PromotionStatusHelper {

    public static final String DANG_HOAT_DONG = "Đang hoạt động";
    public static final String SAP_DIEN_RA = "Sắp diễn ra";
    public static final String DA_HET_HAN = "Đã hết hạn";
    public static final String TAM_KHOA = "Tạm khóa";
    public static final String HET_LUOT = "Hết lượt";

    private PromotionStatusHelper() {
    }

    public static String displayStatus(KhuyenMai km) {
        if (km == null) return "";
        LocalDate today = LocalDate.now();

        boolean manuallyActive = Constants.TRANG_THAI_KM_HOAT_DONG.equalsIgnoreCase(km.getTrangThai())
                || "ACTIVE".equalsIgnoreCase(km.getTrangThai());
        if (!manuallyActive) {
            return TAM_KHOA;
        }
        if (km.getNgayKetThuc() != null && today.isAfter(km.getNgayKetThuc())) {
            return DA_HET_HAN;
        }
        if (km.getSoLanToiDa() != null && km.getSoLanDaDung() >= km.getSoLanToiDa()) {
            return HET_LUOT;
        }
        if (km.getNgayBatDau() != null && today.isBefore(km.getNgayBatDau())) {
            return SAP_DIEN_RA;
        }
        return DANG_HOAT_DONG;
    }
}
