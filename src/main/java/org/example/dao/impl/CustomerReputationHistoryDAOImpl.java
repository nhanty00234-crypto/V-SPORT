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
                "SELECT ReputationHistoryID, AccountID, DatSanID, ActionType, ScoreDelta, ScoreBefore, ScoreAfter, Reason, CreatedBy, CreatedAt, IpAddress " +
                "FROM CustomerReputationHistory WHERE AccountID = ? ");
        if (actionType != null && !actionType.isBlank() && !"ALL".equalsIgnoreCase(actionType)) {
            sql.append("AND ActionType = ? ");
        }
        sql.append("ORDER BY CreatedAt DESC");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, accountId);
            if (actionType != null && !actionType.isBlank() && !"ALL".equalsIgnoreCase(actionType)) {
                ps.setString(2, actionType);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomerReputationHistory h = new CustomerReputationHistory();
                    h.setReputationHistoryId(rs.getLong("ReputationHistoryID"));
                    h.setAccountId(rs.getInt("AccountID"));
                    int datSanId = rs.getInt("DatSanID");
                    if (!rs.wasNull()) h.setDatSanId(datSanId);
                    h.setActionType(rs.getString("ActionType"));
                    h.setScoreDelta(rs.getInt("ScoreDelta"));
                    h.setScoreBefore(rs.getInt("ScoreBefore"));
                    h.setScoreAfter(rs.getInt("ScoreAfter"));
                    h.setReason(rs.getNString("Reason"));
                    int createdBy = rs.getInt("CreatedBy");
                    if (!rs.wasNull()) h.setCreatedBy(createdBy);
                    java.sql.Timestamp ts = rs.getTimestamp("CreatedAt");
                    if (ts != null) h.setCreatedAt(ts.toLocalDateTime());
                    h.setIpAddress(rs.getString("IpAddress"));
                    list.add(h);
                }
            }
        } catch (Exception e) {
            logger.error("Error fetching CustomerReputationHistory for accountId={}: {}", accountId, e.getMessage(), e);
        }
        return list;
    }
}
