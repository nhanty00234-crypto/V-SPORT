package org.example.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/** Một kỳ tính lương của một cơ sở (bảng KyLuong). */
public class KyLuong {
    public static final String DRAFT     = "Draft";
    public static final String DANG_TINH = "DangTinh";
    public static final String DA_PHAT   = "DaPhat";

    private int kyLuongId;
    private int coSoId;
    private String tenKy;
    private LocalDate ngayBatDau;
    private LocalDate ngayKetThuc;
    private LocalDate ngayPhatLuong;
    private String trangThai = DRAFT;
    private int createdBy;
    private LocalDateTime createdAt;

    // Trường tổng hợp, tính khi load danh sách — không có cột trong KyLuong.
    private int soNhanVien;
    private BigDecimal tongChi = BigDecimal.ZERO;

    public int getKyLuongId() { return kyLuongId; }
    public void setKyLuongId(int v) { this.kyLuongId = v; }
    public int getCoSoId() { return coSoId; }
    public void setCoSoId(int v) { this.coSoId = v; }
    public String getTenKy() { return tenKy; }
    public void setTenKy(String v) { this.tenKy = v; }
    public LocalDate getNgayBatDau() { return ngayBatDau; }
    public void setNgayBatDau(LocalDate v) { this.ngayBatDau = v; }
    public LocalDate getNgayKetThuc() { return ngayKetThuc; }
    public void setNgayKetThuc(LocalDate v) { this.ngayKetThuc = v; }
    public LocalDate getNgayPhatLuong() { return ngayPhatLuong; }
    public void setNgayPhatLuong(LocalDate v) { this.ngayPhatLuong = v; }
    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String v) { this.trangThai = v; }
    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int v) { this.createdBy = v; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }
    public int getSoNhanVien() { return soNhanVien; }
    public void setSoNhanVien(int v) { this.soNhanVien = v; }
    public BigDecimal getTongChi() { return tongChi; }
    public void setTongChi(BigDecimal v) { this.tongChi = v; }

    /** Kỳ đã phát lương thì khoá, không cho tính lại. */
    public boolean isKhoa() { return DA_PHAT.equals(trangThai); }
}
