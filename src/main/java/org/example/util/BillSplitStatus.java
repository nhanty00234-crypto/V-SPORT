package org.example.util;

import java.util.Set;

/** Trạng thái NhomChiaTien (BillSplit). Không dùng chuỗi rải rác — mọi so sánh phải qua đây. */
public final class BillSplitStatus {

    private BillSplitStatus() {
    }

    public static final String DRAFT = "DRAFT";
    public static final String ACTIVE = "ACTIVE";
    public static final String PARTIALLY_PAID = "PARTIALLY_PAID";
    public static final String PAID = "PAID";
    public static final String CANCELLED = "CANCELLED";
    public static final String EXPIRED = "EXPIRED";

    public static final Set<String> ALL = Set.of(DRAFT, ACTIVE, PARTIALLY_PAID, PAID, CANCELLED, EXPIRED);

    /** Chỉ được sửa cấu hình chia (số người/số tiền) khi chưa có share nào PAID. */
    public static final Set<String> EDITABLE = Set.of(DRAFT, ACTIVE);

    /** Chủ booking chỉ được hủy khi chưa ai thanh toán. */
    public static final Set<String> CANCELLABLE = Set.of(DRAFT, ACTIVE);

    public static boolean isValid(String status) {
        return status != null && ALL.contains(status);
    }

    public static boolean isTerminal(String status) {
        return PAID.equals(status) || CANCELLED.equals(status) || EXPIRED.equals(status);
    }
}
