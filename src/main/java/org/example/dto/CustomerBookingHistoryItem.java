package org.example.dto;

import java.math.BigDecimal;

public class CustomerBookingHistoryItem {
    private int datSanId;
    private int sanId;
    private Integer hoaDonId;
    private String tenSan;
    private String tenCoSo;
    private String diaChi;
    private String ngayDat;
    private String gioBatDau;
    private String gioKetThuc;
    private String bookingStatus;
    private boolean paid;
    private BigDecimal amountPaid;
    private String paymentMethod;
    private String refundStatus;

    public int getDatSanId() { return datSanId; }
    public void setDatSanId(int datSanId) { this.datSanId = datSanId; }

    public int getSanId() { return sanId; }
    public void setSanId(int sanId) { this.sanId = sanId; }

    public Integer getHoaDonId() { return hoaDonId; }
    public void setHoaDonId(Integer hoaDonId) { this.hoaDonId = hoaDonId; }

    public String getTenSan() { return tenSan; }
    public void setTenSan(String tenSan) { this.tenSan = tenSan; }

    public String getTenCoSo() { return tenCoSo; }
    public void setTenCoSo(String tenCoSo) { this.tenCoSo = tenCoSo; }

    public String getDiaChi() { return diaChi; }
    public void setDiaChi(String diaChi) { this.diaChi = diaChi; }

    public String getNgayDat() { return ngayDat; }
    public void setNgayDat(String ngayDat) { this.ngayDat = ngayDat; }

    public String getGioBatDau() { return gioBatDau; }
    public void setGioBatDau(String gioBatDau) { this.gioBatDau = gioBatDau; }

    public String getGioKetThuc() { return gioKetThuc; }
    public void setGioKetThuc(String gioKetThuc) { this.gioKetThuc = gioKetThuc; }

    public String getBookingStatus() { return bookingStatus; }
    public void setBookingStatus(String bookingStatus) { this.bookingStatus = bookingStatus; }

    public boolean isPaid() { return paid; }
    public void setPaid(boolean paid) { this.paid = paid; }

    public BigDecimal getAmountPaid() { return amountPaid; }
    public void setAmountPaid(BigDecimal amountPaid) { this.amountPaid = amountPaid; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getRefundStatus() { return refundStatus; }
    public void setRefundStatus(String refundStatus) { this.refundStatus = refundStatus; }
}
