package org.example.dao;

import org.example.model.San;
import java.util.List;

public interface SanDAO {
    List<San> getAllSan();
    San getSanById(int id);
    long countSanByTrangThai(String trangThai);

    // Thêm phương thức thống kê tổng số sân
    long getTotalSan();
    List<San> getSansByCoSo(int coSoId);
    long countSansByLoaiSanId(int loaiSanId);

    void insert(San san);
    void update(San existing);
}