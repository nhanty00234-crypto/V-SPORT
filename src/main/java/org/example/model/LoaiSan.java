package org.example.model;

import jakarta.persistence.*;
import java.time.LocalTime;

@Entity
@Table(name = "LoaiSan")
public class LoaiSan {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "LoaiSanID")
    private int loaiSanID;

    @Column(name = "MonTheThaoID")
    private int monTheThaoID;

    @Column(name = "TenLoai")
    private String tenLoai;

    @Column(name = "GiaKhongDen")
    private double giaKhongDen;

    @Column(name = "GiaCoDen")
    private double giaCoDen;

    @Column(name = "GioBatDauLenDen")
    private LocalTime gioBatDauLenDen;

    @Column(name = "GioKetThucLenDen")
    private LocalTime gioKetThucLenDen;

    @Column(name = "CoSoID")
    private Integer coSoID;

    public LoaiSan(int loaiSanID, int monTheThaoID, String tenLoai, double giaKhongDen, double giaCoDen, LocalTime gioBatDauLenDen) {
        this.loaiSanID = loaiSanID;
        this.monTheThaoID = monTheThaoID;
        this.tenLoai = tenLoai;
        this.giaKhongDen = giaKhongDen;
        this.giaCoDen = giaCoDen;
        this.gioBatDauLenDen = gioBatDauLenDen;
    }

    public LoaiSan(int loaiSanID, int monTheThaoID, String tenLoai, double giaKhongDen, double giaCoDen, LocalTime gioBatDauLenDen, Integer coSoID) {
        this.loaiSanID = loaiSanID;
        this.monTheThaoID = monTheThaoID;
        this.tenLoai = tenLoai;
        this.giaKhongDen = giaKhongDen;
        this.giaCoDen = giaCoDen;
        this.gioBatDauLenDen = gioBatDauLenDen;
        this.coSoID = coSoID;
    }

    public LoaiSan(int loaiSanID, int monTheThaoID, String tenLoai, double giaKhongDen, double giaCoDen, LocalTime gioBatDauLenDen, LocalTime gioKetThucLenDen, Integer coSoID) {
        this.loaiSanID = loaiSanID;
        this.monTheThaoID = monTheThaoID;
        this.tenLoai = tenLoai;
        this.giaKhongDen = giaKhongDen;
        this.giaCoDen = giaCoDen;
        this.gioBatDauLenDen = gioBatDauLenDen;
        this.gioKetThucLenDen = gioKetThucLenDen;
        this.coSoID = coSoID;
    }

    public LoaiSan() {
    }

    public int getLoaiSanID() {
        return loaiSanID;
    }

    public void setLoaiSanID(int loaiSanID) {
        this.loaiSanID = loaiSanID;
    }

    public int getMonTheThaoID() {
        return monTheThaoID;
    }

    public void setMonTheThaoID(int monTheThaoID) {
        this.monTheThaoID = monTheThaoID;
    }

    public String getTenLoai() {
        return tenLoai;
    }

    public void setTenLoai(String tenLoai) {
        this.tenLoai = tenLoai;
    }

    public double getGiaKhongDen() {
        return giaKhongDen;
    }

    public void setGiaKhongDen(double giaKhongDen) {
        this.giaKhongDen = giaKhongDen;
    }

    public double getGiaCoDen() {
        return giaCoDen;
    }

    public void setGiaCoDen(double giaCoDen) {
        this.giaCoDen = giaCoDen;
    }

    public LocalTime getGioBatDauLenDen() {
        return gioBatDauLenDen;
    }

    public void setGioBatDauLenDen(LocalTime gioBatDauLenDen) {
        this.gioBatDauLenDen = gioBatDauLenDen;
    }

    public LocalTime getGioKetThucLenDen() {
        return gioKetThucLenDen;
    }

    public void setGioKetThucLenDen(LocalTime gioKetThucLenDen) {
        this.gioKetThucLenDen = gioKetThucLenDen;
    }

    public Integer getCoSoID() {
        return coSoID;
    }

    public void setCoSoID(Integer coSoID) {
        this.coSoID = coSoID;
    }

    @Override
    public String toString() {
        return "LoaiSan{" +
                "loaiSanID=" + loaiSanID +
                ", monTheThaoID=" + monTheThaoID +
                ", tenLoai='" + tenLoai + '\'' +
                ", giaKhongDen=" + giaKhongDen +
                ", giaCoDen=" + giaCoDen +
                ", gioBatDauLenDen=" + gioBatDauLenDen +
                ", gioKetThucLenDen=" + gioKetThucLenDen +
                ", coSoID=" + coSoID +
                '}';
    }
}
