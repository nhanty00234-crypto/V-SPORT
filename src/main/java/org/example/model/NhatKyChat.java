package org.example.model;

import java.util.Date;

public class NhatKyChat {
    private int NhatKyChatID;
    private int AccountID;
    private String Kenh;
    private int TurnSo;
    private String VaiTro;
    private String NoiDung;
    private String TrangThaiBot;
    private Date ThoiGian;

    public NhatKyChat() {
    }

    public NhatKyChat(int nhatKyChatID, int accountID, String kenh, int turnSo, String vaiTro, String noiDung, String trangThaiBot, Date thoiGian) {
        NhatKyChatID = nhatKyChatID;
        AccountID = accountID;
        Kenh = kenh;
        TurnSo = turnSo;
        VaiTro = vaiTro;
        NoiDung = noiDung;
        TrangThaiBot = trangThaiBot;
        ThoiGian = thoiGian;
    }

    public int getNhatKyChatID() {
        return NhatKyChatID;
    }

    public void setNhatKyChatID(int nhatKyChatID) {
        NhatKyChatID = nhatKyChatID;
    }

    public int getAccountID() {
        return AccountID;
    }

    public void setAccountID(int accountID) {
        AccountID = accountID;
    }

    public String getKenh() {
        return Kenh;
    }

    public void setKenh(String kenh) {
        Kenh = kenh;
    }

    public int getTurnSo() {
        return TurnSo;
    }

    public void setTurnSo(int turnSo) {
        TurnSo = turnSo;
    }

    public String getVaiTro() {
        return VaiTro;
    }

    public void setVaiTro(String vaiTro) {
        VaiTro = vaiTro;
    }

    public String getNoiDung() {
        return NoiDung;
    }

    public void setNoiDung(String noiDung) {
        NoiDung = noiDung;
    }

    public String getTrangThaiBot() {
        return TrangThaiBot;
    }

    public void setTrangThaiBot(String trangThaiBot) {
        TrangThaiBot = trangThaiBot;
    }

    public Date getThoiGian() {
        return ThoiGian;
    }

    public void setThoiGian(Date thoiGian) {
        ThoiGian = thoiGian;
    }

    @Override
    public String toString() {
        return "NhatKyChat{" +
                "NhatKyChatID=" + NhatKyChatID +
                ", AccountID=" + AccountID +
                ", Kenh='" + Kenh + '\'' +
                ", TurnSo=" + TurnSo +
                ", VaiTro='" + VaiTro + '\'' +
                ", NoiDung='" + NoiDung + '\'' +
                ", TrangThaiBot='" + TrangThaiBot + '\'' +
                ", ThoiGian=" + ThoiGian +
                '}';
    }
}

