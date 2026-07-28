package org.example.dao;

import org.example.model.CustomerReputationHistory;
import java.util.List;

public interface CustomerReputationHistoryDAO {
    /** Lịch sử điểm uy tín của một khách hàng, mới nhất trước, dùng để hiển thị (read-only). */
    List<CustomerReputationHistory> getByAccountId(int accountId);

    /** Lấy lịch sử lọc theo loại hành động (actionType) */
    List<CustomerReputationHistory> getByAccountIdAndAction(int accountId, String actionType);
}
