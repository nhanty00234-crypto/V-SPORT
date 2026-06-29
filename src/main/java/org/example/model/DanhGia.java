package org.example.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "DanhGia")
public class DanhGia {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "DanhGiaID")
    private int danhGiaId;

    @Column(name = "DatSanID")
    private int datSanId;

    @Column(name = "AccountID_NguoiDanhGia")
    private int accountIdNguoiDanhGia;

    @Column(name = "AccountID_NguoiBiDanhGia")
    private Integer accountIdNguoiBiDanhGia;

    @Column(name = "SoSao")
    private int soSao;

    @Column(name = "BinhLuan", length = 255)
    private String binhLuan;

    @Column(name = "NgayDanhGia")
    private LocalDateTime ngayDanhGia;

    public DanhGia() {
    }

    public DanhGia(int danhGiaId, int datSanId, int accountIdNguoiDanhGia, Integer accountIdNguoiBiDanhGia, int soSao, String binhLuan, LocalDateTime ngayDanhGia) {
        this.danhGiaId = danhGiaId;
        this.datSanId = datSanId;
        this.accountIdNguoiDanhGia = accountIdNguoiDanhGia;
        this.accountIdNguoiBiDanhGia = accountIdNguoiBiDanhGia;
        this.soSao = soSao;
        this.binhLuan = binhLuan;
        this.ngayDanhGia = ngayDanhGia;
    }

    public int getDanhGiaId() {
        return danhGiaId;
    }

    public void setDanhGiaId(int danhGiaId) {
        this.danhGiaId = danhGiaId;
    }

    public int getDatSanId() {
        return datSanId;
    }

    public void setDatSanId(int datSanId) {
        this.datSanId = datSanId;
    }

    public int getAccountIdNguoiDanhGia() {
        return accountIdNguoiDanhGia;
    }

    public void setAccountIdNguoiDanhGia(int accountIdNguoiDanhGia) {
        this.accountIdNguoiDanhGia = accountIdNguoiDanhGia;
    }

    public Integer getAccountIdNguoiBiDanhGia() {
        return accountIdNguoiBiDanhGia;
    }

    public void setAccountIdNguoiBiDanhGia(Integer accountIdNguoiBiDanhGia) {
        this.accountIdNguoiBiDanhGia = accountIdNguoiBiDanhGia;
    }

    public int getSoSao() {
        return soSao;
    }

    public void setSoSao(int soSao) {
        this.soSao = soSao;
    }

    public String getBinhLuan() {
        return binhLuan;
    }

    public void setBinhLuan(String binhLuan) {
        this.binhLuan = binhLuan;
    }

    public LocalDateTime getNgayDanhGia() {
        return ngayDanhGia;
    }

    public void setNgayDanhGia(LocalDateTime ngayDanhGia) {
        this.ngayDanhGia = ngayDanhGia;
    }

    @Override
    public String toString() {
        return "DanhGia{" +
                "danhGiaId=" + danhGiaId +
                ", datSanId=" + datSanId +
                ", accountIdNguoiDanhGia=" + accountIdNguoiDanhGia +
                ", accountIdNguoiBiDanhGia=" + accountIdNguoiBiDanhGia +
                ", soSao=" + soSao +
                ", binhLuan='" + binhLuan + '\'' +
                ", ngayDanhGia=" + ngayDanhGia +
                '}';
    }
}
