package org.example.dao;

import org.example.model.ChiTietHoaDon;
import org.example.model.HoaDon;
import org.example.model.Hoantien;

import java.math.BigDecimal;
import java.util.List;

public interface HoaDonDAO {
    BigDecimal getRevenueToday();
    long countOrdersToday();
    List<HoaDon> getRecentInvoices(int limit);

    List<HoaDon> getAllHoaDon();
    HoaDon getHoaDonById(int id);
    boolean updateHoaDon(HoaDon hd);
    List<Hoantien> getAllHoanTien();
    Hoantien getHoanTienById(int id);
    boolean updateHoanTien(Hoantien ht);
    List<ChiTietHoaDon> getChiTietByHoaDonId(int hoaDonId);
    BigDecimal getTotalDoanhThu();
    BigDecimal getRevenueTodayByCoSo(int coSoId);
    long countOrdersTodayByCoSo(int coSoId);
    List<HoaDon> getRecentInvoicesByCoSo(int coSoId, int limit);
    BigDecimal getTotalDoanhThuByCoSo(int coSoId);

    /**
     * Tra HoaDonID của hóa đơn MAIN (không phải bill tách dịch vụ) theo DatSanID.
     * Trả về null nếu chưa có hóa đơn nào được khởi tạo cho đơn đặt sân này.
     */
    Integer getMainHoaDonIdByDatSanId(int datSanId);

    /**
     * Danh sách HoaDonID của các hóa đơn tách dịch vụ (LoaiHoaDon = 'SPLIT') có ParentHoaDonID
     * trỏ về hóa đơn chính này. Dùng để hiển thị liên kết "hóa đơn tách" trên bill in.
     */
    List<Integer> getSplitHoaDonIdsByParent(int parentHoaDonId);
}