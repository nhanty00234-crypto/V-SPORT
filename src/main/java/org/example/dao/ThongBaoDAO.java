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
     * Đánh dấu thông báo đã đọc
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
