package org.example.model;

public class GhepKeo {
    private int keoId;
    private int datSanId;
    private int accountIdNguoiTao;
    private Integer monTheThaoId;
    private String moTa;
    private String trinhDo;
    private String trangThai;

    public GhepKeo() {
    }

    public GhepKeo(int keoId, int datSanId, int accountIdNguoiTao, Integer monTheThaoId, String moTa, String trinhDo, String trangThai) {
        this.keoId = keoId;
        this.datSanId = datSanId;
        this.accountIdNguoiTao = accountIdNguoiTao;
        this.monTheThaoId = monTheThaoId;
        this.moTa = moTa;
        this.trinhDo = trinhDo;
        this.trangThai = trangThai;
    }

    public int getKeoId() {
        return keoId;
    }

    public void setKeoId(int keoId) {
        this.keoId = keoId;
    }

    public int getDatSanId() {
        return datSanId;
    }

    public void setDatSanId(int datSanId) {
        this.datSanId = datSanId;
    }

    public int getAccountIdNguoiTao() {
        return accountIdNguoiTao;
    }

    public void setAccountIdNguoiTao(int accountIdNguoiTao) {
        this.accountIdNguoiTao = accountIdNguoiTao;
    }

    public Integer getMonTheThaoId() {
        return monTheThaoId;
    }

    public void setMonTheThaoId(Integer monTheThaoId) {
        this.monTheThaoId = monTheThaoId;
    }

    public String getMoTa() {
        return moTa;
    }

    public void setMoTa(String moTa) {
        this.moTa = moTa;
    }

    public String getTrinhDo() {
        return trinhDo;
    }

    public void setTrinhDo(String trinhDo) {
        this.trinhDo = trinhDo;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    @Override
    public String toString() {
        return "GhepKeo{" +
                "keoId=" + keoId +
                ", datSanId=" + datSanId +
                ", accountIdNguoiTao=" + accountIdNguoiTao +
                ", monTheThaoId=" + monTheThaoId +
                ", moTa='" + moTa + '\'' +
                ", trinhDo='" + trinhDo + '\'' +
                ", trangThai='" + trangThai + '\'' +
                '}';
    }
}

