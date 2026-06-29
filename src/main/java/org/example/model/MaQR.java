package org.example.model;

import java.util.Date;

public class MaQR {
    private int MaQRID;
    private int ChiaHoaDonID;
    private String NoiDungQR;
    private Date NgayTao;
    private Date NgayHetHan;
    private boolean DaQuet;

    public MaQR() {
    }


    public MaQR(int maQRID, int chiaHoaDonID, String noiDungQR, Date ngayTao, Date ngayHetHan, boolean daQuet) {
        MaQRID = maQRID;
        ChiaHoaDonID = chiaHoaDonID;
        NoiDungQR = noiDungQR;
        NgayTao = ngayTao;
        NgayHetHan = ngayHetHan;
        DaQuet = daQuet;
    }

    public int getMaQRID() {
        return MaQRID;
    }

    public void setMaQRID(int maQRID) {
        MaQRID = maQRID;
    }

    public int getChiaHoaDonID() {
        return ChiaHoaDonID;
    }

    public void setChiaHoaDonID(int chiaHoaDonID) {
        ChiaHoaDonID = chiaHoaDonID;
    }

    public String getNoiDungQR() {
        return NoiDungQR;
    }

    public void setNoiDungQR(String noiDungQR) {
        NoiDungQR = noiDungQR;
    }

    public Date getNgayTao() {
        return NgayTao;
    }

    public void setNgayTao(Date ngayTao) {
        NgayTao = ngayTao;
    }

    public Date getNgayHetHan() {
        return NgayHetHan;
    }

    public void setNgayHetHan(Date ngayHetHan) {
        NgayHetHan = ngayHetHan;
    }

    public boolean isDaQuet() {
        return DaQuet;
    }

    public void setDaQuet(boolean daQuet) {
        DaQuet = daQuet;
    }

    @Override
    public String toString() {
        return "MaQR{" +
                "MaQRID=" + MaQRID +
                ", ChiaHoaDonID=" + ChiaHoaDonID +
                ", NoiDungQR='" + NoiDungQR + '\'' +
                ", NgayTao=" + NgayTao +
                ", NgayHetHan=" + NgayHetHan +
                ", DaQuet=" + DaQuet +
                '}';
    }
}

