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
