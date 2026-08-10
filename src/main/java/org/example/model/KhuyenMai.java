package org.example.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "promotions")
public class KhuyenMai {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "promotion_id")
    private int KhuyenMaiID;

    @Column(name = "promo_code", unique = true, nullable = false, length = 50)
    private String MaCode;

    @Column(name = "description", length = 255)
    private String MoTa;

    @Column(name = "discount_type", nullable = false, length = 20)
    private String LoaiGiam;

    @Column(name = "discount_value", nullable = false)
    private double GiaTriGiam;

    @Column(name = "start_date", nullable = false)
    private LocalDate NgayBatDau;

    @Column(name = "end_date", nullable = false)
    private LocalDate NgayKetThuc;

    @Column(name = "max_usage_count")
    private Integer SoLanToiDa;

    @Column(name = "used_count")
    private int SoLanDaDung;

    @Column(name = "facility_id")
    private Integer CoSoID;

    @Column(name = "status", length = 20)
    private String TrangThai;

    @Column(name = "min_order_amount")
    private java.math.BigDecimal GiaTriToiThieu;

    @Column(name = "max_discount_amount")
    private java.math.BigDecimal GiamToiDa;

    // Cờ cho phép Customer nhìn thấy khuyến mãi này (ảnh + thông tin) ở các trang công khai.
    // Độc lập với TrangThai: TrangThai điều khiển việc mã có áp dụng được không, còn cờ này chỉ
    // điều khiển hiển thị. Mặc định true (xem sql/migration_khuyenmai_hinhanh.sql).
    @Column(name = "is_public")
    private boolean HienThiCongKhai = true;

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

    public java.math.BigDecimal getGiaTriToiThieu() {
        return GiaTriToiThieu;
    }

    public void setGiaTriToiThieu(java.math.BigDecimal giaTriToiThieu) {
        GiaTriToiThieu = giaTriToiThieu;
    }

    public java.math.BigDecimal getGiamToiDa() {
        return GiamToiDa;
    }

    public void setGiamToiDa(java.math.BigDecimal giamToiDa) {
        GiamToiDa = giamToiDa;
    }

    public boolean isHienThiCongKhai() {
        return HienThiCongKhai;
    }

    public void setHienThiCongKhai(boolean hienThiCongKhai) {
        HienThiCongKhai = hienThiCongKhai;
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
