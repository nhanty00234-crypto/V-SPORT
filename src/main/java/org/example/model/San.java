package org.example.model;

import jakarta.persistence.*;

@Entity
@Table(name = "San")
public class San {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "SanID")
    private int sanID;

    @Column(name = "TenSan")
    private String tenSan;

    @Column(name = "LoaiSanID")
    private int loaiSanID;

    @Column(name = "CoSoID")
    private int coSoID;

    @Column(name = "TrangThai")
    private String trangThai;

    @Column(name = "MoTa")
    private String moTa;

    @Column(name = "HinhAnh")
    private String hinhAnh;

    public San(int sanID, String tenSan, int loaiSanID, int coSoID, String trangThai, String moTa, String hinhAnh) {
        this.sanID = sanID;
        this.tenSan = tenSan;
        this.loaiSanID = loaiSanID;
        this.coSoID = coSoID;
        this.trangThai = trangThai;
        this.moTa = moTa;
        this.hinhAnh = hinhAnh;
    }

    public San() {
    }

    public int getSanID() {
        return sanID;
    }

    public void setSanID(int sanID) {
        this.sanID = sanID;
    }

    public String getTenSan() {
        return tenSan;
    }

    public void setTenSan(String tenSan) {
        this.tenSan = tenSan;
    }

    public int getLoaiSanID() {
        return loaiSanID;
    }

    public void setLoaiSanID(int loaiSanID) {
        this.loaiSanID = loaiSanID;
    }

    public int getCoSoID() {
        return coSoID;
    }

    public void setCoSoID(int coSoID) {
        this.coSoID = coSoID;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public String getMoTa() {
        return moTa;
    }

    public void setMoTa(String moTa) {
        this.moTa = moTa;
    }

    public String getHinhAnh() {
        return hinhAnh;
    }

    public void setHinhAnh(String hinhAnh) {
        this.hinhAnh = hinhAnh;
    }

    @Override
    public String toString() {
        return "San{" +
                "sanID=" + sanID +
                ", tenSan='" + tenSan + '\'' +
                ", loaiSanID=" + loaiSanID +
                ", coSoID=" + coSoID +
                ", trangThai='" + trangThai + '\'' +
                ", moTa='" + moTa + '\'' +
                ", hinhAnh='" + hinhAnh + '\'' +
                '}';
    }
}
