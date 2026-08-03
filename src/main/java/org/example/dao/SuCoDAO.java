package org.example.dao;

import org.example.model.SuCo;
import java.util.List;

public interface SuCoDAO {
    int insert(SuCo suCo);
    List<SuCo> getByBaoVe(int baoVeId, int limit);
    List<SuCo> getByCoSo(int coSoId, String trangThai, int limit);
    boolean updateTrangThai(int suCoId, String trangThai, String ghiChuXuLy, int xuLyBoi);
    int countTodayByBaoVe(int baoVeId);
    int countTodayByCoSo(int coSoId);
}
