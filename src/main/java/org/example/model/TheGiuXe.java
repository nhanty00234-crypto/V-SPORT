package org.example.model;

public class TheGiuXe {
    private int TheID;
    private int CoSoID;
    private String MaSoThe;
    private String LoaiXe;
    private String TrangThai;
    private Integer
            SucChua;
    private double GiaVeTheoLuot;

    public TheGiuXe() {
    }

    public TheGiuXe(int theID, int coSoID, String maSoThe, String loaiXe, String trangThai, int sucChua, double giaVeTheoLuot) {
        TheID = theID;
        CoSoID = coSoID;
        MaSoThe = maSoThe;
        LoaiXe = loaiXe;
        TrangThai = trangThai;
        SucChua = sucChua;
        GiaVeTheoLuot = giaVeTheoLuot;
    }

    public int getTheID() {
        return TheID;
    }

    public void setTheID(int theID) {
        TheID = theID;
    }

    public int getCoSoID() {
        return CoSoID;
    }

    public void setCoSoID(int coSoID) {
        CoSoID = coSoID;
    }

    public String getMaSoThe() {
        return MaSoThe;
    }

    public void setMaSoThe(String maSoThe) {
        MaSoThe = maSoThe;
    }

    public String getLoaiXe() {
        return LoaiXe;
    }

    public void setLoaiXe(String loaiXe) {
        LoaiXe = loaiXe;
    }

    public String getTrangThai() {
        return TrangThai;
    }

    public void setTrangThai(String trangThai) {
        TrangThai = trangThai;
    }

    public int getSucChua() {
        return SucChua;
    }

    public void setSucChua(int sucChua) {
        SucChua = sucChua;
    }

    public double getGiaVeTheoLuot() {
        return GiaVeTheoLuot;
    }

    public void setGiaVeTheoLuot(double giaVeTheoLuot) {
        GiaVeTheoLuot = giaVeTheoLuot;
    }

    @Override
    public String toString() {
        return "TheGiuXe{" +
                "TheID=" + TheID +
                ", CoSoID=" + CoSoID +
                ", MaSoThe='" + MaSoThe + '\'' +
                ", LoaiXe='" + LoaiXe + '\'' +
                ", TrangThai='" + TrangThai + '\'' +
                ", SucChua=" + SucChua +
                ", GiaVeTheoLuot=" + GiaVeTheoLuot +
                '}';
    }
}

