package org.example.service;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/** Quản lý tuỳ chọn nhận thông báo (NhanThongBaoMarketing) cho Accounts. */
public class NotificationPreferenceService {

    private static final Logger logger = LogManager.getLogger(NotificationPreferenceService.class);

    public boolean loadMarketingPref(int accountId) {
        String sql = "SELECT NhanThongBaoMarketing FROM Accounts WHERE AccountID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBoolean("NhanThongBaoMarketing");
            }
        } catch (Exception e) {
            logger.warn("loadMarketingPref accountId={}: {} — default true", accountId, e.getMessage());
        }
        return true;
    }

    public void saveMarketingPref(int accountId, boolean enable) {
        String sql = "UPDATE Accounts SET NhanThongBaoMarketing = ? WHERE AccountID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, enable);
            ps.setInt(2, accountId);
            ps.executeUpdate();
            logger.info("saveMarketingPref accountId={} enable={}", accountId, enable);
        } catch (Exception e) {
            logger.error("saveMarketingPref accountId={}: {}", accountId, e.getMessage(), e);
        }
    }
}
