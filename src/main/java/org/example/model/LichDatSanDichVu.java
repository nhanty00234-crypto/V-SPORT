package org.example.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Dịch vụ khách đặt trước cùng lúc đặt sân (Phase 8A).
 * Tách biệt hoàn toàn khỏi HoaDon/ChiTietHoaDon — chỉ là checklist "khách muốn gì",
 * không đụng tồn kho, không đụng kế toán. Thanh toán tại quầy.
 */
@Entity
@Table(name = "LichDatSan_DichVu")
public class LichDatSanDichVu {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private int id;

    @Column(name = "DatSanID", nullable = false)
    private int datSanId;

    @Column(name = "SanPhamID", nullable = false)
    private int sanPhamId;

    @Column(name = "Quantity", nullable = false)
    private int quantity;

    @Column(name = "UnitPrice", nullable = false)
    private BigDecimal unitPrice;

    @Column(name = "TotalPrice", nullable = false)
    private BigDecimal totalPrice;

    @Column(name = "Status", length = 50)
    private String status;

    @Column(name = "Note", length = 255)
    private String note;

    @Column(name = "CreatedAt", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "DeliveredAt")
    private LocalDateTime deliveredAt;

    @Column(name = "DeliveredBy")
    private Integer deliveredBy;

    // Không map trong DB — chỉ dùng để render (JOIN thủ công ở tầng DAO/servlet)
    @Transient
    private String tenSanPham;
    @Transient
    private String donViTinh;

    public LichDatSanDichVu() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getDatSanId() { return datSanId; }
    public void setDatSanId(int datSanId) { this.datSanId = datSanId; }

    public int getSanPhamId() { return sanPhamId; }
    public void setSanPhamId(int sanPhamId) { this.sanPhamId = sanPhamId; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }

    public BigDecimal getTotalPrice() { return totalPrice; }
    public void setTotalPrice(BigDecimal totalPrice) { this.totalPrice = totalPrice; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getDeliveredAt() { return deliveredAt; }
    public void setDeliveredAt(LocalDateTime deliveredAt) { this.deliveredAt = deliveredAt; }

    public Integer getDeliveredBy() { return deliveredBy; }
    public void setDeliveredBy(Integer deliveredBy) { this.deliveredBy = deliveredBy; }

    public String getTenSanPham() { return tenSanPham; }
    public void setTenSanPham(String tenSanPham) { this.tenSanPham = tenSanPham; }

    public String getDonViTinh() { return donViTinh; }
    public void setDonViTinh(String donViTinh) { this.donViTinh = donViTinh; }
}
