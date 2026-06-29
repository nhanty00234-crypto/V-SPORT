package org.example.dao;

import org.example.model.DatSan;

/**
 * Interface DAO cho thực thể DatSan
 */
public interface DatSanDAO {
    int getTotalDatSan();
    // Thêm các phương thức CRUD khác theo nhu cầu
    // Ví dụ:
    // DatSan getDatSanById(int id);
    // List<DatSan> getAllDatSan();
    // boolean addDatSan(DatSan datSan);
    // boolean updateDatSan(DatSan datSan);
    // boolean deleteDatSan(int id);
}