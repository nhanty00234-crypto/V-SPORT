package org.example.dao.impl;

import org.example.dao.DatSanDAO;
import org.example.model.DatSan;
import org.example.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Implementation của DatSanDAO sử dụng JDBC
 */
public class DatSanDAOImpl implements DatSanDAO {

    @Override
    public int getTotalDatSan() {
        int total = 0;
        String sql = "SELECT COUNT(*) FROM DatSan";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                total = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }
}
