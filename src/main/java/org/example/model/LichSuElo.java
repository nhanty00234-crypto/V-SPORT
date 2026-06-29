package org.example.model;

import java.util.Date;

public class LichSuElo {
    private int LichSuELOID;
    private int AccountID;
    private Integer DatSanID;
    private int DiemTruoc;
    private int  DiemSau;
    private int ThayDoi;
    private String LyDo;
    private Date ThoiGian;

    public LichSuElo() {
    }

    public LichSuElo(int lichSuELOID, int accountID, int datSanID, int diemTruoc, int diemSau, int thayDoi, String lyDo, Date thoiGian) {
        LichSuELOID = lichSuELOID;
        AccountID = accountID;
        DatSanID = datSanID;
        DiemTruoc = diemTruoc;
        DiemSau = diemSau;
        ThayDoi = thayDoi;
        LyDo = lyDo;
        ThoiGian = thoiGian;
    }

    public int getLichSuELOID() {
        return LichSuELOID;
    }

    public void setLichSuELOID(int lichSuELOID) {
        LichSuELOID = lichSuELOID;
    }

    public int getAccountID() {
        return AccountID;
    }

    public void setAccountID(int accountID) {
        AccountID = accountID;
    }

    public int getDatSanID() {
        return DatSanID;
    }

    public void setDatSanID(int datSanID) {
        DatSanID = datSanID;
    }

    public int getDiemTruoc() {
        return DiemTruoc;
    }

    public void setDiemTruoc(int diemTruoc) {
        DiemTruoc = diemTruoc;
    }

    public int getDiemSau() {
        return DiemSau;
    }

    public void setDiemSau(int diemSau) {
        DiemSau = diemSau;
    }

    public int getThayDoi() {
        return ThayDoi;
    }

    public void setThayDoi(int thayDoi) {
        ThayDoi = thayDoi;
    }

    public String getLyDo() {
        return LyDo;
    }

    public void setLyDo(String lyDo) {
        LyDo = lyDo;
    }

    public Date getThoiGian() {
        return ThoiGian;
    }

    public void setThoiGian(Date thoiGian) {
        ThoiGian = thoiGian;
    }

    @Override
    public String toString() {
        return "LichSuElo{" +
                "LichSuELOID=" + LichSuELOID +
                ", AccountID=" + AccountID +
                ", DatSanID=" + DatSanID +
                ", DiemTruoc=" + DiemTruoc +
                ", DiemSau=" + DiemSau +
                ", ThayDoi=" + ThayDoi +
                ", LyDo='" + LyDo + '\'' +
                ", ThoiGian=" + ThoiGian +
                '}';
    }
}

