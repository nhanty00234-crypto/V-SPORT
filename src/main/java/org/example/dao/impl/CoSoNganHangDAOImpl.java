package org.example.dao.impl;

import org.example.dao.CoSoNganHangDAO;
import org.example.model.CoSoNganHang;
import org.example.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class CoSoNganHangDAOImpl implements CoSoNganHangDAO {

    @Override
    public CoSoNganHang findByCoSoId(int coSoId) throws Exception {
        String sql = "SELECT CoSoID, BankName, BankShortCode, AccountName, AccountNumber " +
                "FROM CoSoNganHang WHERE CoSoID = ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                CoSoNganHang config = new CoSoNganHang(
                        rs.getInt("CoSoID"),
                        rs.getNString("BankName"),
                        rs.getString("BankShortCode"),
                        rs.getNString("AccountName"),
                        rs.getString("AccountNumber"));
                return config.isConfigured() ? config : null;
            }
        }
    }
}
