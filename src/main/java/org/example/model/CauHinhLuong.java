package org.example.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** Cấu hình lương của một nhân viên tại một cơ sở (bảng CauHinhLuong). */
public class CauHinhLuong {
    private int cauHinhLuongId;
    private int accountId;
    private int coSoId;
    private BigDecimal luongCoBan = BigDecimal.ZERO;
    private BigDecimal phuCapMoiCa = BigDecimal.ZERO;
    private BigDecimal hanMucUng = BigDecimal.ZERO;
    private String ghiChu;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Trường hiển thị, join từ Accounts — không có cột tương ứng trong CauHinhLuong.
    private String hoTen;
    private String tenVaiTro;

    public int getCauHinhLuongId() { return cauHinhLuongId; }
    public void setCauHinhLuongId(int v) { this.cauHinhLuongId = v; }
    public int getAccountId() { return accountId; }
    public void setAccountId(int v) { this.accountId = v; }
    public int getCoSoId() { return coSoId; }
    public void setCoSoId(int v) { this.coSoId = v; }
    public BigDecimal getLuongCoBan() { return luongCoBan; }
    public void setLuongCoBan(BigDecimal v) { this.luongCoBan = v; }
    public BigDecimal getPhuCapMoiCa() { return phuCapMoiCa; }
    public void setPhuCapMoiCa(BigDecimal v) { this.phuCapMoiCa = v; }
    public BigDecimal getHanMucUng() { return hanMucUng; }
    public void setHanMucUng(BigDecimal v) { this.hanMucUng = v; }
    public String getGhiChu() { return ghiChu; }
    public void setGhiChu(String v) { this.ghiChu = v; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime v) { this.updatedAt = v; }
    public String getHoTen() { return hoTen; }
    public void setHoTen(String v) { this.hoTen = v; }
    public String getTenVaiTro() { return tenVaiTro; }
    public void setTenVaiTro(String v) { this.tenVaiTro = v; }
}
