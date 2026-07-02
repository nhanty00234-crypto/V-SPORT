package org.example.dao.impl;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import org.example.dao.CoSoDAO;
import org.example.model.CoSo;
import org.example.model.LoaiSan;
import org.example.model.MonTheThao;
import org.example.model.San;
import org.example.util.JPAUtil;

import java.util.List;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class CoSoDAOImpl implements CoSoDAO {

    private static final Logger logger = LogManager.getLogger(CoSoDAOImpl.class);

    @Override
    public List<CoSo> getAllCoSo() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT c FROM CoSo c", CoSo.class).getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public CoSo getCoSoById(int id) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.find(CoSo.class, id);
        } finally {
            em.close();
        }
    }

    @Override
    public boolean addCoSo(CoSo coSo) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.persist(coSo);
            // Flush to get the generated CoSoID
            em.flush();

            // autoGenerateCourts(coSo, em);

            trans.commit();
            return true;
        } catch (Exception e) {
            if (trans.isActive())
                trans.rollback();
            logger.error("Lỗi khi thêm cơ sở mới: {}", e.getMessage(), e);
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean updateCoSo(CoSo coSo) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            CoSo updatedCoSo = em.merge(coSo);

            // Check if this branch has any courts. If not, auto-generate.
            // Long count = em.createQuery("SELECT COUNT(s) FROM San s WHERE s.coSoID =
            // :id", Long.class)
            // .setParameter("id", updatedCoSo.getCoSoID())
            // .getSingleResult();

            // if (count == 0) {
            // autoGenerateCourts(updatedCoSo, em);
            // }

            trans.commit();
            return true;
        } catch (Exception e) {
            if (trans.isActive())
                trans.rollback();
            logger.error("Lỗi khi cập nhật cơ sở ID {}: {}", coSo.getCoSoID(), e.getMessage(), e);
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean deleteCoSo(int id) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            // Check if branch exists first using a count native query to be safe
            Number count = (Number) em.createNativeQuery("SELECT COUNT(*) FROM CoSo WHERE CoSoID = ?")
                    .setParameter(1, id)
                    .getSingleResult();

            if (count != null && count.intValue() > 0) {
                // 0. Get the manager account ID first to delete it robustly later
                Integer managerAccountId = null;
                try {
                    Object managerIdObj = em.createNativeQuery("SELECT AccountID_QuanLy FROM CoSo WHERE CoSoID = ?")
                            .setParameter(1, id)
                            .getSingleResult();
                    if (managerIdObj != null) {
                        managerAccountId = ((Number) managerIdObj).intValue();
                    }
                } catch (Exception ex) {
                    // Ignore if no manager found or multiple/none
                }

                // 1. Break circular dependency first
                em.createNativeQuery("UPDATE CoSo SET AccountID_QuanLy = NULL WHERE CoSoID = ?")
                        .setParameter(1, id)
                        .executeUpdate();

                // 2. Clean up bookings referencing courts of this branch
                em.createNativeQuery("DELETE FROM LichDatSan WHERE SanID IN (SELECT SanID FROM San WHERE CoSoID = ?)")
                        .setParameter(1, id)
                        .executeUpdate();

                // 3. SOS requests
                em.createNativeQuery("DELETE FROM NhatKySOSGui WHERE YeuCauSOSID IN (SELECT YeuCauSOSID FROM YeuCauSOS WHERE DatSanID IN (SELECT DatSanID FROM LichDatSan WHERE SanID IN (SELECT SanID FROM San WHERE CoSoID = ?)))")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM YeuCauSOS WHERE DatSanID IN (SELECT DatSanID FROM LichDatSan WHERE SanID IN (SELECT SanID FROM San WHERE CoSoID = ?))")
                        .setParameter(1, id)
                        .executeUpdate();

                // 4. Matchmaking
                em.createNativeQuery("DELETE FROM ChiTietGhepKeo WHERE KeoID IN (SELECT KeoID FROM GhepKeo WHERE DatSanID IN (SELECT DatSanID FROM LichDatSan WHERE SanID IN (SELECT SanID FROM San WHERE CoSoID = ?)))")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM GhepKeo WHERE DatSanID IN (SELECT DatSanID FROM LichDatSan WHERE SanID IN (SELECT SanID FROM San WHERE CoSoID = ?))")
                        .setParameter(1, id)
                        .executeUpdate();

                // 5. Reviews
                em.createNativeQuery("DELETE FROM DanhGia WHERE DatSanID IN (SELECT DatSanID FROM LichDatSan WHERE SanID IN (SELECT SanID FROM San WHERE CoSoID = ?))")
                        .setParameter(1, id)
                        .executeUpdate();

                // 6. ELO
                em.createNativeQuery("DELETE FROM LichSuELO WHERE DatSanID IN (SELECT DatSanID FROM LichDatSan WHERE SanID IN (SELECT SanID FROM San WHERE CoSoID = ?))")
                        .setParameter(1, id)
                        .executeUpdate();

                // 7. Parking card logs for bookings
                em.createNativeQuery("DELETE FROM LichXeRaVao WHERE DatSanID IN (SELECT DatSanID FROM LichDatSan WHERE SanID IN (SELECT SanID FROM San WHERE CoSoID = ?))")
                        .setParameter(1, id)
                        .executeUpdate();

                // 8. Invoices
                em.createNativeQuery("DELETE FROM ChiTietHoaDon WHERE HoaDonID IN (SELECT HoaDonID FROM HoaDon WHERE DatSanID IN (SELECT DatSanID FROM LichDatSan WHERE SanID IN (SELECT SanID FROM San WHERE CoSoID = ?)))")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM HoanTien WHERE HoaDonID IN (SELECT HoaDonID FROM HoaDon WHERE DatSanID IN (SELECT DatSanID FROM LichDatSan WHERE SanID IN (SELECT SanID FROM San WHERE CoSoID = ?)))")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM HoaDon WHERE DatSanID IN (SELECT DatSanID FROM LichDatSan WHERE SanID IN (SELECT SanID FROM San WHERE CoSoID = ?))")
                        .setParameter(1, id)
                        .executeUpdate();

                // 9. Courts
                em.createNativeQuery("DELETE FROM San WHERE CoSoID = ?")
                        .setParameter(1, id)
                        .executeUpdate();

                // 10. Court Types
                em.createNativeQuery("DELETE FROM LoaiSan WHERE CoSoID = ?")
                        .setParameter(1, id)
                        .executeUpdate();

                // 11. Products and Services
                em.createNativeQuery("DELETE FROM ChiTietHoaDon WHERE SanPhamID IN (SELECT SanPhamID FROM SanPham_DichVu WHERE CoSoID = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM SanPham_DichVu WHERE CoSoID = ?")
                        .setParameter(1, id)
                        .executeUpdate();

                // 12. Parking Cards
                em.createNativeQuery("DELETE FROM LichXeRaVao WHERE TheID IN (SELECT TheID FROM TheGiuXe WHERE CoSoID = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM TheGiuXe WHERE CoSoID = ?")
                        .setParameter(1, id)
                        .executeUpdate();

                // 13. Promo Codes
                em.createNativeQuery("DELETE FROM KhuyenMai WHERE CoSoID = ?")
                        .setParameter(1, id)
                        .executeUpdate();

                // 14. Accounts references cleanup
                em.createNativeQuery("UPDATE CoSo SET AccountID_QuanLy = NULL WHERE AccountID_QuanLy IN (SELECT AccountID FROM Accounts WHERE CoSoID = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM CaLamViec WHERE CoSoID = ? OR AccountID IN (SELECT AccountID FROM Accounts WHERE CoSoID = ?)")
                        .setParameter(1, id)
                        .setParameter(2, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM MonTheThaoYeuThich WHERE AccountID IN (SELECT AccountID FROM Accounts WHERE CoSoID = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM NhatKyChat WHERE AccountID IN (SELECT AccountID FROM Accounts WHERE CoSoID = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM ThongBao WHERE AccountID IN (SELECT AccountID FROM Accounts WHERE CoSoID = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM LichXeRaVao WHERE AccountID_NhanVien IN (SELECT AccountID FROM Accounts WHERE CoSoID = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("UPDATE HoaDon SET AccountID_NhanVien = NULL WHERE AccountID_NhanVien IN (SELECT AccountID FROM Accounts WHERE CoSoID = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("UPDATE HoaDon SET AccountID_KhachHang = NULL WHERE AccountID_KhachHang IN (SELECT AccountID FROM Accounts WHERE CoSoID = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM LichSuELO WHERE AccountID IN (SELECT AccountID FROM Accounts WHERE CoSoID = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM HoanTien WHERE AccountID IN (SELECT AccountID FROM Accounts WHERE CoSoID = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM DanhGia WHERE AccountID_NguoiDanhGia IN (SELECT AccountID FROM Accounts WHERE CoSoID = ?) OR AccountID_NguoiBiDanhGia IN (SELECT AccountID FROM Accounts WHERE CoSoID = ?)")
                        .setParameter(1, id)
                        .setParameter(2, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM NhatKySOSGui WHERE AccountID_NhanGui IN (SELECT AccountID FROM Accounts WHERE CoSoID = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM YeuCauSOS WHERE AccountID_Tao IN (SELECT AccountID FROM Accounts WHERE CoSoID = ?)")
                        .setParameter(1, id)
                        .executeUpdate();

                // 15. Delete Accounts associated with the branch
                em.createNativeQuery("DELETE FROM Accounts WHERE CoSoID = ?")
                        .setParameter(1, id)
                        .executeUpdate();
                if (managerAccountId != null) {
                    em.createNativeQuery("DELETE FROM Accounts WHERE AccountID = ?")
                            .setParameter(1, managerAccountId)
                            .executeUpdate();
                }

                // 16. Finally delete the branch itself
                em.createNativeQuery("DELETE FROM CoSo WHERE CoSoID = ?")
                        .setParameter(1, id)
                        .executeUpdate();

                trans.commit();
                return true;
            }
            return false;
        } catch (Exception e) {
            if (trans.isActive())
                trans.rollback();
            logger.error("Lỗi khi xóa cơ sở ID {}: {}", id, e.getMessage(), e);
            return false;
        } finally {
            em.close();
        }
    }

    private void autoGenerateCourts(CoSo coSo, EntityManager em) {
        String loaiHinh = coSo.getLoaiHinhKinhDoanh();
        if (loaiHinh == null || loaiHinh.isEmpty())
            return;

        int totalCourts = coSo.getSoLuongSanDuKien();
        if (totalCourts <= 0)
            return;

        String[] sports = loaiHinh.split(", ");
        if (sports.length == 0)
            return;

        int courtsPerSport = totalCourts / sports.length;
        int remainder = totalCourts % sports.length;

        for (int i = 0; i < sports.length; i++) {
            String sportName = sports[i].trim();
            Integer loaiSanId = findLoaiSanIdBySportName(sportName, em);
            if (loaiSanId == null)
                continue;

            int countForThisSport = courtsPerSport + (i < remainder ? 1 : 0);
            for (int j = 1; j <= countForThisSport; j++) {
                San san = new San();
                san.setCoSoID(coSo.getCoSoID());
                san.setLoaiSanID(loaiSanId);
                san.setTenSan(sportName + " " + (j < 10 ? "0" + j : j));
                san.setTrangThai("Sẵn sàng");
                san.setMoTa("Sân tự động tạo từ cấu hình Cơ Sở " + coSo.getTenCoSo());
                em.persist(san);
            }
        }
    }

    private Integer findLoaiSanIdBySportName(String sportName, EntityManager em) {
        try {
            // Find MonTheThao first using TenMon field
            List<MonTheThao> mList = em
                    .createQuery("SELECT m FROM MonTheThao m WHERE m.TenMon = :name", MonTheThao.class)
                    .setParameter("name", sportName)
                    .getResultList();
            if (mList.isEmpty())
                return null;
            int monId = mList.get(0).getMonTheThaoID();

            // Then find first LoaiSan for this monId
            List<LoaiSan> lList = em.createQuery("SELECT l FROM LoaiSan l WHERE l.monTheThaoID = :monId", LoaiSan.class)
                    .setParameter("monId", monId)
                    .getResultList();
            if (lList.isEmpty())
                return null;
            return lList.get(0).getLoaiSanID();
        } catch (Exception e) {
            return null;
        }
    }
}
