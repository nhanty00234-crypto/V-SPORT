package org.example.model;

public class ChiTietGhepKeo {
    private int chiTietKeoId;
    private int keoId;
    private int accountIdNguoiThamGia;
    private String trangThaiThamGia;
    private String viTriThamGia;


    public ChiTietGhepKeo() {
    }

    public ChiTietGhepKeo(int chiTietKeoId, int keoId, int accountIdNguoiThamGia, String trangThaiThamGia, String viTriThamGia) {
        this.chiTietKeoId = chiTietKeoId;
        this.keoId = keoId;
        this.accountIdNguoiThamGia = accountIdNguoiThamGia;
        this.trangThaiThamGia = trangThaiThamGia;
        this.viTriThamGia = viTriThamGia;
    }

    public int getChiTietKeoId() {
        return chiTietKeoId;
    }

    public void setChiTietKeoId(int chiTietKeoId) {
        this.chiTietKeoId = chiTietKeoId;
    }

    public int getKeoId() {
        return keoId;
    }

    public void setKeoId(int keoId) {
        this.keoId = keoId;
    }

    public int getAccountIdNguoiThamGia() {
        return accountIdNguoiThamGia;
    }

    public void setAccountIdNguoiThamGia(int accountIdNguoiThamGia) {
        this.accountIdNguoiThamGia = accountIdNguoiThamGia;
    }

    public String getTrangThaiThamGia() {
        return trangThaiThamGia;
    }

    public void setTrangThaiThamGia(String trangThaiThamGia) {
        this.trangThaiThamGia = trangThaiThamGia;
    }

    public String getViTriThamGia() {
        return viTriThamGia;
    }

    public void setViTriThamGia(String viTriThamGia) {
        this.viTriThamGia = viTriThamGia;
    }


    @Override
    public String toString() {
        return "ChiTietGhepKeo{" +
                "chiTietKeoId=" + chiTietKeoId +
                ", keoId=" + keoId +
                ", accountIdNguoiThamGia=" + accountIdNguoiThamGia +
                ", trangThaiThamGia='" + trangThaiThamGia + '\'' +
                ", viTriThamGia='" + viTriThamGia + '\'' +
                '}';
    }
}

