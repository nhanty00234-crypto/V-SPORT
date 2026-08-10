package org.example.dao.impl;

import org.example.dao.CustomerReputationHistoryDAO;
import org.example.model.CustomerReputationHistory;
import org.example.util.DBUtil;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class CustomerReputationHistoryDAOImpl implements CustomerReputationHistoryDAO {

    private static final Logger logger = LogManager.getLogger(CustomerReputationHistoryDAOImpl.class);

    @Override
    public List<CustomerReputationHistory> getByAccountId(int accountId) {
        return getByAccountIdAndAction(accountId, null);
    }

    @Override
    public List<CustomerReputationHistory> getByAccountIdAndAction(int accountId, String actionType) {
        List<CustomerReputationHistory> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT reputation_history_id, account_id, booking_id, action_type, score_delta, score_before, score_after, Reason, created_by, created_at, ip_address " +
                "FROM customer_reputation_history WHERE account_id = ? ");
        if (actionType != null && !actionType.isBlank() && !"ALL".equalsIgnoreCase(actionType)) {
            sql.append("AND ActionType = ? ");
        }
        sql.append("ORDER BY created_at DESC");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, accountId);
            if (actionType != null && !actionType.isBlank() && !"ALL".equalsIgnoreCase(actionType)) {
                ps.setString(2, actionType);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomerReputationHistory h = new CustomerReputationHistory();
                    h.setReputationHistoryId(rs.getLong("reputation_history_id"));
                    h.setAccountId(rs.getInt("account_id"));
                    int datSanId = rs.getInt("booking_id");
                    if (!rs.wasNull()) h.setDatSanId(datSanId);
                    h.setActionType(rs.getString("action_type"));
                    h.setScoreDelta(rs.getInt("score_delta"));
                    h.setScoreBefore(rs.getInt("score_before"));
                    h.setScoreAfter(rs.getInt("score_after"));
                    h.setReason(rs.getNString("Reason"));
                    int createdBy = rs.getInt("created_by");
                    if (!rs.wasNull()) h.setCreatedBy(createdBy);
                    java.sql.Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) h.setCreatedAt(ts.toLocalDateTime());
                    h.setIpAddress(rs.getString("ip_address"));
                    list.add(h);
                }
            }
        } catch (Exception e) {
            logger.error("Error fetching CustomerReputationHistory for accountId={}: {}", accountId, e.getMessage(), e);
        }
        return list;
    }
}
