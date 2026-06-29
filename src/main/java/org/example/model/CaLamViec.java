package org.example.model;

import java.time.LocalDate;
import java.time.LocalTime;

public class CaLamViec {
    private int caLamViecId;
    private int accountId;
    private int coSoId;
    private LocalDate ngayLam;
    private LocalTime gioBatDau;
    private LocalTime gioKetThuc;
    private String ghiChu;
    private Integer thu; // Thứ trong tuần: 2=Thứ 2, 3=Thứ 3, ..., 8=Chủ nhật. Null nếu là ca theo ngày cụ thể
    private boolean isPublished;
    private String tenCa; // Tên ca (Ca sáng, Ca chiều, Ca đêm, Tùy chỉnh)
    private String viTri; // Vị trí trong ca (Lễ tân, Bảo vệ, ...)
    private String trangThai = "Draft"; // Draft, Published, Confirmed
    private int gioNghi; // Giờ nghỉ giữa ca (phút)

    public CaLamViec() {
    }

    public CaLamViec(int caLamViecId, int accountId, int coSoId, LocalDate ngayLam, LocalTime gioBatDau, LocalTime gioKetThuc, String ghiChu) {
        this.caLamViecId = caLamViecId;
        this.accountId = accountId;
        this.coSoId = coSoId;
        this.ngayLam = ngayLam;
        this.gioBatDau = gioBatDau;
        this.gioKetThuc = gioKetThuc;
        this.ghiChu = ghiChu;
        this.isPublished = false;
        this.trangThai = "Draft";
        this.gioNghi = 0;
    }

    public CaLamViec(int accountId, int coSoId, LocalDate ngayLam, LocalTime gioBatDau, LocalTime gioKetThuc, String ghiChu, Integer thu) {
        this.accountId = accountId;
        this.coSoId = coSoId;
        this.ngayLam = ngayLam;
        this.gioBatDau = gioBatDau;
        this.gioKetThuc = gioKetThuc;
        this.ghiChu = ghiChu;
        this.thu = thu;
        this.isPublished = false;
        this.trangThai = "Draft";
        this.gioNghi = 0;
    }

    public CaLamViec(int caLamViecId, int accountId, int coSoId, LocalDate ngayLam, LocalTime gioBatDau, LocalTime gioKetThuc, String ghiChu, Integer thu, boolean isPublished) {
        this.caLamViecId = caLamViecId;
        this.accountId = accountId;
        this.coSoId = coSoId;
        this.ngayLam = ngayLam;
        this.gioBatDau = gioBatDau;
        this.gioKetThuc = gioKetThuc;
        this.ghiChu = ghiChu;
        this.thu = thu;
        this.isPublished = isPublished;
        this.trangThai = isPublished ? "Published" : "Draft";
        this.gioNghi = 0;
    }

    public String getTenCa() {
        return tenCa;
    }

    public void setTenCa(String tenCa) {
        this.tenCa = tenCa;
    }

    public String getViTri() {
        return viTri;
    }

    public void setViTri(String viTri) {
        this.viTri = viTri;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
        if ("Published".equals(trangThai) || "Confirmed".equals(trangThai) || "CheckedIn".equals(trangThai) || "CheckedOut".equals(trangThai)) {
            this.isPublished = true;
        } else {
            this.isPublished = false;
        }
    }

    public int getGioNghi() {
        return gioNghi;
    }

    public void setGioNghi(int gioNghi) {
        this.gioNghi = gioNghi;
    }

    public int getCaLamViecId() {
        return caLamViecId;
    }

    public void setCaLamViecId(int caLamViecId) {
        this.caLamViecId = caLamViecId;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public int getCoSoId() {
        return coSoId;
    }

    public void setCoSoId(int coSoId) {
        this.coSoId = coSoId;
    }

    public LocalDate getNgayLam() {
        return ngayLam;
    }

    public void setNgayLam(LocalDate ngayLam) {
        this.ngayLam = ngayLam;
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

    public String getGhiChu() {
        return ghiChu;
    }

    public void setGhiChu(String ghiChu) {
        this.ghiChu = ghiChu;
    }

    public Integer getThu() {
        return thu;
    }

    public void setThu(Integer thu) {
        this.thu = thu;
    }

    public boolean isPublished() {
        return isPublished;
    }

    public void setPublished(boolean published) {
        isPublished = published;
        if (published && "Draft".equals(this.trangThai)) {
            this.trangThai = "Published";
        } else if (!published) {
            this.trangThai = "Draft";
        }
    }

    @Override
    public String toString() {
        return "CaLamViec{" +
                "caLamViecId=" + caLamViecId +
                ", accountId=" + accountId +
                ", coSoId=" + coSoId +
                ", ngayLam=" + ngayLam +
                ", gioBatDau=" + gioBatDau +
                ", gioKetThuc=" + gioKetThuc +
                ", ghiChu='" + ghiChu + '\'' +
                ", thu=" + thu +
                ", isPublished=" + isPublished +
                ", tenCa='" + tenCa + '\'' +
                ", viTri='" + viTri + '\'' +
                ", trangThai='" + trangThai + '\'' +
                ", gioNghi=" + gioNghi +
                '}';
    }
}

