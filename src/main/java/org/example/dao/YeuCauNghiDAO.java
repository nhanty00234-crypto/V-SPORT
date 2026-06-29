package org.example.dao;

import org.example.model.YeuCauNghi;
import java.time.LocalDate;
import java.util.List;

/**
 * DAO interface cho entity YeuCauNghi
 * Định nghĩa các phương thức truy vấn cơ bản
 */
public interface YeuCauNghiDAO {
    /**
     * Thêm yêu cầu nghỉ mới
     */
    int insert(YeuCauNghi yeuCauNghi);

    /**
     * Cập nhật yêu cầu nghỉ
     */
    boolean update(YeuCauNghi yeuCauNghi);

    /**
     * Xóa yêu cầu nghỉ (soft delete bằng cách set trang thai = 'DaHuy')
     */
    boolean delete(int yeuCauNghiID);

    /**
     * Lấy yêu cầu nghỉ theo ID
     */
    YeuCauNghi findById(int yeuCauNghiID);

    /**
     * Lấy tất cả yêu cầu nghỉ
     */
    List<YeuCauNghi> findAll();

    /**
     * Lấy danh sách yêu cầu nghỉ theo AccountID
     */
    List<YeuCauNghi> findByAccountID(int accountID);

    /**
     * Lấy danh sách yêu cầu nghỉ theo CoSoID
     */
    List<YeuCauNghi> findByCoSoID(int coSoID);

    /**
     * Lấy danh sách yêu cầu nghỉ theo CoSoID và trạng thái
     */
    List<YeuCauNghi> findByCoSoIDAndTrangThai(int coSoID, String trangThai);

    /**
     * Lấy danh sách yêu cầu nghỉ theo AccountID và trạng thái
     */
    List<YeuCauNghi> findByAccountIDAndTrangThai(int accountID, String trangThai);

    /**
     * Lấy số lượng yêu cầu chờ duyệt theo CoSoID
     */
    int countPendingByCoSoID(int coSoID);

    /**
     * Lấy yêu cầu nghỉ theo ngày và AccountID
     */
    List<YeuCauNghi> findByNgayNghiAndAccountID(LocalDate ngayNghi, int accountID);

    /**
     * Kiểm tra xem nhân viên đã có yêu cầu nghỉ vào ngày này chưa
     */
    boolean existsByAccountIDAndNgayNghi(int accountID, LocalDate ngayNghi);

    /**
     * Lấy danh sách yêu cầu nghỉ sắp tới (từ ngày hiện tại)
     */
    List<YeuCauNghi> findUpcomingByAccountID(int accountID);
}
