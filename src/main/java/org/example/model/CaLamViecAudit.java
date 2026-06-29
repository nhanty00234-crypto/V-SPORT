package org.example.model;

import java.time.LocalDateTime;

public class CaLamViecAudit {
    private int auditId;
    private int caLamViecId;
    private String thaoTac; // 'INSERT', 'UPDATE', 'DELETE', 'PUBLISH', 'CLONE', 'SWAP'
    private int nguoiThucHien;
    private LocalDateTime thoiGian;
    private String giaTriCu;
    private String giaTriMoi;
    private String lyDo;

    // Display fields
    private String tenNguoiThucHien;

    public CaLamViecAudit() {
    }

    public int getAuditId() {
        return auditId;
    }

    public void setAuditId(int auditId) {
        this.auditId = auditId;
    }

    public int getCaLamViecId() {
        return caLamViecId;
    }

    public void setCaLamViecId(int caLamViecId) {
        this.caLamViecId = caLamViecId;
    }

    public String getThaoTac() {
        return thaoTac;
    }

    public void setThaoTac(String thaoTac) {
        this.thaoTac = thaoTac;
    }

    public int getNguoiThucHien() {
        return nguoiThucHien;
    }

    public void setNguoiThucHien(int nguoiThucHien) {
        this.nguoiThucHien = nguoiThucHien;
    }

    public LocalDateTime getThoiGian() {
        return thoiGian;
    }

    public void setThoiGian(LocalDateTime thoiGian) {
        this.thoiGian = thoiGian;
    }

    public String getGiaTriCu() {
        return giaTriCu;
    }

    public void setGiaTriCu(String giaTriCu) {
        this.giaTriCu = giaTriCu;
    }

    public String getGiaTriMoi() {
        return giaTriMoi;
    }

    public void setGiaTriMoi(String giaTriMoi) {
        this.giaTriMoi = giaTriMoi;
    }

    public String getLyDo() {
        return lyDo;
    }

    public void setLyDo(String lyDo) {
        this.lyDo = lyDo;
    }

    public String getTenNguoiThucHien() {
        return tenNguoiThucHien;
    }

    public void setTenNguoiThucHien(String tenNguoiThucHien) {
        this.tenNguoiThucHien = tenNguoiThucHien;
    }
}
