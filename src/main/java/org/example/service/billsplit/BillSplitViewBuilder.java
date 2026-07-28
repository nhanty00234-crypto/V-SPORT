package org.example.service.billsplit;

import org.example.model.NhomChiaTien;
import org.example.model.NhomChiaTienChiTiet;
import org.example.util.BillSplitShareStatus;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Dựng JSON response cho frontend theo đúng mục 14 spec (tổng hóa đơn, loại chia, số người,
 * từng share, số tiền, trạng thái, tổng đã thanh toán, tổng còn lại, progress, payment/share
 * URL). Dùng chung cho cả 3 phía Customer/Participant/Staff để đảm bảo cùng 1 hình dạng JSON.
 * Không bao giờ lộ ShareToken của participant khác trong response (chỉ chính participant đó
 * xem qua đúng token của mình mới thấy paymentUrl/qrCodeUrl chứa token — spec mục 13).
 */
public final class BillSplitViewBuilder {

    private BillSplitViewBuilder() {
    }

    public static Map<String, Object> buildOverview(String contextPath, NhomChiaTien nct,
                                                      List<NhomChiaTienChiTiet> shares, boolean includeTokens) {
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("billSplitId", nct.getNhomChiaTienId());
        out.put("hoaDonId", nct.getHoaDonId());
        out.put("datSanId", nct.getDatSanId());
        out.put("splitType", nct.getSplitType());
        out.put("trangThai", nct.getTrangThai());
        out.put("tongTien", nct.getTongTien());

        BigDecimal totalPaid = BigDecimal.ZERO;
        List<Map<String, Object>> shareList = new ArrayList<>();
        for (NhomChiaTienChiTiet ct : shares) {
            if (BillSplitShareStatus.PAID.equals(ct.getTrangThai())) {
                totalPaid = totalPaid.add(ct.getSoTien());
            }
            shareList.add(buildShare(contextPath, ct, includeTokens));
        }
        BigDecimal remaining = nct.getTongTien().subtract(totalPaid);
        if (remaining.signum() < 0) remaining = BigDecimal.ZERO;

        out.put("shares", shareList);
        out.put("soNguoi", shares.size());
        out.put("tongDaThanhToan", totalPaid);
        out.put("tongConLai", remaining);
        int progress = nct.getTongTien().signum() > 0
                ? totalPaid.multiply(BigDecimal.valueOf(100)).divide(nct.getTongTien(), 0, java.math.RoundingMode.DOWN).intValue()
                : 0;
        out.put("progress", Math.min(100, progress));
        return out;
    }

    public static Map<String, Object> buildShare(String contextPath, NhomChiaTienChiTiet ct, boolean includeToken) {
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("shareId", ct.getChiTietId());
        out.put("displayName", ct.getDisplayName());
        out.put("amount", ct.getSoTien());
        out.put("status", ct.getTrangThai());
        out.put("paymentMethod", ct.getPaymentMethod());
        out.put("paidAt", ct.getPaidAt());
        if (includeToken) {
            String token = ct.getShareToken();
            String base = contextPath == null ? "" : contextPath;
            out.put("shareToken", token);
            out.put("paymentUrl", base + "/chia-tien/thanh-toan?token=" + token);
            out.put("qrCodeUrl", base + "/chia-tien/qr?token=" + token);
        }
        return out;
    }
}
