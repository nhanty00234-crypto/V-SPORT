package org.example.dao;

import org.example.model.ThongBao;
import java.util.List;

/**
 * DAO interface cho entity ThongBao
 * Định nghĩa các phương thức truy vấn cơ bản cho bảng ThongBao
 */
public interface ThongBaoDAO {
    /**
     * Thêm thông báo mới
     */
    int insert(ThongBao thongBao);

    /**
     * Thêm thông báo mới với Connection có sẵn
     */
    int insert(java.sql.Connection conn, ThongBao thongBao) throws java.sql.SQLException;

    /**
     * Cập nhật thông báo
     */
    boolean update(ThongBao thongBao);

    /**
     * Xóa cứng thông báo theo ID (xóa khỏi DB)
     */
    boolean hardDelete(int thongBaoId);

    /**
     * Lấy thông báo theo ID
     */
    ThongBao findById(int thongBaoId);

    /**
     * Lấy tất cả thông báo (chỉ những bản ghi chưa bị xóa mềm)
     */
    List<ThongBao> findAll();

    /**
     * Lấy danh sách thông báo theo AccountID (chỉ những bản ghi chưa bị xóa mềm)
     */
    List<ThongBao> findByAccountID(int accountId);

    /**
     * Lấy N thông báo mới nhất của tài khoản (sử dụng SQL TOP limit)
     */
    List<ThongBao> findLatestByAccountId(int accountId, int limit);

    /**
     * Đếm tổng số thông báo chưa bị xóa của một tài khoản (cho phân trang)
     */
    int countByAccountId(int accountId);

    /**
     * Lấy danh sách thông báo theo AccountID có phân trang
     */
    List<ThongBao> findByAccountId(int accountId, int page, int pageSize);

    /**
     * Đếm số thông báo chưa đọc của một tài khoản
     */
    int countUnread(int accountId);

    /**
     * Đánh dấu một thông báo đã đọc — kiểm tra AccountID để chống IDOR
     */
    boolean markAsRead(int thongBaoId, int accountId);

    /**
     * Đánh dấu tất cả thông báo chưa đọc của một tài khoản là đã đọc
     */
    int markAllAsRead(int accountId);

    /**
     * Kiểm tra đã tồn tại thông báo có cùng accountId + loai + maBanGhi chưa (tránh tạo trùng)
     */
    boolean existsByAccountIdAndLoaiAndMaBanGhi(int accountId, String loaiThongBao, String maBanGhi);

    /**
     * Đánh dấu thông báo đã đọc (legacy — không kiểm tra owner, dùng nội bộ)
     */
    boolean markAsRead(int thongBaoId);

    /**
     * Xóa mềm thông báo theo ID
     */
    boolean softDelete(int thongBaoId, int actorId);

    /**
     * Khôi phục thông báo đã bị xóa mềm
     */
    boolean restore(int thongBaoId);

    /**
     * Lấy danh sách thông báo đã bị xóa mềm theo cơ sở
     */
    List<ThongBao> findDeletedByCoSo(int coSoId);

    /**
     * Lấy danh sách ID thông báo đã bị xóa mềm lâu hơn N ngày
     */
    List<Integer> findDeletedIdsOlderThan(int days);
}
