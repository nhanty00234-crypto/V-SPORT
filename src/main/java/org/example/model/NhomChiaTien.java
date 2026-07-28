package org.example.model;

import java.math.BigDecimal;
import java.util.Date;

/** Map bảng NhomChiaTien (tương đương "BillSplit" trong spec nghiệp vụ). POJO thuần, JDBC. */
public class NhomChiaTien {

    private int nhomChiaTienId;
    private int hoaDonId;
    private int datSanId;
    private int createdByAccountId;
    private String splitType;
    private BigDecimal tongTien;
    private String trangThai;
    private Date expiresAt;
    private Date createdAt;
    private Date updatedAt;

    public int getNhomChiaTienId() { return nhomChiaTienId; }
    public void setNhomChiaTienId(int v) { this.nhomChiaTienId = v; }

    public int getHoaDonId() { return hoaDonId; }
    public void setHoaDonId(int v) { this.hoaDonId = v; }

    public int getDatSanId() { return datSanId; }
    public void setDatSanId(int v) { this.datSanId = v; }

    public int getCreatedByAccountId() { return createdByAccountId; }
    public void setCreatedByAccountId(int v) { this.createdByAccountId = v; }

    public String getSplitType() { return splitType; }
    public void setSplitType(String v) { this.splitType = v; }

    public BigDecimal getTongTien() { return tongTien; }
    public void setTongTien(BigDecimal v) { this.tongTien = v; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String v) { this.trangThai = v; }

    public Date getExpiresAt() { return expiresAt; }
    public void setExpiresAt(Date v) { this.expiresAt = v; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date v) { this.createdAt = v; }

    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date v) { this.updatedAt = v; }
}
