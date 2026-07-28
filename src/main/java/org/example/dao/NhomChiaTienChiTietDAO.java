package org.example.dao;

import org.example.model.NhomChiaTienChiTiet;

import java.math.BigDecimal;
import java.sql.Connection;
import java.util.List;

public interface NhomChiaTienChiTietDAO {

    int insert(Connection conn, NhomChiaTienChiTiet ct);

    List<NhomChiaTienChiTiet> findByNhomChiaTienId(int nhomChiaTienId);

    NhomChiaTienChiTiet findById(int chiTietId);

    /** Participant chỉ xem đúng Share của mình qua token — không đoán được, không lộ share khác. */
    NhomChiaTienChiTiet findByShareToken(String shareToken);

    /** Chống IDOR: chỉ trả nếu ChiTiet thuộc đúng NhomChiaTienID (dùng khi Customer chủ booking thao tác). */
    NhomChiaTienChiTiet findByIdAndNhomChiaTienId(int chiTietId, int nhomChiaTienId);

    int countByNhomChiaTienId(int nhomChiaTienId);

    int countPaidByNhomChiaTienId(int nhomChiaTienId);

    BigDecimal sumPaidByNhomChiaTienId(int nhomChiaTienId);

    /**
     * Chuyển trạng thái Share, luôn kiểm tra trạng thái nguồn — chống thanh toán 2 lần
     * (double payment) và double submit đổi trạng thái.
     */
    boolean updateTrangThai(Connection conn, int chiTietId, String trangThaiCu, String trangThaiMoi,
                            String paymentMethod, String paymentTransactionId, Integer payerAccountId,
                            Integer confirmedByStaffId);

    boolean updateTrangThai(int chiTietId, String trangThaiCu, String trangThaiMoi,
                            String paymentMethod, String paymentTransactionId, Integer payerAccountId,
                            Integer confirmedByStaffId);

    /** Vô hiệu hóa toàn bộ share cũ khi hủy NhomChiaTien (chuyển sang CANCELLED trong transaction). */
    int cancelAllByNhomChiaTienId(Connection conn, int nhomChiaTienId);
}
