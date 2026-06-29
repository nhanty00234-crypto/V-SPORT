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
     * Xóa thông báo theo ID
     */
    boolean delete(int thongBaoId);

    /**
     * Lấy thông báo theo ID
     */
    ThongBao findById(int thongBaoId);

    /**
     * Lấy tất cả thông báo
     */
    List<ThongBao> findAll();

    /**
     * Lấy danh sách thông báo theo AccountID
     */
    List<ThongBao> findByAccountID(int accountId);

    /**
     * Đánh dấu thông báo đã đọc
     */
    boolean markAsRead(int thongBaoId);
}
