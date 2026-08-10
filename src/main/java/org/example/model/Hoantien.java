package org.example.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.util.Date;

@Entity
@Table(name = "refunds")
public class Hoantien {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "refund_id")
    private int hoanTienId;

    @Column(name = "invoice_id", nullable = false)
    private int hoaDonId;

    @Column(name = "account_id", nullable = false)
    private int accountId;

    @Column(name = "refunded_amount", nullable = false)
    private BigDecimal soTienHoan;

    @Column(name = "reason", length = 255)
    private String lyDo;

    @Column(name = "status", length = 50)
    private String trangThai;

    @Column(name = "requested_at")
    @Temporal(TemporalType.TIMESTAMP)
    private Date thoiGianYeuCau;

    @Column(name = "refunded_at")
    @Temporal(TemporalType.TIMESTAMP)
    private Date thoiGianHoan;

    // --- Các trường bổ sung quản lý xử lý hoàn tiền ---

    @Column(name = "processor_account_id")
    private Integer accountIdNguoiXuLy;

    @Column(name = "processing_note", length = 500)
    private String ghiChuXuLy;

    @Column(name = "refund_transaction_code", length = 100)
    private String maGiaoDichHoan;

    @Column(name = "processed_at")
    @Temporal(TemporalType.TIMESTAMP)
    private Date thoiGianXuLy;

    @Column(name = "receiving_bank_name", length = 100)
    private String nganHangNhan;

    @Column(name = "receiving_account_number", length = 30)
    private String soTaiKhoanNhan;

    @Column(name = "receiving_account_holder", length = 100)
    private String chuTaiKhoanNhan;

    // --- Mở rộng cho luồng Hoàn tiền Customer self-service ---

    @Column(name = "booking_id")
    private Integer datSanId;

    @Column(name = "facility_id")
    private Integer coSoId;

    @Column(name = "paid_amount")
    private BigDecimal soTienDaThanhToan;

    @Column(name = "requested_amount")
    private BigDecimal soTienDeNghiHoan;

    @Column(name = "approved_amount")
    private BigDecimal soTienDuocDuyet;

    @Column(name = "receiving_qr_path", length = 300)
    private String qrNhanTienPath;

    @Column(name = "customer_note", length = 500)
    private String ghiChuKhachHang;

    @Column(name = "reject_reason", length = 500)
    private String lyDoTuChoi;

    @Column(name = "approved_at")
    @Temporal(TemporalType.TIMESTAMP)
    private Date approvedAt;

    @Column(name = "completed_at")
    @Temporal(TemporalType.TIMESTAMP)
    private Date completedAt;

    @Column(name = "updated_at")
    @Temporal(TemporalType.TIMESTAMP)
    private Date updatedAt;

    // Relationships
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "invoice_id", insertable = false, updatable = false)
    private HoaDon hoaDon;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "account_id", insertable = false, updatable = false)
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

    public Integer getDatSanId() { return datSanId; }
    public void setDatSanId(Integer v) { this.datSanId = v; }

    public Integer getCoSoId() { return coSoId; }
    public void setCoSoId(Integer v) { this.coSoId = v; }

    public BigDecimal getSoTienDaThanhToan() { return soTienDaThanhToan; }
    public void setSoTienDaThanhToan(BigDecimal v) { this.soTienDaThanhToan = v; }

    public BigDecimal getSoTienDeNghiHoan() { return soTienDeNghiHoan; }
    public void setSoTienDeNghiHoan(BigDecimal v) { this.soTienDeNghiHoan = v; }

    public BigDecimal getSoTienDuocDuyet() { return soTienDuocDuyet; }
    public void setSoTienDuocDuyet(BigDecimal v) { this.soTienDuocDuyet = v; }

    public String getQrNhanTienPath() { return qrNhanTienPath; }
    public void setQrNhanTienPath(String v) { this.qrNhanTienPath = v; }

    public String getGhiChuKhachHang() { return ghiChuKhachHang; }
    public void setGhiChuKhachHang(String v) { this.ghiChuKhachHang = v; }

    public String getLyDoTuChoi() { return lyDoTuChoi; }
    public void setLyDoTuChoi(String v) { this.lyDoTuChoi = v; }

    public Date getApprovedAt() { return approvedAt; }
    public void setApprovedAt(Date v) { this.approvedAt = v; }

    public Date getCompletedAt() { return completedAt; }
    public void setCompletedAt(Date v) { this.completedAt = v; }

    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date v) { this.updatedAt = v; }

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
