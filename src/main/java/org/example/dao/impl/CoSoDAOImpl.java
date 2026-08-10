package org.example.dao.impl;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import org.example.dao.CoSoDAO;
import org.example.dto.FacilityMapDTO;
import org.example.model.CoSo;
import org.example.model.LoaiSan;
import org.example.model.MonTheThao;
import org.example.model.San;
import org.example.util.DBUtil;
import org.example.util.JPAUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Time;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class CoSoDAOImpl implements CoSoDAO {

    private static final Logger logger = LogManager.getLogger(CoSoDAOImpl.class);

    @Override
    public List<CoSo> getAllCoSo() {
        // Loại trừ cơ sở đang "Chờ duyệt"/"Từ chối" vì đây là yêu cầu Owner
        // chưa được Admin duyệt, không phải cơ sở đang vận hành thật sự.
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT c FROM CoSo c WHERE (c.isDeleted = false OR c.isDeleted IS NULL) " +
                    "AND c.TrangThai NOT IN ('Chờ duyệt', 'Từ chối')", CoSo.class)
                .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<CoSo> searchCoSo(String keyword, Integer monTheThaoId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            StringBuilder jpql = new StringBuilder(
                    "SELECT DISTINCT c FROM CoSo c WHERE (c.isDeleted = false OR c.isDeleted IS NULL) " +
                    "AND c.TrangThai NOT IN ('Chờ duyệt', 'Từ chối')");

            String trimmedKeyword = keyword != null ? keyword.trim() : "";
            boolean hasKeyword = !trimmedKeyword.isEmpty();
            if (hasKeyword) {
                jpql.append(" AND (LOWER(c.TenCoSo) LIKE :kw ESCAPE '\\' OR LOWER(c.DiaChi) LIKE :kw ESCAPE '\\')");
            }
            if (monTheThaoId != null) {
                // Source of truth for sport: San → LoaiSan → MonTheThao (not CoSo.LoaiHinhKinhDoanh).
                // Only check isDeleted; do NOT filter on s.trangThai here — court status values
                // are not guaranteed uniform across deployments and would silently hide all results.
                jpql.append(" AND EXISTS (SELECT 1 FROM San s, LoaiSan ls " +
                        "WHERE s.coSoID = c.CoSoID " +
                        "AND s.loaiSanID = ls.loaiSanID " +
                        "AND (s.isDeleted = false OR s.isDeleted IS NULL) " +
                        "AND ls.isDeleted = false " +
                        "AND ls.monTheThaoID = :monTheThaoId)");
            }

            jakarta.persistence.TypedQuery<CoSo> query = em.createQuery(jpql.toString(), CoSo.class);
            if (hasKeyword) {
                // Escape LIKE wildcards trong keyword người dùng nhập để tránh họ tự ý
                // dùng % / _ làm ký tự đại diện ngoài ý muốn ứng dụng.
                String escaped = trimmedKeyword.toLowerCase()
                        .replace("\\", "\\\\")
                        .replace("%", "\\%")
                        .replace("_", "\\_");
                query.setParameter("kw", "%" + escaped + "%");
            }
            if (monTheThaoId != null) {
                query.setParameter("monTheThaoId", monTheThaoId);
            }
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<CoSo> getAllCoSoIncludingPending() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT c FROM CoSo c WHERE c.isDeleted = false OR c.isDeleted IS NULL ORDER BY c.CoSoID DESC", CoSo.class)
                .getResultList();
        } catch (Exception e) {
            logger.error("Lỗi getAllCoSoIncludingPending: {}", e.getMessage(), e);
            return java.util.Collections.emptyList();
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
        return hardDeleteCascade(id);
    }

    @Override
    public boolean softDelete(int coSoId, int actorId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            int updated = em.createQuery(
                    "UPDATE CoSo c SET c.isDeleted = true, c.deletedAt = :now, c.deletedBy = :actor " +
                    "WHERE c.CoSoID = :id AND (c.isDeleted = false OR c.isDeleted IS NULL)")
                .setParameter("now", java.time.LocalDateTime.now())
                .setParameter("actor", actorId)
                .setParameter("id", coSoId)
                .executeUpdate();
            trans.commit();
            return updated > 0;
        } catch (Exception e) {
            if (trans.isActive()) trans.rollback();
            logger.error("Lỗi soft-delete cơ sở ID {}: {}", coSoId, e.getMessage(), e);
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean restore(int coSoId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            int updated = em.createQuery(
                    "UPDATE CoSo c SET c.isDeleted = false, c.deletedAt = null, c.deletedBy = null " +
                    "WHERE c.CoSoID = :id")
                .setParameter("id", coSoId)
                .executeUpdate();
            trans.commit();
            return updated > 0;
        } catch (Exception e) {
            if (trans.isActive()) trans.rollback();
            logger.error("Lỗi restore cơ sở ID {}: {}", coSoId, e.getMessage(), e);
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public List<CoSo> findDeleted() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT c FROM CoSo c WHERE c.isDeleted = true", CoSo.class).getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<Integer> findDeletedIdsOlderThan(int days) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            java.time.LocalDateTime cutoff = java.time.LocalDateTime.now().minusDays(days);
            return em.createQuery(
                    "SELECT c.CoSoID FROM CoSo c WHERE c.isDeleted = true AND c.deletedAt <= :cutoff",
                    Integer.class)
                .setParameter("cutoff", cutoff)
                .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public boolean hardDeleteCascade(int id) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            // Check if branch exists first using a count native query to be safe
            Number count = (Number) em.createNativeQuery("SELECT COUNT(*) FROM facilities WHERE facility_id = ?")
                    .setParameter(1, id)
                    .getSingleResult();

            if (count != null && count.intValue() > 0) {
                // 0. Get the manager account ID first to delete it robustly later
                Integer managerAccountId = null;
                try {
                    Object managerIdObj = em.createNativeQuery("SELECT manager_account_id FROM facilities WHERE facility_id = ?")
                            .setParameter(1, id)
                            .getSingleResult();
                    if (managerIdObj != null) {
                        managerAccountId = ((Number) managerIdObj).intValue();
                    }
                } catch (Exception ex) {
                    // Ignore if no manager found or multiple/none
                }

                // 1. Break circular dependency first
                em.createNativeQuery("UPDATE facilities SET manager_account_id = NULL WHERE facility_id = ?")
                        .setParameter(1, id)
                        .executeUpdate();

                // 2. Clean up bookings referencing courts of this branch
                em.createNativeQuery("DELETE FROM bookings WHERE court_id IN (SELECT court_id FROM courts WHERE facility_id = ?)")
                        .setParameter(1, id)
                        .executeUpdate();

                // 3. Matchmaking
                em.createNativeQuery("DELETE FROM match_participants WHERE match_id IN (SELECT match_id FROM matches WHERE booking_id IN (SELECT booking_id FROM bookings WHERE court_id IN (SELECT court_id FROM courts WHERE facility_id = ?)))")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM matches WHERE booking_id IN (SELECT booking_id FROM bookings WHERE court_id IN (SELECT court_id FROM courts WHERE facility_id = ?))")
                        .setParameter(1, id)
                        .executeUpdate();

                // 4. Reviews
                em.createNativeQuery("DELETE FROM reviews WHERE booking_id IN (SELECT booking_id FROM bookings WHERE court_id IN (SELECT court_id FROM courts WHERE facility_id = ?))")
                        .setParameter(1, id)
                        .executeUpdate();

                // 5. Invoices
                em.createNativeQuery("DELETE FROM invoice_items WHERE invoice_id IN (SELECT invoice_id FROM invoices WHERE booking_id IN (SELECT booking_id FROM bookings WHERE court_id IN (SELECT court_id FROM courts WHERE facility_id = ?)))")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM refunds WHERE invoice_id IN (SELECT invoice_id FROM invoices WHERE booking_id IN (SELECT booking_id FROM bookings WHERE court_id IN (SELECT court_id FROM courts WHERE facility_id = ?)))")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM invoices WHERE booking_id IN (SELECT booking_id FROM bookings WHERE court_id IN (SELECT court_id FROM courts WHERE facility_id = ?))")
                        .setParameter(1, id)
                        .executeUpdate();

                // 9. Courts
                em.createNativeQuery("DELETE FROM courts WHERE facility_id = ?")
                        .setParameter(1, id)
                        .executeUpdate();

                // 10. Court Types
                em.createNativeQuery("DELETE FROM court_types WHERE facility_id = ?")
                        .setParameter(1, id)
                        .executeUpdate();

                // 11. Products and Services
                em.createNativeQuery("DELETE FROM invoice_items WHERE product_id IN (SELECT product_id FROM products_services WHERE facility_id = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM products_services WHERE facility_id = ?")
                        .setParameter(1, id)
                        .executeUpdate();

                // 12. Promo Codes
                em.createNativeQuery("DELETE FROM promotions WHERE facility_id = ?")
                        .setParameter(1, id)
                        .executeUpdate();

                // 13. Accounts references cleanup
                em.createNativeQuery("UPDATE facilities SET manager_account_id = NULL WHERE manager_account_id IN (SELECT account_id FROM accounts WHERE facility_id = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM work_shifts WHERE facility_id = ? OR account_id IN (SELECT account_id FROM accounts WHERE facility_id = ?)")
                        .setParameter(1, id)
                        .setParameter(2, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM favorite_sports WHERE account_id IN (SELECT account_id FROM accounts WHERE facility_id = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM notifications WHERE account_id IN (SELECT account_id FROM accounts WHERE facility_id = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("UPDATE invoices SET staff_account_id = NULL WHERE staff_account_id IN (SELECT account_id FROM accounts WHERE facility_id = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("UPDATE invoices SET customer_account_id = NULL WHERE customer_account_id IN (SELECT account_id FROM accounts WHERE facility_id = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM refunds WHERE account_id IN (SELECT account_id FROM accounts WHERE facility_id = ?)")
                        .setParameter(1, id)
                        .executeUpdate();
                em.createNativeQuery("DELETE FROM reviews WHERE reviewer_account_id IN (SELECT account_id FROM accounts WHERE facility_id = ?) OR reviewed_account_id IN (SELECT account_id FROM accounts WHERE facility_id = ?)")
                        .setParameter(1, id)
                        .setParameter(2, id)
                        .executeUpdate();

                // 15. Delete Accounts associated with the branch
                em.createNativeQuery("DELETE FROM accounts WHERE facility_id = ?")
                        .setParameter(1, id)
                        .executeUpdate();
                if (managerAccountId != null) {
                    em.createNativeQuery("DELETE FROM accounts WHERE account_id = ?")
                            .setParameter(1, managerAccountId)
                            .executeUpdate();
                }

                // 16. Finally delete the branch itself
                em.createNativeQuery("DELETE FROM facilities WHERE facility_id = ?")
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

    @Override
    public boolean archiveRejectedForAccount(int accountId, int excludeCoSoId, int actorId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.createQuery(
                    "UPDATE CoSo c SET c.isDeleted = true, c.deletedAt = :now, c.deletedBy = :actor " +
                    "WHERE c.AccountID_QuanLy = :accId AND c.TrangThai = 'Từ chối' AND c.CoSoID <> :excludeId " +
                    "AND (c.isDeleted = false OR c.isDeleted IS NULL)")
                .setParameter("now", java.time.LocalDateTime.now())
                .setParameter("actor", actorId)
                .setParameter("accId", accountId)
                .setParameter("excludeId", excludeCoSoId)
                .executeUpdate();
            trans.commit();
            return true;
        } catch (Exception e) {
            if (trans.isActive()) trans.rollback();
            logger.error("Lỗi archive rejected CoSo for accountId={}: {}", accountId, e.getMessage(), e);
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean hasActiveOrPendingCoSo(int accountId, int excludeCoSoId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Long count = em.createQuery(
                    "SELECT COUNT(c) FROM CoSo c WHERE c.AccountID_QuanLy = :accId AND c.CoSoID <> :excludeId " +
                    "AND (c.isDeleted = false OR c.isDeleted IS NULL) " +
                    "AND c.TrangThai IN ('Chờ duyệt', 'Đang hoạt động')", Long.class)
                .setParameter("accId", accountId)
                .setParameter("excludeId", excludeCoSoId)
                .getSingleResult();
            return count != null && count > 0;
        } finally {
            em.close();
        }
    }

    @Override
    public List<FacilityMapDTO> getAllCoSoForMap(Integer sportId, String keyword, Integer facilityId) {
        List<FacilityMapDTO> result = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT c.facility_id, c.facility_name, c.address, c.phone_number, c.latitude, c.longitude, c.image_path, " +
                "       c.opening_time, c.closing_time, c.status, c.business_type, " +
                "       (SELECT MIN(ls.price_without_light) FROM court_types ls WHERE ls.facility_id = c.facility_id) AS MinPrice, " +
                "       (SELECT COUNT(*) FROM courts s WHERE s.facility_id = c.facility_id AND s.status = N'Sẵn sàng' " +
                "               AND (s.is_deleted = 0 OR s.is_deleted IS NULL)) AS ReadyCourtCount " +
                "FROM facilities c " +
                "WHERE (c.is_deleted = 0 OR c.is_deleted IS NULL) " +
                "  AND c.status = N'Đang hoạt động' " +
                "  AND c.latitude IS NOT NULL AND c.longitude IS NOT NULL " +
                "  AND c.latitude BETWEEN -90 AND 90 AND c.longitude BETWEEN -180 AND 180");

        if (facilityId != null) {
            sql.append(" AND c.CoSoID = ?");
        }
        if (sportId != null) {
            sql.append(" AND c.facility_id IN (SELECT DISTINCT ls.facility_id FROM court_types ls WHERE ls.sport_id = ?)");
        }
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        if (hasKeyword) {
            sql.append(" AND (LOWER(c.TenCoSo) LIKE ? ESCAPE '\\' OR LOWER(c.DiaChi) LIKE ? ESCAPE '\\')");
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;
            if (facilityId != null) {
                ps.setInt(idx++, facilityId);
            }
            if (sportId != null) {
                ps.setInt(idx++, sportId);
            }
            if (hasKeyword) {
                String escaped = keyword.trim().toLowerCase()
                        .replace("\\", "\\\\")
                        .replace("%", "\\%")
                        .replace("_", "\\_");
                String pattern = "%" + escaped + "%";
                ps.setString(idx++, pattern);
                ps.setString(idx++, pattern);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    FacilityMapDTO dto = new FacilityMapDTO();
                    dto.setCoSoId(rs.getInt("facility_id"));
                    dto.setTenCoSo(rs.getString("facility_name"));
                    dto.setDiaChi(rs.getString("address"));
                    dto.setSoDienThoai(rs.getString("phone_number"));

                    BigDecimal viDo = rs.getBigDecimal("latitude");
                    BigDecimal kinhDo = rs.getBigDecimal("longitude");
                    dto.setViDo(viDo.doubleValue());
                    dto.setKinhDo(kinhDo.doubleValue());

                    Time gioMo = rs.getTime("opening_time");
                    Time gioDong = rs.getTime("closing_time");
                    dto.setGioMoCua(gioMo != null ? gioMo.toString().substring(0, 5) : null);
                    dto.setGioDongCua(gioDong != null ? gioDong.toString().substring(0, 5) : null);

                    dto.setTrangThai(rs.getString("status"));
                    String hinhAnh = rs.getString("image_path");
                    dto.setHinhAnh(hinhAnh != null ? hinhAnh.trim() : "");

                    double minPrice = rs.getDouble("MinPrice");
                    dto.setMinPrice(rs.wasNull() ? 0.0 : minPrice);
                    dto.setReadyCourtCount(rs.getInt("ReadyCourtCount"));

                    List<String> sportsList = new ArrayList<>();
                    String loaiHinh = rs.getString("business_type");
                    if (loaiHinh != null && !loaiHinh.trim().isEmpty()) {
                        for (String s : loaiHinh.split(",")) {
                            if (!s.trim().isEmpty()) {
                                sportsList.add(s.trim());
                            }
                        }
                    }
                    dto.setSports(sportsList);

                    result.add(dto);
                }
            }
        } catch (Exception e) {
            logger.error("Lỗi khi tải danh sách cơ sở cho bản đồ: {}", e.getMessage(), e);
        }

        return result;
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
