package org.example.model;

import java.math.BigDecimal;
import java.util.Date;

/** Map bảng NhomChiaTienChiTiet (tương đương "BillSplitShare" trong spec nghiệp vụ). */
public class NhomChiaTienChiTiet {

    private int chiTietId;
    private int nhomChiaTienId;
    private Integer accountId;
    private String displayName;
    private String shareToken;
    private BigDecimal soTien;
    private String trangThai;
    private String paymentMethod;
    private String paymentTransactionId;
    private Integer payerAccountId;
    private Date paidAt;
    private Integer confirmedByStaffId;
    private Date createdAt;
    private Date updatedAt;

    public int getChiTietId() { return chiTietId; }
    public void setChiTietId(int v) { this.chiTietId = v; }

    public int getNhomChiaTienId() { return nhomChiaTienId; }
    public void setNhomChiaTienId(int v) { this.nhomChiaTienId = v; }

    public Integer getAccountId() { return accountId; }
    public void setAccountId(Integer v) { this.accountId = v; }

    public String getDisplayName() { return displayName; }
    public void setDisplayName(String v) { this.displayName = v; }

    public String getShareToken() { return shareToken; }
    public void setShareToken(String v) { this.shareToken = v; }

    public BigDecimal getSoTien() { return soTien; }
    public void setSoTien(BigDecimal v) { this.soTien = v; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String v) { this.trangThai = v; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String v) { this.paymentMethod = v; }

    public String getPaymentTransactionId() { return paymentTransactionId; }
    public void setPaymentTransactionId(String v) { this.paymentTransactionId = v; }

    public Integer getPayerAccountId() { return payerAccountId; }
    public void setPayerAccountId(Integer v) { this.payerAccountId = v; }

    public Date getPaidAt() { return paidAt; }
    public void setPaidAt(Date v) { this.paidAt = v; }

    public Integer getConfirmedByStaffId() { return confirmedByStaffId; }
    public void setConfirmedByStaffId(Integer v) { this.confirmedByStaffId = v; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date v) { this.createdAt = v; }

    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date v) { this.updatedAt = v; }
}
