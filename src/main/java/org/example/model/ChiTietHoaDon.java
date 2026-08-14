package org.example.model;

import jakarta.persistence.*;

@Entity
@Table(name = "ChiTietHoaDon")
public class ChiTietHoaDon {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ChiTietID")
    private int ChiTietID;

    @Column(name = "HoaDonID")
    private int HoaDonID;

    @Column(name = "SanPhamID")
    private int SanPhamID;

    @Column(name = "SoLuong", nullable = false)
    private int SoLuong;

    @Column(name = "DonGiaTaiThoiDiemBan")
    private double DonGiaTaiThoiDiemBan;

    @Column(name = "ThanhTien")
    private double ThanhTien;

    // Relationships
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "HoaDonID", insertable = false, updatable = false)
    private HoaDon hoaDon;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "SanPhamID", insertable = false, updatable = false)
    private SanPham_DichVu sanPham;

    public ChiTietHoaDon() {}

    public ChiTietHoaDon(int chiTietID, int hoaDonID, int sanPhamID, int soLuong, double donGiaTaiThoiDiemBan, double thanhTien) {
        ChiTietID = chiTietID;
        HoaDonID = hoaDonID;
        SanPhamID = sanPhamID;
        SoLuong = soLuong;
        DonGiaTaiThoiDiemBan = donGiaTaiThoiDiemBan;
        ThanhTien = thanhTien;
    }

    public int getChiTietID() {
        return ChiTietID;
    }

    public void setChiTietID(int chiTietID) {
        ChiTietID = chiTietID;
    }

    public int getHoaDonID() {
        return HoaDonID;
    }

    public void setHoaDonID(int hoaDonID) {
        HoaDonID = hoaDonID;
    }

    public int getSanPhamID() {
        return SanPhamID;
    }

    public void setSanPhamID(int sanPhamID) {
        SanPhamID = sanPhamID;
    }

    public int getSoLuong() {
        return SoLuong;
    }

    public void setSoLuong(int soLuong) {
        SoLuong = soLuong;
    }

    public double getDonGiaTaiThoiDiemBan() {
        return DonGiaTaiThoiDiemBan;
    }

    public void setDonGiaTaiThoiDiemBan(double donGiaTaiThoiDiemBan) {
        DonGiaTaiThoiDiemBan = donGiaTaiThoiDiemBan;
    }

    public double getThanhTien() {
        return ThanhTien;
    }

    public void setThanhTien(double thanhTien) {
        ThanhTien = thanhTien;
    }

    public HoaDon getHoaDon() {
        return hoaDon;
    }

    public void setHoaDon(HoaDon hoaDon) {
        this.hoaDon = hoaDon;
    }

    public SanPham_DichVu getSanPham() {
        return sanPham;
    }

    public void setSanPham(SanPham_DichVu sanPham) {
        this.sanPham = sanPham;
    }

    @Override
    public String toString() {
        return "ChiTietHoaDon{" +
                "ChiTietID=" + ChiTietID +
                ", HoaDonID=" + HoaDonID +
                ", SanPhamID=" + SanPhamID +
                ", SoLuong=" + SoLuong +
                ", DonGiaTaiThoiDiemBan=" + DonGiaTaiThoiDiemBan +
                ", ThanhTien=" + ThanhTien +
                '}';
    }
}
