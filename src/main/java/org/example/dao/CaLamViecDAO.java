package org.example.dao;

import org.example.model.CaLamViec;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

public interface CaLamViecDAO {
    List<CaLamViec> getAllCaLamViec();
    List<CaLamViec> getCaByCoSo(int coSoId);
    CaLamViec getCaById(int id);
    long getTotalCaLamViec();

    /**
     * Thêm mới ca làm việc
     * @param ca Đối tượng CaLamViec cần thêm
     * @return true nếu thành công, false nếu thất bại
     */
    boolean addCaLamViec(CaLamViec ca);

    /**
     * Thêm mới ca làm việc trong một transaction hiện có.
     * Set ca.caLamViecId theo generated key.
     * @return generated ID (> 0) nếu thành công, -1 nếu thất bại
     */
    int addCaLamViecWithConnection(CaLamViec ca, Connection conn) throws SQLException;

    /**
     * Cập nhật ca làm việc
     * @param ca Đối tượng CaLamViec đã có ID
     * @return true nếu thành công, false nếu thất bại
     */
    boolean updateCaLamViec(CaLamViec ca);

    /**
     * Xóa cứng ca làm việc theo ID (xóa khỏi DB)
     * @param id ID của ca làm việc
     * @return true nếu thành công, false nếu thất bại
     */
    boolean hardDelete(int id);

    /**
     * Xóa mềm ca làm việc theo ID
     */
    boolean softDelete(int id, int actorId);

    /**
     * Khôi phục ca làm việc đã bị xóa mềm
     */
    boolean restore(int id);

    /**
     * Lấy danh sách ca làm việc đã bị xóa mềm theo cơ sở
     */
    List<CaLamViec> findDeletedByCoSo(int coSoId);

    /**
     * Lấy danh sách ID ca làm việc đã bị xóa mềm lâu hơn N ngày
     */
    List<Integer> findDeletedIdsOlderThan(int days);

    /**
     * Kiểm tra xem có xung đột lịch ca làm không
     * @param accountId ID của nhân viên
     * @param ngayLam Ngày làm việc cần kiểm tra
     * @param gioBatDau Giờ bắt đầu ca mới
     * @param gioKetThuc Giờ kết thúc ca mới
     * @param excludeCaLamViecId ID của ca làm việc cần bỏ qua (dùng khi update, có thể null)
     * @return true nếu có xung đột, false nếu không có
     */
    boolean checkShiftConflict(int accountId, LocalDate ngayLam, LocalTime gioBatDau, LocalTime gioKetThuc, Integer excludeCaLamViecId);

    /**
     * Lấy danh sách ca làm của một nhân viên theo khoảng ngày
     */
    List<CaLamViec> getCaByAccountIDAndDateRange(int accountId, LocalDate startDate, LocalDate endDate);

    /**
     * Lấy danh sách ca làm của một nhân viên theo khoảng ngày (alias)
     */
    List<CaLamViec> getShiftsByAccountAndDateRange(int accountId, LocalDate startDate, LocalDate endDate);

    /**
     * Lấy danh sách ca làm định kỳ (theo thứ) của một nhân viên
     */
    List<CaLamViec> getRecurringShiftsByAccountID(int accountId);

    /**
     * Xóa các ca làm của nhân viên vào một ngày cụ thể
     */
    boolean deleteByAccountIDAndNgayLam(int accountId, LocalDate ngayLam);

    /**
     * Công bố các ca làm việc của một cơ sở trong khoảng ngày
     */
    boolean publishWeekShifts(LocalDate startOfWeek, LocalDate endOfWeek, int coSoId);

    /**
     * Lấy danh sách ca làm việc của một cơ sở theo khoảng ngày
     */
    List<CaLamViec> getShiftsByCoSoAndDateRange(int coSoId, LocalDate start, LocalDate end);

    /**
     * Cập nhật ca làm việc trong một transaction hiện có.
     */
    boolean updateCaLamViecWithConnection(CaLamViec ca, Connection conn) throws SQLException;

    /**
     * Publish (Draft → Published) các ca Draft trong khoảng tuần trong một transaction hiện có.
     * Chỉ update TrangThai='Draft', không đụng Cancelled/CheckedIn/Published/...
     * @return số dòng đã được update
     */
    int publishDraftShiftsWithConnection(LocalDate startOfWeek, LocalDate endOfWeek, int coSoId, Connection conn) throws SQLException;

    /** Lấy ca hôm nay của nhân viên (dùng cho điểm danh bảo vệ) */
    CaLamViec getCaHomNay(int accountId, LocalDate ngay);

    /** Ghi giờ vào ca thực tế */
    boolean checkInCa(int caLamViecId);

    /** Ghi giờ ra ca thực tế */
    boolean checkOutCa(int caLamViecId);
}
