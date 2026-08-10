package org.example.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;

@Entity
@Table(name = "bookings")
public class Lichdatsan {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "booking_id")
    private int datSanId;

    @Column(name = "account_id")
    private Integer accountId;

    @Column(name = "court_id")
    private Integer sanId;

    @Column(name = "booking_date", nullable = false)
    private LocalDate ngayDat;

    @Column(name = "start_time", nullable = false)
    private LocalTime gioBatDau;

    @Column(name = "end_time", nullable = false)
    private LocalTime gioKetThuc;

    @Column(name = "apply_light_price")
    private boolean apDungGiaCoDen;

    @Column(name = "estimated_total")
    private BigDecimal tongTienDuKien;

    @Column(name = "status", length = 50)
    private String trangThai;

    @Column(name = "note", length = 255)
    private String ghiChu;

    @Column(name = "booking_source", length = 50)
    private String nguonDatSan;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdTime;

    @Column(name = "is_deleted")
    private boolean isDeleted;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    @Column(name = "deleted_by")
    private Integer deletedBy;

    @Column(name = "time_mode", length = 30)
    private String timeMode;

    @Column(name = "reserved_duration_minutes")
    private Integer reservedDurationMinutes;

    @Column(name = "actual_end_time_of_day")
    private LocalTime actualEndTime;

    @Column(name = "actual_start_time_of_day")
    private LocalTime actualStartTime;

    @Column(name = "actual_started_at")
    private LocalDateTime actualStartAt;

    @Column(name = "actual_ended_at")
    private LocalDateTime actualEndAt;

    @Column(name = "pricing_finalized_at")
    private LocalDateTime pricingFinalizedAt;

    @Column(name = "early_checkout_reason", length = 255)
    private String earlyCheckoutReason;

    @Column(name = "early_checkout_discount")
    private BigDecimal earlyCheckoutDiscount;

    @Column(name = "hold_expires_at")
    private LocalDateTime holdExpiresAt;

    @Column(name = "deposit_amount")
    private BigDecimal depositAmount;

    @Column(name = "payment_method_confirmed", length = 50)
    private String paymentMethodConfirmed;

    @Column(name = "transaction_code", length = 100)
    private String transactionCode;

    @Column(name = "confirmed_at")
    private LocalDateTime confirmedAt;

    @Column(name = "confirmed_by")
    private Integer confirmedBy;

    @Column(name = "confirm_source", length = 20)
    private String confirmSource;

    @Column(name = "no_show_at")
    private LocalDateTime noShowAt;

    @Column(name = "cancel_type", length = 20)
    private String cancelType;

    @Column(name = "cancel_reason", length = 255)
    private String cancelReason;

    @Column(name = "cancelled_at")
    private LocalDateTime cancelledAt;

    @Column(name = "cancelled_by")
    private Integer cancelledBy;

    @Column(name = "requires_refund_review")
    private boolean requiresRefundReview;

    // Relationships
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "court_id", insertable = false, updatable = false)
    private San san;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "account_id", insertable = false, updatable = false)
    private TaiKhoan account;

    public Lichdatsan() {
    }

    public Lichdatsan(int datSanId, Integer accountId, Integer sanId, LocalDate ngayDat, LocalTime gioBatDau, LocalTime gioKetThuc, boolean apDungGiaCoDen, BigDecimal tongTienDuKien, String trangThai, String ghiChu, String nguonDatSan) {
        this.datSanId = datSanId;
        this.accountId = accountId;
        this.sanId = sanId;
        this.ngayDat = ngayDat;
        this.gioBatDau = gioBatDau;
        this.gioKetThuc = gioKetThuc;
        this.apDungGiaCoDen = apDungGiaCoDen;
        this.tongTienDuKien = tongTienDuKien;
        this.trangThai = trangThai;
        this.ghiChu = ghiChu;
        this.nguonDatSan = nguonDatSan;
    }

    public int getDatSanId() {
        return datSanId;
    }

    public void setDatSanId(int datSanId) {
        this.datSanId = datSanId;
    }

    public Integer getAccountId() {
        return accountId;
    }

    public void setAccountId(Integer accountId) {
        this.accountId = accountId;
    }

    public Integer getSanId() {
        return sanId;
    }

    public void setSanId(Integer sanId) {
        this.sanId = sanId;
    }

    public LocalDate getNgayDat() {
        return ngayDat;
    }

    public void setNgayDat(LocalDate ngayDat) {
        this.ngayDat = ngayDat;
    }

    public LocalTime getGioBatDau() {
        return gioBatDau;
    }

    public void setGioBatDau(LocalTime gioBatDau) {
        this.gioBatDau = gioBatDau;
    }

    public LocalTime getGioKetThuc() {
        return gioKetThuc;
    }

    public void setGioKetThuc(LocalTime gioKetThuc) {
        this.gioKetThuc = gioKetThuc;
    }

    public boolean isApDungGiaCoDen() {
        return apDungGiaCoDen;
    }

    public void setApDungGiaCoDen(boolean apDungGiaCoDen) {
        this.apDungGiaCoDen = apDungGiaCoDen;
    }

    public BigDecimal getTongTienDuKien() {
        return tongTienDuKien;
    }

    public void setTongTienDuKien(BigDecimal tongTienDuKien) {
        this.tongTienDuKien = tongTienDuKien;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public String getGhiChu() {
        return ghiChu;
    }

    public void setGhiChu(String ghiChu) {
        this.ghiChu = ghiChu;
    }

    public String getNguonDatSan() {
        return nguonDatSan;
    }

    public void setNguonDatSan(String nguonDatSan) {
        this.nguonDatSan = nguonDatSan;
    }

    public San getSan() {
        return san;
    }

    public void setSan(San san) {
        this.san = san;
    }

    public TaiKhoan getAccount() {
        return account;
    }

    public void setAccount(TaiKhoan account) {
        this.account = account;
    }

    public LocalDateTime getCreatedTime() {
        return createdTime;
    }

    public void setCreatedTime(LocalDateTime createdTime) {
        this.createdTime = createdTime;
    }

    public boolean isDeleted() { return isDeleted; }

    public void setDeleted(boolean deleted) { isDeleted = deleted; }

    public LocalDateTime getDeletedAt() { return deletedAt; }

    public void setDeletedAt(LocalDateTime deletedAt) { this.deletedAt = deletedAt; }

    public Integer getDeletedBy() { return deletedBy; }

    public void setDeletedBy(Integer deletedBy) { this.deletedBy = deletedBy; }

    public String getTimeMode() {
        return timeMode;
    }

    public void setTimeMode(String timeMode) {
        this.timeMode = timeMode;
    }

    public Integer getReservedDurationMinutes() {
        return reservedDurationMinutes;
    }

    public void setReservedDurationMinutes(Integer reservedDurationMinutes) {
        this.reservedDurationMinutes = reservedDurationMinutes;
    }

    public LocalTime getActualEndTime() {
        return actualEndTime;
    }

    public void setActualEndTime(LocalTime actualEndTime) {
        this.actualEndTime = actualEndTime;
    }

    public LocalTime getActualStartTime() {
        return actualStartTime;
    }

    public void setActualStartTime(LocalTime actualStartTime) {
        this.actualStartTime = actualStartTime;
    }

    public LocalDateTime getActualStartAt() { return actualStartAt; }
    public void setActualStartAt(LocalDateTime actualStartAt) { this.actualStartAt = actualStartAt; }
    public LocalDateTime getActualEndAt() { return actualEndAt; }
    public void setActualEndAt(LocalDateTime actualEndAt) { this.actualEndAt = actualEndAt; }
    public LocalDateTime getPricingFinalizedAt() { return pricingFinalizedAt; }
    public void setPricingFinalizedAt(LocalDateTime pricingFinalizedAt) { this.pricingFinalizedAt = pricingFinalizedAt; }

    public String getEarlyCheckoutReason() {
        return earlyCheckoutReason;
    }

    public void setEarlyCheckoutReason(String earlyCheckoutReason) {
        this.earlyCheckoutReason = earlyCheckoutReason;
    }

    public BigDecimal getEarlyCheckoutDiscount() {
        return earlyCheckoutDiscount;
    }

    public void setEarlyCheckoutDiscount(BigDecimal earlyCheckoutDiscount) {
        this.earlyCheckoutDiscount = earlyCheckoutDiscount;
    }

    public LocalDateTime getHoldExpiresAt() {
        return holdExpiresAt;
    }

    public void setHoldExpiresAt(LocalDateTime holdExpiresAt) {
        this.holdExpiresAt = holdExpiresAt;
    }

    public BigDecimal getDepositAmount() {
        return depositAmount;
    }

    public void setDepositAmount(BigDecimal depositAmount) {
        this.depositAmount = depositAmount;
    }

    public String getPaymentMethodConfirmed() {
        return paymentMethodConfirmed;
    }

    public void setPaymentMethodConfirmed(String paymentMethodConfirmed) {
        this.paymentMethodConfirmed = paymentMethodConfirmed;
    }

    public String getTransactionCode() {
        return transactionCode;
    }

    public void setTransactionCode(String transactionCode) {
        this.transactionCode = transactionCode;
    }

    public LocalDateTime getConfirmedAt() {
        return confirmedAt;
    }

    public void setConfirmedAt(LocalDateTime confirmedAt) {
        this.confirmedAt = confirmedAt;
    }

    public Integer getConfirmedBy() {
        return confirmedBy;
    }

    public void setConfirmedBy(Integer confirmedBy) {
        this.confirmedBy = confirmedBy;
    }

    public String getConfirmSource() {
        return confirmSource;
    }

    public void setConfirmSource(String confirmSource) {
        this.confirmSource = confirmSource;
    }

    public LocalDateTime getNoShowAt() {
        return noShowAt;
    }

    public void setNoShowAt(LocalDateTime noShowAt) {
        this.noShowAt = noShowAt;
    }

    public String getCancelType() {
        return cancelType;
    }

    public void setCancelType(String cancelType) {
        this.cancelType = cancelType;
    }

    public String getCancelReason() {
        return cancelReason;
    }

    public void setCancelReason(String cancelReason) {
        this.cancelReason = cancelReason;
    }

    public LocalDateTime getCancelledAt() {
        return cancelledAt;
    }

    public void setCancelledAt(LocalDateTime cancelledAt) {
        this.cancelledAt = cancelledAt;
    }

    public Integer getCancelledBy() {
        return cancelledBy;
    }

    public void setCancelledBy(Integer cancelledBy) {
        this.cancelledBy = cancelledBy;
    }

    public boolean getRequiresRefundReview() {
        return requiresRefundReview;
    }

    public void setRequiresRefundReview(boolean requiresRefundReview) {
        this.requiresRefundReview = requiresRefundReview;
    }

    @Override
    public String toString() {
        return "Lichdatsan{" +
                "datSanId=" + datSanId +
                ", accountId=" + accountId +
                ", sanId=" + sanId +
                ", ngayDat=" + ngayDat +
                ", gioBatDau=" + gioBatDau +
                ", gioKetThuc=" + gioKetThuc +
                ", apDungGiaCoDen=" + apDungGiaCoDen +
                ", tongTienDuKien=" + tongTienDuKien +
                ", trangThai='" + trangThai + '\'' +
                ", ghiChu='" + ghiChu + '\'' +
                ", nguonDatSan='" + nguonDatSan + '\'' +
                '}';
    }
}
