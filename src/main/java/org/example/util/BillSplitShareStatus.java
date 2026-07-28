package org.example.util;

import java.util.Set;

/** Trạng thái NhomChiaTienChiTiet (BillSplitShare). Không dùng chuỗi rải rác. */
public final class BillSplitShareStatus {

    private BillSplitShareStatus() {
    }

    public static final String PENDING = "PENDING";
    public static final String PROCESSING = "PROCESSING";
    public static final String PAID = "PAID";
    public static final String CANCELLED = "CANCELLED";
    public static final String EXPIRED = "EXPIRED";

    public static final Set<String> ALL = Set.of(PENDING, PROCESSING, PAID, CANCELLED, EXPIRED);

    /** Chỉ được bắt đầu thanh toán (PayOS/tại sân) từ 2 trạng thái này. */
    public static final Set<String> PAYABLE_FROM = Set.of(PENDING, PROCESSING);

    public static boolean isValid(String status) {
        return status != null && ALL.contains(status);
    }
}
