package org.example.model;

import java.time.LocalDateTime;

/**
 * Một ảnh trong gallery của một chương trình khuyến mãi (KhuyenMai). Ánh xạ thuần JDBC
 * tới bảng KhuyenMaiHinhAnh (không dùng Hibernate) — cùng phong cách với KhuyenMai.
 * DuongDan chỉ lưu đường dẫn tương đối dùng để build publicUrl, không phải filesystem path.
 */
public class KhuyenMaiHinhAnh {

    private int hinhAnhId;
    private int khuyenMaiId;
    private String duongDan;
    private String tenFileGoc;
    private String mimeType;
    private Long dungLuong;
    private Integer chieuRong;
    private Integer chieuCao;
    private int thuTu;
    private boolean laAnhBia;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public int getHinhAnhId() {
        return hinhAnhId;
    }

    public void setHinhAnhId(int hinhAnhId) {
        this.hinhAnhId = hinhAnhId;
    }

    public int getKhuyenMaiId() {
        return khuyenMaiId;
    }

    public void setKhuyenMaiId(int khuyenMaiId) {
        this.khuyenMaiId = khuyenMaiId;
    }

    public String getDuongDan() {
        return duongDan;
    }

    public void setDuongDan(String duongDan) {
        this.duongDan = duongDan;
    }

    public String getTenFileGoc() {
        return tenFileGoc;
    }

    public void setTenFileGoc(String tenFileGoc) {
        this.tenFileGoc = tenFileGoc;
    }

    public String getMimeType() {
        return mimeType;
    }

    public void setMimeType(String mimeType) {
        this.mimeType = mimeType;
    }

    public Long getDungLuong() {
        return dungLuong;
    }

    public void setDungLuong(Long dungLuong) {
        this.dungLuong = dungLuong;
    }

    public Integer getChieuRong() {
        return chieuRong;
    }

    public void setChieuRong(Integer chieuRong) {
        this.chieuRong = chieuRong;
    }

    public Integer getChieuCao() {
        return chieuCao;
    }

    public void setChieuCao(Integer chieuCao) {
        this.chieuCao = chieuCao;
    }

    public int getThuTu() {
        return thuTu;
    }

    public void setThuTu(int thuTu) {
        this.thuTu = thuTu;
    }

    public boolean isLaAnhBia() {
        return laAnhBia;
    }

    public void setLaAnhBia(boolean laAnhBia) {
        this.laAnhBia = laAnhBia;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
