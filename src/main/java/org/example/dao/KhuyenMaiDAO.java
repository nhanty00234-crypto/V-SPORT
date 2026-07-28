package org.example.dao;

import org.example.model.KhuyenMai;

import java.util.List;

/**
 * DAO thuần CRUD cho bảng KhuyenMai, phục vụ giao diện Manager quản lý mã khuyến mãi.
 * Không chứa logic tính giảm giá — việc validate/tính toán khi áp mã vẫn thuộc
 * org.example.service.customer.PromotionService (không tạo service tính giá thứ hai ở đây).
 */
public interface KhuyenMaiDAO {

    List<KhuyenMai> findByCoSoId(int coSoId);

    KhuyenMai findByIdAndCoSoId(int khuyenMaiId, int coSoId);

    boolean existsByCode(String maCode, Integer excludeKhuyenMaiId);

    int insert(KhuyenMai km);

    boolean update(KhuyenMai km, int coSoId);

    boolean updateTrangThai(int khuyenMaiId, int coSoId, String trangThai);
}
