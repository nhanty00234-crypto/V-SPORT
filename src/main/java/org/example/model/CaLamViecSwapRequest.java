package org.example.model;

import java.time.LocalDateTime;

public class CaLamViecSwapRequest {
    private int swapRequestId;
    private int accountIdGui;
    private int caLamViecIdGui;
    private int accountIdNhan;
    private Integer caLamViecIdNhan; // Nullable
    private String lyDo;
    private String trangThai; // 'ChoXacNhan', 'ChoQuanLyDuyet', 'DaDuyet', 'TuChoi', 'DaHuy'
    private Integer nguoiDuyet;
    private LocalDateTime ngayGui;
    private LocalDateTime ngayDuyet;
    private String ghiChuQuanLy;

    // Display fields
    private String tenNguoiGui;
    private String tenNguoiNhan;
    private String caGuiInfo; // Info about requester's shift
    private String caNhanInfo; // Info about receiver's shift

    public CaLamViecSwapRequest() {
    }

    public int getSwapRequestId() {
        return swapRequestId;
    }

    public void setSwapRequestId(int swapRequestId) {
        this.swapRequestId = swapRequestId;
    }

    public int getAccountIdGui() {
        return accountIdGui;
    }

    public void setAccountIdGui(int accountIdGui) {
        this.accountIdGui = accountIdGui;
    }

    public int getCaLamViecIdGui() {
        return caLamViecIdGui;
    }

    public void setCaLamViecIdGui(int caLamViecIdGui) {
        this.caLamViecIdGui = caLamViecIdGui;
    }

    public int getAccountIdNhan() {
        return accountIdNhan;
    }

    public void setAccountIdNhan(int accountIdNhan) {
        this.accountIdNhan = accountIdNhan;
    }

    public Integer getCaLamViecIdNhan() {
        return caLamViecIdNhan;
    }

    public void setCaLamViecIdNhan(Integer caLamViecIdNhan) {
        this.caLamViecIdNhan = caLamViecIdNhan;
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

    public Integer getNguoiDuyet() {
        return nguoiDuyet;
    }

    public void setNguoiDuyet(Integer nguoiDuyet) {
        this.nguoiDuyet = nguoiDuyet;
    }

    public LocalDateTime getNgayGui() {
        return ngayGui;
    }

    public void setNgayGui(LocalDateTime ngayGui) {
        this.ngayGui = ngayGui;
    }

    public LocalDateTime getNgayDuyet() {
        return ngayDuyet;
    }

    public void setNgayDuyet(LocalDateTime ngayDuyet) {
        this.ngayDuyet = ngayDuyet;
    }

    public String getGhiChuQuanLy() {
        return ghiChuQuanLy;
    }

    public void setGhiChuQuanLy(String ghiChuQuanLy) {
        this.ghiChuQuanLy = ghiChuQuanLy;
    }

    public String getTenNguoiGui() {
        return tenNguoiGui;
    }

    public void setTenNguoiGui(String tenNguoiGui) {
        this.tenNguoiGui = tenNguoiGui;
    }

    public String getTenNguoiNhan() {
        return tenNguoiNhan;
    }

    public void setTenNguoiNhan(String tenNguoiNhan) {
        this.tenNguoiNhan = tenNguoiNhan;
    }

    public String getCaGuiInfo() {
        return caGuiInfo;
    }

    public void setCaGuiInfo(String caGuiInfo) {
        this.caGuiInfo = caGuiInfo;
    }

    public String getCaNhanInfo() {
        return caNhanInfo;
    }

    public void setCaNhanInfo(String caNhanInfo) {
        this.caNhanInfo = caNhanInfo;
    }
}
