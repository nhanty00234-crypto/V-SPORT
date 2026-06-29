package org.example.model;

import jakarta.persistence.*;

@Entity
@Table(name = "DanhMucSanPham")
public class DanhMucSanPham {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "DanhMucID")
    private int DanhMucID;

    @Column(name = "TenDanhMuc", nullable = false, length = 100)
    private String TenDanhMuc;

    public DanhMucSanPham(int danhMucID, String tenDanhMuc) {
        this.DanhMucID = danhMucID;
        this.TenDanhMuc = tenDanhMuc;
    }

    public DanhMucSanPham() {
    }

    public int getDanhMucID() {
        return DanhMucID;
    }

    public void setDanhMucID(int danhMucID) {
        this.DanhMucID = danhMucID;
    }

    public String getTenDanhMuc() {
        return TenDanhMuc;
    }

    public void setTenDanhMuc(String tenDanhMuc) {
        this.TenDanhMuc = tenDanhMuc;
    }

    @Override
    public String toString() {
        return "DanhMucSanPham{" +
                "DanhMucID=" + DanhMucID +
                ", TenDanhMuc='" + TenDanhMuc + '\'' +
                '}';
    }
}
