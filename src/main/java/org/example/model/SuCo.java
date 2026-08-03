package org.example.model;

import java.time.LocalDateTime;

public class SuCo {
    private int suCoId;
    private int coSoId;
    private Integer sanId;
    private int baoVeId;
    private String loaiSuCo;
    private String mucDo;
    private String moTa;
    private String anhUrl;
    private String trangThai;
    private String ghiChuXuLy;
    private LocalDateTime thoiGianTao;
    private LocalDateTime thoiGianXuLy;
    private Integer xuLyBoi;

    // Transient display fields
    private String tenBaoVe;
    private String tenSan;

    public SuCo() {}

    public int getSuCoId() { return suCoId; }
    public void setSuCoId(int suCoId) { this.suCoId = suCoId; }

    public int getCoSoId() { return coSoId; }
    public void setCoSoId(int coSoId) { this.coSoId = coSoId; }

    public Integer getSanId() { return sanId; }
    public void setSanId(Integer sanId) { this.sanId = sanId; }

    public int getBaoVeId() { return baoVeId; }
    public void setBaoVeId(int baoVeId) { this.baoVeId = baoVeId; }

    public String getLoaiSuCo() { return loaiSuCo; }
    public void setLoaiSuCo(String loaiSuCo) { this.loaiSuCo = loaiSuCo; }

    public String getMucDo() { return mucDo; }
    public void setMucDo(String mucDo) { this.mucDo = mucDo; }

    public String getMoTa() { return moTa; }
    public void setMoTa(String moTa) { this.moTa = moTa; }

    public String getAnhUrl() { return anhUrl; }
    public void setAnhUrl(String anhUrl) { this.anhUrl = anhUrl; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }

    public String getGhiChuXuLy() { return ghiChuXuLy; }
    public void setGhiChuXuLy(String ghiChuXuLy) { this.ghiChuXuLy = ghiChuXuLy; }

    public LocalDateTime getThoiGianTao() { return thoiGianTao; }
    public void setThoiGianTao(LocalDateTime thoiGianTao) { this.thoiGianTao = thoiGianTao; }

    public LocalDateTime getThoiGianXuLy() { return thoiGianXuLy; }
    public void setThoiGianXuLy(LocalDateTime thoiGianXuLy) { this.thoiGianXuLy = thoiGianXuLy; }

    public Integer getXuLyBoi() { return xuLyBoi; }
    public void setXuLyBoi(Integer xuLyBoi) { this.xuLyBoi = xuLyBoi; }

    public String getTenBaoVe() { return tenBaoVe; }
    public void setTenBaoVe(String tenBaoVe) { this.tenBaoVe = tenBaoVe; }

    public String getTenSan() { return tenSan; }
    public void setTenSan(String tenSan) { this.tenSan = tenSan; }

    public String getLoaiSuCoDisplay() {
        if (loaiSuCo == null) return "";
        switch (loaiSuCo) {
            case "VI_PHAM_NOI_QUY":    return "Vi phạm nội quy";
            case "HU_HONG_THIET_BI":   return "Hư hỏng thiết bị";
            case "SU_CO_AN_NINH":      return "Sự cố an ninh";
            default:                    return "Khác";
        }
    }

    public String getMucDoDisplay() {
        if (mucDo == null) return "";
        switch (mucDo) {
            case "THAP":       return "Thấp";
            case "TRUNG_BINH": return "Trung bình";
            case "CAO":        return "Cao";
            default:           return mucDo;
        }
    }

    public String getTrangThaiDisplay() {
        if (trangThai == null) return "";
        switch (trangThai) {
            case "CHO_XU_LY":   return "Chờ xử lý";
            case "DANG_XU_LY":  return "Đang xử lý";
            case "DA_XONG":     return "Đã xong";
            default:             return trangThai;
        }
    }
}
