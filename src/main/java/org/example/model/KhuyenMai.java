package org.example.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "KhuyenMai")
public class KhuyenMai {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "KhuyenMaiID")
    private int KhuyenMaiID;

    @Column(name = "MaCode", unique = true, nullable = false, length = 50)
    private String MaCode;

    @Column(name = "MoTa", length = 255)
    private String MoTa;

    @Column(name = "LoaiGiam", nullable = false, length = 20)
    private String LoaiGiam;

    @Column(name = "GiaTriGiam", nullable = false)
    private double GiaTriGiam;

    @Column(name = "NgayBatDau", nullable = false)
    private LocalDate NgayBatDau;

    @Column(name = "NgayKetThuc", nullable = false)
    private LocalDate NgayKetThuc;

    @Column(name = "SoLanToiDa")
    private Integer SoLanToiDa;

    @Column(name = "SoLanDaDung")
    private int SoLanDaDung;

    @Column(name = "CoSoID")
    private Integer CoSoID;

    @Column(name = "TrangThai", length = 20)
    private String TrangThai;

    public KhuyenMai() {
    }

    public KhuyenMai(int khuyenMaiID, String maCode, String moTa, String loaiGiam, double giaTriGiam, LocalDate ngayBatDau, LocalDate ngayKetThuc, Integer soLanToiDa, int soLanDaDung, Integer coSoID, String trangThai) {
        KhuyenMaiID = khuyenMaiID;
        MaCode = maCode;
        MoTa = moTa;
        LoaiGiam = loaiGiam;
        GiaTriGiam = giaTriGiam;
        NgayBatDau = ngayBatDau;
        NgayKetThuc = ngayKetThuc;
        SoLanToiDa = soLanToiDa;
        SoLanDaDung = soLanDaDung;
        CoSoID = coSoID;
        TrangThai = trangThai;
    }

    public int getKhuyenMaiID() {
        return KhuyenMaiID;
    }

    public void setKhuyenMaiID(int khuyenMaiID) {
        KhuyenMaiID = khuyenMaiID;
    }

    public String getMaCode() {
        return MaCode;
    }

    public void setMaCode(String maCode) {
        MaCode = maCode;
    }

    public String getMoTa() {
        return MoTa;
    }

    public void setMoTa(String moTa) {
        MoTa = moTa;
    }

    public String getLoaiGiam() {
        return LoaiGiam;
    }

    public void setLoaiGiam(String loaiGiam) {
        LoaiGiam = loaiGiam;
    }

    public double getGiaTriGiam() {
        return GiaTriGiam;
    }

    public void setGiaTriGiam(double giaTriGiam) {
        GiaTriGiam = giaTriGiam;
    }

    public LocalDate getNgayBatDau() {
        return NgayBatDau;
    }

    public void setNgayBatDau(LocalDate ngayBatDau) {
        NgayBatDau = ngayBatDau;
    }

    public LocalDate getNgayKetThuc() {
        return NgayKetThuc;
    }

    public void setNgayKetThuc(LocalDate ngayKetThuc) {
        NgayKetThuc = ngayKetThuc;
    }

    public Integer getSoLanToiDa() {
        return SoLanToiDa;
    }

    public void setSoLanToiDa(Integer soLanToiDa) {
        SoLanToiDa = soLanToiDa;
    }

    public int getSoLanDaDung() {
        return SoLanDaDung;
    }

    public void setSoLanDaDung(int soLanDaDung) {
        SoLanDaDung = soLanDaDung;
    }

    public Integer getCoSoID() {
        return CoSoID;
    }

    public void setCoSoID(Integer coSoID) {
        CoSoID = coSoID;
    }

    public String getTrangThai() {
        return TrangThai;
    }

    public void setTrangThai(String trangThai) {
        TrangThai = trangThai;
    }

    @Override
    public String toString() {
        return "KhuyenMai{" +
                "KhuyenMaiID=" + KhuyenMaiID +
                ", MaCode='" + MaCode + '\'' +
                ", MoTa='" + MoTa + '\'' +
                ", LoaiGiam='" + LoaiGiam + '\'' +
                ", GiaTriGiam=" + GiaTriGiam +
                ", NgayBatDau=" + NgayBatDau +
                ", NgayKetThuc=" + NgayKetThuc +
                ", SoLanToiDa=" + SoLanToiDa +
                ", SoLanDaDung=" + SoLanDaDung +
                ", CoSoID=" + CoSoID +
                ", TrangThai='" + TrangThai + '\'' +
                '}';
    }
}
