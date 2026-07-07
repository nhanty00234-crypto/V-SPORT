package org.example.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "San")
public class San {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "SanID")
    private int sanID;

    @Column(name = "TenSan")
    private String tenSan;

    @Column(name = "LoaiSanID")
    private int loaiSanID;

    @Column(name = "CoSoID")
    private int coSoID;

    @Column(name = "TrangThai")
    private String trangThai;

    @Column(name = "MoTa")
    private String moTa;

    @Column(name = "HinhAnh")
    private String hinhAnh;

    @Column(name = "IsDeleted")
    private boolean isDeleted;

    @Column(name = "DeletedAt")
    private LocalDateTime deletedAt;

    @Column(name = "DeletedBy")
    private Integer deletedBy;

    @Transient
    private String tenLoaiSan;
    @Transient
    private double giaKhongDen;
    @Transient
    private double giaCoDen;
    @Transient
    private java.time.LocalTime gioBatDauLenDen;
    @Transient
    private java.time.LocalTime gioKetThucLenDen;
    @Transient
    private Integer datSanIdActive;
    @Transient
    private String gioBatDauActive;
    @Transient
    private String gioKetThucActive;
    @Transient
    private String ghiChuActive;


    public San(int sanID, String tenSan, int loaiSanID, int coSoID, String trangThai, String moTa, String hinhAnh) {
        this.sanID = sanID;
        this.tenSan = tenSan;
        this.loaiSanID = loaiSanID;
        this.coSoID = coSoID;
        this.trangThai = trangThai;
        this.moTa = moTa;
        this.hinhAnh = hinhAnh;
    }

    public San() {
    }

    public int getSanID() {
        return sanID;
    }

    public void setSanID(int sanID) {
        this.sanID = sanID;
    }

    public String getTenSan() {
        return tenSan;
    }

    public void setTenSan(String tenSan) {
        this.tenSan = tenSan;
    }

    public int getLoaiSanID() {
        return loaiSanID;
    }

    public void setLoaiSanID(int loaiSanID) {
        this.loaiSanID = loaiSanID;
    }

    public int getCoSoID() {
        return coSoID;
    }

    public void setCoSoID(int coSoID) {
        this.coSoID = coSoID;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public String getMoTa() {
        return moTa;
    }

    public void setMoTa(String moTa) {
        this.moTa = moTa;
    }

    public String getHinhAnh() {
        return hinhAnh;
    }

    public void setHinhAnh(String hinhAnh) {
        this.hinhAnh = hinhAnh;
    }

    public boolean isDeleted() { return isDeleted; }

    public void setDeleted(boolean deleted) { isDeleted = deleted; }

    public LocalDateTime getDeletedAt() { return deletedAt; }

    public void setDeletedAt(LocalDateTime deletedAt) { this.deletedAt = deletedAt; }

    public Integer getDeletedBy() { return deletedBy; }

    public void setDeletedBy(Integer deletedBy) { this.deletedBy = deletedBy; }

    public String getTenLoaiSan() { return tenLoaiSan; }
    public void setTenLoaiSan(String tenLoaiSan) { this.tenLoaiSan = tenLoaiSan; }

    public double getGiaKhongDen() { return giaKhongDen; }
    public void setGiaKhongDen(double giaKhongDen) { this.giaKhongDen = giaKhongDen; }

    public double getGiaCoDen() { return giaCoDen; }
    public void setGiaCoDen(double giaCoDen) { this.giaCoDen = giaCoDen; }

    public java.time.LocalTime getGioBatDauLenDen() { return gioBatDauLenDen; }
    public void setGioBatDauLenDen(java.time.LocalTime gioBatDauLenDen) { this.gioBatDauLenDen = gioBatDauLenDen; }

    public java.time.LocalTime getGioKetThucLenDen() { return gioKetThucLenDen; }
    public void setGioKetThucLenDen(java.time.LocalTime gioKetThucLenDen) { this.gioKetThucLenDen = gioKetThucLenDen; }

    public Integer getDatSanIdActive() { return datSanIdActive; }
    public void setDatSanIdActive(Integer datSanIdActive) { this.datSanIdActive = datSanIdActive; }

    public String getGioBatDauActive() { return gioBatDauActive; }
    public void setGioBatDauActive(String gioBatDauActive) { this.gioBatDauActive = gioBatDauActive; }

    public String getGioKetThucActive() { return gioKetThucActive; }
    public void setGioKetThucActive(String gioKetThucActive) { this.gioKetThucActive = gioKetThucActive; }

    public String getGhiChuActive() { return ghiChuActive; }
    public void setGhiChuActive(String ghiChuActive) { this.ghiChuActive = ghiChuActive; }


    @Override
    public String toString() {
        return "San{" +
                "sanID=" + sanID +
                ", tenSan='" + tenSan + '\'' +
                ", loaiSanID=" + loaiSanID +
                ", coSoID=" + coSoID +
                ", trangThai='" + trangThai + '\'' +
                ", moTa='" + moTa + '\'' +
                ", hinhAnh='" + hinhAnh + '\'' +
                '}';
    }
}
