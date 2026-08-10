package org.example.model;

import jakarta.persistence.*;
import java.util.Date;
import java.time.LocalDateTime;

@Entity
@Table(name = "accounts")
public class TaiKhoan {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "account_id")
    private int accountId;

    @Column(name = "username")
    private String username;

    @Column(name = "password_hash")
    private String password;

    @Transient // Not in DB schema based on SQL provided
    private String passwordSalt;

    @Column(name = "failed_login_count")
    private Integer failedLoginCount = 0;

    @Column(name = "is_locked")
    private boolean isLocked;

    @Column(name = "last_login_at")
    @Temporal(TemporalType.TIMESTAMP)
    private Date lastLogin;

    @Column(name = "google_id")
    private String googleId;

    @Column(name = "facebook_id")
    private String facebookId;

    @Column(name = "full_name")
    private String fullName;

    @Column(name = "phone_number")
    private String phoneNumber;

    @Column(name = "email")
    private String email;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Column(name = "role_id")
    private Integer roleId;

    @Column(name = "facility_id")
    private Integer coSoId;

    @Column(name = "zalo_id")
    private String zaloId;

    @Column(name = "messenger_id")
    private String messengerId;

    @Column(name = "reputation_score", columnDefinition = "int default 100")
    private int diemUyTin = 100;

    @Column(name = "late_cancel_count", columnDefinition = "int default 0")
    private int lateCancelCount = 0;

    @Column(name = "no_show_count", columnDefinition = "int default 0")
    private int noShowCount = 0;

    @Column(name = "completed_booking_count", columnDefinition = "int default 0")
    private int completedBookingCount = 0;

    @Column(name = "bank_code")
    private String maNganHang;

    @Column(name = "bank_account_number")
    private String soTaiKhoan;

    @Column(name = "qr_image_path")
    private String qrImagePath;

    @Column(name = "preferred_position")
    private String viTriSoTruong;

    @Column(name = "date_of_birth")
    @Temporal(TemporalType.DATE)
    private Date ngaySinh;

    @Column(name = "gender")
    private String gioiTinh;

    @Column(name = "created_at", insertable = false, updatable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private Date createdAt;

    @Transient // Not directly in the Accounts table (mapped via many-to-many usually)
    private String monTheThaoYeuThich;

    @Transient // First preferred sport ID, populated at login from MonTheThaoYeuThich table
    private Integer monTheThaoYeuThichId;

    @Column(name = "is_deleted", columnDefinition = "bit default 0")
    private Boolean isDeleted = false;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    @Column(name = "deleted_by")
    private Integer deletedBy;

    public Boolean isDeleted() {
        return isDeleted != null && isDeleted;
    }

    public void setDeleted(Boolean deleted) {
        isDeleted = deleted;
    }

    public LocalDateTime getDeletedAt() { return deletedAt; }

    public void setDeletedAt(LocalDateTime deletedAt) { this.deletedAt = deletedAt; }

    public Integer getDeletedBy() { return deletedBy; }

    public void setDeletedBy(Integer deletedBy) { this.deletedBy = deletedBy; }

    public boolean isLocked() {
        return isLocked;
    }

    public void setLocked(boolean locked) {
        isLocked = locked;
    }

    public String getMonTheThaoYeuThich() {
        return monTheThaoYeuThich;
    }

    public void setMonTheThaoYeuThich(String monTheThaoYeuThich) {
        this.monTheThaoYeuThich = monTheThaoYeuThich;
    }

    public Integer getMonTheThaoYeuThichId() {
        return monTheThaoYeuThichId;
    }

    public void setMonTheThaoYeuThichId(Integer monTheThaoYeuThichId) {
        this.monTheThaoYeuThichId = monTheThaoYeuThichId;
    }

    public TaiKhoan() {
    }

    public TaiKhoan(int accountId, String username, String password, String passwordSalt, 
                   int failedLoginCount, boolean isLocked, Date lastLogin, 
                   String googleId, String facebookId, String fullName, String phoneNumber, 
                   String email, Integer roleId, int coSoId, String zaloId, String messengerId,
                   int diemUyTin, String maNganHang, String soTaiKhoan,
                   String viTriSoTruong, Date ngaySinh, String gioiTinh,
                   Date createdAt) {
        this.accountId = accountId;
        this.username = username;
        this.password = password;
        this.passwordSalt = passwordSalt;
        this.failedLoginCount = failedLoginCount;
        this.isLocked = isLocked;
        this.lastLogin = lastLogin;
        this.googleId = googleId;
        this.facebookId = facebookId;
        this.fullName = fullName;
        this.phoneNumber = phoneNumber;
        this.email = email;
        this.roleId = roleId;
        this.coSoId = coSoId;
        this.zaloId = zaloId;
        this.messengerId = messengerId;
        this.diemUyTin = diemUyTin;
        this.maNganHang = maNganHang;
        this.soTaiKhoan = soTaiKhoan;
        this.viTriSoTruong = viTriSoTruong;
        this.ngaySinh = ngaySinh;
        this.gioiTinh = gioiTinh;
        this.createdAt = createdAt;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPasswordSalt() {
        return passwordSalt;
    }

    public void setPasswordSalt(String passwordSalt) {
        this.passwordSalt = passwordSalt;
    }

    public int getFailedLoginCount() {
        return failedLoginCount;
    }

    public void setFailedLoginCount(int failedLoginCount) {
        this.failedLoginCount = failedLoginCount;
    }

    public boolean getIsLocked() {
        return isLocked;
    }

    public void setIsLocked(boolean isLocked) {
        this.isLocked = isLocked;
    }

    public Date getLastLogin() {
        return lastLogin;
    }

    public void setLastLogin(Date lastLogin) {
        this.lastLogin = lastLogin;
    }

    public String getGoogleId() {
        return googleId;
    }

    public void setGoogleId(String googleId) {
        this.googleId = googleId;
    }

    public String getFacebookId() {
        return facebookId;
    }

    public void setFacebookId(String facebookId) {
        this.facebookId = facebookId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public Integer getRoleId() {
        return roleId;
    }

    public void setRoleId(Integer roleId) {
        this.roleId = roleId;
    }

    public Integer getCoSoId() {
        return coSoId;
    }

    public void setCoSoId(Integer coSoId) {
        this.coSoId = coSoId;
    }

    public String getZaloId() {
        return zaloId;
    }

    public void setZaloId(String zaloId) {
        this.zaloId = zaloId;
    }

    public String getMessengerId() {
        return messengerId;
    }

    public void setMessengerId(String messengerId) {
        this.messengerId = messengerId;
    }

    public int getDiemUyTin() {
        return diemUyTin;
    }

    public void setDiemUyTin(int diemUyTin) {
        this.diemUyTin = diemUyTin;
    }

    public int getLateCancelCount() {
        return lateCancelCount;
    }

    public void setLateCancelCount(int lateCancelCount) {
        this.lateCancelCount = lateCancelCount;
    }

    public int getNoShowCount() {
        return noShowCount;
    }

    public void setNoShowCount(int noShowCount) {
        this.noShowCount = noShowCount;
    }

    public int getCompletedBookingCount() {
        return completedBookingCount;
    }

    public void setCompletedBookingCount(int completedBookingCount) {
        this.completedBookingCount = completedBookingCount;
    }

    public String getMaNganHang() {
        return maNganHang;
    }

    public void setMaNganHang(String maNganHang) {
        this.maNganHang = maNganHang;
    }

    public String getSoTaiKhoan() {
        return soTaiKhoan;
    }

    public void setSoTaiKhoan(String soTaiKhoan) {
        this.soTaiKhoan = soTaiKhoan;
    }

    /** Đường dẫn tương đối tới ảnh QR ngân hàng tĩnh nhân viên tự upload, ví dụ "nhan-vien-qr/12/<uuid>.png". */
    public String getQrImagePath() {
        return qrImagePath;
    }

    public void setQrImagePath(String qrImagePath) {
        this.qrImagePath = qrImagePath;
    }

    public String getViTriSoTruong() {
        return viTriSoTruong;
    }

    public void setViTriSoTruong(String viTriSoTruong) {
        this.viTriSoTruong = viTriSoTruong;
    }

    public Date getNgaySinh() {
        return ngaySinh;
    }

    public void setNgaySinh(Date ngaySinh) {
        this.ngaySinh = ngaySinh;
    }

    public String getGioiTinh() {
        return gioiTinh;
    }

    public void setGioiTinh(String gioiTinh) {
        this.gioiTinh = gioiTinh;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "TaiKhoan{" +
                "accountId=" + accountId +
                ", username='" + username + '\'' +
                ", password='" + password + '\'' +
                ", passwordSalt='" + passwordSalt + '\'' +
                ", failedLoginCount=" + failedLoginCount +
                ", isLocked=" + isLocked +
                ", lastLogin=" + lastLogin +
                ", googleId='" + googleId + '\'' +
                ", facebookId='" + facebookId + '\'' +
                ", fullName='" + fullName + '\'' +
                ", phoneNumber='" + phoneNumber + '\'' +
                ", email='" + email + '\'' +
                ", avatarUrl='" + avatarUrl + '\'' +
                ", roleId=" + roleId +
                ", coSoId=" + coSoId +
                ", zaloId='" + zaloId + '\'' +
                ", messengerId='" + messengerId + '\'' +
                ", diemUyTin=" + diemUyTin +
                ", maNganHang='" + maNganHang + '\'' +
                ", soTaiKhoan='" + soTaiKhoan + '\'' +
                ", viTriSoTruong='" + viTriSoTruong + '\'' +
                ", ngaySinh=" + ngaySinh +
                ", gioiTinh='" + gioiTinh + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }

    public void setRoleID(Integer roleID) {
        this.roleId = roleID;
    }
}



