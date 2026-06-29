package org.example.model;

import java.util.Date;

/**
 * Model đại diện cho đơn đặt sân
 */
public class DatSan {
    private int maDatSan;
    private int maSan;
    private int maTaiKhoan;
    private Date ngayDat;
    private String caBatDau;
    private String caKetThuc;
    private double tongTien;
    private int trangThai; // 0: chờ, 1: đã thanh toán, 2: đã hủy
    private Date ngayTao;
    private Date ngayCapNhat;

    // Constructors
    public DatSan() {
    }

    public DatSan(int maSan, int maTaiKhoan, Date ngayDat, String caBatDau, String caKetThuc, double tongTien) {
        this.maSan = maSan;
        this.maTaiKhoan = maTaiKhoan;
        this.ngayDat = ngayDat;
        this.caBatDau = caBatDau;
        this.caKetThuc = caKetThuc;
        this.tongTien = tongTien;
    }

    // Getters and Setters
    public int getMaDatSan() {
        return maDatSan;
    }

    public void setMaDatSan(int maDatSan) {
        this.maDatSan = maDatSan;
    }

    public int getMaSan() {
        return maSan;
    }

    public void setMaSan(int maSan) {
        this.maSan = maSan;
    }

    public int getMaTaiKhoan() {
        return maTaiKhoan;
    }

    public void setMaTaiKhoan(int maTaiKhoan) {
        this.maTaiKhoan = maTaiKhoan;
    }

    public Date getNgayDat() {
        return ngayDat;
    }

    public void setNgayDat(Date ngayDat) {
        this.ngayDat = ngayDat;
    }

    public String getCaBatDau() {
        return caBatDau;
    }

    public void setCaBatDau(String caBatDau) {
        this.caBatDau = caBatDau;
    }

    public String getCaKetThuc() {
        return caKetThuc;
    }

    public void setCaKetThuc(String caKetThuc) {
        this.caKetThuc = caKetThuc;
    }

    public double getTongTien() {
        return tongTien;
    }

    public void setTongTien(double tongTien) {
        this.tongTien = tongTien;
    }

    public int getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(int trangThai) {
        this.trangThai = trangThai;
    }

    public Date getNgayTao() {
        return ngayTao;
    }

    public void setNgayTao(Date ngayTao) {
        this.ngayTao = ngayTao;
    }

    public Date getNgayCapNhat() {
        return ngayCapNhat;
    }

    public void setNgayCapNhat(Date ngayCapNhat) {
        this.ngayCapNhat = ngayCapNhat;
    }
}