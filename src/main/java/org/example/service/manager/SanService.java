package org.example.service.manager;

import org.example.dao.LoaiSanDAO;
import org.example.dao.SanDAO;
import org.example.dao.impl.LoaiSanDAOImpl;
import org.example.dao.impl.SanDAOImpl;
import org.example.model.LoaiSan;
import org.example.model.MonTheThao;
import org.example.model.San;
import org.example.util.BranchSecurityUtils;
import org.example.util.Constants;
import org.example.util.ValidationUtils;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

/**
 * Service layer cho quản lý sân thi đấu (Manager scope)
 */
public class SanService {

    private final SanDAO sanDAO;
    private final LoaiSanDAO loaiSanDAO;

    public SanService() {
        this.sanDAO = new SanDAOImpl();
        this.loaiSanDAO = new LoaiSanDAOImpl();
    }

    public SanService(SanDAO sanDAO, LoaiSanDAO loaiSanDAO) {
        this.sanDAO = sanDAO;
        this.loaiSanDAO = loaiSanDAO;
    }

    // ==================== DTOs ====================

    /**
     * DTO cho San (Court)
     */
    public static class SanDTO {
        private int sanId;
        private String tenSan;
        private int loaiSanId;
        private String tenLoaiSan;
        private int monTheThaoId;
        private String tenMonTheThao;
        private int coSoId;
        private String trangThai;
        private String moTa;
        private String hinhAnh;
        private BigDecimal giaKhongDen;
        private BigDecimal giaCoDen;
        private LocalTime gioBatDauLenDen;
        private LocalTime gioKetThucLenDen;

        // Getters and setters
        public int getSanId() { return sanId; }
        public void setSanId(int sanId) { this.sanId = sanId; }
        public String getTenSan() { return tenSan; }
        public void setTenSan(String tenSan) { this.tenSan = tenSan; }
        public int getLoaiSanId() { return loaiSanId; }
        public void setLoaiSanId(int loaiSanId) { this.loaiSanId = loaiSanId; }
        public String getTenLoaiSan() { return tenLoaiSan; }
        public void setTenLoaiSan(String tenLoaiSan) { this.tenLoaiSan = tenLoaiSan; }
        public int getMonTheThaoId() { return monTheThaoId; }
        public void setMonTheThaoId(int monTheThaoId) { this.monTheThaoId = monTheThaoId; }
        public String getTenMonTheThao() { return tenMonTheThao; }
        public void setTenMonTheThao(String tenMonTheThao) { this.tenMonTheThao = tenMonTheThao; }
        public int getCoSoId() { return coSoId; }
        public void setCoSoId(int coSoId) { this.coSoId = coSoId; }
        public String getTrangThai() { return trangThai; }
        public void setTrangThai(String trangThai) { this.trangThai = trangThai; }
        public String getMoTa() { return moTa; }
        public void setMoTa(String moTa) { this.moTa = moTa; }
        public String getHinhAnh() { return hinhAnh; }
        public void setHinhAnh(String hinhAnh) { this.hinhAnh = hinhAnh; }
        public BigDecimal getGiaKhongDen() { return giaKhongDen; }
        public void setGiaKhongDen(BigDecimal giaKhongDen) { this.giaKhongDen = giaKhongDen; }
        public BigDecimal getGiaCoDen() { return giaCoDen; }
        public void setGiaCoDen(BigDecimal giaCoDen) { this.giaCoDen = giaCoDen; }
        public LocalTime getGioBatDauLenDen() { return gioBatDauLenDen; }
        public void setGioBatDauLenDen(LocalTime gioBatDauLenDen) { this.gioBatDauLenDen = gioBatDauLenDen; }
        public LocalTime getGioKetThucLenDen() { return gioKetThucLenDen; }
        public void setGioKetThucLenDen(LocalTime gioKetThucLenDen) { this.gioKetThucLenDen = gioKetThucLenDen; }
    }

    /**
     * DTO cho Loại sân (Court Type)
     */
    public static class LoaiSanDTO {
        private int loaiSanId;
        private int monTheThaoId;
        private String tenMonTheThao;
        private String tenLoai;
        private BigDecimal giaKhongDen;
        private BigDecimal giaCoDen;
        private LocalTime gioBatDauLenDen;
        private LocalTime gioKetThucLenDen;
        private int coSoId;

        // Getters and setters
        public int getLoaiSanId() { return loaiSanId; }
        public void setLoaiSanId(int loaiSanId) { this.loaiSanId = loaiSanId; }
        public int getMonTheThaoId() { return monTheThaoId; }
        public void setMonTheThaoId(int monTheThaoId) { this.monTheThaoId = monTheThaoId; }
        public String getTenMonTheThao() { return tenMonTheThao; }
        public void setTenMonTheThao(String tenMonTheThao) { this.tenMonTheThao = tenMonTheThao; }
        public String getTenLoai() { return tenLoai; }
        public void setTenLoai(String tenLoai) { this.tenLoai = tenLoai; }
        public BigDecimal getGiaKhongDen() { return giaKhongDen; }
        public void setGiaKhongDen(BigDecimal giaKhongDen) { this.giaKhongDen = giaKhongDen; }
        public BigDecimal getGiaCoDen() { return giaCoDen; }
        public void setGiaCoDen(BigDecimal giaCoDen) { this.giaCoDen = giaCoDen; }
        public LocalTime getGioBatDauLenDen() { return gioBatDauLenDen; }
        public void setGioBatDauLenDen(LocalTime gioBatDauLenDen) { this.gioBatDauLenDen = gioBatDauLenDen; }
        public LocalTime getGioKetThucLenDen() { return gioKetThucLenDen; }
        public void setGioKetThucLenDen(LocalTime gioKetThucLenDen) { this.gioKetThucLenDen = gioKetThucLenDen; }
        public int getCoSoId() { return coSoId; }
        public void setCoSoId(int coSoId) { this.coSoId = coSoId; }
    }

    /**
     * Request để tạo sân mới
     */
    public static class SanCreateRequest {
        private String tenSan;
        private int loaiSanId;
        private String trangThai;
        private String moTa;
        private String hinhAnh;

        // Getters and setters
        public String getTenSan() { return tenSan; }
        public void setTenSan(String tenSan) { this.tenSan = tenSan; }
        public int getLoaiSanId() { return loaiSanId; }
        public void setLoaiSanId(int loaiSanId) { this.loaiSanId = loaiSanId; }
        public String getTrangThai() { return trangThai; }
        public void setTrangThai(String trangThai) { this.trangThai = trangThai; }
        public String getMoTa() { return moTa; }
        public void setMoTa(String moTa) { this.moTa = moTa; }
        public String getHinhAnh() { return hinhAnh; }
        public void setHinhAnh(String hinhAnh) { this.hinhAnh = hinhAnh; }
    }

    /**
     * Request để cập nhật sân
     */
    public static class SanUpdateRequest {
        private String tenSan;
        private int loaiSanId;
        private String trangThai;
        private String moTa;
        private String hinhAnh;

        // Getters and setters
        public String getTenSan() { return tenSan; }
        public void setTenSan(String tenSan) { this.tenSan = tenSan; }
        public int getLoaiSanId() { return loaiSanId; }
        public void setLoaiSanId(int loaiSanId) { this.loaiSanId = loaiSanId; }
        public String getTrangThai() { return trangThai; }
        public void setTrangThai(String trangThai) { this.trangThai = trangThai; }
        public String getMoTa() { return moTa; }
        public void setMoTa(String moTa) { this.moTa = moTa; }
        public String getHinhAnh() { return hinhAnh; }
        public void setHinhAnh(String hinhAnh) { this.hinhAnh = hinhAnh; }
    }

    /**
     * Request để tạo/cập nhật loại sân
     */
    public static class LoaiSanRequest {
        private String tenLoai;
        private int monTheThaoId;
        private BigDecimal giaKhongDen;
        private BigDecimal giaCoDen;
        private LocalTime gioBatDauLenDen;
        private LocalTime gioKetThucLenDen;

        // Getters and setters
        public String getTenLoai() { return tenLoai; }
        public void setTenLoai(String tenLoai) { this.tenLoai = tenLoai; }
        public int getMonTheThaoId() { return monTheThaoId; }
        public void setMonTheThaoId(int monTheThaoId) { this.monTheThaoId = monTheThaoId; }
        public BigDecimal getGiaKhongDen() { return giaKhongDen; }
        public void setGiaKhongDen(BigDecimal giaKhongDen) { this.giaKhongDen = giaKhongDen; }
        public BigDecimal getGiaCoDen() { return giaCoDen; }
        public void setGiaCoDen(BigDecimal giaCoDen) { this.giaCoDen = giaCoDen; }
        public LocalTime getGioBatDauLenDen() { return gioBatDauLenDen; }
        public void setGioBatDauLenDen(LocalTime gioBatDauLenDen) { this.gioBatDauLenDen = gioBatDauLenDen; }
        public LocalTime getGioKetThucLenDen() { return gioKetThucLenDen; }
        public void setGioKetThucLenDen(LocalTime gioKetThucLenDen) { this.gioKetThucLenDen = gioKetThucLenDen; }
    }

    // ==================== READ OPERATIONS ====================

    /**
     * Lấy danh sách sân của cơ sở
     */
    public List<San> getSansByCoSo(int coSoId) {
        return sanDAO.getSansByCoSo(coSoId);
    }

    /**
     * Lấy sân theo ID với validation branch access
     */
    public San getSanById(int sanId, int managerCoSoId) {
        San san = sanDAO.getSanById(sanId);
        BranchSecurityUtils.getEntityOrThrow(san, "Sân");

        BranchSecurityUtils.checkBranchAccess(san.getCoSoID(), managerCoSoId);

        return san;
    }

    /**
     * Lấy danh sách loại sân của cơ sở
     */
    public List<LoaiSan> getLoaiSansByCoSo(int coSoId) {
        return loaiSanDAO.getLoaiSansByCoSo(coSoId);
    }

    /**
     * Lấy tất cả môn thể thao
     */
    public List<MonTheThao> getAllMonTheThao() {
        return loaiSanDAO.getAllMonTheThao();
    }

    /**
     * Lấy loại sân theo ID với validation branch access
     */
    public LoaiSan getLoaiSanById(int loaiSanId, int managerCoSoId) {
        LoaiSan ls = loaiSanDAO.getLoaiSanById(loaiSanId);
        BranchSecurityUtils.getEntityOrThrow(ls, "Loại sân");

        BranchSecurityUtils.validateBranchAccess(ls.getCoSoID(), managerCoSoId, "Loại sân");

        return ls;
    }

    // ==================== SAN OPERATIONS ====================

    /**
     * Tạo sân mới
     */
    public San createSan(SanCreateRequest request, int managerCoSoId) {
        validateSanRequest(request);

        San san = new San();
        updateSanFromRequest(san, request);
        san.setCoSoID(managerCoSoId);

        sanDAO.insert(san);
        return san;
    }

    /**
     * Cập nhật sân
     */
    public void updateSan(int sanId, SanUpdateRequest request, int managerCoSoId) {
        San existing = sanDAO.getSanById(sanId);
        BranchSecurityUtils.getEntityOrThrow(existing, "Sân");
        BranchSecurityUtils.checkBranchAccess(existing.getCoSoID(), managerCoSoId);

        validateSanRequest(request);

        updateSanFromRequest(existing, request);
        // Ensure coSoId không thay đổi
        existing.setCoSoID(managerCoSoId);

        sanDAO.update(existing);
    }

    /**
     * Xóa sân (soft delete - chuyển trạng thái)
     */
    public void deleteSan(int sanId, int managerCoSoId) {
        San san = sanDAO.getSanById(sanId);
        BranchSecurityUtils.getEntityOrThrow(san, "Sân");
        BranchSecurityUtils.checkBranchAccess(san.getCoSoID(), managerCoSoId);

        // Check if court type has any other courts
        Long courtCount = sanDAO.countSansByLoaiSanId(san.getLoaiSanID());
        if (courtCount > 0) {
            throw new IllegalArgumentException(
                "Không thể xóa loại sân này vì đang có " + courtCount + " sân liên kết với nó"
            );
        }

        san.setTrangThai(Constants.TRANG_THAI_SAN_TAM_DONG);
        sanDAO.update(san);
    }

    /**
     * Cập nhật trạng thái sân
     */
    public void updateSanStatus(int sanId, String newStatus, int managerCoSoId) {
        San san = sanDAO.getSanById(sanId);
        BranchSecurityUtils.getEntityOrThrow(san, "Sân");
        BranchSecurityUtils.checkBranchAccess(san.getCoSoID(), managerCoSoId);

        san.setTrangThai(newStatus);
        sanDAO.update(san);
    }

    // ==================== LOAI SAN OPERATIONS ====================

    /**
     * Tạo loại sân mới
     */
    public LoaiSan createLoaiSan(LoaiSanRequest request, int managerCoSoId) {
        validateLoaiSanRequest(request);

        LoaiSan ls = new LoaiSan();
        updateLoaiSanFromRequest(ls, request);
        ls.setCoSoID(managerCoSoId);

        loaiSanDAO.insert(ls);
        return ls;
    }

    /**
     * Cập nhật loại sân
     */
    public void updateLoaiSan(int loaiSanId, LoaiSanRequest request, int managerCoSoId) {
        LoaiSan existing = loaiSanDAO.getLoaiSanById(loaiSanId);
        BranchSecurityUtils.getEntityOrThrow(existing, "Loại sân");
        BranchSecurityUtils.checkBranchAccess(existing.getCoSoID(), managerCoSoId);

        validateLoaiSanRequest(request);

        updateLoaiSanFromRequest(existing, request);
        existing.setCoSoID(managerCoSoId); // Lock to manager's branch

        loaiSanDAO.update(existing);
    }

    /**
     * Xóa loại sân (hard delete)
     */
    public void deleteLoaiSan(int loaiSanId, int managerCoSoId) {
        LoaiSan ls = loaiSanDAO.getLoaiSanById(loaiSanId);
        BranchSecurityUtils.getEntityOrThrow(ls, "Loại sân");
        BranchSecurityUtils.checkBranchAccess(ls.getCoSoID(), managerCoSoId);

        // Check if any courts use this type
        Long courtCount = sanDAO.countSansByLoaiSanId(loaiSanId);
        if (courtCount > 0) {
            throw new IllegalArgumentException(
                "Không thể xóa loại sân này vì đang có " + courtCount + " sân liên kết với nó"
            );
        }

        loaiSanDAO.delete(loaiSanId);
    }

    // ==================== VALIDATION HELPERS ====================

    private void validateSanRequest(SanCreateRequest req) {
        Map<String, String> errors = new java.util.HashMap<>();

        if (req.getTenSan() == null || req.getTenSan().trim().isEmpty()) {
            errors.put("tenSan", "Tên sân không được để trống");
        }

        if (req.getLoaiSanId() <= 0) {
            errors.put("loaiSanId", "Phải chọn loại sân");
        }

        if (!errors.isEmpty()) {
            throw new IllegalArgumentException(errors.toString());
        }
    }

    private void validateSanRequest(SanUpdateRequest req) {
        validateSanRequest(new SanCreateRequest() {{
            setTenSan(req.getTenSan());
            setLoaiSanId(req.getLoaiSanId());
        }});
    }

    private void validateLoaiSanRequest(LoaiSanRequest req) {
        Map<String, String> errors = new java.util.HashMap<>();

        if (req.getTenLoai() == null || req.getTenLoai().trim().isEmpty()) {
            errors.put("tenLoai", "Tên loại sân không được để trống");
        }

        if (req.getMonTheThaoId() <= 0) {
            errors.put("monTheThaoId", "Phải chọn môn thể thao");
        }

        ValidationUtils.validatePositiveNumber(req.getGiaKhongDen(), "giaKhongDen");
        ValidationUtils.validatePositiveNumber(req.getGiaCoDen(), "giaCoDen");

        if (req.getGiaCoDen() != null && req.getGiaKhongDen() != null) {
            if (req.getGiaCoDen().compareTo(req.getGiaKhongDen()) < 0) {
                errors.put("giaCoDen", "Giá tối (có bật đèn) không được thấp hơn giá ngày (không đèn)");
            }
        }

        if (req.getGioBatDauLenDen() == null) {
            errors.put("gioBatDauLenDen", "Giờ bắt đầu lên đèn không được để trống");
        }
        if (req.getGioKetThucLenDen() == null) {
            errors.put("gioKetThucLenDen", "Giờ kết thúc lên đèn không được để trống");
        }

        if (req.getGioBatDauLenDen() != null && req.getGioKetThucLenDen() != null) {
            if (!req.getGioBatDauLenDen().isBefore(req.getGioKetThucLenDen())) {
                errors.put("gioBatDauLenDen", "Giờ bắt đầu lên đèn phải trước giờ kết thúc");
            }
        }

        if (!errors.isEmpty()) {
            throw new IllegalArgumentException(errors.toString());
        }
    }

    // ==================== MAPPER HELPERS ====================

    private void updateSanFromRequest(San san, SanCreateRequest req) {
        san.setTenSan(req.getTenSan());
        san.setLoaiSanID(req.getLoaiSanId());
        san.setTrangThai(req.getTrangThai() != null ? req.getTrangThai() : Constants.TRANG_THAI_SAN_SAN_SANG);
        san.setMoTa(req.getMoTa());
        san.setHinhAnh(req.getHinhAnh());
    }

    private void updateSanFromRequest(San san, SanUpdateRequest req) {
        san.setTenSan(req.getTenSan());
        san.setLoaiSanID(req.getLoaiSanId());
        if (req.getTrangThai() != null) {
            san.setTrangThai(req.getTrangThai());
        }
        san.setMoTa(req.getMoTa());
        san.setHinhAnh(req.getHinhAnh());
    }

    private void updateLoaiSanFromRequest(LoaiSan ls, LoaiSanRequest req) {
        ls.setTenLoai(req.getTenLoai());
        ls.setMonTheThaoID(req.getMonTheThaoId());
        ls.setGiaKhongDen(req.getGiaKhongDen() != null ? req.getGiaKhongDen().doubleValue() : 0.0);
        ls.setGiaCoDen(req.getGiaCoDen() != null ? req.getGiaCoDen().doubleValue() : 0.0);
        ls.setGioBatDauLenDen(req.getGioBatDauLenDen());
        ls.setGioKetThucLenDen(req.getGioKetThucLenDen());
    }
}
