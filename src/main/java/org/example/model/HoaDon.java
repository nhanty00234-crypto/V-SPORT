package org.example.model;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(name = "invoices")
public class HoaDon {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "invoice_id")
    private int hoaDonId;

    @Column(name = "booking_id")
    private Integer datSanId;

    @Column(name = "customer_account_id")
    private Integer accountIdKhachHang;

    @Column(name = "staff_account_id")
    private Integer accountIdNhanVien;

    @Column(name = "issued_at")
    @Temporal(TemporalType.TIMESTAMP)
    private Date ngayLap;

    @Column(name = "court_total")
    private double tongTienSan;

    @Column(name = "service_total")
    private double tongTienDichVu;

    @Column(name = "parking_fee")
    private double phiGuiXe;

    @Column(name = "promotion_id")
    private Integer khuyenMaiId;

    @Column(name = "discount_amount")
    private double giamGia;

    @Column(name = "grand_total")
    private double tongThanhToan;

    @Column(name = "payment_method")
    private String phuongThucThanhToan;

    @Column(name = "payment_status")
    private String trangThaiThanhToan;

    @Column(name = "invoice_type")
    private String loaiHoaDon;

    @Column(name = "parent_invoice_id")
    private Integer parentHoaDonId;

    @Column(name = "note")
    private String ghiChu;

    // Relationships
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", insertable = false, updatable = false)
    private Lichdatsan datSan;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_account_id", insertable = false, updatable = false)
    private TaiKhoan khachHang;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "staff_account_id", insertable = false, updatable = false)
    private TaiKhoan nhanVien;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "promotion_id", insertable = false, updatable = false)
    private KhuyenMai khuyenMai;

    public HoaDon() {}

    public HoaDon(int hoaDonId, Integer datSanId, Integer accountIdKhachHang, Integer accountIdNhanVien, Date ngayLap, 
                  double tongTienSan, double tongTienDichVu, double phiGuiXe, Integer khuyenMaiId, 
                  double giamGia, double tongThanhToan, String phuongThucThanhToan, String trangThaiThanhToan) {
        this.hoaDonId = hoaDonId;
        this.datSanId = datSanId;
        this.accountIdKhachHang = accountIdKhachHang;
        this.accountIdNhanVien = accountIdNhanVien;
        this.ngayLap = ngayLap;
        this.tongTienSan = tongTienSan;
        this.tongTienDichVu = tongTienDichVu;
        this.phiGuiXe = phiGuiXe;
        this.khuyenMaiId = khuyenMaiId;
        this.giamGia = giamGia;
        this.tongThanhToan = tongThanhToan;
        this.phuongThucThanhToan = phuongThucThanhToan;
        this.trangThaiThanhToan = trangThaiThanhToan;
    }

    public int getHoaDonId() { return hoaDonId; }
    public void setHoaDonId(int hoaDonId) { this.hoaDonId = hoaDonId; }

    public Integer getDatSanId() { return datSanId; }
    public void setDatSanId(Integer datSanId) { this.datSanId = datSanId; }

    public Integer getAccountIdKhachHang() { return accountIdKhachHang; }
    public void setAccountIdKhachHang(Integer accountIdKhachHang) { this.accountIdKhachHang = accountIdKhachHang; }

    public Integer getAccountIdNhanVien() { return accountIdNhanVien; }
    public void setAccountIdNhanVien(Integer accountIdNhanVien) { this.accountIdNhanVien = accountIdNhanVien; }

    public Date getNgayLap() { return ngayLap; }
    public void setNgayLap(Date ngayLap) { this.ngayLap = ngayLap; }

    public double getTongTienSan() { return tongTienSan; }
    public void setTongTienSan(double tongTienSan) { this.tongTienSan = tongTienSan; }

    public double getTongTienDichVu() { return tongTienDichVu; }
    public void setTongTienDichVu(double tongTienDichVu) { this.tongTienDichVu = tongTienDichVu; }

    public double getPhiGuiXe() { return phiGuiXe; }
    public void setPhiGuiXe(double phiGuiXe) { this.phiGuiXe = phiGuiXe; }

    public Integer getKhuyenMaiId() { return khuyenMaiId; }
    public void setKhuyenMaiId(Integer khuyenMaiId) { this.khuyenMaiId = khuyenMaiId; }

    public double getGiamGia() { return giamGia; }
    public void setGiamGia(double giamGia) { this.giamGia = giamGia; }

    public double getTongThanhToan() { return tongThanhToan; }
    public void setTongThanhToan(double tongThanhToan) { this.tongThanhToan = tongThanhToan; }

    public String getPhuongThucThanhToan() { return phuongThucThanhToan; }
    public void setPhuongThucThanhToan(String phuongThucThanhToan) { this.phuongThucThanhToan = phuongThucThanhToan; }

    public String getTrangThaiThanhToan() { return trangThaiThanhToan; }
    public void setTrangThaiThanhToan(String trangThaiThanhToan) { this.trangThaiThanhToan = trangThaiThanhToan; }

    public String getLoaiHoaDon() { return loaiHoaDon; }
    public void setLoaiHoaDon(String loaiHoaDon) { this.loaiHoaDon = loaiHoaDon; }

    public Integer getParentHoaDonId() { return parentHoaDonId; }
    public void setParentHoaDonId(Integer parentHoaDonId) { this.parentHoaDonId = parentHoaDonId; }

    public String getGhiChu() { return ghiChu; }
    public void setGhiChu(String ghiChu) { this.ghiChu = ghiChu; }

    public Lichdatsan getDatSan() { return datSan; }
    public void setDatSan(Lichdatsan datSan) { this.datSan = datSan; }

    public TaiKhoan getKhachHang() { return khachHang; }
    public void setKhachHang(TaiKhoan khachHang) { this.khachHang = khachHang; }

    public TaiKhoan getNhanVien() { return nhanVien; }
    public void setNhanVien(TaiKhoan nhanVien) { this.nhanVien = nhanVien; }

    public KhuyenMai getKhuyenMai() { return khuyenMai; }
    public void setKhuyenMai(KhuyenMai khuyenMai) { this.khuyenMai = khuyenMai; }

    @Override
    public String toString() {
        return "HoaDon{" +
                "hoaDonId=" + hoaDonId +
                ", datSanId=" + datSanId +
                ", accountIdKhachHang=" + accountIdKhachHang +
                ", accountIdNhanVien=" + accountIdNhanVien +
                ", ngayLap=" + ngayLap +
                ", tongThanhToan=" + tongThanhToan +
                ", trangThaiThanhToan='" + trangThaiThanhToan + '\'' +
                '}';
    }
}
