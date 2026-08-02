package org.example.dao;

import org.example.model.DanhGia;

import java.util.List;

public interface DanhGiaDAO {

    /** Chèn đánh giá mới. Trả về DanhGiaID hoặc 0 nếu thất bại. */
    int insert(DanhGia dg);

    /** Kiểm tra customer đã đánh giá booking này chưa (unique per DatSanID + AccountID). */
    boolean existsByDatSanAndAccount(int datSanId, int accountId);

    /**
     * Kiểm tra booking thuộc customer và đã hoàn thành (TrangThai = 'Hoàn thành').
     * Phòng trường hợp customer đánh giá booking chưa xong hoặc của người khác.
     */
    boolean isBookingCompletedByCustomer(int datSanId, int accountId);

    /** Manager: lấy đánh giá của cơ sở, filter theo soSao nếu != 0, tìm theo tên KH nếu không rỗng. Phân trang. */
    List<DanhGia> findByCoSoId(int coSoId, int filterSoSao, String searchName, int page, int pageSize);

    /** Tính điểm trung bình sao cho cơ sở. */
    double avgByCoSoId(int coSoId);

    /** Customer: xem đánh giá của mình. */
    List<DanhGia> findByAccountId(int accountId, int page, int pageSize);
}
