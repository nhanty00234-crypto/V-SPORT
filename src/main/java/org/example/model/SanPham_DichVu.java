package org.example.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "products_services")
public class SanPham_DichVu {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "product_id")
    private int SanPhamID;

    @Column(name = "category_id", nullable = false)
    private int DanhMucID;

    @Column(name = "facility_id", nullable = false)
    private int CoSoID;

    @Column(name = "product_name", nullable = false, length = 100)
    private String TenSanPham;

    @Column(name = "unit_price", nullable = false)
    private double DonGia;

    @Column(name = "unit_of_measure", length = 20)
    private String DonViTinh;

    @Column(name = "stock_quantity")
    private int SoLuongTon;

    @Column(name = "status", length = 50)
    private String TrangThai;

    @Column(name = "sku_code", length = 50)
    private String SkuCode;

    @Column(name = "cost_price")
    private double GiaNhap;

    @Column(name = "description", length = 255)
    private String MoTa;

    @Column(name = "image_path", length = 500)
    private String HinhAnh;

    @Column(name = "is_deleted")
    private boolean isDeleted;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    @Column(name = "deleted_by")
    private Integer deletedBy;

    public SanPham_DichVu() {}

    public SanPham_DichVu(int sanPhamID, int danhMucID, int coSoID, String tenSanPham, double donGia, String donViTinh, int soLuongTon, String trangThai, String skuCode, double giaNhap, String moTa) {
        SanPhamID = sanPhamID;
        DanhMucID = danhMucID;
        CoSoID = coSoID;
        TenSanPham = tenSanPham;
        DonGia = donGia;
        DonViTinh = donViTinh;
        SoLuongTon = soLuongTon;
        TrangThai = trangThai;
        SkuCode = skuCode;
        GiaNhap = giaNhap;
        MoTa = moTa;
    }

    public int getSanPhamID() {
        return SanPhamID;
    }

    public void setSanPhamID(int sanPhamID) {
        SanPhamID = sanPhamID;
    }

    public int getDanhMucID() {
        return DanhMucID;
    }

    public void setDanhMucID(int danhMucID) {
        DanhMucID = danhMucID;
    }

    public int getCoSoID() {
        return CoSoID;
    }

    public void setCoSoID(int coSoID) {
        CoSoID = coSoID;
    }

    public String getTenSanPham() {
        return TenSanPham;
    }

    public void setTenSanPham(String tenSanPham) {
        TenSanPham = tenSanPham;
    }

    public double getDonGia() {
        return DonGia;
    }

    public void setDonGia(double donGia) {
        DonGia = donGia;
    }

    public String getDonViTinh() {
        return DonViTinh;
    }

    public void setDonViTinh(String donViTinh) {
        DonViTinh = donViTinh;
    }

    public int getSoLuongTon() {
        return SoLuongTon;
    }

    public void setSoLuongTon(int soLuongTon) {
        SoLuongTon = soLuongTon;
    }

    public String getTrangThai() {
        return TrangThai;
    }

    public void setTrangThai(String trangThai) {
        TrangThai = trangThai;
    }

    public String getSkuCode() {
        return SkuCode;
    }

    public void setSkuCode(String skuCode) {
        SkuCode = skuCode;
    }

    public double getGiaNhap() {
        return GiaNhap;
    }

    public void setGiaNhap(double giaNhap) {
        GiaNhap = giaNhap;
    }

    public String getMoTa() {
        return MoTa;
    }

    public void setMoTa(String moTa) {
        MoTa = moTa;
    }

    public String getHinhAnh() {
        return HinhAnh;
    }

    public void setHinhAnh(String hinhAnh) {
        HinhAnh = hinhAnh;
    }

    public boolean isDeleted() { return isDeleted; }

    public void setDeleted(boolean deleted) { isDeleted = deleted; }

    public LocalDateTime getDeletedAt() { return deletedAt; }

    public void setDeletedAt(LocalDateTime deletedAt) { this.deletedAt = deletedAt; }

    public Integer getDeletedBy() { return deletedBy; }

    public void setDeletedBy(Integer deletedBy) { this.deletedBy = deletedBy; }

    @Override
    public String toString() {
        return "SanPham_DichVu{" +
                "SanPhamID=" + SanPhamID +
                ", DanhMucID=" + DanhMucID +
                ", CoSoID=" + CoSoID +
                ", TenSanPham='" + TenSanPham + '\'' +
                ", DonGia=" + DonGia +
                ", DonViTinh='" + DonViTinh + '\'' +
                ", SoLuongTon=" + SoLuongTon +
                ", TrangThai='" + TrangThai + '\'' +
                ", SkuCode='" + SkuCode + '\'' +
                ", GiaNhap=" + GiaNhap +
                ", MoTa='" + MoTa + '\'' +
                '}';
    }
}
