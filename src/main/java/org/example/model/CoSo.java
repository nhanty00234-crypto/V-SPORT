package org.example.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalTime;
import java.time.LocalDateTime;

@Entity
@Table(name = "facilities")
public class CoSo {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "facility_id")
    private int CoSoID;

    @Column(name = "facility_name")
    private String TenCoSo;

    @Column(name = "address")
    private String DiaChi;

    @Column(name = "phone_number")
    private String SoDienThoai;

    @Column(name = "status")
    private String TrangThai;

    @Column(name = "opening_time")
    private LocalTime GioMoCua;

    @Column(name = "closing_time")
    private LocalTime GioDongCua;

    @Column(name = "image_path")
    private String HinhAnh;

    @Column(name = "description")
    private String MoTa;

    @Column(name = "business_type")
    private String LoaiHinhKinhDoanh;

    @Column(name = "planned_court_count")
    private int SoLuongSanDuKien;

    @Column(name = "manager_account_id")
    private Integer AccountID_QuanLy;

    @Column(name = "is_deleted")
    private Boolean isDeleted;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    @Column(name = "deleted_by")
    private Integer deletedBy;

    @Column(name = "latitude")
    private BigDecimal viDo;

    @Column(name = "longitude")
    private BigDecimal kinhDo;

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

    /** Trả về URL ảnh đại diện đầu tiên, xử lý cả JSON array lẫn plain URL. */
    public String getThumbnailUrl() {
        if (HinhAnh == null || HinhAnh.isBlank()) return null;
        String s = HinhAnh.trim();
        if (s.startsWith("[")) {
            // JSON array: ["url1","url2"] → lấy url1
            s = s.substring(1, s.endsWith("]") ? s.length() - 1 : s.length()).trim();
            if (s.startsWith("\"")) s = s.substring(1);
            int end = s.indexOf('"');
            return end > 0 ? s.substring(0, end) : s;
        }
        return s;
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

    public BigDecimal getViDo() { return viDo; }

    public void setViDo(BigDecimal viDo) { this.viDo = viDo; }

    public BigDecimal getKinhDo() { return kinhDo; }

    public void setKinhDo(BigDecimal kinhDo) { this.kinhDo = kinhDo; }

    public boolean isDeleted() { return isDeleted != null && isDeleted; }

    public void setDeleted(Boolean deleted) { isDeleted = deleted; }

    public LocalDateTime getDeletedAt() { return deletedAt; }

    public void setDeletedAt(LocalDateTime deletedAt) { this.deletedAt = deletedAt; }

    public Integer getDeletedBy() { return deletedBy; }

    public void setDeletedBy(Integer deletedBy) { this.deletedBy = deletedBy; }

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

