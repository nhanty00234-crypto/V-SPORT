package org.example.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.util.Date;

@Entity
@Table(name = "HoanTien")
public class Hoantien {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "HoanTienID")
    private int hoanTienId;

    @Column(name = "HoaDonID", nullable = false)
    private int hoaDonId;

    @Column(name = "AccountID", nullable = false)
    private int accountId;

    @Column(name = "SoTienHoan", nullable = false)
    private BigDecimal soTienHoan;

    @Column(name = "LyDo", length = 255)
    private String lyDo;

    @Column(name = "TrangThai", length = 50)
    private String trangThai;

    @Column(name = "ThoiGianYeuCau")
    @Temporal(TemporalType.TIMESTAMP)
    private Date thoiGianYeuCau;

    @Column(name = "ThoiGianHoan")
    @Temporal(TemporalType.TIMESTAMP)
    private Date thoiGianHoan;

    // --- Các trường bổ sung quản lý xử lý hoàn tiền ---

    @Column(name = "AccountID_NguoiXuLy")
    private Integer accountIdNguoiXuLy;

    @Column(name = "GhiChuXuLy", length = 500)
    private String ghiChuXuLy;

    @Column(name = "MaGiaoDichHoan", length = 100)
    private String maGiaoDichHoan;

    @Column(name = "ThoiGianXuLy")
    @Temporal(TemporalType.TIMESTAMP)
    private Date thoiGianXuLy;

    @Column(name = "NganHangNhan", length = 100)
    private String nganHangNhan;

    @Column(name = "SoTaiKhoanNhan", length = 30)
    private String soTaiKhoanNhan;

    @Column(name = "ChuTaiKhoanNhan", length = 100)
    private String chuTaiKhoanNhan;

    // Relationships
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "HoaDonID", insertable = false, updatable = false)
    private HoaDon hoaDon;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "AccountID", insertable = false, updatable = false)
    private TaiKhoan khachHang;

    public Hoantien() {
    }

    public Hoantien(int hoanTienId, int hoaDonId, int accountId, BigDecimal soTienHoan, String lyDo, String trangThai, Date thoiGianYeuCau, Date thoiGianHoan) {
        this.hoanTienId = hoanTienId;
        this.hoaDonId = hoaDonId;
        this.accountId = accountId;
        this.soTienHoan = soTienHoan;
        this.lyDo = lyDo;
        this.trangThai = trangThai;
        this.thoiGianYeuCau = thoiGianYeuCau;
        this.thoiGianHoan = thoiGianHoan;
    }

    public int getHoanTienId() {
        return hoanTienId;
    }

    public void setHoanTienId(int hoanTienId) {
        this.hoanTienId = hoanTienId;
    }

    public int getHoaDonId() {
        return hoaDonId;
    }

    public void setHoaDonId(int hoaDonId) {
        this.hoaDonId = hoaDonId;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public BigDecimal getSoTienHoan() {
        return soTienHoan;
    }

    public void setSoTienHoan(BigDecimal soTienHoan) {
        this.soTienHoan = soTienHoan;
    }

    public String getLyDo() {
        return lyDo;
    }

    public void setLyDo(String lyDo) {
        this.lyDo = lyDo;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public Date getThoiGianYeuCau() {
        return thoiGianYeuCau;
    }

    public void setThoiGianYeuCau(Date thoiGianYeuCau) {
        this.thoiGianYeuCau = thoiGianYeuCau;
    }

    public Date getThoiGianHoan() {
        return thoiGianHoan;
    }

    public void setThoiGianHoan(Date thoiGianHoan) {
        this.thoiGianHoan = thoiGianHoan;
    }

    public HoaDon getHoaDon() {
        return hoaDon;
    }

    public void setHoaDon(HoaDon hoaDon) {
        this.hoaDon = hoaDon;
    }

    public TaiKhoan getKhachHang() {
        return khachHang;
    }

    public void setKhachHang(TaiKhoan khachHang) {
        this.khachHang = khachHang;
    }

    public Integer getAccountIdNguoiXuLy() { return accountIdNguoiXuLy; }
    public void setAccountIdNguoiXuLy(Integer v) { this.accountIdNguoiXuLy = v; }

    public String getGhiChuXuLy() { return ghiChuXuLy; }
    public void setGhiChuXuLy(String v) { this.ghiChuXuLy = v; }

    public String getMaGiaoDichHoan() { return maGiaoDichHoan; }
    public void setMaGiaoDichHoan(String v) { this.maGiaoDichHoan = v; }

    public Date getThoiGianXuLy() { return thoiGianXuLy; }
    public void setThoiGianXuLy(Date v) { this.thoiGianXuLy = v; }

    public String getNganHangNhan() { return nganHangNhan; }
    public void setNganHangNhan(String v) { this.nganHangNhan = v; }

    public String getSoTaiKhoanNhan() { return soTaiKhoanNhan; }
    public void setSoTaiKhoanNhan(String v) { this.soTaiKhoanNhan = v; }

    public String getChuTaiKhoanNhan() { return chuTaiKhoanNhan; }
    public void setChuTaiKhoanNhan(String v) { this.chuTaiKhoanNhan = v; }

    @Override
    public String toString() {
        return "Hoantien{" +
                "hoanTienId=" + hoanTienId +
                ", hoaDonId=" + hoaDonId +
                ", accountId=" + accountId +
                ", soTienHoan=" + soTienHoan +
                ", lyDo='" + lyDo + '\'' +
                ", trangThai='" + trangThai + '\'' +
                ", thoiGianYeuCau=" + thoiGianYeuCau +
                ", thoiGianHoan=" + thoiGianHoan +
                '}';
    }
}
