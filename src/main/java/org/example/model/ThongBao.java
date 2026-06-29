package org.example.model;

import java.util.Date;

public class ThongBao {
    private int thongBaoId;
    private int accountId;
    private String tieuDe;
    private String noiDung;
    private String loaiThongBao;
    private boolean daDoc;
    private Date thoiGianGui;
    private String maBanGhi;
    private String duongDan;

    public ThongBao() {
    }

    public ThongBao(int thongBaoId, int accountId, String tieuDe, String noiDung, String loaiThongBao, boolean daDoc, Date thoiGianGui) {
        this.thongBaoId = thongBaoId;
        this.accountId = accountId;
        this.tieuDe = tieuDe;
        this.noiDung = noiDung;
        this.loaiThongBao = loaiThongBao;
        this.daDoc = daDoc;
        this.thoiGianGui = thoiGianGui;
    }

    public ThongBao(int accountId, String tieuDe, String noiDung, String loaiThongBao) {
        this.accountId = accountId;
        this.tieuDe = tieuDe;
        this.noiDung = noiDung;
        this.loaiThongBao = loaiThongBao;
        this.daDoc = false;
        this.thoiGianGui = new Date();
        this.maBanGhi = "YEU_CAU_NGHI";
        this.duongDan = "/quan-ly/yeu-cau-nghi";
    }

    public int getThongBaoId() {
        return thongBaoId;
    }

    public void setThongBaoId(int thongBaoId) {
        this.thongBaoId = thongBaoId;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public String getTieuDe() {
        return tieuDe;
    }

    public void setTieuDe(String tieuDe) {
        this.tieuDe = tieuDe;
    }

    public String getNoiDung() {
        return noiDung;
    }

    public void setNoiDung(String noiDung) {
        this.noiDung = noiDung;
    }

    public String getLoaiThongBao() {
        return loaiThongBao;
    }

    public void setLoaiThongBao(String loaiThongBao) {
        this.loaiThongBao = loaiThongBao;
    }

    public boolean getDaDoc() {
        return daDoc;
    }

    public void setDaDoc(boolean daDoc) {
        this.daDoc = daDoc;
    }

    public Date getThoiGianGui() {
        return thoiGianGui;
    }

    public void setThoiGianGui(Date thoiGianGui) {
        this.thoiGianGui = thoiGianGui;
    }

    public String getMaBanGhi() {
        return maBanGhi;
    }

    public void setMaBanGhi(String maBanGhi) {
        this.maBanGhi = maBanGhi;
    }

    public String getDuongDan() {
        return duongDan;
    }

    public void setDuongDan(String duongDan) {
        this.duongDan = duongDan;
    }

    @Override
    public String toString() {
        return "ThongBao{" +
                "thongBaoId=" + thongBaoId +
                ", accountId=" + accountId +
                ", tieuDe='" + tieuDe + '\'' +
                ", noiDung='" + noiDung + '\'' +
                ", loaiThongBao='" + loaiThongBao + '\'' +
                ", daDoc=" + daDoc +
                ", thoiGianGui=" + thoiGianGui +
                '}';
    }
}

