package org.example.model;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;

public class CaLamViecAvailability {
    private int availabilityId;
    private int accountId;
    private int coSoId;
    private LocalDate ngay;
    private LocalTime gioBatDau;
    private LocalTime gioKetThuc;
    private String trangThai; // 'Ranh', 'Ban'
    private String ghiChu;
    private LocalDateTime createdAt;
    private String duyetTrangThai; // 'ChoDuyet', 'DaDuyet', 'TuChoi'
    private String phanHoi;

    // Additional fields for display
    private String tenNhanVien;
    private String username;

    public CaLamViecAvailability() {
    }

    public int getAvailabilityId() {
        return availabilityId;
    }

    public void setAvailabilityId(int availabilityId) {
        this.availabilityId = availabilityId;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public int getCoSoId() {
        return coSoId;
    }

    public void setCoSoId(int coSoId) {
        this.coSoId = coSoId;
    }

    public LocalDate getNgay() {
        return ngay;
    }

    public void setNgay(LocalDate ngay) {
        this.ngay = ngay;
    }

    public LocalTime getGioBatDau() {
        return gioBatDau;
    }

    public void setGioBatDau(LocalTime gioBatDau) {
        this.gioBatDau = gioBatDau;
    }

    public LocalTime getGioKetThuc() {
        return gioKetThuc;
    }

    public void setGioKetThuc(LocalTime gioKetThuc) {
        this.gioKetThuc = gioKetThuc;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public String getGhiChu() {
        return ghiChu;
    }

    public void setGhiChu(String ghiChu) {
        this.ghiChu = ghiChu;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getTenNhanVien() {
        return tenNhanVien;
    }

    public void setTenNhanVien(String tenNhanVien) {
        this.tenNhanVien = tenNhanVien;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getDuyetTrangThai() {
        return duyetTrangThai;
    }

    public void setDuyetTrangThai(String duyetTrangThai) {
        this.duyetTrangThai = duyetTrangThai;
    }

    public String getPhanHoi() {
        return phanHoi;
    }

    public void setPhanHoi(String phanHoi) {
        this.phanHoi = phanHoi;
    }
}
