package org.example.util;

import java.util.Set;

/**
 * 7 trạng thái chuẩn hóa của HoanTien (Hoàn tiền Customer). Thay thế cho 2 tập giá trị
 * xung đột từng tồn tại song song (org.example.service.RefundService dùng tiếng Việt có dấu;
 * org.example.service.refund.RefundService dùng "CHO_XU_LY"/"DA_DUYET"/"TU_CHUOI") — xem
 * sql/migration_refund_customer_selfservice.sql để biết cách dữ liệu cũ được chuẩn hóa về đây.
 *
 * State machine hợp lệ:
 *   CHO_BO_SUNG_THONG_TIN --(customer bổ sung ngân hàng)--> CHO_XU_LY
 *   CHO_XU_LY             --(manager duyệt)--> DA_DUYET
 *   CHO_XU_LY             --(manager từ chối)--> TU_CHOI
 *   CHO_XU_LY             --(manager yêu cầu bổ sung)--> CHO_BO_SUNG_THONG_TIN
 *   DA_DUYET              --(manager bắt đầu xử lý)--> DANG_HOAN_TIEN
 *   DANG_HOAN_TIEN        --(manager xác nhận đã hoàn)--> DA_HOAN_TIEN
 *   CHO_XU_LY / CHO_BO_SUNG_THONG_TIN --(customer hủy yêu cầu)--> DA_HUY
 *
 * DA_DUYET KHÔNG được coi là đã chuyển tiền — chỉ DA_HOAN_TIEN mới là đã chuyển tiền thật.
 */
public final class RefundStatus {

    private RefundStatus() {
    }

    public static final String CHO_BO_SUNG_THONG_TIN = "CHO_BO_SUNG_THONG_TIN";
    public static final String CHO_XU_LY = "CHO_XU_LY";
    public static final String DA_DUYET = "DA_DUYET";
    public static final String DANG_HOAN_TIEN = "DANG_HOAN_TIEN";
    public static final String DA_HOAN_TIEN = "DA_HOAN_TIEN";
    public static final String TU_CHOI = "TU_CHOI";
    public static final String DA_HUY = "DA_HUY";

    public static final Set<String> ALL = Set.of(
            CHO_BO_SUNG_THONG_TIN, CHO_XU_LY, DA_DUYET, DANG_HOAN_TIEN, DA_HOAN_TIEN, TU_CHOI, DA_HUY);

    /** Customer được sửa thông tin ngân hàng/QR chỉ khi ở 2 trạng thái này. */
    public static final Set<String> EDITABLE_BY_CUSTOMER = Set.of(CHO_BO_SUNG_THONG_TIN, CHO_XU_LY);

    /** Customer được tự hủy yêu cầu chỉ khi chưa được Manager xử lý gì. */
    public static final Set<String> CANCELLABLE_BY_CUSTOMER = Set.of(CHO_BO_SUNG_THONG_TIN, CHO_XU_LY);

    public static boolean isValid(String status) {
        return status != null && ALL.contains(status);
    }

    /** true nếu tiền đã thực sự được chuyển — dùng để chặn logic coi DA_DUYET là đã trả tiền. */
    public static boolean isMoneyTransferred(String status) {
        return DA_HOAN_TIEN.equals(status);
    }

    public static boolean isTerminal(String status) {
        return DA_HOAN_TIEN.equals(status) || TU_CHOI.equals(status) || DA_HUY.equals(status);
    }

    /** Nhãn hiển thị tiếng Việt cho UI (JSP dùng trực tiếp, không hard-code text trạng thái). */
    public static String label(String status) {
        if (status == null) return "";
        switch (status) {
            case CHO_BO_SUNG_THONG_TIN: return "Chờ bổ sung thông tin";
            case CHO_XU_LY: return "Chờ xử lý";
            case DA_DUYET: return "Đã duyệt";
            case DANG_HOAN_TIEN: return "Đang hoàn tiền";
            case DA_HOAN_TIEN: return "Đã hoàn tiền";
            case TU_CHOI: return "Từ chối";
            case DA_HUY: return "Đã hủy";
            default: return status;
        }
    }
}
