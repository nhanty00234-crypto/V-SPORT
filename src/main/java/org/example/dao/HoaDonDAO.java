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
}