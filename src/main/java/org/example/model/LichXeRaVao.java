package org.example.model;

import java.util.Date;

public class LichXeRaVao {
    private int LichXeID;
    private int TheID;
    private Integer DatSanID;
    private String BienSoXe;
    private String KieuGuiXe;
    private Date GioVao;
    private Date GioRa;
    private double PhiGuiXe;
    private Integer AccountID_NhanVien;

    public LichXeRaVao() {
    }

    public LichXeRaVao(int lichXeID, int theID, Integer datSanID, String bienSoXe, String kieuGuiXe, Date gioVao, Date gioRa, double phiGuiXe, Integer accountID_NhanVien) {
        LichXeID = lichXeID;
        TheID = theID;
        DatSanID = datSanID;
        BienSoXe = bienSoXe;
        KieuGuiXe = kieuGuiXe;
        GioVao = gioVao;
        GioRa = gioRa;
        PhiGuiXe = phiGuiXe;
        AccountID_NhanVien = accountID_NhanVien;
    }

    public int getLichXeID() {
        return LichXeID;
    }

    public void setLichXeID(int lichXeID) {
        LichXeID = lichXeID;
    }

    public int getTheID() {
        return TheID;
    }

    public void setTheID(int theID) {
        TheID = theID;
    }

    public Integer getDatSanID() {
        return DatSanID;
    }

    public void setDatSanID(Integer datSanID) {
        this.DatSanID = datSanID;
    }

    public String getBienSoXe() {
        return BienSoXe;
    }

    public void setBienSoXe(String bienSoXe) {
        this.BienSoXe = bienSoXe;
    }

    public String getKieuGuiXe() {
        return KieuGuiXe;
    }

    public void setKieuGuiXe(String kieuGuiXe) {
        this.KieuGuiXe = kieuGuiXe;
    }

    public Date getGioVao() {
        return GioVao;
    }

    public void setGioVao(Date gioVao) {
        this.GioVao = gioVao;
    }

    public Date getGioRa() {
        return GioRa;
    }

    public void setGioRa(Date gioRa) {
        this.GioRa = gioRa;
    }

    public double getPhiGuiXe() {
        return PhiGuiXe;
    }

    public void setPhiGuiXe(double phiGuiXe) {
        this.PhiGuiXe = phiGuiXe;
    }

    public Integer getAccountID_NhanVien() {
        return AccountID_NhanVien;
    }

    public void setAccountID_NhanVien(Integer accountID_NhanVien) {
        AccountID_NhanVien = accountID_NhanVien;
    }

    @Override
    public String toString() {
        return "LichXeRaVao{" +
                "LichXeID=" + LichXeID +
                ", TheID=" + TheID +
                ", DatSanID=" + DatSanID +
                ", BienSoXe='" + BienSoXe + '\'' +
                ", KieuGuiXe='" + KieuGuiXe + '\'' +
                ", GioVao=" + GioVao +
                ", GioRa=" + GioRa +
                ", PhiGuiXe=" + PhiGuiXe +
                ", AccountID_NhanVien=" + AccountID_NhanVien +
                '}';
    }
}
