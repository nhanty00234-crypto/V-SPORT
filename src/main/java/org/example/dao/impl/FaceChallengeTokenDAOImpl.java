package org.example.dao.impl;

import org.example.dao.FaceChallengeTokenDAO;
import org.example.model.FaceChallengeToken;
import org.example.util.DBUtil;

import java.sql.*;
import java.time.LocalDateTime;

public class FaceChallengeTokenDAOImpl implements FaceChallengeTokenDAO {

    @Override
    public void insert(FaceChallengeToken token) {
        String sql = "INSERT INTO FaceChallengeToken (TokenID, AccountID, CaLamViecID, Action, Challenges, CreatedAt, ExpiresAt) VALUES (?,?,?,?,?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token.getTokenId());
            ps.setInt(2, token.getAccountId());
            ps.setInt(3, token.getCaLamViecId());
            ps.setString(4, token.getAction());
            ps.setString(5, token.getChallenges());
            ps.setTimestamp(6, Timestamp.valueOf(token.getCreatedAt()));
            ps.setTimestamp(7, Timestamp.valueOf(token.getExpiresAt()));
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("insert FaceChallengeToken failed", e);
        }
    }

    @Override
    public FaceChallengeToken findById(String tokenId) {
        String sql = "SELECT * FROM FaceChallengeToken WHERE TokenID=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tokenId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("findById FaceChallengeToken failed", e);
        }
        return null;
    }

    @Override
    public void markUsed(String tokenId) {
        String sql = "UPDATE FaceChallengeToken SET UsedAt=GETDATE() WHERE TokenID=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tokenId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("markUsed FaceChallengeToken failed", e);
        }
    }

    @Override
    public void deleteExpired() {
        String sql = "DELETE FROM FaceChallengeToken WHERE ExpiresAt < GETDATE()";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("deleteExpired FaceChallengeToken failed", e);
        }
    }

    private FaceChallengeToken map(ResultSet rs) throws SQLException {
        FaceChallengeToken t = new FaceChallengeToken();
        t.setTokenId(rs.getString("TokenID"));
        t.setAccountId(rs.getInt("AccountID"));
        t.setCaLamViecId(rs.getInt("CaLamViecID"));
        t.setAction(rs.getString("Action"));
        t.setChallenges(rs.getString("Challenges"));
        Timestamp created = rs.getTimestamp("CreatedAt");
        if (created != null) t.setCreatedAt(created.toLocalDateTime());
        Timestamp expires = rs.getTimestamp("ExpiresAt");
        if (expires != null) t.setExpiresAt(expires.toLocalDateTime());
        Timestamp used = rs.getTimestamp("UsedAt");
        if (used != null) t.setUsedAt(used.toLocalDateTime());
        return t;
    }
}
