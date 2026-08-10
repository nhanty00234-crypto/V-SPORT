package org.example.service;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.KhuyenMaiDAO;
import org.example.dao.impl.KhuyenMaiDAOImpl;
import org.example.model.KhuyenMai;

import java.sql.Connection;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Nghiệp vụ khuyến mãi.
 * - Manager CRUD (luôn scope bởi CoSoID từ session, không tin client).
 * - Customer apply code (server-side validate + atomic increment trong transaction).
 */
public class KhuyenMaiService {

    private static final Logger logger = LogManager.getLogger(KhuyenMaiService.class);

    public static final String LOAI_GIAM_PHAN_TRAM = "PhanTram";
    public static final String LOAI_GIAM_SO_TIEN   = "amount";

    private final KhuyenMaiDAO dao;

    public KhuyenMaiService() {
        this(new KhuyenMaiDAOImpl());
    }

    public KhuyenMaiService(KhuyenMaiDAO dao) {
        this.dao = dao;
    }

    public static class KmResult {
        public final boolean success;
        public final String message;
        public final List<String> errors;
        public final KhuyenMai data;

        private KmResult(boolean success, String message, List<String> errors, KhuyenMai data) {
            this.success = success;
            this.message = message;
            this.errors = errors;
            this.data = data;
        }

        public static KmResult ok(String msg, KhuyenMai data) {
            return new KmResult(true, msg, List.of(), data);
        }

        public static KmResult fail(List<String> errors) {
            return new KmResult(false, null, errors, null);
        }

        public static KmResult fail(String msg) {
            return new KmResult(false, msg, List.of(msg), null);
        }
    }

    // -----------------------------------------------------------------------
    // Manager CRUD
    // -----------------------------------------------------------------------

    public List<KhuyenMai> list(int coSoId, int page) {
        return dao.findByCoSoId(coSoId, page, 20);
    }

    public int count(int coSoId) {
        return dao.countByCoSoId(coSoId);
    }

    public KhuyenMai findById(int id, int coSoId) {
        KhuyenMai km = dao.findById(id);
        if (km == null || km.getCoSoID() == null || km.getCoSoID() != coSoId) return null;
        return km;
    }

    public KmResult create(int coSoId, String maCode, String moTa, String loaiGiam,
                            double giaTriGiam, LocalDate ngayBatDau, LocalDate ngayKetThuc,
                            Integer soLanToiDa) {
        List<String> errors = validate(maCode, loaiGiam, giaTriGiam, ngayBatDau, ngayKetThuc,
                soLanToiDa, -1);
        if (!errors.isEmpty()) return KmResult.fail(errors);

        KhuyenMai km = buildKm(coSoId, maCode, moTa, loaiGiam, giaTriGiam,
                ngayBatDau, ngayKetThuc, soLanToiDa);
        int id = dao.insert(km);
        if (id <= 0) return KmResult.fail("Không thể lưu khuyến mãi. Vui lòng thử lại.");
        km.setKhuyenMaiID(id);
        logger.info("Created KhuyenMai #{} maCode={} coSoId={}", id, maCode, coSoId);
        return KmResult.ok("Đã tạo mã khuyến mãi " + maCode, km);
    }

    public KmResult update(int khuyenMaiId, int coSoId, String maCode, String moTa, String loaiGiam,
                            double giaTriGiam, LocalDate ngayBatDau, LocalDate ngayKetThuc,
                            Integer soLanToiDa, String trangThai) {
        KhuyenMai existing = dao.findById(khuyenMaiId);
        if (existing == null || existing.getCoSoID() == null || existing.getCoSoID() != coSoId) {
            return KmResult.fail("Không tìm thấy khuyến mãi trong cơ sở của bạn.");
        }
        List<String> errors = validate(maCode, loaiGiam, giaTriGiam, ngayBatDau, ngayKetThuc,
                soLanToiDa, khuyenMaiId);
        if (!errors.isEmpty()) return KmResult.fail(errors);

        existing.setMaCode(maCode);
        existing.setMoTa(moTa);
        existing.setLoaiGiam(loaiGiam);
        existing.setGiaTriGiam(giaTriGiam);
        existing.setNgayBatDau(ngayBatDau);
        existing.setNgayKetThuc(ngayKetThuc);
        existing.setSoLanToiDa(soLanToiDa);
        if (trangThai != null) existing.setTrangThai(trangThai);
        boolean ok = dao.update(existing);
        if (!ok) return KmResult.fail("Cập nhật thất bại.");
        return KmResult.ok("Đã cập nhật mã khuyến mãi " + maCode, existing);
    }

    public KmResult delete(int khuyenMaiId, int coSoId) {
        KhuyenMai existing = dao.findById(khuyenMaiId);
        if (existing == null || existing.getCoSoID() == null || existing.getCoSoID() != coSoId) {
            return KmResult.fail("Không tìm thấy khuyến mãi trong cơ sở của bạn.");
        }
        if (existing.getSoLanDaDung() > 0) {
            return KmResult.fail("Không thể xóa mã đã được sử dụng. Hãy đổi trạng thái thành 'Ngừng hoạt động'.");
        }
        boolean ok = dao.delete(khuyenMaiId, coSoId);
        if (!ok) return KmResult.fail("Xóa thất bại.");
        return KmResult.ok("Đã xóa mã khuyến mãi #" + khuyenMaiId, null);
    }

    // -----------------------------------------------------------------------
    // Customer apply
    // -----------------------------------------------------------------------

    /**
     * Validate mã khuyến mãi khi customer áp dụng.
     * Trả về KhuyenMai nếu hợp lệ, null nếu không.
     * KHÔNG tăng SoLanDaDung ở đây — tăng trong transaction booking (incrementUsage).
     */
    public KhuyenMai validateCode(String maCode, int coSoId) {
        if (maCode == null || maCode.isBlank()) return null;
        return dao.findApplicable(maCode.toUpperCase().trim(), coSoId, LocalDate.now());
    }

    /**
     * Tăng lượt dùng atomically — phải gọi trong cùng transaction với booking.
     * Trả về false nếu mã đã hết lượt hoặc không còn active.
     */
    public boolean incrementUsage(Connection conn, int khuyenMaiId) {
        return dao.incrementUsage(conn, khuyenMaiId);
    }

    /**
     * Tính giá trị giảm giá (không trust số tiền client).
     *
     * @param tongTienGoc tổng tiền trước giảm (phải đọc từ DB/server, không trust form)
     * @return giá trị giảm (không âm, không vượt tongTienGoc)
     */
    public double tinhGiamGia(KhuyenMai km, double tongTienGoc) {
        if (km == null || tongTienGoc <= 0) return 0;
        double giam;
        if (LOAI_GIAM_PHAN_TRAM.equalsIgnoreCase(km.getLoaiGiam())) {
            giam = tongTienGoc * km.getGiaTriGiam() / 100.0;
        } else {
            giam = km.getGiaTriGiam();
        }
        return Math.min(Math.max(giam, 0), tongTienGoc);
    }

    // -----------------------------------------------------------------------
    // Validation
    // -----------------------------------------------------------------------

    private List<String> validate(String maCode, String loaiGiam, double giaTriGiam,
                                   LocalDate ngayBatDau, LocalDate ngayKetThuc,
                                   Integer soLanToiDa, int excludeId) {
        List<String> errors = new ArrayList<>();
        if (maCode == null || maCode.isBlank()) {
            errors.add("Mã code không được để trống.");
        } else {
            maCode = maCode.trim().toUpperCase();
            if (maCode.length() > 50) errors.add("Mã code tối đa 50 ký tự.");
            boolean dup = (excludeId < 0) ? dao.existsByCode(maCode) : dao.existsByCodeExcluding(maCode, excludeId);
            if (dup) errors.add("Mã code '" + maCode + "' đã tồn tại.");
        }
        if (!LOAI_GIAM_PHAN_TRAM.equals(loaiGiam) && !LOAI_GIAM_SO_TIEN.equals(loaiGiam)) {
            errors.add("Loại giảm không hợp lệ (chỉ chấp nhận PhanTram hoặc SoTien).");
        } else if (LOAI_GIAM_PHAN_TRAM.equals(loaiGiam)) {
            if (giaTriGiam <= 0 || giaTriGiam > 100) errors.add("Phần trăm giảm phải trong khoảng 1–100.");
        } else {
            if (giaTriGiam <= 0) errors.add("Số tiền giảm phải lớn hơn 0.");
        }
        if (ngayBatDau == null) errors.add("Ngày bắt đầu không được để trống.");
        if (ngayKetThuc == null) errors.add("Ngày kết thúc không được để trống.");
        if (ngayBatDau != null && ngayKetThuc != null && ngayKetThuc.isBefore(ngayBatDau)) {
            errors.add("Ngày kết thúc phải sau ngày bắt đầu.");
        }
        if (soLanToiDa != null && soLanToiDa < 0) {
            errors.add("Số lần tối đa phải ≥ 0 (hoặc để trống = không giới hạn).");
        }
        return errors;
    }

    private KhuyenMai buildKm(int coSoId, String maCode, String moTa, String loaiGiam,
                                double giaTriGiam, LocalDate ngayBatDau, LocalDate ngayKetThuc,
                                Integer soLanToiDa) {
        KhuyenMai km = new KhuyenMai();
        km.setCoSoID(coSoId);
        km.setMaCode(maCode.trim().toUpperCase());
        km.setMoTa(moTa != null ? moTa.trim() : null);
        km.setLoaiGiam(loaiGiam);
        km.setGiaTriGiam(giaTriGiam);
        km.setNgayBatDau(ngayBatDau);
        km.setNgayKetThuc(ngayKetThuc);
        km.setSoLanToiDa(soLanToiDa);
        km.setSoLanDaDung(0);
        km.setTrangThai("Hoạt động");
        return km;
    }
}
