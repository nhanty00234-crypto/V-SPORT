package org.example.dao;

import org.example.model.NhomChiaTien;

import java.sql.Connection;
import java.util.List;

public interface NhomChiaTienDAO {

    int insert(Connection conn, NhomChiaTien nct);

    NhomChiaTien findById(int nhomChiaTienId);

    /** Chống IDOR: chủ booking chỉ xem/thao tác BillSplit của chính mình. */
    NhomChiaTien findByIdAndCreatedBy(int nhomChiaTienId, int accountId);

    /** Kiểm tra HoaDon đã có NhomChiaTien đang hoạt động (ACTIVE/PARTIALLY_PAID) chưa — dùng
     * unique filtered index UX_NhomChiaTien_HoaDon_Active làm nguồn sự thật cuối cùng, đây chỉ
     * là pre-check để trả lỗi thân thiện trước khi INSERT thất bại do vi phạm index. */
    NhomChiaTien findActiveByHoaDonId(int hoaDonId);

    List<NhomChiaTien> findByDatSanId(int datSanId);

    /**
     * Chuyển trạng thái, luôn kiểm tra trạng thái nguồn trong WHERE để chống double submit.
     * Trả về true chỉ khi có đúng 1 dòng bị ảnh hưởng.
     */
    boolean updateTrangThai(Connection conn, int nhomChiaTienId, String trangThaiCu, String trangThaiMoi);

    boolean updateTrangThai(int nhomChiaTienId, String trangThaiCu, String trangThaiMoi);
}
