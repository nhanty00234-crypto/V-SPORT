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
import org.example.exception.*;
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
        private boolean overrideConfirm;
        private boolean isCustomTime;
        private String customTimeReason;
        private String shiftTemplateId;

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
        public boolean isOverrideConfirm() { return overrideConfirm; }
        public void setOverrideConfirm(boolean overrideConfirm) { this.overrideConfirm = overrideConfirm; }
        public boolean isCustomTime() { return isCustomTime; }
        public void setCustomTime(boolean customTime) { isCustomTime = customTime; }
        public String getCustomTimeReason() { return customTimeReason; }
        public void setCustomTimeReason(String customTimeReason) { this.customTimeReason = customTimeReason; }
        public String getShiftTemplateId() { return shiftTemplateId; }
        public void setShiftTemplateId(String shiftTemplateId) { this.shiftTemplateId = shiftTemplateId; }
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
    public List<String> createShift(CaLamRequest request, int managerCoSoId) {
        return createShift(request, managerCoSoId, managerCoSoId);
    }

    public List<String> createShift(CaLamRequest request, int managerCoSoId, int actorId) {
        // 3.1 Input validate
        if (request == null) {
            throw new IllegalArgumentException("Yêu cầu ca làm việc không được null.");
        }
        if (request.getAccountId() <= 0) {
            throw new IllegalArgumentException("Phải chọn nhân viên hợp lệ (accountId > 0).");
        }
        if (request.getNgayLam() == null) {
            throw new IllegalArgumentException("Ngày làm việc không được để trống.");
        }
        if (request.getGioBatDau() == null || request.getGioKetThuc() == null) {
            throw new IllegalArgumentException("Giờ bắt đầu và giờ kết thúc không được để trống.");
        }

        // Validate repeat properties
        String repeatType = request.getRepeatType();
        if (repeatType == null || repeatType.trim().isEmpty()) {
            repeatType = "none";
        }
        repeatType = repeatType.trim().toLowerCase();
        if (!"none".equals(repeatType) && !"daily".equals(repeatType) && !"weekly".equals(repeatType)) {
            throw new IllegalArgumentException("Repeat type không hợp lệ. Chỉ chấp nhận 'none', 'daily', hoặc 'weekly'.");
        }

        if (!"none".equals(repeatType)) {
            if (request.getRepeatUntil() == null) {
                throw new IllegalArgumentException("Vui lòng chọn ngày kết thúc lặp lại.");
            }
            if (request.getRepeatUntil().isBefore(request.getNgayLam())) {
                throw new IllegalArgumentException("Ngày kết thúc lặp lại phải sau hoặc bằng ngày bắt đầu.");
            }
            if (request.getRepeatUntil().isAfter(request.getNgayLam().plusMonths(3))) {
                throw new IllegalArgumentException("Chỉ cho phép lặp lại tối đa trong vòng 3 tháng!");
            }
        }

        // Check nhân viên
        TaiKhoan staff = taiKhoanDAO.getAccountById(request.getAccountId());
        if (staff == null) {
            throw new NotFoundException("Nhân viên không tồn tại.");
        }

        int targetCoSoId = request.getCoSoId() > 0 ? request.getCoSoId() : managerCoSoId;
        BranchSecurityUtils.checkBranchAccess(targetCoSoId, managerCoSoId);

        // Collect all dates to generate shifts
        List<LocalDate> datesToSchedule = new ArrayList<>();
        datesToSchedule.add(request.getNgayLam());

        if (!"none".equals(repeatType)) {
            LocalDate current = request.getNgayLam();
            LocalDate until = request.getRepeatUntil();
            if ("daily".equalsIgnoreCase(repeatType)) {
                while (current.isBefore(until)) {
                    current = current.plusDays(1);
                    datesToSchedule.add(current);
                }
            } else if ("weekly".equalsIgnoreCase(repeatType)) {
                while (current.isBefore(until)) {
                    current = current.plusWeeks(1);
                    if (!current.isAfter(until)) {
                        datesToSchedule.add(current);
                    }
                }
            }
        }

        // MAX_REPEAT_OCCURRENCES = 90
        if (datesToSchedule.size() > 90) {
            throw new ValidationException("Không thể tạo quá 90 ca làm việc lặp lại trong một lần!");
        }

        // P1-2: No duplicate dates in batch
        java.util.Set<LocalDate> uniqueDates = new java.util.HashSet<>();
        for (LocalDate d : datesToSchedule) {
            if (!uniqueDates.add(d)) {
                throw new ValidationException("Danh sách ngày tạo ca bị trùng lặp: " + d);
            }
        }

        // Validate all generated dates using validationEngine
        boolean hasOverlap = false;
        boolean hasCompleted = false;
        boolean hasActive = false;
        boolean hasNotFound = false;
        boolean hasMismatch = false;
        List<String> errorMessages = new ArrayList<>();
        List<String> allWarnings = new ArrayList<>();
        List<CaLamViec> shiftsToCreate = new ArrayList<>();

        for (LocalDate date : datesToSchedule) {
            CaLamValidationEngine.ValidationResult valRes = validationEngine.validateShift(
                    request.getAccountId(), date, request.getGioBatDau(), request.getGioKetThuc(), request.getGioNghi(), null, targetCoSoId,
                    request.isCustomTime(), request.getCustomTimeReason()
            );
            if (!valRes.isValid()) {
                errorMessages.addAll(valRes.getErrors());
                for (CaLamValidationEngine.ValidationItem item : valRes.getErrorsItems()) {
                    String code = item.getCode();
                    if ("SHIFT_OVERLAP".equalsIgnoreCase(code)) {
                        hasOverlap = true;
                    } else if ("SHIFT_COMPLETED".equalsIgnoreCase(code)) {
                        hasCompleted = true;
                    } else if ("SHIFT_ACTIVE".equalsIgnoreCase(code)) {
                        hasActive = true;
                    } else if ("STAFF_NOT_FOUND".equalsIgnoreCase(code)) {
                        hasNotFound = true;
                    } else if ("BRANCH_MISMATCH".equalsIgnoreCase(code)) {
                        hasMismatch = true;
                    }
                }
            } else {
                allWarnings.addAll(valRes.getWarnings());
                CaLamViec ca = new CaLamViec();
                ca.setAccountId(request.getAccountId());
                ca.setCoSoId(targetCoSoId);
                ca.setNgayLam(date);
                ca.setGioBatDau(request.getGioBatDau());
                ca.setGioKetThuc(request.getGioKetThuc());
                ca.setGhiChu(sanitizeText(request.getGhiChu()));
                ca.setTenCa(request.getTenCa() != null ? request.getTenCa() : "Tùy chỉnh");
                ca.setViTri(request.getViTri());
                String initialStatus = request.getTrangThai() != null ? request.getTrangThai() : "Draft";
                ca.setTrangThai(initialStatus);
                ca.setPublished("Published".equals(initialStatus) || "Confirmed".equals(initialStatus));
                ca.setGioNghi(request.getGioNghi());
                ca.setCustomTime(request.isCustomTime());
                ca.setCustomTimeReason(sanitizeText(request.getCustomTimeReason()));
                
                int thuVal = date.getDayOfWeek().getValue() + 1; // Mon is 1 -> 2 in DB logic
                ca.setThu(thuVal);

                shiftsToCreate.add(ca);
            }
        }

        if (!errorMessages.isEmpty()) {
            String errorMsg = String.join("\n- ", errorMessages);
            if (hasOverlap) {
                throw new ConflictException("Trùng ca.");
            } else if (hasCompleted || hasActive) {
                throw new ConflictException(errorMsg);
            } else if (hasNotFound) {
                throw new NotFoundException(errorMsg);
            } else if (hasMismatch) {
                throw new ForbiddenException(errorMsg);
            } else {
                throw new ValidationException(errorMsg);
            }
        }

        // All-or-nothing batch insert using a shared JDBC transaction
        try (Connection txConn = DBUtil.getConnection()) {
            txConn.setAutoCommit(false);
            try {
                for (CaLamViec ca : shiftsToCreate) {
                    int generatedId = caLamViecDAO.addCaLamViecWithConnection(ca, txConn);
                    if (generatedId <= 0) {
                        throw new IllegalArgumentException("Thêm ca làm việc thất bại cho ngày " + ca.getNgayLam());
                    }

                    CaLamViecAudit audit = new CaLamViecAudit();
                    audit.setCaLamViecId(generatedId);
                    audit.setThaoTac("INSERT");
                    audit.setNguoiThucHien(actorId);
                    audit.setGiaTriMoi(ca.toString());
                    audit.setLyDo("Thêm ca làm mới bởi quản lý" + (datesToSchedule.size() > 1 ? " (Lặp lại)" : ""));
                    auditDAO.insertWithConnection(audit, txConn);
                }
                txConn.commit();
            } catch (Exception e) {
                txConn.rollback();
                if (e instanceof RuntimeException) throw (RuntimeException) e;
                throw new IllegalArgumentException("Lỗi khi lưu batch ca làm việc: " + e.getMessage(), e);
            }
        } catch (java.sql.SQLException e) {
            throw new IllegalArgumentException("Lỗi kết nối CSDL khi tạo ca làm việc: " + e.getMessage(), e);
        }

        // Post-commit notifications (outside transaction — non-critical)
        for (CaLamViec ca : shiftsToCreate) {
            if (ca.isPublished()) {
                org.example.model.ThongBao tb = new org.example.model.ThongBao();
                tb.setAccountId(ca.getAccountId());
                tb.setTieuDe("Lịch làm việc mới đã được phân công");
                tb.setNoiDung(String.format("Bạn có ca làm mới ngày %s (%s - %s) tại cơ sở ID %d.",
                        ca.getNgayLam(), ca.getGioBatDau(), ca.getGioKetThuc(), ca.getCoSoId()));
                tb.setLoaiThongBao("LichLamViec");
                tb.setDaDoc(false);
                tb.setThoiGianGui(new java.util.Date());
                tb.setMaBanGhi("CA_LAM_VIEC");
                tb.setDuongDan("/staff/ca-lam");
                thongBaoDAO.insert(tb);
            }
        }

        return allWarnings;
    }

    /**
     * Helper method to map validation errors to custom exceptions.
     */
    private void throwValidationResultException(CaLamValidationEngine.ValidationResult valRes) {
        if (valRes.isValid()) return;
        
        boolean hasOverlap = false;
        boolean hasCompleted = false;
        boolean hasActive = false;
        boolean hasNotFound = false;
        boolean hasMismatch = false;
        
        for (CaLamValidationEngine.ValidationItem item : valRes.getErrorsItems()) {
            String code = item.getCode();
            if ("SHIFT_OVERLAP".equalsIgnoreCase(code)) {
                hasOverlap = true;
            } else if ("SHIFT_COMPLETED".equalsIgnoreCase(code)) {
                hasCompleted = true;
            } else if ("SHIFT_ACTIVE".equalsIgnoreCase(code)) {
                hasActive = true;
            } else if ("STAFF_NOT_FOUND".equalsIgnoreCase(code)) {
                hasNotFound = true;
            } else if ("BRANCH_MISMATCH".equalsIgnoreCase(code)) {
                hasMismatch = true;
            }
        }
        
        String errorMsg = String.join(", ", valRes.getErrors());
        if (hasOverlap) {
            throw new ConflictException("Trùng ca.");
        } else if (hasCompleted || hasActive) {
            throw new ConflictException(errorMsg);
        } else if (hasNotFound) {
            throw new NotFoundException(errorMsg);
        } else if (hasMismatch) {
            throw new ForbiddenException(errorMsg);
        } else {
            throw new ValidationException(errorMsg);
        }
    }

    /**
     * Cập nhật ca làm
     */
    public List<String> updateShift(int caLamViecId, CaLamRequest request, int managerCoSoId) {
        return updateShift(caLamViecId, request, managerCoSoId, managerCoSoId, "Cập nhật ca làm");
    }

    public List<String> updateShift(int caLamViecId, CaLamRequest request, int managerCoSoId, int actorId, String changeReason) {
        CaLamViec existing = caLamViecDAO.getCaById(caLamViecId);
        BranchSecurityUtils.getEntityOrThrow(existing, "Ca làm việc");
        BranchSecurityUtils.checkBranchAccess(existing.getCoSoId(), managerCoSoId);

        // CHECK TRẠNG THÁI TRƯỚC
        if (Constants.isTerminalStatus(existing.getTrangThai())) {
            throw new ConflictException("Không sửa hoặc hủy ca đã completed.");
        }
        if (Constants.SHIFT_STATUS_CHECKED_IN.equalsIgnoreCase(existing.getTrangThai())) {
            throw new ConflictException("Không thể sửa ca làm việc đang diễn ra (CheckedIn).");
        }
        if (Constants.SHIFT_STATUS_CANCELLED.equalsIgnoreCase(existing.getTrangThai())) {
            throw new ConflictException("Không thể sửa ca làm việc đã bị hủy.");
        }

        if (Constants.SHIFT_STATUS_CONFIRMED.equalsIgnoreCase(existing.getTrangThai())) {
            if (!request.isOverrideConfirm()) {
                throw new ValidationException("CONFIRMED_OVERRIDE_REQUIRED: Ca làm việc đã được xác nhận. Vui lòng xác nhận để tiếp tục thay đổi.");
            }
        }

        validateShiftRequest(request);

        // Check nhân viên
        TaiKhoan staff = taiKhoanDAO.getAccountById(request.getAccountId());
        if (staff == null) {
            throw new NotFoundException("Nhân viên không tồn tại.");
        }

        // Không cho phép sửa ngày về quá khứ nếu ca đang Published
        if (existing.isPublished() && request.getNgayLam().isBefore(LocalDate.now())) {
            throw new ValidationException("Không cho phép sửa ngày làm việc về quá khứ đối với ca đã công bố.");
        }

        int targetCoSoId = request.getCoSoId() > 0 ? request.getCoSoId() : managerCoSoId;
        BranchSecurityUtils.checkBranchAccess(targetCoSoId, managerCoSoId);

        // Run validation engine
        CaLamValidationEngine.ValidationResult valRes = validationEngine.validateShift(
                request.getAccountId(), request.getNgayLam(), request.getGioBatDau(), request.getGioKetThuc(), request.getGioNghi(), caLamViecId, targetCoSoId,
                request.isCustomTime(), request.getCustomTimeReason()
        );
        if (!valRes.isValid()) {
            throwValidationResultException(valRes);
        }

        String oldValue = existing.toString();

        existing.setAccountId(request.getAccountId());
        existing.setNgayLam(request.getNgayLam());
        existing.setGioBatDau(request.getGioBatDau());
        existing.setGioKetThuc(request.getGioKetThuc());
        existing.setGhiChu(sanitizeText(request.getGhiChu()));
        existing.setCoSoId(targetCoSoId);
        existing.setTenCa(request.getTenCa() != null ? request.getTenCa() : "Tùy chỉnh");
        existing.setViTri(request.getViTri());
        if (request.getTrangThai() != null) {
            existing.setTrangThai(request.getTrangThai());
        }
        existing.setGioNghi(request.getGioNghi());
        existing.setCustomTime(request.isCustomTime());
        existing.setCustomTimeReason(sanitizeText(request.getCustomTimeReason()));
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

        return valRes.getWarnings();
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

        // CheckedIn / CheckedOut -> ERROR cứng
        if (Constants.isTerminalStatus(ca.getTrangThai())) {
            throw new ConflictException("Không sửa hoặc hủy ca đã completed.");
        }
        if (Constants.SHIFT_STATUS_CHECKED_IN.equalsIgnoreCase(ca.getTrangThai())) {
            throw new ConflictException("Không thể xóa ca làm việc đang diễn ra (CheckedIn).");
        }
        if (Constants.SHIFT_STATUS_CANCELLED.equalsIgnoreCase(ca.getTrangThai())) {
            throw new ConflictException("Ca làm việc đã bị hủy.");
        }

        // reason null/blank khi ca đã Published/Confirmed -> throw
        boolean isPublished = ca.isPublished();
        boolean isConfirmed = Constants.SHIFT_STATUS_CONFIRMED.equalsIgnoreCase(ca.getTrangThai());
        if (isPublished || isConfirmed) {
            if (deleteReason == null || deleteReason.trim().isEmpty()) {
                throw new ValidationException("Vui lòng nhập lý do xóa ca làm việc đã công bố hoặc xác nhận.");
            }
        }

        String oldValue = ca.toString();

        // Soft Cancel: Update status thành Cancelled instead of hardDelete
        ca.setTrangThai(Constants.SHIFT_STATUS_CANCELLED);
        boolean success = caLamViecDAO.updateCaLamViec(ca);
        if (!success) {
            throw new IllegalArgumentException("Hủy ca làm việc thất bại");
        }

        // Log audit log
        CaLamViecAudit audit = new CaLamViecAudit();
        audit.setCaLamViecId(caLamViecId);
        audit.setThaoTac("CANCEL");
        audit.setNguoiThucHien(actorId);
        audit.setGiaTriCu(oldValue);
        audit.setGiaTriMoi(ca.toString());
        audit.setLyDo(deleteReason != null ? deleteReason : "Hủy ca làm bởi quản lý");
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

    static String sanitizeText(String text) {
        if (text == null) return null;
        return text.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#x27;");
    }

    private void validateShiftRequest(CaLamRequest request) {
        Map<String, String> errors = new java.util.HashMap<>();

        if (request.getAccountId() <= 0) {
            errors.put("accountId", "Phải chọn nhân viên");
        }

        if (request.getNgayLam() == null) {
            errors.put("ngayLam", "Ngày làm không được để trống");
        }

        if (request.getGhiChu() != null && request.getGhiChu().length() > 255) {
            errors.put("ghiChu", "Ghi chú không được vượt quá 255 ký tự");
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
            throw new ValidationException(errors.toString());
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
        return validateShiftAssignment(accountId, ngayLam, gioBatDau, gioKetThuc, gioNghi, excludeCaLamViecId, false, null);
    }

    public CaLamValidationEngine.ValidationResult validateShiftAssignment(int accountId, LocalDate ngayLam, LocalTime gioBatDau, LocalTime gioKetThuc, int gioNghi, Integer excludeCaLamViecId, boolean isCustomTime, String customTimeReason) {
        Integer coSoId = null;
        if (excludeCaLamViecId != null) {
            CaLamViec existing = caLamViecDAO.getCaById(excludeCaLamViecId);
            if (existing != null) {
                coSoId = existing.getCoSoId();
            }
        } else {
            TaiKhoan staff = taiKhoanDAO.getAccountById(accountId);
            if (staff != null) {
                coSoId = staff.getCoSoId();
            }
        }
        return validationEngine.validateShift(accountId, ngayLam, gioBatDau, gioKetThuc, gioNghi, excludeCaLamViecId, coSoId, isCustomTime, customTimeReason);
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
    public List<String> cloneWeekShifts(LocalDate fromStart, LocalDate toStart, int coSoId, int actorId) {
        if (fromStart == null || toStart == null) {
            throw new IllegalArgumentException("Ngày bắt đầu tuần nguồn và tuần đích không được để trống.");
        }
        if (fromStart.getDayOfWeek() != java.time.DayOfWeek.MONDAY) {
            throw new IllegalArgumentException("Tuần nguồn phải bắt đầu từ thứ Hai (Monday).");
        }
        if (toStart.getDayOfWeek() != java.time.DayOfWeek.MONDAY) {
            throw new IllegalArgumentException("Tuần đích phải bắt đầu từ thứ Hai (Monday).");
        }
        if (fromStart.equals(toStart)) {
            throw new IllegalArgumentException("Không thể nhân bản lịch sang chính tuần đó.");
        }
        // Priority 3 stub: Không cho clone vào tuần đã qua (tất cả 7 ngày đích đã là quá khứ)
        if (toStart.plusDays(6).isBefore(LocalDate.now())) {
            throw new ValidationException("Không thể nhân bản lịch vào tuần đã kết thúc trong quá khứ.");
        }

        // Không cho clone tuần nguồn từ quá khứ > 4 tuần (stale data)
        LocalDate fourWeeksAgo = LocalDate.now().minusWeeks(4);
        if (fromStart.isBefore(fourWeeksAgo)) {
            throw new IllegalArgumentException("Không thể nhân bản tuần nguồn trong quá khứ đã quá 4 tuần.");
        }

        List<CaLamViec> sourceShifts = caLamViecDAO.getShiftsByCoSoAndDateRange(coSoId, fromStart, fromStart.plusDays(6));
        if (sourceShifts.isEmpty()) {
            throw new IllegalArgumentException("Không tìm thấy ca làm việc nào ở tuần nguồn để nhân bản.");
        }

        // Kiểm tra tuần đích đã có ca chưa -> WARNING
        List<CaLamViec> targetShifts = caLamViecDAO.getShiftsByCoSoAndDateRange(coSoId, toStart, toStart.plusDays(6));
        List<String> reports = new ArrayList<>();
        if (!targetShifts.isEmpty()) {
            reports.add("WARNING: Tuần đích đã có " + targetShifts.size() + " ca, hệ thống sẽ tạo thêm ca mới.");
        }

        long daysDiff = java.time.temporal.ChronoUnit.DAYS.between(fromStart, toStart);
        // BUG-CLONE-03: skip ALL terminal statuses, not just CheckedOut
        java.util.Set<String> SKIP_STATUSES = java.util.Set.of(
                "CheckedOut", "CheckedIn", "Cancelled", "Completed"
        );
        List<CaLamViec> targetShiftsToInsert = new ArrayList<>();

        for (CaLamViec src : sourceShifts) {
            if (src.getNgayLam() == null) continue;

            // BUG-CLONE-03: skip terminal/in-progress statuses
            if (src.getTrangThai() != null && SKIP_STATUSES.contains(src.getTrangThai())) {
                continue;
            }

            LocalDate targetDate = src.getNgayLam().plusDays(daysDiff);

            // Run validation
            CaLamValidationEngine.ValidationResult valRes = validationEngine.validateShift(
                    src.getAccountId(), targetDate, src.getGioBatDau(), src.getGioKetThuc(), src.getGioNghi(), null, coSoId
            );

            if (!valRes.isValid()) {
                TaiKhoan staff = taiKhoanDAO.getAccountById(src.getAccountId());
                String staffName = staff != null ? staff.getFullName() : "Nhân viên ID " + src.getAccountId();
                reports.add(String.format("Bỏ qua ca của %s ngày %s do xung đột: %s",
                        staffName, targetDate, String.join("; ", valRes.getErrors())));
            } else {
                CaLamViec target = new CaLamViec();
                target.setAccountId(src.getAccountId());
                target.setCoSoId(coSoId);
                target.setNgayLam(targetDate);
                target.setGioBatDau(src.getGioBatDau());
                target.setGioKetThuc(src.getGioKetThuc());
                target.setGhiChu(src.getGhiChu());
                target.setGioNghi(src.getGioNghi());
                target.setTrangThai("Draft");
                target.setPublished(false);
                // BUG-CLONE-04: copy all business fields
                target.setTenCa(src.getTenCa());
                target.setViTri(src.getViTri());
                target.setCustomTime(src.isCustomTime());
                target.setCustomTimeReason(src.getCustomTimeReason());

                int thuVal = targetDate.getDayOfWeek().getValue() + 1;
                target.setThu(thuVal);

                targetShiftsToInsert.add(target);
            }
        }

        if (targetShiftsToInsert.isEmpty()) {
            throw new ValidationException("Không có ca nào hợp lệ để nhân bản sang tuần đích. " +
                    (reports.isEmpty() ? "" : "Chi tiết: " + String.join("; ", reports)));
        }

        // BUG-CLONE-01: wrap all inserts in one transaction
        // BUG-CLONE-02: use addCaLamViecWithConnection to get generated ID for audit
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                for (CaLamViec target : targetShiftsToInsert) {
                    int generatedId = caLamViecDAO.addCaLamViecWithConnection(target, conn);
                    if (generatedId <= 0) {
                        throw new IllegalStateException("Insert ca làm thất bại khi nhân bản.");
                    }
                    CaLamViecAudit audit = new CaLamViecAudit();
                    audit.setCaLamViecId(generatedId);
                    audit.setThaoTac("CLONE");
                    audit.setNguoiThucHien(actorId);
                    audit.setGiaTriMoi(target.toString());
                    audit.setLyDo("Nhân bản lịch từ tuần " + fromStart);
                    auditDAO.insertWithConnection(audit, conn);
                }
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw new IllegalStateException("Nhân bản lịch thất bại (đã rollback): " + e.getMessage(), e);
            }
        } catch (java.sql.SQLException e) {
            throw new IllegalStateException("Lỗi kết nối DB khi nhân bản lịch: " + e.getMessage(), e);
        }

        return reports;
    }

    /**
     * Công bố lịch làm việc cho cả tuần
     */
    public List<String> publishWeekShifts(LocalDate startOfWeek, int coSoId, int actorId) {
        if (startOfWeek == null) {
            throw new IllegalArgumentException("Ngày bắt đầu tuần không được để trống.");
        }
        if (startOfWeek.getDayOfWeek() != java.time.DayOfWeek.MONDAY) {
            throw new IllegalArgumentException("Tuần công bố phải bắt đầu từ thứ Hai (Monday).");
        }

        LocalDate endOfWeek = startOfWeek.plusDays(6);

        // BUG-PUB-04: block publishing past weeks
        if (endOfWeek.isBefore(LocalDate.now())) {
            throw new ValidationException("Không thể công bố lịch cho tuần đã kết thúc trong quá khứ.");
        }

        List<CaLamViec> shifts = caLamViecDAO.getShiftsByCoSoAndDateRange(coSoId, startOfWeek, endOfWeek);

        // BUG-PUB-01: only check for Draft status, ignore Cancelled/CheckedIn/etc.
        boolean hasDraft = shifts.stream().anyMatch(ca ->
            "Draft".equalsIgnoreCase(ca.getTrangThai())
        );
        if (shifts.isEmpty() || !hasDraft) {
            throw new IllegalArgumentException("Không có ca làm việc nháp nào trong tuần để công bố.");
        }

        // Keep only Draft shifts for audit (non-Draft shifts are untouched)
        List<CaLamViec> draftShifts = shifts.stream()
            .filter(ca -> "Draft".equalsIgnoreCase(ca.getTrangThai()))
            .toList();

        List<String> warnings = new ArrayList<>();

        // WARNING nếu có ca chưa được assign (accountId <= 0 hoặc null)
        boolean hasUnassigned = draftShifts.stream().anyMatch(ca -> ca.getAccountId() <= 0);
        if (hasUnassigned) {
            warnings.add("Có ca làm việc trong tuần chưa được phân công cho nhân viên.");
        }

        // WARNING nếu bất kỳ ngày nào trong tuần không có ca nào (cơ sở làm việc 7 ngày)
        for (int i = 0; i < 7; i++) {
            LocalDate date = startOfWeek.plusDays(i);
            boolean dayHasShift = shifts.stream().anyMatch(ca -> date.equals(ca.getNgayLam()));
            if (!dayHasShift) {
                warnings.add("Cơ sở làm việc 7 ngày nhưng ngày " + date + " không có ca làm việc nào.");
            }
        }

        // BUG-PUB-02: wrap publish + all audits in one transaction
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // BUG-PUB-01 + PUB-03: use new method that only touches Draft, returns count
                int publishedCount = caLamViecDAO.publishDraftShiftsWithConnection(startOfWeek, endOfWeek, coSoId, conn);
                if (publishedCount == 0) {
                    throw new IllegalArgumentException("Công bố lịch tuần thất bại: không có ca nào được publish.");
                }

                // BUG-PUB-03: read actual old status per shift rather than hardcoding "Unpublished"
                for (CaLamViec s : draftShifts) {
                    String oldStatus = s.getTrangThai() != null ? s.getTrangThai() : "Draft";
                    CaLamViecAudit audit = new CaLamViecAudit();
                    audit.setCaLamViecId(s.getCaLamViecId());
                    audit.setThaoTac("PUBLISH");
                    audit.setNguoiThucHien(actorId);
                    audit.setGiaTriCu(oldStatus);
                    audit.setGiaTriMoi("Published");
                    audit.setLyDo("Quản lý công bố lịch tuần");
                    auditDAO.insertWithConnection(audit, conn);
                }
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                if (e instanceof IllegalArgumentException) throw (IllegalArgumentException) e;
                if (e instanceof ValidationException) throw (ValidationException) e;
                throw new IllegalStateException("Công bố lịch thất bại (đã rollback): " + e.getMessage(), e);
            }
        } catch (java.sql.SQLException e) {
            throw new IllegalStateException("Lỗi kết nối DB khi công bố lịch: " + e.getMessage(), e);
        }

        // Notifications sent AFTER commit (non-critical, outside transaction)
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.set(java.util.Calendar.HOUR_OF_DAY, 0);
        cal.set(java.util.Calendar.MINUTE, 0);
        cal.set(java.util.Calendar.SECOND, 0);
        cal.set(java.util.Calendar.MILLISECOND, 0);
        java.util.Date todayZero = cal.getTime();

        List<Integer> notifiedAccounts = new ArrayList<>();
        for (CaLamViec s : draftShifts) {
            if (s.getAccountId() > 0 && !notifiedAccounts.contains(s.getAccountId())) {
                notifiedAccounts.add(s.getAccountId());

                List<org.example.model.ThongBao> userNotifs = thongBaoDAO.findByAccountID(s.getAccountId());
                boolean alreadyNotified = false;
                for (org.example.model.ThongBao nt : userNotifs) {
                    if (nt.getThoiGianGui() != null && !nt.getThoiGianGui().before(todayZero)) {
                        if ("LichLamViec".equals(nt.getLoaiThongBao()) &&
                            (nt.getTieuDe().contains("công bố") || nt.getTieuDe().contains("Lịch làm việc"))) {
                            alreadyNotified = true;
                            break;
                        }
                    }
                }

                if (!alreadyNotified) {
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
            }
        }

        return warnings;
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

        // BUG-SWAP-05: only allow swap for Published/Confirmed shifts
        String shiftStatus = shift.getTrangThai();
        if (shiftStatus == null ||
                (!"Published".equalsIgnoreCase(shiftStatus) && !"Confirmed".equalsIgnoreCase(shiftStatus))) {
            throw new ValidationException("Chỉ có thể gửi yêu cầu đổi ca cho ca ở trạng thái Đã Công Bố hoặc Đã Xác Nhận.");
        }

        // BUG-SWAP-06: block duplicate pending requests for the same shift
        if (swapRequestDAO.hasPendingForShift(sr.getCaLamViecIdGui())) {
            throw new ConflictException("Ca này đã có yêu cầu đổi ca đang chờ xử lý. Vui lòng đợi yêu cầu hiện tại được giải quyết.");
        }

        TaiKhoan guiAcc = taiKhoanDAO.getAccountById(sr.getAccountIdGui());
        TaiKhoan nhanAcc = taiKhoanDAO.getAccountById(sr.getAccountIdNhan());
        if (guiAcc == null || nhanAcc == null) {
            throw new IllegalArgumentException("Thông tin tài khoản không tồn tại.");
        }
        if (guiAcc.getCoSoId() == null || nhanAcc.getCoSoId() == null || !guiAcc.getCoSoId().equals(nhanAcc.getCoSoId())) {
            throw new IllegalArgumentException("Chỉ có thể hoán đổi ca làm với đồng nghiệp cùng chi nhánh.");
        }

        // BUG-SWAP-07: require same role (no LE_TAN swapping with BAO_VE)
        if (guiAcc.getRoleId() != nhanAcc.getRoleId()) {
            throw new ValidationException("Chỉ có thể đổi ca với nhân viên cùng vị trí (vai trò).");
        }

        // Validate receiver conflict for this shift
        CaLamValidationEngine.ValidationResult valRes = validationEngine.validateShift(
                sr.getAccountIdNhan(), shift.getNgayLam(), shift.getGioBatDau(), shift.getGioKetThuc(), shift.getGioNghi(), null, shift.getCoSoId()
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
                // BUG-SWAP-03: null-guard m.getCoSoId() before equals() to prevent NPE
                if (m.getRoleId() == Constants.ROLE_MANAGER &&
                        m.getCoSoId() != null && receiver != null &&
                        m.getCoSoId().equals(receiver.getCoSoId())) {
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

    public void approveSwapRequest(int swapId, int managerId, String notes) {
        CaLamViecSwapRequest sr = swapRequestDAO.getById(swapId);
        if (sr == null || !"ChoQuanLyDuyet".equals(sr.getTrangThai())) {
            throw new IllegalArgumentException("Yêu cầu không hợp lệ hoặc không ở trạng thái chờ duyệt.");
        }

        TaiKhoan manager = taiKhoanDAO.getAccountById(managerId);
        BranchSecurityUtils.getEntityOrThrow(manager, "Người duyệt");
        
        TaiKhoan requester = taiKhoanDAO.getAccountById(sr.getAccountIdGui());
        BranchSecurityUtils.getEntityOrThrow(requester, "Nhân viên gửi yêu cầu");
        BranchSecurityUtils.checkBranchAccess(requester.getCoSoId(), manager.getCoSoId());

        CaLamViec caGui = caLamViecDAO.getCaById(sr.getCaLamViecIdGui());
        CaLamViec caNhan = sr.getCaLamViecIdNhan() != null ? caLamViecDAO.getCaById(sr.getCaLamViecIdNhan()) : null;

        if (caGui == null) {
            throw new IllegalArgumentException("Ca làm nguồn không tồn tại.");
        }

        // Ca nguồn và ca nhận (nếu có) phải ở trạng thái Published/Confirmed (chưa CheckedIn/CheckedOut)
        if (!"Published".equalsIgnoreCase(caGui.getTrangThai()) && !"Confirmed".equalsIgnoreCase(caGui.getTrangThai())) {
            throw new IllegalArgumentException("Ca làm nguồn phải ở trạng thái Published hoặc Confirmed (chưa thực hiện hoặc hoàn thành).");
        }
        if (caNhan != null && !"Published".equalsIgnoreCase(caNhan.getTrangThai()) && !"Confirmed".equalsIgnoreCase(caNhan.getTrangThai())) {
            throw new IllegalArgumentException("Ca làm nhận phải ở trạng thái Published hoặc Confirmed.");
        }

        // Re-validate receiver onto caGui
        CaLamValidationEngine.ValidationResult valRes1 = validationEngine.validateShift(
                sr.getAccountIdNhan(), caGui.getNgayLam(), caGui.getGioBatDau(), caGui.getGioKetThuc(), caGui.getGioNghi(), caGui.getCaLamViecId(), caGui.getCoSoId()
        );

        // Re-validate requester onto caNhan
        CaLamValidationEngine.ValidationResult valRes2 = null;
        if (caNhan != null) {
            valRes2 = validationEngine.validateShift(
                    sr.getAccountIdGui(), caNhan.getNgayLam(), caNhan.getGioBatDau(), caNhan.getGioKetThuc(), caNhan.getGioNghi(), caNhan.getCaLamViecId(), caNhan.getCoSoId()
            );
        }

        // BUG-SWAP-02: throw BEFORE any DB write when validation fails, so DB stays clean
        if (!valRes1.isValid() || (valRes2 != null && !valRes2.isValid())) {
            String autoRejectReason = "Hệ thống tự động từ chối do phát sinh xung đột lịch: ";
            if (!valRes1.isValid()) {
                autoRejectReason += "Xung đột lịch với nhân viên nhận: " + String.join(", ", valRes1.getErrors());
            }
            if (valRes2 != null && !valRes2.isValid()) {
                autoRejectReason += "; Xung đột lịch với nhân viên gửi: " + String.join(", ", valRes2.getErrors());
            }
            throw new ConflictException(autoRejectReason);
        }

        // BUG-SWAP-01: wrap all swap DB ops in a single transaction
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 1. Swap caGui to receiver
                caGui.setAccountId(sr.getAccountIdNhan());
                caLamViecDAO.updateCaLamViecWithConnection(caGui, conn);

                CaLamViecAudit audit1 = new CaLamViecAudit();
                audit1.setCaLamViecId(caGui.getCaLamViecId());
                audit1.setThaoTac("SWAP");
                audit1.setNguoiThucHien(managerId);
                audit1.setGiaTriCu("Staff ID: " + sr.getAccountIdGui());
                audit1.setGiaTriMoi("Staff ID: " + sr.getAccountIdNhan());
                audit1.setLyDo("Phê duyệt hoán đổi ca làm. Ghi chú: " + notes);
                auditDAO.insertWithConnection(audit1, conn);

                // 2. Swap caNhan to requester (if trade)
                if (caNhan != null) {
                    caNhan.setAccountId(sr.getAccountIdGui());
                    caLamViecDAO.updateCaLamViecWithConnection(caNhan, conn);

                    CaLamViecAudit audit2 = new CaLamViecAudit();
                    audit2.setCaLamViecId(caNhan.getCaLamViecId());
                    audit2.setThaoTac("SWAP");
                    audit2.setNguoiThucHien(managerId);
                    audit2.setGiaTriCu("Staff ID: " + sr.getAccountIdNhan());
                    audit2.setGiaTriMoi("Staff ID: " + sr.getAccountIdGui());
                    audit2.setLyDo("Phê duyệt hoán đổi ca làm. Ghi chú: " + notes);
                    auditDAO.insertWithConnection(audit2, conn);
                }

                // 3. Update swap request to DaDuyet
                sr.setTrangThai("DaDuyet");
                sr.setNguoiDuyet(managerId);
                sr.setNgayDuyet(LocalDateTime.now());
                sr.setGhiChuQuanLy(notes);
                swapRequestDAO.updateWithConnection(sr, conn);

                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                if (e instanceof ConflictException) throw (ConflictException) e;
                if (e instanceof IllegalArgumentException) throw (IllegalArgumentException) e;
                throw new IllegalStateException("Phê duyệt hoán đổi ca thất bại (đã rollback): " + e.getMessage(), e);
            }
        } catch (java.sql.SQLException e) {
            throw new IllegalStateException("Lỗi kết nối DB khi phê duyệt hoán đổi ca: " + e.getMessage(), e);
        }

        // Notify both staff AFTER commit (non-critical)
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

    public void rejectSwapRequest(int swapId, int managerId, String notes) {
        CaLamViecSwapRequest sr = swapRequestDAO.getById(swapId);
        if (sr == null || !"ChoQuanLyDuyet".equals(sr.getTrangThai())) {
            throw new IllegalArgumentException("Yêu cầu không hợp lệ hoặc không ở trạng thái chờ duyệt.");
        }

        TaiKhoan manager = taiKhoanDAO.getAccountById(managerId);
        BranchSecurityUtils.getEntityOrThrow(manager, "Người từ chối");

        TaiKhoan requester = taiKhoanDAO.getAccountById(sr.getAccountIdGui());
        BranchSecurityUtils.getEntityOrThrow(requester, "Nhân viên gửi yêu cầu");
        BranchSecurityUtils.checkBranchAccess(requester.getCoSoId(), manager.getCoSoId());

        sr.setTrangThai("TuChoi");
        sr.setNguoiDuyet(managerId);
        sr.setNgayDuyet(LocalDateTime.now());
        sr.setGhiChuQuanLy(notes);
        swapRequestDAO.update(sr);

        // BUG-SWAP-04: write audit log on rejection
        CaLamViecAudit rejectAudit = new CaLamViecAudit();
        rejectAudit.setCaLamViecId(sr.getCaLamViecIdGui());
        rejectAudit.setThaoTac("SWAP_REJECT");
        rejectAudit.setNguoiThucHien(managerId);
        rejectAudit.setGiaTriCu("ChoQuanLyDuyet");
        rejectAudit.setGiaTriMoi("TuChoi");
        rejectAudit.setLyDo("Quản lý từ chối yêu cầu đổi ca. Ghi chú: " + (notes != null ? notes : ""));
        auditDAO.insert(rejectAudit);

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
    /**
     * Tự động ghép ca cho các ca làm việc trong khoảng thời gian dựa trên nguyện vọng rảnh/bận của nhân viên
     */
    public String autoScheduleShifts(LocalDate startDate, LocalDate endDate, int coSoId, int actorId) {
        if (startDate == null || endDate == null) {
            throw new IllegalArgumentException("Ngày bắt đầu và kết thúc không được để trống.");
        }
        if (startDate.isAfter(endDate)) {
            throw new IllegalArgumentException("Ngày bắt đầu phải trước hoặc bằng ngày kết thúc.");
        }
        if (java.time.temporal.ChronoUnit.DAYS.between(startDate, endDate) > 30) {
            throw new IllegalArgumentException("Khoảng thời gian tự động sắp lịch không được quá 30 ngày.");
        }
        // Priority 3 stub: Không cho auto-schedule ngày đã qua hoàn toàn
        if (endDate.isBefore(LocalDate.now())) {
            throw new ValidationException("Không thể tự động sắp lịch cho khoảng ngày đã kết thúc trong quá khứ.");
        }
        // BUG-AUTO-04: block if startDate itself is in the past
        if (startDate.isBefore(LocalDate.now())) {
            throw new ValidationException("Ngày bắt đầu sắp lịch tự động không thể là ngày đã qua.");
        }

        // 1. Lấy tất cả ca làm việc trong khoảng ngày của cơ sở
        List<CaLamViec> shifts = caLamViecDAO.getShiftsByCoSoAndDateRange(coSoId, startDate, endDate);
        if (shifts.isEmpty()) {
            throw new IllegalArgumentException("Không tìm thấy ca làm việc nào trong khoảng thời gian này để sắp lịch.");
        }

        // 2. Lấy tất cả nguyện vọng Ranh đã được duyệt của nhân viên trong cơ sở
        List<CaLamViecAvailability> avails = availabilityDAO.getByCoSoAndDateRange(coSoId, startDate, endDate);
        // Lọc các nguyện vọng 'Ranh' và đã 'DaDuyet' VÀ ngay của ngày đó chưa qua
        LocalDate today = LocalDate.now();
        List<CaLamViecAvailability> freeAvails = avails.stream()
                .filter(a -> "Ranh".equalsIgnoreCase(a.getTrangThai()) && 
                             "DaDuyet".equalsIgnoreCase(a.getDuyetTrangThai()) &&
                             a.getNgay() != null &&
                             !a.getNgay().isBefore(today))
                .toList();

        // 3. Lấy danh sách nhân viên của cơ sở
        List<TaiKhoan> staffs = getStaffAvailableForShift(coSoId);

        int scheduledCount = 0;
        int unassignedCount = 0;
        List<String> autoErrors = new ArrayList<>();

        // BUG-AUTO-02: track assigned hours in-session (in-memory, updated as we assign)
        java.util.Map<Integer, Double> assignedHoursMap = new java.util.HashMap<>();

        // Duyệt qua từng ca làm việc để tìm nhân viên phù hợp
        for (CaLamViec shift : shifts) {
            // BUG-AUTO-01: null status must be skipped (treated as non-Draft)
            if (shift.getTrangThai() == null) continue;
            // Only auto-schedule Draft shifts
            if (!"Draft".equals(shift.getTrangThai())) {
                continue;
            }

            // Tìm các nhân viên có nguyện vọng rảnh bao phủ khung giờ của ca này
            List<TaiKhoan> candidateStaffs = new ArrayList<>();
            for (TaiKhoan staff : staffs) {
                boolean isAvailable = freeAvails.stream().anyMatch(a ->
                    a.getAccountId() == staff.getAccountId() &&
                    a.getNgay().equals(shift.getNgayLam()) &&
                    !shift.getGioBatDau().isBefore(a.getGioBatDau()) &&
                    !shift.getGioKetThuc().isAfter(a.getGioKetThuc())
                );

                if (isAvailable) {
                    CaLamValidationEngine.ValidationResult valRes = validationEngine.validateShift(
                            staff.getAccountId(), shift.getNgayLam(), shift.getGioBatDau(), shift.getGioKetThuc(), shift.getGioNghi(), shift.getCaLamViecId(), shift.getCoSoId()
                    );
                    if (valRes.isValid()) {
                        candidateStaffs.add(staff);
                    }
                }
            }

            if (!candidateStaffs.isEmpty()) {
                // BUG-AUTO-02: fairness using in-session tracking map, not just the DB snapshot
                TaiKhoan bestStaff = null;
                double minHours = Double.MAX_VALUE;
                for (TaiKhoan staff : candidateStaffs) {
                    double h = assignedHoursMap.getOrDefault(staff.getAccountId(), 0.0);
                    if (h < minHours) {
                        minHours = h;
                        bestStaff = staff;
                    }
                }

                if (bestStaff != null) {
                    int oldStaffId = shift.getAccountId();
                    shift.setAccountId(bestStaff.getAccountId());
                    boolean updated = caLamViecDAO.updateCaLamViec(shift);
                    if (!updated) {
                        // BUG-AUTO-03: consistent error tracking instead of silently dropping
                        autoErrors.add("Cập nhật ca ID=" + shift.getCaLamViecId() + " thất bại.");
                        unassignedCount++;
                        continue;
                    }
                    scheduledCount++;

                    // Update in-session hours map
                    long netMinutes = java.time.Duration.between(shift.getGioBatDau(), shift.getGioKetThuc()).toMinutes() - shift.getGioNghi();
                    assignedHoursMap.merge(bestStaff.getAccountId(), netMinutes / 60.0, Double::sum);

                    CaLamViecAudit audit = new CaLamViecAudit();
                    audit.setCaLamViecId(shift.getCaLamViecId());
                    audit.setThaoTac("AUTO_SCHEDULE");
                    audit.setNguoiThucHien(actorId);
                    audit.setGiaTriCu("Nhân viên ID: " + oldStaffId);
                    audit.setGiaTriMoi("Nhân viên ID: " + bestStaff.getAccountId());
                    audit.setLyDo("Tự động sắp lịch dựa trên nguyện vọng rảnh");
                    auditDAO.insert(audit);
                } else {
                    unassignedCount++;
                }
            } else {
                unassignedCount++;
            }
        }

        // BUG-AUTO-03: consistent error handling — throw only when zero scheduled AND no partial success
        if (scheduledCount == 0 && autoErrors.isEmpty()) {
            throw new ValidationException("Không thể tự động sắp lịch: Không có nhân viên nào phù hợp hoặc rảnh trong khoảng thời gian đã chọn.");
        }
        if (scheduledCount == 0 && !autoErrors.isEmpty()) {
            throw new IllegalStateException("Tự động sắp lịch thất bại hoàn toàn: " + String.join("; ", autoErrors));
        }

        String result = String.format("Tự động sắp lịch thành công: đã phân bổ %d ca làm việc, còn lại %d ca chưa tìm được nhân sự phù hợp.", scheduledCount, unassignedCount);
        if (!autoErrors.isEmpty()) {
            result += " Lỗi ghi nhận: " + String.join("; ", autoErrors);
        }
        return result;
    }
}
