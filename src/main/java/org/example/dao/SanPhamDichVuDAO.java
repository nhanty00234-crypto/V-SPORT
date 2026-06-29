package org.example.dao;

import org.example.model.SanPham_DichVu;
import java.util.List;

public interface SanPhamDichVuDAO {
    List<SanPham_DichVu> findByCoSo(int coSoId);
    List<SanPham_DichVu> findByCoSoAndCategory(int coSoId, int categoryId);
    SanPham_DichVu findById(int id);
    SanPham_DichVu findBySkuAndCoSo(String sku, int coSoId);
    boolean insert(SanPham_DichVu sp);
    boolean update(SanPham_DichVu sp);
    boolean delete(int id);
    boolean existsInInvoices(int sanPhamId);
}
