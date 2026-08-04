package org.example.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/** Yêu cầu ứng lương của nhân viên (bảng YeuCauUngLuong). */
public class YeuCauUngLuong {
    public static final String CHO_DUYET = "ChoDuyet";
    public static final String DA_DUYET  = "DaDuyet";
    public static final String TU_CHOI   = "TuChoi";
    public static final String DA_HUY    = "DaHuy";

    private int yeuCauUngLuongId;
    private int accountId;
    private int coSoId;
    private BigDecimal soTienUng = BigDecimal.ZERO;
    private String lyDo;
    private String trangThai = CHO_DUYET;
    private String ghiChuQuanLy;
    private Integer xuLyBy;
    private LocalDateTime ngayXuLy;
    private LocalDateTime createdAt;

    // Trường hiển thị, join từ Accounts.
    private String hoTen;
    private String tenNguoiXuLy;

    public int getYeuCauUngLuongId() { return yeuCauUngLuongId; }
    public void setYeuCauUngLuongId(int v) { this.yeuCauUngLuongId = v; }
    public int getAccountId() { return accountId; }
    public void setAccountId(int v) { this.accountId = v; }
    public int getCoSoId() { return coSoId; }
    public void setCoSoId(int v) { this.coSoId = v; }
    public BigDecimal getSoTienUng() { return soTienUng; }
    public void setSoTienUng(BigDecimal v) { this.soTienUng = v; }
    public String getLyDo() { return lyDo; }
    public void setLyDo(String v) { this.lyDo = v; }
    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String v) { this.trangThai = v; }
    public String getGhiChuQuanLy() { return ghiChuQuanLy; }
    public void setGhiChuQuanLy(String v) { this.ghiChuQuanLy = v; }
    public Integer getXuLyBy() { return xuLyBy; }
    public void setXuLyBy(Integer v) { this.xuLyBy = v; }
    public LocalDateTime getNgayXuLy() { return ngayXuLy; }
    public void setNgayXuLy(LocalDateTime v) { this.ngayXuLy = v; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }
    public String getHoTen() { return hoTen; }
    public void setHoTen(String v) { this.hoTen = v; }
    public String getTenNguoiXuLy() { return tenNguoiXuLy; }
    public void setTenNguoiXuLy(String v) { this.tenNguoiXuLy = v; }

    /** Chỉ yêu cầu đang chờ duyệt mới được nhân viên tự huỷ hoặc manager xử lý. */
    public boolean isChoDuyet() { return CHO_DUYET.equals(trangThai); }

    public String getCreatedAtFormatted() {
        return createdAt == null ? "" : createdAt.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public String getNgayXuLyFormatted() {
        return ngayXuLy == null ? "" : ngayXuLy.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }
}
