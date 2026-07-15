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
    /** Xóa cứng lịch đặt sân khỏi DB */
    boolean hardDelete(int id);
    List<Lichdatsan> getLichDatSanTodayByCoSo(int coSoId);
    List<Lichdatsan> getLichDatSanByCoSo(int coSoId);
    boolean duyetLichDatSan(int datSanId, int approvedByAccountId, int coSoId, boolean confirmPriceChange) throws Exception;
    boolean tuChoiLichDatSan(int datSanId, String ghiChu, int coSoId) throws Exception;
    boolean updateDichVuDatSan(int datSanId, int[] productIds, int[] quantities) throws Exception;
    /** Xóa mềm lịch đặt sân theo ID */
    boolean softDelete(int id, int actorId);
    /** Khôi phục lịch đặt sân đã bị xóa mềm */
    boolean restore(int id);
    /** Lấy danh sách lịch đặt sân đã bị xóa mềm theo cơ sở */
    List<Lichdatsan> findDeletedByCoSo(int coSoId);
    /** Lấy danh sách ID lịch đặt sân đã bị xóa mềm lâu hơn N ngày */
    List<Integer> findDeletedIdsOlderThan(int days);
}
