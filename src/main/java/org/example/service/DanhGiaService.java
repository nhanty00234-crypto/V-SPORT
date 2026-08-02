package org.example.service;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.DanhGiaDAO;
import org.example.dao.impl.DanhGiaDAOImpl;
import org.example.model.DanhGia;
import java.util.ArrayList;
import java.util.List;

/**
 * Nghiệp vụ đánh giá sân.
 * - Customer: chỉ review booking đã hoàn thành của chính mình, mỗi booking 1 lần.
 * - Manager: xem review cơ sở mình, filter sao, không sửa nội dung.
 * - BinhLuan được lưu dạng raw (đã validate); escape tại output bằng c:out hoặc encoder.
 */
public class DanhGiaService {

    private static final Logger logger = LogManager.getLogger(DanhGiaService.class);

    private final DanhGiaDAO dao;

    public DanhGiaService() {
        this(new DanhGiaDAOImpl());
    }

    public DanhGiaService(DanhGiaDAO dao) {
        this.dao = dao;
    }

    public static class DgResult {
        public final boolean success;
        public final String message;
        public final List<String> errors;

        private DgResult(boolean success, String message, List<String> errors) {
            this.success = success; this.message = message; this.errors = errors;
        }

        public static DgResult ok(String msg) { return new DgResult(true, msg, List.of()); }
        public static DgResult fail(String msg) { return new DgResult(false, msg, List.of(msg)); }
        public static DgResult failList(List<String> errors) { return new DgResult(false, null, errors); }
    }

    /**
     * Customer gửi đánh giá.
     * Validate: booking hoàn thành + thuộc customer + chưa đánh giá + sao hợp lệ + bình luận không rỗng.
     */
    public DgResult submitReview(int datSanId, int accountId, int soSao, String binhLuan) {
        List<String> errors = new ArrayList<>();

        if (soSao < 1 || soSao > 5) errors.add("Số sao phải từ 1 đến 5.");

        String binhLuanSafe = (binhLuan != null) ? binhLuan.trim() : "";
        if (binhLuanSafe.isEmpty()) errors.add("Bình luận không được để trống.");
        else if (binhLuanSafe.length() > 255) errors.add("Bình luận tối đa 255 ký tự.");

        if (!errors.isEmpty()) return DgResult.failList(errors);

        // Kiểm tra booking hoàn thành + owner (không trust client)
        if (!dao.isBookingCompletedByCustomer(datSanId, accountId)) {
            return DgResult.fail("Chỉ có thể đánh giá đơn đặt sân đã hoàn thành của bạn.");
        }
        // Unique per booking + customer
        if (dao.existsByDatSanAndAccount(datSanId, accountId)) {
            return DgResult.fail("Bạn đã đánh giá đơn đặt sân này rồi.");
        }

        DanhGia dg = new DanhGia();
        dg.setDatSanId(datSanId);
        dg.setAccountIdNguoiDanhGia(accountId);
        dg.setSoSao(soSao);
        dg.setBinhLuan(binhLuanSafe); // raw text; escape at JSP output via c:out

        int id = dao.insert(dg);
        if (id <= 0) return DgResult.fail("Không thể lưu đánh giá. Vui lòng thử lại.");

        logger.info("Customer {} đã đánh giá DatSan #{}: {} sao", accountId, datSanId, soSao);
        return DgResult.ok("Cảm ơn bạn đã đánh giá!");
    }

    /** Manager: lấy danh sách đánh giá. filterSoSao = 0 → tất cả, searchName null/"" → không lọc tên. */
    public List<DanhGia> getForManager(int coSoId, int filterSoSao, String searchName, int page) {
        return dao.findByCoSoId(coSoId, filterSoSao, searchName, page, 20);
    }

    public double avgRating(int coSoId) {
        return dao.avgByCoSoId(coSoId);
    }

    public List<DanhGia> getByCustomer(int accountId, int page) {
        return dao.findByAccountId(accountId, page, 20);
    }

}
