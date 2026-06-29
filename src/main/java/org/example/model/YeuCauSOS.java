package org.example.model;

import java.util.Date;

public class YeuCauSOS {
    private int yeuCauSosId;
    private int accountIdTao;
    private int datSanId;
    private int monTheThaoId;
    private int soNguoiCanTuyen;
    private String viTriCanTuyen;
    private String ghiChu;
    private String trangThai;
    private Date thoiGianTao;

    public YeuCauSOS() {
    }

    public YeuCauSOS(int yeuCauSosId, int accountIdTao, int datSanId, int monTheThaoId, int soNguoiCanTuyen, String viTriCanTuyen, String ghiChu, String trangThai, Date thoiGianTao) {
        this.yeuCauSosId = yeuCauSosId;
        this.accountIdTao = accountIdTao;
        this.datSanId = datSanId;
        this.monTheThaoId = monTheThaoId;
        this.soNguoiCanTuyen = soNguoiCanTuyen;
        this.viTriCanTuyen = viTriCanTuyen;
        this.ghiChu = ghiChu;
        this.trangThai = trangThai;
        this.thoiGianTao = thoiGianTao;
    }

    public int getYeuCauSosId() {
        return yeuCauSosId;
    }

    public void setYeuCauSosId(int yeuCauSosId) {
        this.yeuCauSosId = yeuCauSosId;
    }

    public int getAccountIdTao() {
        return accountIdTao;
    }

    public void setAccountIdTao(int accountIdTao) {
        this.accountIdTao = accountIdTao;
    }

    public int getDatSanId() {
        return datSanId;
    }

    public void setDatSanId(int datSanId) {
        this.datSanId = datSanId;
    }

    public int getMonTheThaoId() {
        return monTheThaoId;
    }

    public void setMonTheThaoId(int monTheThaoId) {
        this.monTheThaoId = monTheThaoId;
    }

    public int getSoNguoiCanTuyen() {
        return soNguoiCanTuyen;
    }

    public void setSoNguoiCanTuyen(int soNguoiCanTuyen) {
        this.soNguoiCanTuyen = soNguoiCanTuyen;
    }

    public String getViTriCanTuyen() {
        return viTriCanTuyen;
    }

    public void setViTriCanTuyen(String viTriCanTuyen) {
        this.viTriCanTuyen = viTriCanTuyen;
    }

    public String getGhiChu() {
        return ghiChu;
    }

    public void setGhiChu(String ghiChu) {
        this.ghiChu = ghiChu;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public Date getThoiGianTao() {
        return thoiGianTao;
    }

    public void setThoiGianTao(Date thoiGianTao) {
        this.thoiGianTao = thoiGianTao;
    }

    @Override
    public String toString() {
        return "YeuCauSOS{" +
                "yeuCauSosId=" + yeuCauSosId +
                ", accountIdTao=" + accountIdTao +
                ", datSanId=" + datSanId +
                ", monTheThaoId=" + monTheThaoId +
                ", soNguoiCanTuyen=" + soNguoiCanTuyen +
                ", viTriCanTuyen='" + viTriCanTuyen + '\'' +
                ", ghiChu='" + ghiChu + '\'' +
                ", trangThai='" + trangThai + '\'' +
                ", thoiGianTao=" + thoiGianTao +
                '}';
    }
}

