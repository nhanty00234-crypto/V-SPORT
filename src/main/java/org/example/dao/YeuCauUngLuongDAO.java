package org.example.dao;

import org.example.model.YeuCauUngLuong;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public interface YeuCauUngLuongDAO {

    /** Tạo yêu cầu ứng lương mới (trạng thái ChoDuyet), trả về ID vừa sinh. */
    int insert(YeuCauUngLuong yc) throws Exception;

    /** Lịch sử yêu cầu ứng của một nhân viên, mới nhất trước. */
    List<YeuCauUngLuong> listByAccount(int accountId) throws Exception;

    /** Yêu cầu ứng của cả cơ sở; trangThai = null nghĩa là không lọc. */
    List<YeuCauUngLuong> listByCoSo(int coSoId, String trangThai) throws Exception;

    /** Một yêu cầu THUỘC cơ sở này; null nếu không tồn tại hoặc thuộc cơ sở khác. */
    YeuCauUngLuong findById(int id, int coSoId) throws Exception;

    /**
     * Manager duyệt/từ chối. Chỉ thành công khi yêu cầu còn ở trạng thái ChoDuyet —
     * trả false nếu đã bị xử lý trước đó (chống bấm duyệt hai lần).
     */
    boolean xuLy(int id, int coSoId, String trangThaiMoi, String ghiChuQuanLy, int xuLyBy) throws Exception;

    /** Nhân viên tự huỷ yêu cầu của chính mình khi còn ChoDuyet. */
    boolean huyBoiNhanVien(int id, int accountId) throws Exception;

    /** Tổng tiền đã DUYỆT trong khoảng ngày (inclusive) — chính là TongKhauTru của kỳ. */
    BigDecimal tongDaDuyetTrongKhoang(int accountId, LocalDate tuNgay, LocalDate denNgay) throws Exception;

    /** Tổng tiền đã duyệt nhưng CHƯA bị khấu trừ vào kỳ lương nào đã phát — dùng để kiểm hạn mức. */
    BigDecimal tongDaDuyetChuaKhauTru(int accountId) throws Exception;
}
