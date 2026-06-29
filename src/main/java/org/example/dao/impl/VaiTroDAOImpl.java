package org.example.dao.impl;

import org.example.dao.VaiTroDAO;
import org.example.model.VaiTro;
import org.example.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class VaiTroDAOImpl implements VaiTroDAO {

    private static final Logger logger = LogManager.getLogger(VaiTroDAOImpl.class);
    @Override
    public List<VaiTro> getAllRoles() {
        List<VaiTro> roles = new ArrayList<>();
        String sql = "SELECT * FROM Roles ORDER BY RoleID ASC";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int id = rs.getInt("RoleID");
                String name = rs.getNString("RoleName");
                
              
                
                roles.add(new VaiTro(id, name));
            }
        } catch (Exception e) {
            logger.error("Lỗi khi lấy danh sách vai trò: {}", e.getMessage(), e);
        }
        return roles;
    }
}
