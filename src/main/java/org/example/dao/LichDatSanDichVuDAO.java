package org.example.dao;

import org.example.model.LichDatSanDichVu;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * DAO cho bảng LichDatSan_DichVu — dịch vụ khách đặt trước cùng lúc đặt sân (Phase 8A).
 * Tách biệt hoàn toàn khỏi HoaDon/ChiTietHoaDon (xem model/LichDatSanDichVu.java).
 */
public interface LichDatSanDichVuDAO {

    /**
     * Insert 1 dòng pre-order, dùng CHUNG connection/transaction với nơi gọi
     * (để atomic với việc tạo LichDatSan trong DatSanServlet.handleDatSan).
     * Giá (unitPrice/totalPrice) phải được tính từ DB ở tầng gọi, không nhận từ client.
     */
    void insertPreOrder(Connection conn, int datSanId, int sanPhamId, int quantity,
                         BigDecimal unitPrice, BigDecimal totalPrice) throws SQLException;

    /** Danh sách dịch vụ đặt trước của 1 đơn đặt sân (dùng cho customer xem lịch sử/chi tiết). */
    List<LichDatSanDichVu> findByDatSanId(int datSanId) throws SQLException;

    /**
     * Danh sách dịch vụ đặt trước hôm nay thuộc 1 Cơ Sở, kèm thông tin đơn đặt sân
     * (tên khách, sân, giờ chơi) để lễ tân hiển thị — trả về dạng Map phẳng cho JSON.
     */
    List<Map<String, Object>> findTodayByCoSo(int coSoId) throws SQLException;

    /**
     * Cập nhật trạng thái (Đã giao / Đã hủy), chỉ cho phép khi:
     *  - dòng đang ở trạng thái 'Chờ chuẩn bị'
     *  - đơn đặt sân thuộc đúng CoSoID của nhân viên đang thao tác (chống IDOR xuyên cơ sở)
     * Trả về true nếu có 1 dòng được cập nhật.
     */
    boolean updateStatus(int id, String newStatus, Integer staffAccountId, int staffCoSoId) throws SQLException;
}
