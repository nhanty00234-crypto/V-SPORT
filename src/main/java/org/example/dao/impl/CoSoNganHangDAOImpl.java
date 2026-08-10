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
        String sql = "SELECT facility_id, bank_name, bank_short_code, account_holder_name, account_number " +
                "FROM facility_bank_accounts WHERE facility_id = ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                CoSoNganHang config = new CoSoNganHang(
                        rs.getInt("facility_id"),
                        rs.getNString("bank_name"),
                        rs.getString("bank_short_code"),
                        rs.getNString("account_holder_name"),
                        rs.getString("account_number"));
                return config.isConfigured() ? config : null;
            }
        }
    }
}
