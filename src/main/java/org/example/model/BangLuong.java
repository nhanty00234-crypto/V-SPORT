package org.example.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/** Dòng lương của một nhân viên trong một kỳ (bảng BangLuong). */
public class BangLuong {
    public static final String CHUA_TINH = "ChuaTinh";
    public static final String DA_TINH   = "DaTinh";
    public static final String DA_PHAT   = "DaPhat";
    public static final String DA_CHUYEN = "XacNhanDaChuyenKhoan";

    private int bangLuongId;
    private int kyLuongId;
    private int accountId;
    private BigDecimal luongCoBan = BigDecimal.ZERO;
    private BigDecimal tongPhuCap = BigDecimal.ZERO;
    private BigDecimal tongKhauTru = BigDecimal.ZERO;
    private BigDecimal tongLuongThuc = BigDecimal.ZERO;
    private int soCaLamViec;
    private String trangThai = CHUA_TINH;
    private String ghiChu;
    private LocalDateTime createdAt;

    // Trường hiển thị, join từ Accounts / KyLuong — không có cột trong BangLuong.
    private String hoTen;
    private String avatarUrl;
    private String maNganHang;
    private String soTaiKhoan;
    private String qrImagePath;
    private String tenKy;
    private LocalDate ngayPhatLuong;
    /** URL ảnh VietQR động, set ở service bằng VietQrUrl.compact2(...). */
    private String qrDongUrl;

    public int getBangLuongId() { return bangLuongId; }
    public void setBangLuongId(int v) { this.bangLuongId = v; }
    public int getKyLuongId() { return kyLuongId; }
    public void setKyLuongId(int v) { this.kyLuongId = v; }
    public int getAccountId() { return accountId; }
    public void setAccountId(int v) { this.accountId = v; }
    public BigDecimal getLuongCoBan() { return luongCoBan; }
    public void setLuongCoBan(BigDecimal v) { this.luongCoBan = v; }
    public BigDecimal getTongPhuCap() { return tongPhuCap; }
    public void setTongPhuCap(BigDecimal v) { this.tongPhuCap = v; }
    public BigDecimal getTongKhauTru() { return tongKhauTru; }
    public void setTongKhauTru(BigDecimal v) { this.tongKhauTru = v; }
    public BigDecimal getTongLuongThuc() { return tongLuongThuc; }
    public void setTongLuongThuc(BigDecimal v) { this.tongLuongThuc = v; }
    public int getSoCaLamViec() { return soCaLamViec; }
    public void setSoCaLamViec(int v) { this.soCaLamViec = v; }
    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String v) { this.trangThai = v; }
    public String getGhiChu() { return ghiChu; }
    public void setGhiChu(String v) { this.ghiChu = v; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }
    public String getHoTen() { return hoTen; }
    public void setHoTen(String v) { this.hoTen = v; }
    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String v) { this.avatarUrl = v; }
    public String getMaNganHang() { return maNganHang; }
    public void setMaNganHang(String v) { this.maNganHang = v; }
    public String getSoTaiKhoan() { return soTaiKhoan; }
    public void setSoTaiKhoan(String v) { this.soTaiKhoan = v; }
    public String getQrImagePath() { return qrImagePath; }
    public void setQrImagePath(String v) { this.qrImagePath = v; }
    public String getTenKy() { return tenKy; }
    public void setTenKy(String v) { this.tenKy = v; }
    public LocalDate getNgayPhatLuong() { return ngayPhatLuong; }
    public void setNgayPhatLuong(LocalDate v) { this.ngayPhatLuong = v; }
    public String getQrDongUrl() { return qrDongUrl; }
    public void setQrDongUrl(String v) { this.qrDongUrl = v; }

    public boolean isDaChuyenKhoan() { return DA_CHUYEN.equals(trangThai); }
}
