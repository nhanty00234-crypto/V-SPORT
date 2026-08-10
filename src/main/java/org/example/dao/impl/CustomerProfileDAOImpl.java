package org.example.dao.impl;

import org.example.dao.CustomerProfileDAO;
import org.example.dto.CustomerProfileExtraDTO;
import org.example.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class CustomerProfileDAOImpl implements CustomerProfileDAO {

    @Override
    public CustomerProfileExtraDTO getExtra(int accountId) throws SQLException {
        String sql = "SELECT a.cover_image_url, a.height_cm, a.weight_kg, a.special_note, a.favorite_positions, " +
                "a.favorite_sport_id, mt.sport_name AS FavoriteSportName, a.skill_level, a.play_goal, a.play_frequency " +
                "FROM dbo.accounts a " +
                "LEFT JOIN dbo.sports mt ON mt.sport_id = a.favorite_sport_id " +
                "WHERE a.account_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                CustomerProfileExtraDTO dto = new CustomerProfileExtraDTO();
                if (rs.next()) {
                    dto.setCoverImageUrl(rs.getString("cover_image_url"));
                    int height = rs.getInt("height_cm");
                    dto.setHeightCm(rs.wasNull() ? null : height);
                    int weight = rs.getInt("weight_kg");
                    dto.setWeightKg(rs.wasNull() ? null : weight);
                    dto.setSpecialNote(rs.getString("special_note"));
                    dto.setPreferredLocation(rs.getString("favorite_positions"));
                    int sportId = rs.getInt("favorite_sport_id");
                    dto.setFavoriteSportId(rs.wasNull() ? null : sportId);
                    dto.setFavoriteSportName(rs.getString("FavoriteSportName"));
                    dto.setSkillLevel(rs.getString("skill_level"));
                    dto.setGoal(rs.getString("play_goal"));
                    dto.setPlayFrequency(rs.getString("play_frequency"));
                }
                return dto;
            }
        }
    }

    @Override
    public boolean updatePhysical(int accountId, Integer heightCm, Integer weightKg) throws SQLException {
        String sql = "UPDATE dbo.accounts SET height_cm = ?, weight_kg = ? WHERE account_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            if (heightCm != null) ps.setInt(1, heightCm); else ps.setNull(1, Types.INTEGER);
            if (weightKg != null) ps.setInt(2, weightKg); else ps.setNull(2, Types.INTEGER);
            ps.setInt(3, accountId);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean updateNote(int accountId, String note) throws SQLException {
        String sql = "UPDATE dbo.accounts SET special_note = ? WHERE account_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            if (note != null) ps.setString(1, note); else ps.setNull(1, Types.NVARCHAR);
            ps.setInt(2, accountId);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean updatePersonalization(int accountId, String location, Integer sportId, String level, String goal, String frequency) throws SQLException {
        String sql = "UPDATE dbo.accounts SET favorite_positions = ?, favorite_sport_id = ?, skill_level = ?, play_goal = ?, play_frequency = ? WHERE account_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            if (location != null) ps.setString(1, location); else ps.setNull(1, Types.NVARCHAR);
            if (sportId != null) ps.setInt(2, sportId); else ps.setNull(2, Types.INTEGER);
            if (level != null) ps.setString(3, level); else ps.setNull(3, Types.VARCHAR);
            if (goal != null) ps.setString(4, goal); else ps.setNull(4, Types.NVARCHAR);
            if (frequency != null) ps.setString(5, frequency); else ps.setNull(5, Types.VARCHAR);
            ps.setInt(6, accountId);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean updateCoverPath(int accountId, String coverPath) throws SQLException {
        String sql = "UPDATE dbo.accounts SET cover_image_url = ? WHERE account_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, coverPath);
            ps.setInt(2, accountId);
            return ps.executeUpdate() > 0;
        }
    }
}
