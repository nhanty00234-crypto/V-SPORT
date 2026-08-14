package org.example.dao.impl;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.PayOSConfigDAO;
import org.example.dto.payment.PayOSConfigState;
import org.example.dto.payment.PayOSCredentials;
import org.example.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

public class PayOSConfigDAOImpl implements PayOSConfigDAO {

    private static final Logger logger = LogManager.getLogger(PayOSConfigDAOImpl.class);

    private static final String SELECT_SQL =
            "SELECT PayOS_ClientID, PayOS_ApiKey, PayOS_ChecksumKey FROM CoSo WHERE CoSoID = ?";

    @Override
    public PayOSCredentials findPayOSConfigurationStatusByCoSoId(int coSoId) {
        return queryRawCredentials(coSoId);
    }

    @Override
    public PayOSCredentials getPayOSCredentialsForInternalUse(int coSoId) {
        return queryRawCredentials(coSoId);
    }

    private PayOSCredentials queryRawCredentials(int coSoId) {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_SQL)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return new PayOSCredentials(
                        rs.getString("PayOS_ClientID"),
                        rs.getString("PayOS_ApiKey"),
                        rs.getString("PayOS_ChecksumKey"));
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi đọc cấu hình PayOS cho CoSoID {}: {}", coSoId, e.getMessage());
            throw new IllegalStateException("Không thể đọc cấu hình PayOS.", e);
        }
    }

    @Override
    public boolean updatePayOSConfiguration(int coSoId, String clientId, String apiKey, String checksumKey) {
        String sql = "UPDATE CoSo SET PayOS_ClientID = ?, PayOS_ApiKey = ?, PayOS_ChecksumKey = ? WHERE CoSoID = ?";
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, clientId);
                ps.setString(2, apiKey);
                ps.setString(3, checksumKey);
                ps.setInt(4, coSoId);
                int affected = ps.executeUpdate();
                if (affected == 1) {
                    conn.commit();
                    return true;
                }
                conn.rollback();
                return false;
            } catch (SQLException e) {
                conn.rollback();
                logger.error("Lỗi khi cập nhật cấu hình PayOS cho CoSoID {}: {}", coSoId, e.getMessage());
                throw new IllegalStateException("Không thể cập nhật cấu hình PayOS.", e);
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            logger.error("Lỗi kết nối khi cập nhật cấu hình PayOS cho CoSoID {}: {}", coSoId, e.getMessage());
            throw new IllegalStateException("Không thể cập nhật cấu hình PayOS.", e);
        }
    }

    @Override
    public Map<Integer, PayOSConfigState> findStatusForAllCoSo() {
        String sql = "SELECT CoSoID, PayOS_ClientID, PayOS_ApiKey, PayOS_ChecksumKey FROM CoSo " +
                "WHERE IsDeleted = 0 OR IsDeleted IS NULL";
        Map<Integer, PayOSConfigState> result = new HashMap<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int coSoId = rs.getInt("CoSoID");
                PayOSConfigState state = PayOSConfigState.fromRawValues(
                        rs.getString("PayOS_ClientID"),
                        rs.getString("PayOS_ApiKey"),
                        rs.getString("PayOS_ChecksumKey"));
                result.put(coSoId, state);
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi tải trạng thái PayOS cho danh sách cơ sở: {}", e.getMessage());
        }
        return result;
    }
}
