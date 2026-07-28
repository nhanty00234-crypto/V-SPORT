package org.example.util;

import java.util.Set;

/** Chế độ chia tiền nhóm. Chỉ EQUAL và CUSTOM được triển khai — ITEMIZED chưa đủ dữ liệu chi tiết
 * dịch vụ để làm chắc chắn nên chưa hỗ trợ (từ chối rõ ràng thay vì làm nửa vời). */
public final class BillSplitType {

    private BillSplitType() {
    }

    public static final String EQUAL = "EQUAL";
    public static final String CUSTOM = "CUSTOM";
    public static final String ITEMIZED = "ITEMIZED";

    public static final Set<String> IMPLEMENTED = Set.of(EQUAL, CUSTOM);
    public static final Set<String> ALL = Set.of(EQUAL, CUSTOM, ITEMIZED);
}
