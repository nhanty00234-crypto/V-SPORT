package org.example.dao.impl;

import org.example.dao.CoSoFaceConfigDAO;
import org.example.model.CoSoFaceConfig;
import org.example.util.DBUtil;

import java.sql.*;

public class CoSoFaceConfigDAOImpl implements CoSoFaceConfigDAO {

    @Override
    public CoSoFaceConfig findByCoSo(int coSoId) {
        String sql = "SELECT * FROM CoSoFaceConfig WHERE CoSoID=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CoSoFaceConfig cfg = new CoSoFaceConfig();
                    cfg.setCoSoId(rs.getInt("CoSoID"));
                    cfg.setFaceRequired(rs.getBoolean("FaceRequired"));
                    cfg.setConfidenceMin(rs.getDouble("ConfidenceMin"));
                    Timestamp ts = rs.getTimestamp("UpdatedAt");
                    if (ts != null) cfg.setUpdatedAt(ts.toLocalDateTime());
                    return cfg;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("findByCoSo CoSoFaceConfig failed", e);
        }
        // Trả về config mặc định nếu chưa cài đặt
        CoSoFaceConfig def = new CoSoFaceConfig();
        def.setCoSoId(coSoId);
        def.setFaceRequired(false);
        def.setConfidenceMin(0.6);
        return def;
    }

    @Override
    public void upsert(CoSoFaceConfig config) {
        String sql = "MERGE CoSoFaceConfig AS target " +
                "USING (VALUES (?,?,?,GETDATE())) AS source (CoSoID, FaceRequired, ConfidenceMin, UpdatedAt) " +
                "ON target.CoSoID = source.CoSoID " +
                "WHEN MATCHED THEN UPDATE SET FaceRequired=source.FaceRequired, ConfidenceMin=source.ConfidenceMin, UpdatedAt=source.UpdatedAt " +
                "WHEN NOT MATCHED THEN INSERT (CoSoID, FaceRequired, ConfidenceMin, UpdatedAt) VALUES (source.CoSoID, source.FaceRequired, source.ConfidenceMin, source.UpdatedAt);";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, config.getCoSoId());
            ps.setBoolean(2, config.isFaceRequired());
            ps.setDouble(3, config.getConfidenceMin());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("upsert CoSoFaceConfig failed", e);
        }
    }
}
