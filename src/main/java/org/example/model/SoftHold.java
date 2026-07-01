package org.example.model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

public class SoftHold {
    private int softHoldId;
    private int accountId;
    private int sanId;
    private LocalDate ngayDat;
    private LocalTime gioBatDau;
    private LocalTime gioKetThuc;
    private LocalDateTime createdTime;

    public SoftHold() {}

    public SoftHold(int softHoldId, int accountId, int sanId, LocalDate ngayDat,
                     LocalTime gioBatDau, LocalTime gioKetThuc, LocalDateTime createdTime) {
        this.softHoldId = softHoldId;
        this.accountId = accountId;
        this.sanId = sanId;
        this.ngayDat = ngayDat;
        this.gioBatDau = gioBatDau;
        this.gioKetThuc = gioKetThuc;
        this.createdTime = createdTime;
    }

    public int getSoftHoldId() { return softHoldId; }
    public void setSoftHoldId(int softHoldId) { this.softHoldId = softHoldId; }
    public int getAccountId() { return accountId; }
    public void setAccountId(int accountId) { this.accountId = accountId; }
    public int getSanId() { return sanId; }
    public void setSanId(int sanId) { this.sanId = sanId; }
    public LocalDate getNgayDat() { return ngayDat; }
    public void setNgayDat(LocalDate ngayDat) { this.ngayDat = ngayDat; }
    public LocalTime getGioBatDau() { return gioBatDau; }
    public void setGioBatDau(LocalTime gioBatDau) { this.gioBatDau = gioBatDau; }
    public LocalTime getGioKetThuc() { return gioKetThuc; }
    public void setGioKetThuc(LocalTime gioKetThuc) { this.gioKetThuc = gioKetThuc; }
    public LocalDateTime getCreatedTime() { return createdTime; }
    public void setCreatedTime(LocalDateTime createdTime) { this.createdTime = createdTime; }
}
