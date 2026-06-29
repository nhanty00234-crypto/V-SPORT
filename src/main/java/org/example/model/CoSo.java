package org.example.model;

import jakarta.persistence.*;
import java.time.LocalTime;

@Entity
@Table(name = "CoSo")
public class CoSo {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "CoSoID")
    private int CoSoID;

    @Column(name = "TenCoSo")
    private String TenCoSo;

    @Column(name = "DiaChi")
    private String DiaChi;

    @Column(name = "SoDienThoai")
    private String SoDienThoai;

    @Column(name = "TrangThai")
    private String TrangThai;

    @Column(name = "GioMoCua")
    private LocalTime GioMoCua;

    @Column(name = "GioDongCua")
    private LocalTime GioDongCua;

    @Column(name = "HinhAnh")
    private String HinhAnh;

    @Column(name = "MoTa")
    private String MoTa;

    @Column(name = "LoaiHinhKinhDoanh")
    private String LoaiHinhKinhDoanh;

    @Column(name = "SoLuongSanDuKien")
    private int SoLuongSanDuKien;

    @Column(name = "AccountID_QuanLy")
    private Integer AccountID_QuanLy;

    public CoSo() {
    }

    public CoSo(int coSoID, String tenCoSo, String diaChi, String soDienThoai, String trangThai, LocalTime gioMoCua, LocalTime gioDongCua, String hinhAnh, String moTa, String loaiHinhKinhDoanh, int soLuongSanDuKien, Integer accountID_QuanLy) {
        CoSoID = coSoID;
        TenCoSo = tenCoSo;
        DiaChi = diaChi;
        SoDienThoai = soDienThoai;
        TrangThai = trangThai;
        GioMoCua = gioMoCua;
        GioDongCua = gioDongCua;
        HinhAnh = hinhAnh;
        MoTa = moTa;
        LoaiHinhKinhDoanh = loaiHinhKinhDoanh;
        SoLuongSanDuKien = soLuongSanDuKien;
        AccountID_QuanLy = accountID_QuanLy;
    }

    public int getCoSoID() {
        return CoSoID;
    }

    public void setCoSoID(int coSoID) {
        CoSoID = coSoID;
    }

    public String getTenCoSo() {
        return TenCoSo;
    }

    public void setTenCoSo(String tenCoSo) {
        TenCoSo = tenCoSo;
    }

    public String getDiaChi() {
        return DiaChi;
    }

    public void setDiaChi(String diaChi) {
        DiaChi = diaChi;
    }

    public String getSoDienThoai() {
        return SoDienThoai;
    }

    public void setSoDienThoai(String soDienThoai) {
        SoDienThoai = soDienThoai;
    }

    public String getTrangThai() {
        return TrangThai;
    }

    public void setTrangThai(String trangThai) {
        TrangThai = trangThai;
    }

    public LocalTime getGioMoCua() {
        return GioMoCua;
    }

    public void setGioMoCua(LocalTime gioMoCua) {
        GioMoCua = gioMoCua;
    }

    public LocalTime getGioDongCua() {
        return GioDongCua;
    }

    public void setGioDongCua(LocalTime gioDongCua) {
        GioDongCua = gioDongCua;
    }

    public String getHinhAnh() {
        return HinhAnh;
    }

    public void setHinhAnh(String hinhAnh) {
        HinhAnh = hinhAnh;
    }

    public String getMoTa() {
        return MoTa;
    }

    public void setMoTa(String moTa) {
        MoTa = moTa;
    }

    public String getLoaiHinhKinhDoanh() {
        return LoaiHinhKinhDoanh;
    }

    public void setLoaiHinhKinhDoanh(String loaiHinhKinhDoanh) {
        LoaiHinhKinhDoanh = loaiHinhKinhDoanh;
    }

    public int getSoLuongSanDuKien() {
        return SoLuongSanDuKien;
    }

    public void setSoLuongSanDuKien(int soLuongSanDuKien) {
        SoLuongSanDuKien = soLuongSanDuKien;
    }

    public Integer getAccountID_QuanLy() {
        return AccountID_QuanLy;
    }

    public void setAccountID_QuanLy(Integer accountID_QuanLy) {
        AccountID_QuanLy = accountID_QuanLy;
    }

    @Override
    public String toString() {
        return "CoSo{" +
                "CoSoID=" + CoSoID +
                ", TenCoSo='" + TenCoSo + '\'' +
                ", DiaChi='" + DiaChi + '\'' +
                ", SoDienThoai='" + SoDienThoai + '\'' +
                ", TrangThai='" + TrangThai + '\'' +
                ", GioMoCua=" + GioMoCua +
                ", GioDongCua=" + GioDongCua +
                ", HinhAnh='" + HinhAnh + '\'' +
                ", MoTa='" + MoTa + '\'' +
                ", LoaiHinhKinhDoanh='" + LoaiHinhKinhDoanh + '\'' +
                ", SoLuongSanDuKien=" + SoLuongSanDuKien +
                ", AccountID_QuanLy=" + AccountID_QuanLy +
                '}';
    }
}

