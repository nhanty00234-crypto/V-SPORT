package org.example.service.manager;

import org.example.dao.TaiKhoanDAO;
import org.example.dao.VaiTroDAO;
import org.example.dao.CaLamViecDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.dao.impl.VaiTroDAOImpl;
import org.example.dao.impl.CaLamViecDAOImpl;

import org.example.model.CaLamViec;
import org.example.model.TaiKhoan;
import org.example.model.VaiTro;
import org.example.util.BranchSecurityUtils;
import org.example.util.Constants;
import org.example.util.ValidationUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Service layer cho quản lý nhân sự (Manager scope)
 * Business logic tập trung, dễ test và maintain
 */
public class NhanSuService {

    private final TaiKhoanDAO taiKhoanDAO;
    private final VaiTroDAO vaiTroDAO;
    private final CaLamViecDAO caLamViecDAO;

    public NhanSuService() {
        this.taiKhoanDAO = new TaiKhoanDAOImpl();
        this.vaiTroDAO = new VaiTroDAOImpl();
        this.caLamViecDAO = new CaLamViecDAOImpl();
    }

    // Constructor for dependency injection (testing)
    public NhanSuService(TaiKhoanDAO taiKhoanDAO, VaiTroDAO vaiTroDAO, CaLamViecDAO caLamViecDAO) {
        this.taiKhoanDAO = taiKhoanDAO;
        this.vaiTroDAO = vaiTroDAO;
        this.caLamViecDAO = caLamViecDAO;
    }

    // ==================== DTOs ====================

    /**
     * DTO cho danh sách nhân viên
     */
    public static class NhanSuDTO {
        private int accountId;
        private String username;
        private String fullName;
        private String email;
        private String phoneNumber;
        private int roleId;
        private String roleName;
        private boolean locked;
        private String statusDisplay;
        private String initial;

        // Constructors, getters, setters
        public NhanSuDTO() {}

        public NhanSuDTO(int accountId, String username, String fullName, String email,
                        String phoneNumber, int roleId, String roleName, boolean locked) {
            this.accountId = accountId;
            this.username = username;
            this.fullName = fullName;
            this.email = email;
            this.phoneNumber = phoneNumber;
            this.roleId = roleId;
            this.roleName = roleName;
            this.locked = locked;
            this.initial = getInitial(fullName, username);
            this.statusDisplay = locked ? "Bị khóa" : "Đang làm";
        }

        private String getInitial(String fullName, String username) {
            if (fullName != null && !fullName.trim().isEmpty()) {
                return fullName.substring(0, 1).toUpperCase();
            }
            return username.substring(0, 1).toUpperCase();
        }

        // Getters
        public int getAccountId() { return accountId; }
        public String getUsername() { return username; }
        public String getFullName() { return fullName; }
        public String getEmail() { return email; }
        public String getPhoneNumber() { return phoneNumber; }
        public int getRoleId() { return roleId; }
        public String getRoleName() { return roleName; }
        public boolean isLocked() { return locked; }
        public String getStatusDisplay() { return statusDisplay; }
        public String getInitial() { return initial; }

        public void setAccountId(int accountId) { this.accountId = accountId; }
        public void setUsername(String username) { this.username = username; }
        public void setFullName(String fullName) { this.fullName = fullName; }
        public void setEmail(String email) { this.email = email; }
        public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
        public void setRoleId(int roleId) { this.roleId = roleId; }
        public void setRoleName(String roleName) { this.roleName = roleName; }
        public void setLocked(boolean locked) { this.locked = locked; }
        public void setStatusDisplay(String statusDisplay) { this.statusDisplay = statusDisplay; }
        public void setInitial(String initial) { this.initial = initial; }
    }

    /**
     * Request object cho tạo nhân viên mới
     */
    public static class StaffCreateRequest {
        private String username;
        private String password;
        private String fullName;
        private String email;
        private String phoneNumber;
        private int roleId;
        private String zaloId;
        private String messengerId;
        private String maNganHang;
        private String soTaiKhoan;
        private String viTriSoTruong;
        private String gioiTinh;
        private String ngaySinh; // YYYY-MM-dd

        // Getters and setters
        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
        public String getFullName() { return fullName; }
        public void setFullName(String fullName) { this.fullName = fullName; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getPhoneNumber() { return phoneNumber; }
        public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
        public int getRoleId() { return roleId; }
        public void setRoleId(int roleId) { this.roleId = roleId; }
        public String getZaloId() { return zaloId; }
        public void setZaloId(String zaloId) { this.zaloId = zaloId; }
        public String getMessengerId() { return messengerId; }
        public void setMessengerId(String messengerId) { this.messengerId = messengerId; }
        public String getMaNganHang() { return maNganHang; }
        public void setMaNganHang(String maNganHang) { this.maNganHang = maNganHang; }
        public String getSoTaiKhoan() { return soTaiKhoan; }
        public void setSoTaiKhoan(String soTaiKhoan) { this.soTaiKhoan = soTaiKhoan; }
        public String getViTriSoTruong() { return viTriSoTruong; }
        public void setViTriSoTruong(String viTriSoTruong) { this.viTriSoTruong = viTriSoTruong; }
        public String getGioiTinh() { return gioiTinh; }
        public void setGioiTinh(String gioiTinh) { this.gioiTinh = gioiTinh; }
        public String getNgaySinh() { return ngaySinh; }
        public void setNgaySinh(String ngaySinh) { this.ngaySinh = ngaySinh; }
    }

    /**
     * Request object cho update nhân viên
     */
    public static class StaffUpdateRequest {
        private String fullName;
        private String email;
        private String phoneNumber;
        private Integer roleId; // nullable
        private Boolean isLocked; // nullable - chỉ update lock status
        private String zaloId;
        private String messengerId;
        private String maNganHang;
        private String soTaiKhoan;
        private String viTriSoTruong;
        private String gioiTinh;
        private String ngaySinh;

        // Getters and setters
        public String getFullName() { return fullName; }
        public void setFullName(String fullName) { this.fullName = fullName; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getPhoneNumber() { return phoneNumber; }
        public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
        public Integer getRoleId() { return roleId; }
        public void setRoleId(Integer roleId) { this.roleId = roleId; }
        public Boolean getIsLocked() { return isLocked; }
        public void setIsLocked(Boolean locked) { isLocked = locked; }
        public String getZaloId() { return zaloId; }
        public void setZaloId(String zaloId) { this.zaloId = zaloId; }
        public String getMessengerId() { return messengerId; }
        public void setMessengerId(String messengerId) { this.messengerId = messengerId; }
        public String getMaNganHang() { return maNganHang; }
        public void setMaNganHang(String maNganHang) { this.maNganHang = maNganHang; }
        public String getSoTaiKhoan() { return soTaiKhoan; }
        public void setSoTaiKhoan(String soTaiKhoan) { this.soTaiKhoan = soTaiKhoan; }
        public String getViTriSoTruong() { return viTriSoTruong; }
        public void setViTriSoTruong(String viTriSoTruong) { this.viTriSoTruong = viTriSoTruong; }
        public String getGioiTinh() { return gioiTinh; }
        public void setGioiTinh(String gioiTinh) { this.gioiTinh = gioiTinh; }
        public String getNgaySinh() { return ngaySinh; }
        public void setNgaySinh(String ngaySinh) { this.ngaySinh = ngaySinh; }
    }

    // ==================== READ OPERATIONS ====================

    /**
     * Lấy danh sách nhân viên (không bao gồm Admin/Manager) của cơ sở
     */
    public List<NhanSuDTO> getStaffListByBranch(int coSoId) {
        List<TaiKhoan> accounts = taiKhoanDAO.getAccountsByCoSoAndRoleNotIn(
            coSoId,
            List.of(Constants.ROLE_ADMIN, Constants.ROLE_MANAGER)
        );

        List<VaiTro> allRoles = vaiTroDAO.getAllRoles();

        return accounts.stream()
            .map(acc -> {
                VaiTro role = allRoles.stream()
                    .filter(r -> r.getRoleId() == acc.getRoleId())
                    .findFirst()
                    .orElse(new VaiTro(acc.getRoleId(), "Không xác định"));
                return new NhanSuDTO(
                    acc.getAccountId(),
                    acc.getUsername(),
                    acc.getFullName(),
                    acc.getEmail(),
                    acc.getPhoneNumber(),
                    acc.getRoleId(),
                    role.getRoleName(),
                    acc.isLocked()
                );
            })
            .collect(Collectors.toList());
    }

    /**
     * Lấy danh sách vai trò có thể gán cho nhân viên (không bao gồm Admin/Manager)
     */
    public List<VaiTro> getAssignableRoles() {
        List<VaiTro> allRoles = vaiTroDAO.getAllRoles();
        return allRoles.stream()
            .filter(r -> r.getRoleId() != Constants.ROLE_ADMIN && r.getRoleId() != Constants.ROLE_MANAGER)
            .collect(Collectors.toList());
    }

    /**
     * Lấy thông tin nhân viên theo ID
     */
    public TaiKhoan getStaffById(int accountId) {
        TaiKhoan account = taiKhoanDAO.getAccountById(accountId);
        if (account == null) {
            throw new IllegalArgumentException("Nhân viên không tồn tại");
        }
        return account;
    }

    /**
     * Kiểm tra xem account có phải là staff (không phải Admin/Manager) không
     */
    public boolean isStaff(int roleId) {
        return roleId != Constants.ROLE_ADMIN && roleId != Constants.ROLE_MANAGER;
    }

    // ==================== CREATE OPERATIONS ====================

    /**
     * Tạo nhân viên mới trong cơ sở
     * @return accountId của nhân viên mới
     */
    public int createStaff(StaffCreateRequest request, int managerCoSoId, int managerAccountId) {
        if (request == null) throw new IllegalArgumentException("Yêu cầu không được để trống");
        if (request.getUsername() != null) request.setUsername(request.getUsername().trim());
        if (request.getEmail() != null) request.setEmail(request.getEmail().trim());
        if (request.getPhoneNumber() != null) request.setPhoneNumber(request.getPhoneNumber().trim());
        if (request.getFullName() != null) request.setFullName(request.getFullName().trim());
        if (request.getPassword() != null) request.setPassword(request.getPassword().trim());

        // Validate input
        Map<String, String> errors = ValidationUtils.validateStaffCreate(
            request.getUsername(),
            request.getEmail(),
            request.getPhoneNumber(),
            request.getFullName(),
            request.getRoleId()
        );

        // Check username exists
        if (taiKhoanDAO.kiemtraUsername(request.getUsername())) {
            errors.put("username", "Tên đăng nhập đã tồn tại");
        }

        // Check email exists
        if (taiKhoanDAO.kiemtraEmail(request.getEmail())) {
            errors.put("email", "Email đã tồn tại trên hệ thống");
        }

        if (!errors.isEmpty()) {
            throw new IllegalArgumentException(errors.toString());
        }

        // Validate password if provided, otherwise use default
        String rawPassword = request.getPassword();
        if (rawPassword == null || rawPassword.trim().isEmpty()) {
            rawPassword = "123"; // Default weak password - TODO: Force change on first login
        } else {
            ValidationUtils.validateStrongPassword(rawPassword);
        }

        // Create account
        TaiKhoan newAcc = new TaiKhoan();
        newAcc.setUsername(request.getUsername());
        newAcc.setFullName(request.getFullName());
        newAcc.setEmail(request.getEmail());
        newAcc.setPhoneNumber(request.getPhoneNumber());
        newAcc.setRoleId(request.getRoleId());
        newAcc.setCoSoId(managerCoSoId);
        newAcc.setZaloId(request.getZaloId());
        newAcc.setMessengerId(request.getMessengerId());
        newAcc.setMaNganHang(request.getMaNganHang());
        newAcc.setSoTaiKhoan(request.getSoTaiKhoan());
        newAcc.setViTriSoTruong(request.getViTriSoTruong());
        newAcc.setGioiTinh(request.getGioiTinh());

        // Parse ngaySinh if provided
        if (request.getNgaySinh() != null && !request.getNgaySinh().isEmpty()) {
            newAcc.setNgaySinh(ValidationUtils.parseDate(request.getNgaySinh(), "yyyy-MM-dd"));
        }

        newAcc.setIsLocked(false);

        // Hash password
        String hashedPassword = org.mindrot.jbcrypt.BCrypt.hashpw(
            rawPassword,
            org.mindrot.jbcrypt.BCrypt.gensalt(12)
        );
        newAcc.setPassword(hashedPassword);

        // Save - set default scores and notification flag
        boolean success = taiKhoanDAO.addAccountByAdmin(newAcc);
        if (!success) {
            throw new IllegalArgumentException("Thêm nhân viên thất bại");
        }
        int newAccountId = newAcc.getAccountId();

        // Send OTP for email verification (existing flow)
        String otpString = taiKhoanDAO.sendRegistrationOTP(
            request.getEmail(),
            request.getFullName()
        );

        // Return newAccountId, caller should store OTP in session
        return newAccountId;
    }

    // ==================== UPDATE OPERATIONS ====================

    /**
     * Cập nhật thông tin nhân viên
     * Supports two modes:
     * 1. Update lock status only (isLocked param != null)
     * 2. Update full info (isLocked == null)
     */
    public void updateStaff(int accountId, StaffUpdateRequest request, int managerCoSoId) {
        if (request == null) throw new IllegalArgumentException("Yêu cầu không được để trống");
        if (request.getFullName() != null) request.setFullName(request.getFullName().trim());
        if (request.getEmail() != null) request.setEmail(request.getEmail().trim());
        if (request.getPhoneNumber() != null) request.setPhoneNumber(request.getPhoneNumber().trim());

        // Get existing account
        TaiKhoan account = taiKhoanDAO.getAccountById(accountId);
        BranchSecurityUtils.getEntityOrThrow(account, "Nhân viên");

        // Check branch access
        BranchSecurityUtils.checkBranchAccess(account.getCoSoId(), managerCoSoId);

        // Check if trying to elevate to Admin/Manager
        if (request.getRoleId() != null) {
            if (request.getRoleId() == Constants.ROLE_ADMIN ||
                request.getRoleId() == Constants.ROLE_MANAGER) {
                throw new IllegalArgumentException("Không thể nâng cấp lên quyền Quản trị hoặc Quản lý!");
            }
        }

        // Lock-only update (quick toggle)
        if (request.getIsLocked() != null) {
            account.setIsLocked(request.getIsLocked());
            taiKhoanDAO.updateAccount(account);
            return;
        }

        // Full update
        // Validate email
        if (request.getEmail() != null && !request.getEmail().equalsIgnoreCase(account.getEmail())) {
            if (taiKhoanDAO.kiemtraEmail(request.getEmail())) {
                throw new IllegalArgumentException("Email đã tồn tại trên hệ thống!");
            }
            ValidationUtils.validateEmail(request.getEmail());
        }

        // Validate phone if provided
        if (request.getPhoneNumber() != null && !request.getPhoneNumber().trim().isEmpty()) {
            ValidationUtils.validateVietnamPhone(request.getPhoneNumber());
        }

        // Update fields
        if (request.getFullName() != null) {
            account.setFullName(request.getFullName());
        }
        if (request.getEmail() != null) {
            account.setEmail(request.getEmail());
        }
        if (request.getPhoneNumber() != null) {
            account.setPhoneNumber(request.getPhoneNumber());
        }
        if (request.getRoleId() != null) {
            account.setRoleId(request.getRoleId());
        }
        if (request.getZaloId() != null) {
            account.setZaloId(request.getZaloId());
        }
        if (request.getMessengerId() != null) {
            account.setMessengerId(request.getMessengerId());
        }
        if (request.getMaNganHang() != null) {
            account.setMaNganHang(request.getMaNganHang());
        }
        if (request.getSoTaiKhoan() != null) {
            account.setSoTaiKhoan(request.getSoTaiKhoan());
        }
        if (request.getViTriSoTruong() != null) {
            account.setViTriSoTruong(request.getViTriSoTruong());
        }
        if (request.getGioiTinh() != null) {
            account.setGioiTinh(request.getGioiTinh());
        }
        if (request.getNgaySinh() != null && !request.getNgaySinh().isEmpty()) {
            account.setNgaySinh(ValidationUtils.parseDate(request.getNgaySinh(), "yyyy-MM-dd"));
        }

        taiKhoanDAO.updateAccount(account);
    }

    // ==================== DELETE OPERATIONS ====================

    /**
     * Xóa nhân viên (hard delete)
     * Chỉ cho phép xóa staff (role != Admin/Manager) và thuộc branch
     */
    public void deleteStaff(int accountId, int managerCoSoId) {
        TaiKhoan account = taiKhoanDAO.getAccountById(accountId);
        BranchSecurityUtils.getEntityOrThrow(account, "Nhân viên");

        // Check branch access
        BranchSecurityUtils.checkBranchAccess(account.getCoSoId(), managerCoSoId);

        // Cannot delete Admin/Manager
        if (!isStaff(account.getRoleId())) {
            throw new IllegalArgumentException("Không thể xóa tài khoản có quyền Quản trị hoặc Quản lý!");
        }

        taiKhoanDAO.deleteAccount(accountId);
    }

    // ==================== SHIFT MANAGEMENT ====================

    /**
     * Thêm ca làm định kỳ cho nhân viên
     * Kiểm tra xung đột trước khi thêm
     */
    public void addShiftPattern(int accountId, int coSoId, int thu, java.time.LocalTime gioBatDau, java.time.LocalTime gioKetThuc, String ghiChu) {
        if (accountId <= 0) throw new IllegalArgumentException("AccountID không hợp lệ");
        if (coSoId <= 0) throw new IllegalArgumentException("CoSoID không hợp lệ");
        if (thu < 2 || thu > 8) throw new IllegalArgumentException("Thứ không hợp lệ (2-8)");
        if (gioBatDau == null || gioKetThuc == null) throw new IllegalArgumentException("Giờ làm không được để trống");
        if (gioKetThuc.isBefore(gioBatDau) || gioKetThuc.equals(gioBatDau)) {
            throw new IllegalArgumentException("Giờ kết thúc phải sau giờ bắt đầu");
        }

        // Kiểm tra xung đột với các ca định kỳ khác của nhân viên
        // (Cùng thứ và thời gian trùng lặp)
        List<CaLamViec> existingShifts = caLamViecDAO.getRecurringShiftsByAccountID(accountId);
        for (CaLamViec shift : existingShifts) {
            if (shift.getThu() == thu) {
                boolean overlap = gioBatDau.isBefore(shift.getGioKetThuc()) &&
                                  gioKetThuc.isAfter(shift.getGioBatDau());
                if (overlap) {
                    throw new IllegalArgumentException(String.format(
                        "Ca làm vào thứ %d (%s - %s) bị trùng với ca đã có (%s - %s)",
                        thu, gioBatDau, gioKetThuc, shift.getGioBatDau(), shift.getGioKetThuc()
                    ));
                }
            }
        }

        CaLamViec newShift = new CaLamViec();
        newShift.setAccountId(accountId);
        newShift.setCoSoId(coSoId);
        newShift.setThu(thu);
        newShift.setGioBatDau(gioBatDau);
        newShift.setGioKetThuc(gioKetThuc);
        newShift.setGhiChu(ghiChu);
        newShift.setNgayLam(null); // Ca định kỳ không có ngày cụ thể

        boolean success = caLamViecDAO.addCaLamViec(newShift);
        if (!success) {
            throw new IllegalArgumentException("Không thể thêm ca làm định kỳ");
        }
    }

    /**
     * Xóa ca làm định kỳ của nhân viên theo thứ
     */
    public void deleteShiftPattern(int accountId, int thu) {
        if (accountId <= 0) throw new IllegalArgumentException("AccountID không hợp lệ");
        if (thu < 2 || thu > 8) throw new IllegalArgumentException("Thứ không hợp lệ");

        List<CaLamViec> shifts = caLamViecDAO.getRecurringShiftsByAccountID(accountId);
        for (CaLamViec shift : shifts) {
            if (shift.getThu() != null && shift.getThu() == thu) {
                caLamViecDAO.deleteCaLamViec(shift.getCaLamViecId());
            }
        }
    }

    /**
     * Lấy danh sách ca làm định kỳ của một nhân viên
     */
    public List<CaLamViec> getShiftPatternsByStaff(int accountId) {
        if (accountId <= 0) throw new IllegalArgumentException("AccountID không hợp lệ");
        return caLamViecDAO.getRecurringShiftsByAccountID(accountId);
    }
}
