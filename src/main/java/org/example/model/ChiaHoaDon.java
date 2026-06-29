package org.example.model;

import java.util.Date;

public class ChiaHoaDon {
    private int ChiaHoaDonID;
    private int HoaDonID;
    private int AccountID;
    private double SoTienPhanBo;
    private boolean DaTra;
    private Date ThoiGianTra;
    private String GhiChu;

    public ChiaHoaDon() {
    }

    public ChiaHoaDon(int chiaHoaDonID, int hoaDonID, int accountID, double soTienPhanBo, boolean daTra, Date thoiGianTra, String ghiChu) {
        ChiaHoaDonID = chiaHoaDonID;
        HoaDonID = hoaDonID;
        AccountID = accountID;
        SoTienPhanBo = soTienPhanBo;
        DaTra = daTra;
        ThoiGianTra = thoiGianTra;
        GhiChu = ghiChu;
    }

    public int getChiaHoaDonID() {
        return ChiaHoaDonID;
    }

    public void setChiaHoaDonID(int chiaHoaDonID) {
        ChiaHoaDonID = chiaHoaDonID;
    }

    public int getHoaDonID() {
        return HoaDonID;
    }

    public void setHoaDonID(int hoaDonID) {
        HoaDonID = hoaDonID;
    }

    public int getAccountID() {
        return AccountID;
    }

    public void setAccountID(int accountID) {
        AccountID = accountID;
    }

    public double getSoTienPhanBo() {
        return SoTienPhanBo;
    }

    public void setSoTienPhanBo(double soTienPhanBo) {
        SoTienPhanBo = soTienPhanBo;
    }

    public boolean isDaTra() {
        return DaTra;
    }

    public void setDaTra(boolean daTra) {
        DaTra = daTra;
    }

    public Date getThoiGianTra() {
        return ThoiGianTra;
    }

    public void setThoiGianTra(Date thoiGianTra) {
        ThoiGianTra = thoiGianTra;
    }

    public String getGhiChu() {
        return GhiChu;
    }

    public void setGhiChu(String ghiChu) {
        GhiChu = ghiChu;
    }

    @Override
    public String toString() {
        return "ChiaHoaDon{" +
                "ChiaHoaDonID=" + ChiaHoaDonID +
                ", HoaDonID=" + HoaDonID +
                ", AccountID=" + AccountID +
                ", SoTienPhanBo=" + SoTienPhanBo +
                ", DaTra=" + DaTra +
                ", ThoiGianTra=" + ThoiGianTra +
                ", GhiChu='" + GhiChu + '\'' +
                '}';
    }
}
