package org.example.dao;

import org.example.model.LoaiSan;
import org.example.model.MonTheThao;

import java.util.List;

/**
 * Data Access Object cho LoaiSan (Court Type)
 */
public interface LoaiSanDAO {
    List<LoaiSan> getAllLoaiSan();
    LoaiSan getLoaiSanById(int id);
    boolean insert(LoaiSan loaiSan);
    boolean update(LoaiSan loaiSan);
    boolean delete(int id);

    // Manager operations
    List<LoaiSan> getLoaiSansByCoSo(int coSoId);
    List<MonTheThao> getAllMonTheThao();
}
