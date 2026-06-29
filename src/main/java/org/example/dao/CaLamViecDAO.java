package org.example.dao;

import org.example.model.CaLamViec;
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
     * Cập nhật ca làm việc
     * @param ca Đối tượng CaLamViec đã có ID
     * @return true nếu thành công, false nếu thất bại
     */
    boolean updateCaLamViec(CaLamViec ca);

    /**
     * Xóa ca làm việc theo ID
     * @param id ID của ca làm việc
     * @return true nếu thành công, false nếu thất bại
     */
    boolean deleteCaLamViec(int id);

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
}
