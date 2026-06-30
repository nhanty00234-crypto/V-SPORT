package org.example.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;

@Entity
@Table(name = "LichDatSan")
public class Lichdatsan {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "DatSanID")
    private int datSanId;

    @Column(name = "AccountID")
    private Integer accountId;

    @Column(name = "SanID")
    private Integer sanId;

    @Column(name = "NgayDat", nullable = false)
    private LocalDate ngayDat;

    @Column(name = "GioBatDau", nullable = false)
    private LocalTime gioBatDau;

    @Column(name = "GioKetThuc", nullable = false)
    private LocalTime gioKetThuc;

    @Column(name = "ApDungGiaCoDen")
    private boolean apDungGiaCoDen;

    @Column(name = "TongTienDuKien")
    private BigDecimal tongTienDuKien;

    @Column(name = "TrangThai", length = 50)
    private String trangThai;

    @Column(name = "GhiChu", length = 255)
    private String ghiChu;

    @Column(name = "NguonDatSan", length = 50)
    private String nguonDatSan;

    @Column(name = "CreatedTime", insertable = false, updatable = false)
    private LocalDateTime createdTime;

    // Relationships
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "SanID", insertable = false, updatable = false)
    private San san;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "AccountID", insertable = false, updatable = false)
    private TaiKhoan account;

    public Lichdatsan() {
    }

    public Lichdatsan(int datSanId, Integer accountId, Integer sanId, LocalDate ngayDat, LocalTime gioBatDau, LocalTime gioKetThuc, boolean apDungGiaCoDen, BigDecimal tongTienDuKien, String trangThai, String ghiChu, String nguonDatSan) {
        this.datSanId = datSanId;
        this.accountId = accountId;
        this.sanId = sanId;
        this.ngayDat = ngayDat;
        this.gioBatDau = gioBatDau;
        this.gioKetThuc = gioKetThuc;
        this.apDungGiaCoDen = apDungGiaCoDen;
        this.tongTienDuKien = tongTienDuKien;
        this.trangThai = trangThai;
        this.ghiChu = ghiChu;
        this.nguonDatSan = nguonDatSan;
    }

    public int getDatSanId() {
        return datSanId;
    }

    public void setDatSanId(int datSanId) {
        this.datSanId = datSanId;
    }

    public Integer getAccountId() {
        return accountId;
    }

    public void setAccountId(Integer accountId) {
        this.accountId = accountId;
    }

    public Integer getSanId() {
        return sanId;
    }

    public void setSanId(Integer sanId) {
        this.sanId = sanId;
    }

    public LocalDate getNgayDat() {
        return ngayDat;
    }

    public void setNgayDat(LocalDate ngayDat) {
        this.ngayDat = ngayDat;
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

    public boolean isApDungGiaCoDen() {
        return apDungGiaCoDen;
    }

    public void setApDungGiaCoDen(boolean apDungGiaCoDen) {
        this.apDungGiaCoDen = apDungGiaCoDen;
    }

    public BigDecimal getTongTienDuKien() {
        return tongTienDuKien;
    }

    public void setTongTienDuKien(BigDecimal tongTienDuKien) {
        this.tongTienDuKien = tongTienDuKien;
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

    public String getNguonDatSan() {
        return nguonDatSan;
    }

    public void setNguonDatSan(String nguonDatSan) {
        this.nguonDatSan = nguonDatSan;
    }

    public San getSan() {
        return san;
    }

    public void setSan(San san) {
        this.san = san;
    }

    public TaiKhoan getAccount() {
        return account;
    }

    public void setAccount(TaiKhoan account) {
        this.account = account;
    }

    public LocalDateTime getCreatedTime() {
        return createdTime;
    }

    public void setCreatedTime(LocalDateTime createdTime) {
        this.createdTime = createdTime;
    }

    @Override
    public String toString() {
        return "Lichdatsan{" +
                "datSanId=" + datSanId +
                ", accountId=" + accountId +
                ", sanId=" + sanId +
                ", ngayDat=" + ngayDat +
                ", gioBatDau=" + gioBatDau +
                ", gioKetThuc=" + gioKetThuc +
                ", apDungGiaCoDen=" + apDungGiaCoDen +
                ", tongTienDuKien=" + tongTienDuKien +
                ", trangThai='" + trangThai + '\'' +
                ", ghiChu='" + ghiChu + '\'' +
                ", nguonDatSan='" + nguonDatSan + '\'' +
                '}';
    }
}
