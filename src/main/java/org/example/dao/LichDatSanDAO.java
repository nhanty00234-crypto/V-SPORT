package org.example.dao;

import org.example.model.Lichdatsan;
import java.util.List;

public interface LichDatSanDAO {
    List<Lichdatsan> getAllLichDatSan();
    List<Lichdatsan> getLichByAccountId(int accountId);
    Lichdatsan getLichById(int id);
    boolean addLichDatSan(Lichdatsan lich);
    boolean updateTrangThai(int id, String trangThai);
    boolean updateGhiChu(int id, String ghiChu);
    boolean deleteLichDatSan(int id);
    List<Lichdatsan> getLichDatSanTodayByCoSo(int coSoId);
}
