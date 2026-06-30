package org.example.service.manager;

import org.example.dao.CaLamViecDAO;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.CaLamViecAvailabilityDAO;
import org.example.dao.CaLamViecSwapRequestDAO;
import org.example.dao.CaLamViecAuditDAO;
import org.example.dao.impl.CaLamViecDAOImpl;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.dao.impl.CaLamViecAvailabilityDAOImpl;
import org.example.dao.impl.CaLamViecSwapRequestDAOImpl;
import org.example.dao.impl.CaLamViecAuditDAOImpl;
import org.example.model.CaLamViec;
import org.example.model.TaiKhoan;
import org.example.model.CaLamViecAvailability;
import org.example.model.CaLamViecSwapRequest;
import org.example.model.CaLamViecAudit;
import org.example.util.BranchSecurityUtils;
import org.example.util.Constants;
import org.example.util.ValidationUtils;
import org.example.util.CaLamValidationEngine;
import org.example.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;

/**
 * Service layer cho quản lý ca làm việc (Manager scope)
 */
public class CaLamService {

    private final CaLamViecDAO caLamViecDAO;
    private final TaiKhoanDAO taiKhoanDAO;
    private final CaLamViecAvailabilityDAO availabilityDAO;
    private final CaLamViecSwapRequestDAO swapRequestDAO;
    private final CaLamViecAuditDAO auditDAO;
    private final org.example.dao.CoSoDAO coSoDAO;
    private final CaLamValidationEngine validationEngine;

    public CaLamService() {
        this.caLamViecDAO = new CaLamViecDAOImpl();
        this.taiKhoanDAO = new TaiKhoanDAOImpl();
        this.availabilityDAO = new CaLamViecAvailabilityDAOImpl();
        this.swapRequestDAO = new CaLamViecSwapRequestDAOImpl();
        this.auditDAO = new CaLamViecAuditDAOImpl();
        this.coSoDAO = new org.example.dao.impl.CoSoDAOImpl();
        this.validationEngine = new CaLamValidationEngine();
    }

    public CaLamService(CaLamViecDAO caLamViecDAO, TaiKhoanDAO taiKhoanDAO) {
        this.caLamViecDAO = caLamViecDAO;
        this.taiKhoanDAO = taiKhoanDAO;
        this.availabilityDAO = new CaLamViecAvailabilityDAOImpl();
        this.swapRequestDAO = new CaLamViecSwapRequestDAOImpl();
        this.auditDAO = new CaLamViecAuditDAOImpl();
        this.coSoDAO = new org.example.dao.impl.CoSoDAOImpl();
        this.validationEngine = new CaLamValidationEngine();
    }

    // ==================== DTOs ====================

    /**
     * DTO cho ca làm việc
     */
    public static class CaLamDTO {
        private int caLamViecId;
        private int accountId;
        private String tenNhanVien;
        private int coSoId;
        private LocalDate ngayLam;
        private LocalTime gioBatDau;
        private LocalTime gioKetThuc;
        private String ghiChu;
        private String tenCa;
        private String viTri;
        private String trangThai;
        private int gioNghi;

        // Getters and setters
        public int getCaLamViecId() { return caLamViecId; }
        public void setCaLamViecId(int caLamViecId) { this.caLamViecId = caLamViecId; }
        public int getAccountId() { return accountId; }
        public void setAccountId(int accountId) { this.accountId = accountId; }
        public String getTenNhanVien() { return tenNhanVien; }
        public void setTenNhanVien(String tenNhanVien) { this.tenNhanVien = tenNhanVien; }
        public int getCoSoId() { return coSoId; }
        public void setCoSoId(int coSoId) { this.coSoId = coSoId; }
        public LocalDate getNgayLam() { return ngayLam; }
        public void setNgayLam(LocalDate ngayLam) { this.ngayLam = ngayLam; }
        public LocalTime getGioBatDau() { return gioBatDau; }
        public void setGioBatDau(LocalTime gioBatDau) { this.gioBatDau = gioBatDau; }
        public LocalTime getGioKetThuc() { return gioKetThuc; }
        public void setGioKetThuc(LocalTime gioKetThuc) { this.gioKetThuc = gioKetThuc; }
        public String getGhiChu() { return ghiChu; }
        public void setGhiChu(String ghiChu) { this.ghiChu = ghiChu; }
        public String getTenCa() { return tenCa; }
        public void setTenCa(String tenCa) { this.tenCa = tenCa; }
        public String getViTri() { return viTri; }
        public void setViTri(String viTri) { this.viTri = viTri; }
        public String getTrangThai() { return trangThai; }
        public void setTrangThai(String trangThai) { this.trangThai = trangThai; }
        public int getGioNghi() { return gioNghi; }
        public void setGioNghi(int gioNghi) { this.gioNghi = gioNghi; }
    }

    /**
     * Request object để tạo/cập nhật ca làm
     */
    public static class CaLamRequest {
        private int accountId;
        private int coSoId; // Dynamic branch
        private LocalDate ngayLam;
        private LocalTime gioBatDau;
        private LocalTime gioKetThuc;
        private String ghiChu;
        private String tenCa;
        private String viTri;
        private String trangThai;
        private int gioNghi;
        
        // Recurring shifts support
        private String repeatType = "none"; // none, daily, weekly
        private LocalDate repeatUntil;

        // Getters and setters
        public int getAccountId() { return accountId; }
        public void setAccountId(int accountId) { this.accountId = accountId; }
        public int getCoSoId() { return coSoId; }
        public void setCoSoId(int coSoId) { this.coSoId = coSoId; }
        public LocalDate getNgayLam() { return ngayLam; }
        public void setNgayLam(LocalDate ngayLam) { this.ngayLam = ngayLam; }
        public LocalTime getGioBatDau() { return gioBatDau; }
        public void setGioBatDau(LocalTime gioBatDau) { this.gioBatDau = gioBatDau; }
        public LocalTime getGioKetThuc() { return gioKetThuc; }
        public void setGioKetThuc(LocalTime gioKetThuc) { this.gioKetThuc = gioKetThuc; }
        public String getGhiChu() { return ghiChu; }
        public void setGhiChu(String ghiChu) { this.ghiChu = ghiChu; }
        public String getTenCa() { return tenCa; }
        public void setTenCa(String tenCa) { this.tenCa = tenCa; }
        public String getViTri() { return viTri; }
        public void setViTri(String viTri) { this.viTri = viTri; }
        public String getTrangThai() { return trangThai; }
        public void setTrangThai(String trangThai) { this.trangThai = trangThai; }
        public int getGioNghi() { return gioNghi; }
        public void setGioNghi(int gioNghi) { this.gioNghi = gioNghi; }
        public String getRepeatType() { return repeatType; }
        public void setRepeatType(String repeatType) { this.repeatType = repeatType; }
        public LocalDate getRepeatUntil() { return repeatUntil; }
        public void setRepeatUntil(LocalDate repeatUntil) { this.repeatUntil = repeatUntil; }
    }

    // ==================== READ OPERATIONS ====================

    /**
     * Lấy danh sách ca làm việc của cơ sở
     */
    public List<CaLamViec> getShiftsByBranch(int coSoId) {
        return caLamViecDAO.getCaByCoSo(coSoId);
    }

    /**
     * Lấy ca làm việc theo ID với branch validation
     */
    public CaLamViec getShiftById(int caLamViecId, int managerCoSoId) {
        CaLamViec ca = caLamViecDAO.getCaById(caLamViecId);
        BranchSecurityUtils.getEntityOrThrow(ca, "Ca làm việc");

        BranchSecurityUtils.checkBranchAccess(ca.getCoSoId(), managerCoSoId);

        return ca;
    }

    /**
     * Lấy danh sách nhân viên có thể phân ca (không phải Admin/Manager)
     */
    public List<TaiKhoan> getStaffAvailableForShift(int coSoId) {
        return taiKhoanDAO.getAccountsByCoSoAndRoleNotIn(
            coSoId,
            List.of(Constants.ROLE_ADMIN, Constants.ROLE_MANAGER)
        );
    }

    // ==================== CRUD OPERATIONS ====================

    /**
     * Tạo ca làm mới
     */
    public void createShift(CaLamRequest request, int managerCoSoId) {
        createShift(request, managerCoSoId, managerCoSoId);
    }

    public void createShift(CaLamRequest request, int managerCoSoId, int actorId) {
        validateShiftRequest(request);

        // Check nhân viên
        TaiKhoan staff = taiKhoanDAO.getAccountById(request.getAccountId());
        if (staff == null) {
            throw new IllegalArgumentException("Nhân viên không tồn tại");
        }

        int targetCoSoId = request.getCoSoId() > 0 ? request.getCoSoId() : managerCoSoId;

        // Collect all dates to generate shifts
        List<LocalDate> datesToSchedule = new ArrayList<>();
        datesToSchedule.add(request.getNgayLam());

        if (request.getRepeatType() != null && !"none".equalsIgnoreCase(request.getRepeatType()) && request.getRepeatUntil() != null) {
            LocalDate current = request.getNgayLam();
            LocalDate until = request.getRepeatUntil();
            if (until.isBefore(current)) {
                throw new IllegalArgumentException("Ngày kết thúc lặp lại phải sau ngày bắt đầu!");
            }
            if (until.isAfter(current.plusMonths(3))) {
                throw new IllegalArgumentException("Chỉ cho phép lặp lại tối đa trong vòng 3 tháng!");
            }
            if ("daily".equalsIgnoreCase(request.getRepeatType())) {
                while (current.isBefore(until)) {
                    current = current.plusDays(1);
                    datesToSchedule.add(current);
                }
            } else if ("weekly".equalsIgnoreCase(request.getRepeatType())) {
                while (current.isBefore(until)) {
                    current = current.plusWeeks(1);
                    if (!current.isAfter(until)) {
                        datesToSchedule.add(current);
                    }
                }
            }
        }

        // Validate all generated dates using validationEngine
        List<String> allErrors = new ArrayList<>();
        List<CaLamViec> shiftsToCreate = new ArrayList<>();

        for (LocalDate date : datesToSchedule) {
            CaLamValidationEngine.ValidationResult valRes = validationEngine.validateShift(
                    request.getAccountId(), date, request.getGioBatDau(), request.getGioKetThuc(), request.getGioNghi(), null
            );
            if (!valRes.isValid()) {
                allErrors.add(date.toString() + ": " + String.join(", ", valRes.getErrors()));
            } else {
                CaLamViec ca = new CaLamViec();
                ca.setAccountId(request.getAccountId());
                ca.setCoSoId(targetCoSoId);
                ca.setNgayLam(date);
                ca.setGioBatDau(request.getGioBatDau());
                ca.setGioKetThuc(request.getGioKetThuc());
                ca.setGhiChu(request.getGhiChu());
                ca.setTenCa(request.getTenCa() != null ? request.getTenCa() : "Tùy chỉnh");
                ca.setViTri(request.getViTri());
                String initialStatus = request.getTrangThai() != null ? request.getTrangThai() : "Draft";
                ca.setTrangThai(initialStatus);
                ca.setPublished("Published".equals(initialStatus) || "Confirmed".equals(initialStatus));
                ca.setGioNghi(request.getGioNghi());
                
                int thuVal = date.getDayOfWeek().getValue() + 1; // Mon is 1 -> 2 in DB logic
                ca.setThu(thuVal);

                shiftsToCreate.add(ca);
            }
        }

        if (!allErrors.isEmpty()) {
            throw new IllegalArgumentException("Lỗi xung đột lịch:\n- " + String.join("\n- ", allErrors));
        }

        for (CaLamViec ca : shiftsToCreate) {
            boolean success = caLamViecDAO.addCaLamViec(ca);
            if (!success) {
                throw new IllegalArgumentException("Thêm ca làm việc thất bại cho ngày " + ca.getNgayLam());
            }

            // Log audit log
            CaLamViecAudit audit = new CaLamViecAudit();
            audit.setCaLamViecId(ca.getCaLamViecId());
            audit.setThaoTac("INSERT");
            audit.setNguoiThucHien(actorId);
            audit.setGiaTriMoi(ca.toString());
            audit.setLyDo("Thêm ca làm mới bởi quản lý" + (datesToSchedule.size() > 1 ? " (Lặp lại)" : ""));
            auditDAO.insert(audit);
        }
    }

    /**
     * Cập nhật ca làm
     */
    public void updateShift(int caLamViecId, CaLamRequest request, int managerCoSoId) {
        updateShift(caLamViecId, request, managerCoSoId, managerCoSoId, "Cập nhật ca làm");
    }

    public void updateShift(int caLamViecId, CaLamRequest request, int managerCoSoId, int actorId, String changeReason) {
        CaLamViec existing = caLamViecDAO.getCaById(caLamViecId);
        BranchSecurityUtils.getEntityOrThrow(existing, "Ca làm việc");
        BranchSecurityUtils.checkBranchAccess(existing.getCoSoId(), managerCoSoId);

        validateShiftRequest(request);

        // Check nhân viên
        TaiKhoan staff = taiKhoanDAO.getAccountById(request.getAccountId());
        if (staff == null) {
            throw new IllegalArgumentException("Nhân viên không tồn tại");
        }

        // Run validation engine
        CaLamValidationEngine.ValidationResult valRes = validationEngine.validateShift(
                request.getAccountId(), request.getNgayLam(), request.getGioBatDau(), request.getGioKetThuc(), request.getGioNghi(), caLamViecId
        );
        if (!valRes.isValid()) {
            throw new IllegalArgumentException("Lỗi xung đột lịch:\n- " + String.join("\n- ", valRes.getErrors()));
        }

        String oldValue = existing.toString();

        existing.setAccountId(request.getAccountId());
        existing.setNgayLam(request.getNgayLam());
        existing.setGioBatDau(request.getGioBatDau());
        existing.setGioKetThuc(request.getGioKetThuc());
        existing.setGhiChu(request.getGhiChu());
        existing.setCoSoId(request.getCoSoId() > 0 ? request.getCoSoId() : managerCoSoId);
        existing.setTenCa(request.getTenCa() != null ? request.getTenCa() : "Tùy chỉnh");
        existing.setViTri(request.getViTri());
        if (request.getTrangThai() != null) {
            existing.setTrangThai(request.getTrangThai());
        }
        existing.setGioNghi(request.getGioNghi());
        int thuVal = request.getNgayLam().getDayOfWeek().getValue() + 1;
        existing.setThu(thuVal);

        boolean success = caLamViecDAO.updateCaLamViec(existing);
        if (!success) {
            throw new IllegalArgumentException("Cập nhật ca làm việc thất bại");
        }

        // Log audit log
        CaLamViecAudit audit = new CaLamViecAudit();
        audit.setCaLamViecId(existing.getCaLamViecId());
        audit.setThaoTac("UPDATE");
        audit.setNguoiThucHien(actorId);
        audit.setGiaTriCu(oldValue);
        audit.setGiaTriMoi(existing.toString());
        audit.setLyDo(changeReason != null && !changeReason.trim().isEmpty() ? changeReason : "Cập nhật ca làm bởi quản lý");
        auditDAO.insert(audit);

        // Notify employee if published
        if (existing.isPublished()) {
            org.example.model.ThongBao tb = new org.example.model.ThongBao();
            tb.setAccountId(existing.getAccountId());
            tb.setTieuDe("Lịch làm việc của bạn đã thay đổi");
            tb.setNoiDung(String.format("Lịch ca làm ngày %s (%s - %s) của bạn đã được thay đổi. Lý do: %s", 
                    existing.getNgayLam(), existing.getGioBatDau(), existing.getGioKetThuc(), 
                    (changeReason != null ? changeReason : "Thay đổi phân công")));
            tb.setLoaiThongBao("LichLamViec");
            tb.setDaDoc(false);
            tb.setThoiGianGui(new java.util.Date());
            tb.setMaBanGhi("CA_LAM_VIEC");
            tb.setDuongDan("/staff/ca-lam");
            thongBaoDAO.insert(tb);
        }
    }

    /**
     * Xóa ca làm
     */
    public void deleteShift(int caLamViecId, int managerCoSoId) {
        deleteShift(caLamViecId, managerCoSoId, managerCoSoId, "Xóa ca làm");
    }

    public void deleteShift(int caLamViecId, int managerCoSoId, int actorId, String deleteReason) {
        CaLamViec ca = caLamViecDAO.getCaById(caLamViecId);
        BranchSecurityUtils.getEntityOrThrow(ca, "Ca làm việc");
        BranchSecurityUtils.checkBranchAccess(ca.getCoSoId(), managerCoSoId);

        String oldValue = ca.toString();

        boolean success = caLamViecDAO.deleteCaLamViec(caLamViecId);
        if (!success) {
            throw new IllegalArgumentException("Xóa ca làm việc thất bại");
        }

        // Log audit log
        CaLamViecAudit audit = new CaLamViecAudit();
        audit.setCaLamViecId(caLamViecId);
        audit.setThaoTac("DELETE");
        audit.setNguoiThucHien(actorId);
        audit.setGiaTriCu(oldValue);
        audit.setLyDo(deleteReason != null ? deleteReason : "Xóa ca làm bởi quản lý");
        auditDAO.insert(audit);

        // Notify employee if published
        if (ca.isPublished()) {
            org.example.model.ThongBao tb = new org.example.model.ThongBao();
            tb.setAccountId(ca.getAccountId());
            tb.setTieuDe("Lịch làm việc của bạn đã bị hủy");
            tb.setNoiDung(String.format("Ca làm việc ngày %s (%s - %s) đã bị hủy bởi quản lý.", ca.getNgayLam(), ca.getGioBatDau(), ca.getGioKetThuc()));
            tb.setLoaiThongBao("LichLamViec");
            tb.setDaDoc(false);
            tb.setThoiGianGui(new java.util.Date());
            tb.setMaBanGhi("CA_LAM_VIEC");
            tb.setDuongDan("/staff/ca-lam");
            thongBaoDAO.insert(tb);
        }
    }

    // ==================== VALIDATION ====================

    private void validateShiftRequest(CaLamRequest request) {
        Map<String, String> errors = new java.util.HashMap<>();

        if (request.getAccountId() <= 0) {
            errors.put("accountId", "Phải chọn nhân viên");
        }

        if (request.getNgayLam() == null) {
            errors.put("ngayLam", "Ngày làm không được để trống");
        }

        try {
            ValidationUtils.validateTimeRange(request.getGioBatDau(), request.getGioKetThuc());
        } catch (IllegalArgumentException ve) {
            errors.put("gioBatDau", ve.getMessage());
        }

        if (request.getGioNghi() < 0) {
            errors.put("gioNghi", "Giờ nghỉ không được là số âm");
        } else if (request.getGioBatDau() != null && request.getGioKetThuc() != null) {
            long shiftDuration = java.time.Duration.between(request.getGioBatDau(), request.getGioKetThuc()).toMinutes();
            if (shiftDuration < 0) shiftDuration += 24 * 60;
            if (request.getGioNghi() >= shiftDuration) {
                errors.put("gioNghi", "Giờ nghỉ phải nhỏ hơn thời lượng ca làm việc");
            }
        }

        if (!errors.isEmpty()) {
            throw new IllegalArgumentException(errors.toString());
        }
    }

    // ==================== CONFLICT CHECK ====================

    /**
     * Kiểm tra xung đột ca làm
     */
    public boolean checkShiftConflict(int accountId, LocalDate ngayLam,
                                       LocalTime gioBatDau, LocalTime gioKetThuc,
                                       Integer excludeCaLamViecId) {
        return caLamViecDAO.checkShiftConflict(accountId, ngayLam, gioBatDau, gioKetThuc, excludeCaLamViecId);
    }

    public CaLamValidationEngine.ValidationResult validateShiftAssignment(int accountId, LocalDate ngayLam, LocalTime gioBatDau, LocalTime gioKetThuc, int gioNghi, Integer excludeCaLamViecId) {
        return validationEngine.validateShift(accountId, ngayLam, gioBatDau, gioKetThuc, gioNghi, excludeCaLamViecId);
    }

    public List<org.example.model.CoSo> getAllCoSo() {
        return coSoDAO.getAllCoSo();
    }

    public void confirmShift(int caLamViecId, int accountId) {
        CaLamViec ca = caLamViecDAO.getCaById(caLamViecId);
        if (ca == null) {
            throw new IllegalArgumentException("Ca làm việc không tồn tại.");
        }
        if (ca.getAccountId() != accountId) {
            throw new IllegalArgumentException("Ca làm việc này không thuộc về bạn.");
        }
        if (!"Published".equals(ca.getTrangThai())) {
            throw new IllegalArgumentException("Chỉ có thể xác nhận ca làm việc đã được công bố.");
        }

        ca.setTrangThai("Confirmed");
        boolean success = caLamViecDAO.updateCaLamViec(ca);
        if (!success) {
            throw new IllegalArgumentException("Xác nhận ca làm việc thất bại.");
        }

        // Log audit log
        CaLamViecAudit audit = new CaLamViecAudit();
        audit.setCaLamViecId(ca.getCaLamViecId());
        audit.setThaoTac("CONFIRM");
        audit.setNguoiThucHien(accountId);
        audit.setGiaTriCu("Published");
        audit.setGiaTriMoi("Confirmed");
        audit.setLyDo("Nhân viên xác nhận ca làm việc");
        auditDAO.insert(audit);
    }

    // ==================== ADVANCED WORKFLOWS ====================

    private final org.example.dao.ThongBaoDAO thongBaoDAO = new org.example.dao.impl.ThongBaoDAOImpl();

    /**
     * Nhân bản lịch làm việc của một tuần sang một tuần khác
     */
    public void cloneWeekShifts(LocalDate fromStart, LocalDate toStart, int coSoId, int actorId) {
        List<CaLamViec> sourceShifts = caLamViecDAO.getShiftsByCoSoAndDateRange(coSoId, fromStart, fromStart.plusDays(6));
        if (sourceShifts.isEmpty()) {
            throw new IllegalArgumentException("Không tìm thấy ca làm việc nào ở tuần nguồn để nhân bản.");
        }

        long daysDiff = java.time.temporal.ChronoUnit.DAYS.between(fromStart, toStart);
        List<String> cloneErrors = new ArrayList<>();
        List<CaLamViec> targetShiftsToInsert = new ArrayList<>();

        for (CaLamViec src : sourceShifts) {
            if (src.getNgayLam() == null) continue;
            LocalDate targetDate = src.getNgayLam().plusDays(daysDiff);

            // Run validation
            CaLamValidationEngine.ValidationResult valRes = validationEngine.validateShift(
                    src.getAccountId(), targetDate, src.getGioBatDau(), src.getGioKetThuc(), null
            );

            if (!valRes.isValid()) {
                TaiKhoan staff = taiKhoanDAO.getAccountById(src.getAccountId());
                String staffName = staff != null ? staff.getFullName() : "Nhân viên ID " + src.getAccountId();
                cloneErrors.add(String.format("Lịch của %s ngày %s bị xung đột: %s", 
                        staffName, targetDate, String.join("; ", valRes.getErrors())));
            } else {
                CaLamViec targetShift = new CaLamViec();
                targetShift.setAccountId(src.getAccountId());
                targetShift.setCoSoId(coSoId);
                targetShift.setNgayLam(targetDate);
                targetShift.setGioBatDau(src.getGioBatDau());
                targetShift.setGioKetThuc(src.getGioKetThuc());
                targetShift.setGhiChu(src.getGhiChu());
                targetShift.setPublished(false);
                targetShiftsToInsert.add(targetShift);
            }
        }

        if (!cloneErrors.isEmpty()) {
            throw new IllegalArgumentException("Không thể nhân bản lịch do có xung đột:\n" + String.join("\n", cloneErrors));
        }

        for (CaLamViec target : targetShiftsToInsert) {
            caLamViecDAO.addCaLamViec(target);
            // Log insert audit trail
            CaLamViecAudit audit = new CaLamViecAudit();
            audit.setCaLamViecId(target.getCaLamViecId());
            audit.setThaoTac("CLONE");
            audit.setNguoiThucHien(actorId);
            audit.setGiaTriMoi(target.toString());
            audit.setLyDo("Nhân bản lịch từ tuần " + fromStart);
            auditDAO.insert(audit);
        }
    }

    /**
     * Công bố lịch làm việc cho cả tuần
     */
    public void publishWeekShifts(LocalDate startOfWeek, int coSoId, int actorId) {
        LocalDate endOfWeek = startOfWeek.plusDays(6);
        boolean success = caLamViecDAO.publishWeekShifts(startOfWeek, endOfWeek, coSoId);
        if (!success) {
            throw new IllegalArgumentException("Không có ca làm nào trong tuần này cần công bố hoặc công bố thất bại.");
        }

        // Notify scheduled employees
        List<CaLamViec> shifts = caLamViecDAO.getShiftsByCoSoAndDateRange(coSoId, startOfWeek, endOfWeek);
        List<Integer> notifiedAccounts = new ArrayList<>();
        
        for (CaLamViec s : shifts) {
            if (!notifiedAccounts.contains(s.getAccountId())) {
                notifiedAccounts.add(s.getAccountId());
                
                org.example.model.ThongBao tb = new org.example.model.ThongBao();
                tb.setAccountId(s.getAccountId());
                tb.setTieuDe("Lịch làm việc mới đã được công bố");
                tb.setNoiDung(String.format("Lịch làm việc cho tuần %s đến %s đã được công bố. Hãy vào kiểm tra ca làm của bạn.", startOfWeek, endOfWeek));
                tb.setLoaiThongBao("LichLamViec");
                tb.setDaDoc(false);
                tb.setThoiGianGui(new java.util.Date());
                tb.setMaBanGhi("CA_LAM_VIEC");
                tb.setDuongDan("/staff/ca-lam");
                thongBaoDAO.insert(tb);
            }

            // Audit
            CaLamViecAudit audit = new CaLamViecAudit();
            audit.setCaLamViecId(s.getCaLamViecId());
            audit.setThaoTac("PUBLISH");
            audit.setNguoiThucHien(actorId);
            audit.setGiaTriCu("Unpublished");
            audit.setGiaTriMoi("Published");
            audit.setLyDo("Quản lý công bố lịch tuần");
            auditDAO.insert(audit);
        }
    }

    /**
     * Lấy lịch sử thay đổi ca làm
     */
    public List<CaLamViecAudit> getAuditLogs(int coSoId) {
        return auditDAO.getByCoSo(coSoId);
    }

    /**
     * Lấy nguyện vọng rảnh bận của nhân viên
     */
    public List<CaLamViecAvailability> getAvailabilityByBranch(int coSoId, LocalDate start, LocalDate end) {
        return availabilityDAO.getByCoSoAndDateRange(coSoId, start, end);
    }

    public List<CaLamViecAvailability> getAvailabilityByStaff(int accountId) {
        return availabilityDAO.getByAccount(accountId);
    }

    public void addAvailability(CaLamViecAvailability avail) {
        availabilityDAO.insert(avail);
    }

    public void deleteAvailability(int id) {
        availabilityDAO.delete(id);
    }

    // ==================== SHIFT SWAPPING WORKFLOW ====================

    public List<CaLamViecSwapRequest> getSwapRequestsByBranch(int coSoId) {
        return swapRequestDAO.getByCoSo(coSoId);
    }

    public List<CaLamViecSwapRequest> getSwapRequestsForStaff(int accountId) {
        return swapRequestDAO.getByAccount(accountId);
    }

    /**
     * Staff gửi yêu cầu đổi ca
     */
    public void createSwapRequest(CaLamViecSwapRequest sr) {
        CaLamViec shift = caLamViecDAO.getCaById(sr.getCaLamViecIdGui());
        if (shift == null) {
            throw new IllegalArgumentException("Ca làm việc nguồn không tồn tại.");
        }
        if (shift.getAccountId() != sr.getAccountIdGui()) {
            throw new IllegalArgumentException("Ca làm việc này không thuộc về bạn.");
        }

        TaiKhoan guiAcc = taiKhoanDAO.getAccountById(sr.getAccountIdGui());
        TaiKhoan nhanAcc = taiKhoanDAO.getAccountById(sr.getAccountIdNhan());
        if (guiAcc == null || nhanAcc == null) {
            throw new IllegalArgumentException("Thông tin tài khoản không tồn tại.");
        }
        if (guiAcc.getCoSoId() == null || nhanAcc.getCoSoId() == null || !guiAcc.getCoSoId().equals(nhanAcc.getCoSoId())) {
            throw new IllegalArgumentException("Chỉ có thể hoán đổi ca làm với đồng nghiệp cùng chi nhánh.");
        }

        // Validate receiver conflict for this shift
        CaLamValidationEngine.ValidationResult valRes = validationEngine.validateShift(
                sr.getAccountIdNhan(), shift.getNgayLam(), shift.getGioBatDau(), shift.getGioKetThuc(), null
        );
        if (!valRes.isValid()) {
            throw new IllegalArgumentException("Đối phương bị xung đột lịch cho ca này: " + String.join("; ", valRes.getErrors()));
        }

        sr.setTrangThai("ChoXacNhan");
        boolean success = swapRequestDAO.insert(sr);
        if (!success) {
            throw new IllegalArgumentException("Gửi yêu cầu đổi ca thất bại.");
        }

        // Notify Receiver
        org.example.model.ThongBao tb = new org.example.model.ThongBao();
        tb.setAccountId(sr.getAccountIdNhan());
        tb.setTieuDe("Yêu cầu hoán đổi ca làm");
        tb.setNoiDung(String.format("Đồng nghiệp muốn đổi ca làm với bạn. Lý do: %s", sr.getLyDo()));
        tb.setLoaiThongBao("DoiCa");
        tb.setDaDoc(false);
        tb.setThoiGianGui(new java.util.Date());
        tb.setMaBanGhi("SWAP_REQUEST");
        tb.setDuongDan("/staff/ca-lam");
        thongBaoDAO.insert(tb);
    }

    /**
     * Staff chấp nhận/từ chối yêu cầu đổi ca
     */
    public void respondToSwapRequest(int swapId, boolean accept, int actorId) {
        CaLamViecSwapRequest sr = swapRequestDAO.getById(swapId);
        if (sr == null || sr.getAccountIdNhan() != actorId) {
            throw new IllegalArgumentException("Yêu cầu không hợp lệ hoặc không thuộc về bạn.");
        }
        if (!"ChoXacNhan".equals(sr.getTrangThai())) {
            throw new IllegalArgumentException("Yêu cầu này không ở trạng thái chờ bạn xác nhận.");
        }

        if (accept) {
            sr.setTrangThai("ChoQuanLyDuyet");
            swapRequestDAO.update(sr);

            // Notify Managers of this branch
            List<TaiKhoan> managers = taiKhoanDAO.findAll(); // Simple lookup
            TaiKhoan receiver = taiKhoanDAO.getAccountById(sr.getAccountIdNhan());
            
            for (TaiKhoan m : managers) {
                if (m.getRoleId() == Constants.ROLE_MANAGER && m.getCoSoId().equals(receiver.getCoSoId())) {
                    org.example.model.ThongBao tb = new org.example.model.ThongBao();
                    tb.setAccountId(m.getAccountId());
                    tb.setTieuDe("Yêu cầu đổi ca chờ duyệt");
                    tb.setNoiDung(String.format("Yêu cầu đổi ca giữa %s và %s đã được cả hai đồng ý. Chờ bạn phê duyệt.", sr.getTenNguoiGui(), sr.getTenNguoiNhan()));
                    tb.setLoaiThongBao("DoiCa");
                    tb.setDaDoc(false);
                    tb.setThoiGianGui(new java.util.Date());
                    tb.setMaBanGhi("SWAP_REQUEST");
                    tb.setDuongDan("/manager/nhan-su?tab=schedule");
                    thongBaoDAO.insert(tb);
                }
            }
        } else {
            sr.setTrangThai("TuChoi");
            swapRequestDAO.update(sr);

            // Notify Requester
            org.example.model.ThongBao tb = new org.example.model.ThongBao();
            tb.setAccountId(sr.getAccountIdGui());
            tb.setTieuDe("Yêu cầu đổi ca bị từ chối");
            tb.setNoiDung("Yêu cầu đổi ca làm của bạn đã bị đối phương từ chối.");
            tb.setLoaiThongBao("DoiCa");
            tb.setDaDoc(false);
            tb.setThoiGianGui(new java.util.Date());
            tb.setMaBanGhi("SWAP_REQUEST");
            tb.setDuongDan("/staff/ca-lam");
            thongBaoDAO.insert(tb);
        }
    }

    /**
     * Manager duyệt yêu cầu đổi ca
     */
    public void approveSwapRequest(int swapId, int managerId, String notes) {
        CaLamViecSwapRequest sr = swapRequestDAO.getById(swapId);
        if (sr == null || !"ChoQuanLyDuyet".equals(sr.getTrangThai())) {
            throw new IllegalArgumentException("Yêu cầu không hợp lệ hoặc không ở trạng thái chờ duyệt.");
        }

        CaLamViec caGui = caLamViecDAO.getCaById(sr.getCaLamViecIdGui());
        CaLamViec caNhan = sr.getCaLamViecIdNhan() != null ? caLamViecDAO.getCaById(sr.getCaLamViecIdNhan()) : null;

        if (caGui == null) {
            throw new IllegalArgumentException("Ca làm nguồn không tồn tại.");
        }

        // Perform swapping database updates
        // 1. Swap first shift to receiver
        caGui.setAccountId(sr.getAccountIdNhan());
        caLamViecDAO.updateCaLamViec(caGui);

        // Audit first swap
        CaLamViecAudit audit1 = new CaLamViecAudit();
        audit1.setCaLamViecId(caGui.getCaLamViecId());
        audit1.setThaoTac("SWAP");
        audit1.setNguoiThucHien(managerId);
        audit1.setGiaTriCu("Staff ID: " + sr.getAccountIdGui());
        audit1.setGiaTriMoi("Staff ID: " + sr.getAccountIdNhan());
        audit1.setLyDo("Phê duyệt hoán đổi ca làm. Ghi chú: " + notes);
        auditDAO.insert(audit1);

        // 2. Swap second shift to requester (if trade)
        if (caNhan != null) {
            caNhan.setAccountId(sr.getAccountIdGui());
            caLamViecDAO.updateCaLamViec(caNhan);

            CaLamViecAudit audit2 = new CaLamViecAudit();
            audit2.setCaLamViecId(caNhan.getCaLamViecId());
            audit2.setThaoTac("SWAP");
            audit2.setNguoiThucHien(managerId);
            audit2.setGiaTriCu("Staff ID: " + sr.getAccountIdNhan());
            audit2.setGiaTriMoi("Staff ID: " + sr.getAccountIdGui());
            audit2.setLyDo("Phê duyệt hoán đổi ca làm. Ghi chú: " + notes);
            auditDAO.insert(audit2);
        }

        // Update swap request status
        sr.setTrangThai("DaDuyet");
        sr.setNguoiDuyet(managerId);
        sr.setNgayDuyet(LocalDateTime.now());
        sr.setGhiChuQuanLy(notes);
        swapRequestDAO.update(sr);

        // Notify both staff
        for (int accId : new int[]{sr.getAccountIdGui(), sr.getAccountIdNhan()}) {
            org.example.model.ThongBao tb = new org.example.model.ThongBao();
            tb.setAccountId(accId);
            tb.setTieuDe("Yêu cầu hoán đổi ca đã được phê duyệt");
            tb.setNoiDung("Quản lý đã phê duyệt yêu cầu hoán đổi ca làm của bạn.");
            tb.setLoaiThongBao("DoiCa");
            tb.setDaDoc(false);
            tb.setThoiGianGui(new java.util.Date());
            tb.setMaBanGhi("SWAP_REQUEST");
            tb.setDuongDan("/staff/ca-lam");
            thongBaoDAO.insert(tb);
        }
    }

    /**
     * Manager từ chối yêu cầu đổi ca
     */
    public void rejectSwapRequest(int swapId, int managerId, String notes) {
        CaLamViecSwapRequest sr = swapRequestDAO.getById(swapId);
        if (sr == null || !"ChoQuanLyDuyet".equals(sr.getTrangThai())) {
            throw new IllegalArgumentException("Yêu cầu không hợp lệ hoặc không ở trạng thái chờ duyệt.");
        }

        sr.setTrangThai("TuChoi");
        sr.setNguoiDuyet(managerId);
        sr.setNgayDuyet(LocalDateTime.now());
        sr.setGhiChuQuanLy(notes);
        swapRequestDAO.update(sr);

        // Notify both staff
        for (int accId : new int[]{sr.getAccountIdGui(), sr.getAccountIdNhan()}) {
            org.example.model.ThongBao tb = new org.example.model.ThongBao();
            tb.setAccountId(accId);
            tb.setTieuDe("Yêu cầu hoán đổi ca bị từ chối");
            tb.setNoiDung(String.format("Quản lý đã từ chối yêu cầu hoán đổi ca làm của bạn. Ghi chú: %s", notes != null ? notes : ""));
            tb.setLoaiThongBao("DoiCa");
            tb.setDaDoc(false);
            tb.setThoiGianGui(new java.util.Date());
            tb.setMaBanGhi("SWAP_REQUEST");
            tb.setDuongDan("/staff/ca-lam");
            thongBaoDAO.insert(tb);
        }
    }

    /**
     * Điểm danh vào ca làm
     */
    public void checkInShift(int caLamViecId, int accountId) {
        CaLamViec ca = caLamViecDAO.getCaById(caLamViecId);
        if (ca == null) {
            throw new IllegalArgumentException("Ca làm việc không tồn tại.");
        }
        if (ca.getAccountId() != accountId) {
            throw new IllegalArgumentException("Ca làm việc này không thuộc về bạn.");
        }
        if (!"Confirmed".equals(ca.getTrangThai()) && !"Published".equals(ca.getTrangThai())) {
            throw new IllegalArgumentException("Chỉ có thể điểm danh ca làm đã được công bố hoặc xác nhận.");
        }
        if (!ca.getNgayLam().equals(LocalDate.now())) {
            throw new IllegalArgumentException("Chỉ có thể điểm danh ca làm trong ngày hôm nay.");
        }

        ca.setTrangThai("CheckedIn");
        boolean success = caLamViecDAO.updateCaLamViec(ca);
        if (!success) {
            throw new IllegalArgumentException("Điểm danh ca làm thất bại.");
        }

        // Log audit
        org.example.model.CaLamViecAudit audit = new org.example.model.CaLamViecAudit();
        audit.setCaLamViecId(ca.getCaLamViecId());
        audit.setThaoTac("CHECK_IN");
        audit.setNguoiThucHien(accountId);
        audit.setGiaTriCu("Confirmed");
        audit.setGiaTriMoi("CheckedIn");
        audit.setLyDo("Nhân viên điểm danh vào ca");
        auditDAO.insert(audit);
    }

    /**
     * Kết thúc ca làm
     */
    public void checkOutShift(int caLamViecId, int accountId) {
        CaLamViec ca = caLamViecDAO.getCaById(caLamViecId);
        if (ca == null) {
            throw new IllegalArgumentException("Ca làm việc không tồn tại.");
        }
        if (ca.getAccountId() != accountId) {
            throw new IllegalArgumentException("Ca làm việc này không thuộc về bạn.");
        }
        if (!"CheckedIn".equals(ca.getTrangThai())) {
            throw new IllegalArgumentException("Chỉ có thể kết thúc ca làm khi đang trong trạng thái đã điểm danh.");
        }

        ca.setTrangThai("CheckedOut");
        boolean success = caLamViecDAO.updateCaLamViec(ca);
        if (!success) {
            throw new IllegalArgumentException("Kết thúc ca làm thất bại.");
        }

        // Log audit
        org.example.model.CaLamViecAudit audit = new org.example.model.CaLamViecAudit();
        audit.setCaLamViecId(ca.getCaLamViecId());
        audit.setThaoTac("CHECK_OUT");
        audit.setNguoiThucHien(accountId);
        audit.setGiaTriCu("CheckedIn");
        audit.setGiaTriMoi("CheckedOut");
        audit.setLyDo("Nhân viên kết thúc ca");
        auditDAO.insert(audit);
    }

    /**
     * Tự động ghép ca cho các ca làm việc trong khoảng thời gian dựa trên nguyện vọng rảnh/bận của nhân viên
     */
    public void autoScheduleShifts(LocalDate startDate, LocalDate endDate, int coSoId, int actorId) {
        // 1. Lấy tất cả ca làm việc trong khoảng ngày của cơ sở
        List<CaLamViec> shifts = caLamViecDAO.getShiftsByCoSoAndDateRange(coSoId, startDate, endDate);
        if (shifts.isEmpty()) {
            throw new IllegalArgumentException("Không tìm thấy ca làm việc nào trong khoảng thời gian này để sắp lịch.");
        }

        // 2. Lấy tất cả nguyện vọng Ranh đã được duyệt của nhân viên trong cơ sở
        List<CaLamViecAvailability> avails = availabilityDAO.getByCoSoAndDateRange(coSoId, startDate, endDate);
        // Lọc các nguyện vọng 'Ranh' và đã 'DaDuyet'
        List<CaLamViecAvailability> freeAvails = avails.stream()
                .filter(a -> "Ranh".equalsIgnoreCase(a.getTrangThai()) && "DaDuyet".equalsIgnoreCase(a.getDuyetTrangThai()))
                .toList();

        // 3. Lấy danh sách nhân viên của cơ sở
        List<TaiKhoan> staffs = getStaffAvailableForShift(coSoId);

        // Duyệt qua từng ca làm việc để tìm nhân viên phù hợp
        for (CaLamViec shift : shifts) {
            // Chỉ phân lịch tự động cho ca ở trạng thái Draft hoặc chưa được Confirmed/CheckedIn/CheckedOut
            if (!"Draft".equals(shift.getTrangThai()) && !"Unpublished".equals(shift.getTrangThai())) {
                continue;
            }

            // Tìm các nhân viên có nguyện vọng rảnh bao phủ khung giờ của ca này
            List<TaiKhoan> candidateStaffs = new ArrayList<>();
            for (TaiKhoan staff : staffs) {
                // Kiểm tra xem nhân viên có đăng ký rảnh vào ngày này và bao phủ khung giờ của ca làm không
                boolean isAvailable = freeAvails.stream().anyMatch(a -> 
                    a.getAccountId() == staff.getAccountId() && 
                    a.getNgay().equals(shift.getNgayLam()) &&
                    !shift.getGioBatDau().isBefore(a.getGioBatDau()) &&
                    !shift.getGioKetThuc().isAfter(a.getGioKetThuc())
                );
                
                if (isAvailable) {
                    // Kiểm tra xem có xung đột ca làm khác không (loại trừ chính ca đang xét nếu staff đang được gán ca này)
                    CaLamValidationEngine.ValidationResult valRes = validationEngine.validateShift(
                            staff.getAccountId(), shift.getNgayLam(), shift.getGioBatDau(), shift.getGioKetThuc(), shift.getGioNghi(), shift.getCaLamViecId()
                    );
                    if (valRes.isValid()) {
                        candidateStaffs.add(staff);
                    }
                }
            }

            if (!candidateStaffs.isEmpty()) {
                // Chọn nhân viên có ít giờ làm nhất trong tuần để công bằng
                TaiKhoan bestStaff = null;
                double minHours = Double.MAX_VALUE;
                for (TaiKhoan staff : candidateStaffs) {
                    // Tính tổng số giờ đã được gán cho nhân viên này trong khoảng ngày
                    double assignedHours = 0;
                    for (CaLamViec s : shifts) {
                        if (s.getAccountId() == staff.getAccountId() && s.getCaLamViecId() != shift.getCaLamViecId()) {
                            long minutes = java.time.Duration.between(s.getGioBatDau(), s.getGioKetThuc()).toMinutes();
                            assignedHours += (minutes - s.getGioNghi()) / 60.0;
                        }
                    }
                    if (assignedHours < minHours) {
                        minHours = assignedHours;
                        bestStaff = staff;
                    }
                }

                if (bestStaff != null && bestStaff.getAccountId() != shift.getAccountId()) {
                    int oldStaffId = shift.getAccountId();
                    shift.setAccountId(bestStaff.getAccountId());
                    caLamViecDAO.updateCaLamViec(shift);

                    // Ghi log thay đổi
                    CaLamViecAudit audit = new CaLamViecAudit();
                    audit.setCaLamViecId(shift.getCaLamViecId());
                    audit.setThaoTac("AUTO_SCHEDULE");
                    audit.setNguoiThucHien(actorId);
                    audit.setGiaTriCu("Nhân viên ID: " + oldStaffId);
                    audit.setGiaTriMoi("Nhân viên ID: " + bestStaff.getAccountId());
                    audit.setLyDo("Tự động sắp lịch dựa trên nguyện vọng rảnh");
                    auditDAO.insert(audit);
                }
            }
        }
    }
}
