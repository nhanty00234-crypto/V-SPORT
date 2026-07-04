package org.example.dao.impl;

import org.example.dao.TaiKhoanDAO;
import org.example.model.TaiKhoan;
import org.example.util.JPAUtil;
import org.example.util.EmailUtil;
import org.mindrot.jbcrypt.BCrypt;
import jakarta.mail.MessagingException;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.Query;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.List;
import java.util.Random;

public class TaiKhoanDAOImpl implements TaiKhoanDAO {

    private static final Logger logger = LogManager.getLogger(TaiKhoanDAOImpl.class);

    @Override
    public boolean addAccountByAdmin(TaiKhoan TaiKhoan) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            TaiKhoan.setDiemUyTin(100);
            TaiKhoan.setDiemTrinhDo(1000);
            TaiKhoan.setNhanThongBaoSos(true);
            em.persist(TaiKhoan);
            trans.commit();
            return true;
        } catch (Exception e) {
            logger.error("Lỗi thêm tài khoản: {}", e.getMessage(), e);
            if (trans.isActive()) trans.rollback();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public List<TaiKhoan> getAllAccounts() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT a FROM TaiKhoan a WHERE a.isDeleted = false OR a.isDeleted IS NULL", TaiKhoan.class).getResultList();
        } catch (Exception e) {
            logger.error("Lỗi lấy danh sách tài khoản: {}", e.getMessage(), e);
            return null;
        } finally {
            em.close();
        }
    }

    @Override
    public List<TaiKhoan> getDeletedAccounts() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT a FROM TaiKhoan a WHERE a.isDeleted = true", TaiKhoan.class).getResultList();
        } catch (Exception e) {
            logger.error("Lỗi lấy danh sách tài khoản đã xóa: {}", e.getMessage(), e);
            return null;
        } finally {
            em.close();
        }
    }

    @Override
    public TaiKhoan getAccountById(int id) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.find(TaiKhoan.class, id);
        } catch (Exception e) {
            logger.error("Lỗi lấy tài khoản ID {}: {}", id, e.getMessage(), e);
            return null;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean updateAccount(TaiKhoan TaiKhoan) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.merge(TaiKhoan);
            trans.commit();
            return true;
        } catch (Exception e) {
            logger.error("Lỗi cập nhật tài khoản ID {}: {}", TaiKhoan.getAccountId(), e.getMessage(), e);
            if (trans.isActive()) trans.rollback();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean softDeleteAccount(int id) {
        return softDeleteAccount(id, 0);
    }

    @Override
    public boolean softDeleteAccount(int accountId, int actorId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            TaiKhoan acc = em.find(TaiKhoan.class, accountId);
            if (acc != null) {
                acc.setDeleted(true);
                acc.setIsLocked(true);
                acc.setDeletedAt(java.time.LocalDateTime.now());
                acc.setDeletedBy(actorId == 0 ? null : actorId);
                em.merge(acc);
                trans.commit();
                return true;
            }
            trans.rollback();
            return false;
        } catch (Exception e) {
            logger.error("Lỗi xóa mềm tài khoản ID {}: {}", accountId, e.getMessage(), e);
            if (trans.isActive()) trans.rollback();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean restoreAccount(int id) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            TaiKhoan acc = em.find(TaiKhoan.class, id);
            if (acc != null) {
                acc.setDeleted(false);
                acc.setIsLocked(false);
                acc.setDeletedAt(null);
                acc.setDeletedBy(null);
                em.merge(acc);
                trans.commit();
                return true;
            }
            trans.rollback();
            return false;
        } catch (Exception e) {
            logger.error("Lỗi khôi phục tài khoản ID {}: {}", id, e.getMessage(), e);
            if (trans.isActive()) trans.rollback();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public List<TaiKhoan> findDeletedByCoSo(int coSoId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT a FROM TaiKhoan a WHERE a.isDeleted = true AND a.coSoId = :coSoId",
                    TaiKhoan.class)
                .setParameter("coSoId", coSoId)
                .getResultList();
        } catch (Exception e) {
            logger.error("Lỗi lấy tài khoản đã xóa theo cơ sở ID {}: {}", coSoId, e.getMessage(), e);
            return null;
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
                    "SELECT a.accountId FROM TaiKhoan a WHERE a.isDeleted = true AND a.deletedAt <= :cutoff",
                    Integer.class)
                .setParameter("cutoff", cutoff)
                .getResultList();
        } catch (Exception e) {
            logger.error("Lỗi lấy ID tài khoản đã xóa cũ hơn {} ngày: {}", days, e.getMessage(), e);
            return null;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean permanentDeleteAccount(int id) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            TaiKhoan acc = em.find(TaiKhoan.class, id);
            if (acc == null) {
                trans.rollback();
                return false;
            }

            // Mỗi câu được bọc IF OBJECT_ID(...) IS NOT NULL để bỏ qua bảng chưa tồn tại trong DB
            String[] sqls = {
                "IF OBJECT_ID('CoSo') IS NOT NULL UPDATE CoSo SET AccountID_QuanLy = NULL WHERE AccountID_QuanLy = " + id,
                "IF OBJECT_ID('MonTheThaoYeuThich') IS NOT NULL DELETE FROM MonTheThaoYeuThich WHERE AccountID = " + id,
                // Xóa child trước parent trong HoaDon
                "IF OBJECT_ID('ChiTietHoaDon') IS NOT NULL DELETE FROM ChiTietHoaDon WHERE HoaDonID IN (SELECT HoaDonID FROM HoaDon WHERE AccountID_KhachHang = " + id + " OR AccountID_NhanVien = " + id + ")",
                "IF OBJECT_ID('MaQR') IS NOT NULL DELETE FROM MaQR WHERE ChiaHoaDonID IN (SELECT ChiaHoaDonID FROM ChiaHoaDon WHERE AccountID = " + id + ")",
                "IF OBJECT_ID('ChiaHoaDon') IS NOT NULL DELETE FROM ChiaHoaDon WHERE AccountID = " + id,
                "IF OBJECT_ID('HoanTien') IS NOT NULL DELETE FROM HoanTien WHERE AccountID = " + id,
                "IF OBJECT_ID('HoaDon') IS NOT NULL UPDATE HoaDon SET AccountID_KhachHang = NULL WHERE AccountID_KhachHang = " + id,
                "IF OBJECT_ID('HoaDon') IS NOT NULL UPDATE HoaDon SET AccountID_NhanVien = NULL WHERE AccountID_NhanVien = " + id,
                "IF OBJECT_ID('LichDatSan') IS NOT NULL UPDATE LichDatSan SET AccountID = NULL WHERE AccountID = " + id,
                "IF OBJECT_ID('GhepKeo') IS NOT NULL UPDATE GhepKeo SET AccountID_NguoiTao = NULL WHERE AccountID_NguoiTao = " + id,
                "IF OBJECT_ID('ChiTietGhepKeo') IS NOT NULL UPDATE ChiTietGhepKeo SET AccountID_NguoiThamGia = NULL WHERE AccountID_NguoiThamGia = " + id,
                "IF OBJECT_ID('DanhGia') IS NOT NULL UPDATE DanhGia SET AccountID_NguoiDanhGia = NULL WHERE AccountID_NguoiDanhGia = " + id,
                "IF OBJECT_ID('DanhGia') IS NOT NULL UPDATE DanhGia SET AccountID_NguoiBiDanhGia = NULL WHERE AccountID_NguoiBiDanhGia = " + id,
                "IF OBJECT_ID('LichSuELO') IS NOT NULL DELETE FROM LichSuELO WHERE AccountID = " + id,
                "IF OBJECT_ID('NhatKyChat') IS NOT NULL DELETE FROM NhatKyChat WHERE AccountID = " + id,
                "IF OBJECT_ID('LichXeRaVao') IS NOT NULL UPDATE LichXeRaVao SET AccountID_NhanVien = NULL WHERE AccountID_NhanVien = " + id,
                "IF OBJECT_ID('NhatKySOSGui') IS NOT NULL AND OBJECT_ID('YeuCauSOS') IS NOT NULL DELETE FROM NhatKySOSGui WHERE YeuCauSOSID IN (SELECT YeuCauSOSID FROM YeuCauSOS WHERE AccountID_Tao = " + id + ")",
                "IF OBJECT_ID('NhatKySOSGui') IS NOT NULL DELETE FROM NhatKySOSGui WHERE AccountID_NhanGui = " + id,
                "IF OBJECT_ID('YeuCauSOS') IS NOT NULL DELETE FROM YeuCauSOS WHERE AccountID_Tao = " + id,
                "IF OBJECT_ID('ThongBao') IS NOT NULL DELETE FROM ThongBao WHERE AccountID = " + id,
                "IF OBJECT_ID('SoftHold') IS NOT NULL DELETE FROM SoftHold WHERE AccountID = " + id,
                // YeuCauNghi & YeuCauNghi_Audit
                "IF OBJECT_ID('YeuCauNghi_Audit') IS NOT NULL DELETE FROM YeuCauNghi_Audit WHERE NguoiThucHien = " + id,
                "IF OBJECT_ID('YeuCauNghi_Audit') IS NOT NULL AND OBJECT_ID('YeuCauNghi') IS NOT NULL DELETE FROM YeuCauNghi_Audit WHERE YeuCauNghiID IN (SELECT YeuCauNghiID FROM YeuCauNghi WHERE AccountID = " + id + ")",
                "IF OBJECT_ID('YeuCauNghi') IS NOT NULL DELETE FROM YeuCauNghi WHERE AccountID = " + id + " OR XuLyBy = " + id,
                // CaLamViec & CaLamViec_Availability & CaLamViec_SwapRequest & CaLamViec_Audit
                "IF OBJECT_ID('CaLamViec_Availability') IS NOT NULL DELETE FROM CaLamViec_Availability WHERE AccountID = " + id,
                "IF OBJECT_ID('CaLamViec_SwapRequest') IS NOT NULL DELETE FROM CaLamViec_SwapRequest WHERE AccountID_Gui = " + id + " OR AccountID_Nhan = " + id,
                "IF OBJECT_ID('CaLamViec_SwapRequest') IS NOT NULL UPDATE CaLamViec_SwapRequest SET NguoiDuyet = NULL WHERE NguoiDuyet = " + id,
                "IF OBJECT_ID('CaLamViec_Audit') IS NOT NULL DELETE FROM CaLamViec_Audit WHERE NguoiThucHien = " + id,
                "IF OBJECT_ID('CaLamViec_Audit') IS NOT NULL AND OBJECT_ID('CaLamViec') IS NOT NULL DELETE FROM CaLamViec_Audit WHERE CaLamViecID IN (SELECT CaLamViecID FROM CaLamViec WHERE AccountID = " + id + ")",
                "IF OBJECT_ID('CaLamViec') IS NOT NULL DELETE FROM CaLamViec WHERE AccountID = " + id,
            };

            for (String sql : sqls) {
                try {
                    em.createNativeQuery(sql).executeUpdate();
                } catch (Exception ex) {
                    logger.warn("Bỏ qua lỗi khi dọn FK cho account {}: {}", id, ex.getMessage());
                }
            }

            em.remove(acc);
            trans.commit();
            return true;
        } catch (Exception e) {
            logger.error("Lỗi xóa vĩnh viễn tài khoản ID {}: {}", id, e.getMessage(), e);
            if (trans.isActive()) trans.rollback();
            Throwable cause = e.getCause() != null ? e.getCause() : e;
            throw new RuntimeException("Xóa thất bại: " + cause.getMessage(), e);
        } finally {
            em.close();
        }
    }

    @Override
    public boolean deleteAccount(int id) {
        return softDeleteAccount(id);
    }

    @Override
    public String dangKyKhachHang(TaiKhoan acc, String[] favoriteSports) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            
            acc.setRoleId(3);
            acc.setDiemUyTin(100);
            acc.setDiemTrinhDo(1000);
            acc.setNhanThongBaoSos(true);
            acc.setIsLocked(false);
            
            em.persist(acc);
            
            if (favoriteSports != null && favoriteSports.length > 0) {
                // JPA equivalent for Native Insert to MonTheThaoYeuThich (many-to-many intermediate without full mapped entity right now)
                for (String sportName : favoriteSports) {
                    int sportId = 0;
                    switch (sportName) {
                        case "Bóng đá": sportId = 1; break;
                        case "Cầu lông": sportId = 2; break;
                        case "Pickleball": sportId = 3; break;
                        case "Tennis": sportId = 4; break;
                    }
                    if (sportId != 0) {
                        em.createNativeQuery("INSERT INTO MonTheThaoYeuThich (AccountID, MonTheThaoID) VALUES (?, ?)")
                          .setParameter(1, acc.getAccountId())
                          .setParameter(2, sportId)
                          .executeUpdate();
                    }
                }
            }

            trans.commit();
            return "Đăng ký thành công";
        } catch (Exception e) {
            logger.error("Lỗi đăng ký khách hàng: {}", e.getMessage(), e);
            if (trans.isActive()) trans.rollback();
            return "Đăng ký thất bại: " + e.getMessage();
        } finally {
            em.close();
        }
    }

    @Override
    public TaiKhoan findByUsername(String username) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<TaiKhoan> accounts = em.createQuery("SELECT a FROM TaiKhoan a WHERE a.username = :uname", TaiKhoan.class)
                                       .setParameter("uname", username)
                                       .getResultList();
            return accounts.isEmpty() ? null : accounts.get(0);
        } catch (Exception e) {
            logger.error("Lỗi tìm tài khoản theo username {}: {}", username, e.getMessage(), e);
            return null;
        } finally {
            em.close();
        }
    }

    @Override
    public Boolean kiemtraUsername(String username) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Long count = em.createQuery("SELECT COUNT(a) FROM TaiKhoan a WHERE a.username = :uname", Long.class)
                           .setParameter("uname", username)
                           .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            logger.error("Lỗi kiểm tra username {}: {}", username, e.getMessage(), e);
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public Boolean kiemtraEmail(String email) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Long count = em.createQuery("SELECT COUNT(a) FROM TaiKhoan a WHERE a.email = :email", Long.class)
                           .setParameter("email", email)
                           .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            logger.error("Lỗi kiểm tra email {}: {}", email, e.getMessage(), e);
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public TaiKhoan dangNhapKhachHang(String usernameOrEmail, String password) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<TaiKhoan> accounts = em.createQuery("SELECT a FROM TaiKhoan a WHERE (a.username = :val OR a.email = :val) AND a.isLocked = false AND (a.isDeleted = false OR a.isDeleted IS NULL)", TaiKhoan.class)
                                       .setParameter("val", usernameOrEmail)
                                       .getResultList();
            if (!accounts.isEmpty()) {
                TaiKhoan acc = accounts.get(0);
                if (BCrypt.checkpw(password, acc.getPassword())) {
                    return acc;
                }
            }
        } catch (Exception e) {
            logger.error("Lỗi đăng nhập khách hàng {}: {}", usernameOrEmail, e.getMessage(), e);
        } finally {
            em.close();
        }
        return null;
    }

    @Override
    public Boolean kiemTraEmailTonTai(String email) {
        return kiemtraEmail(email);
    }

    @Override
    public Boolean capNhatMatKhau(String email, String newPassword) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            int updatedCount = em.createQuery("UPDATE TaiKhoan a SET a.password = :pass WHERE a.email = :email")
                                 .setParameter("pass", BCrypt.hashpw(newPassword, BCrypt.gensalt(12)))
                                 .setParameter("email", email)
                                 .executeUpdate();
            trans.commit();
            return updatedCount > 0;
        } catch (Exception e) {
            logger.error("Lỗi cập nhật mật khẩu email {}: {}", email, e.getMessage(), e);
            if (trans.isActive()) trans.rollback();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public String sendRegistrationOTP(String email, String fullName) {
        Random random = new Random();
        int otp = random.nextInt(900000) + 100000; // Đảm bảo luôn 6 chữ số
        String otpString = String.valueOf(otp);
        new Thread(() -> {
            try {
                EmailUtil.sendEmail(email, "Mã xác thực đăng ký V-SPORT", "Chào " + fullName + ",\n\nMã OTP của bạn là: " + otpString);
            } catch (Exception e) {
                logger.error("Lỗi gửi email đăng ký OTP đến {}: {}", email, e.getMessage(), e);
            }
        }).start();
        return otpString;
    }

    @Override
    public String sendForgotPasswordOTP(String email) {
        Random random = new Random();
        int otp = random.nextInt(900000) + 100000;
        String otpString = String.valueOf(otp);
        new Thread(() -> {
            try {
                EmailUtil.sendEmail(email, "Xác thực đặt lại mật khẩu", "Mã OTP của bạn là: " + otpString);
            } catch (Exception e) {
                logger.error("Lỗi gửi email quên mật khẩu OTP đến {}: {}", email, e.getMessage(), e);
            }
        }).start();
        return otpString;
    }

    @Override
    public List<TaiKhoan> getAccountsByCoSoAndRoleNotIn(int coSoId, List<Integer> excludedRoleIds) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            String jpql = "SELECT a FROM TaiKhoan a WHERE a.coSoId = :coSoId AND (a.isDeleted = false OR a.isDeleted IS NULL)";
            if (excludedRoleIds != null && !excludedRoleIds.isEmpty()) {
                jpql += " AND a.roleId NOT IN :excludedRoles";
            }
            jakarta.persistence.Query query = em.createQuery(jpql, TaiKhoan.class)
                .setParameter("coSoId", coSoId);
            if (excludedRoleIds != null && !excludedRoleIds.isEmpty()) {
                query.setParameter("excludedRoles", excludedRoleIds);
            }
            return query.getResultList();
        } catch (Exception e) {
            logger.error("Lỗi lấy tài khoản theo cơ sở {} và role: {}", coSoId, e.getMessage(), e);
            return null;
        } finally {
            em.close();
        }
    }

    @Override
    public List<TaiKhoan> getDeletedAccountsByCoSoAndRoleNotIn(int coSoId, List<Integer> excludedRoleIds) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            String jpql = "SELECT a FROM TaiKhoan a WHERE a.coSoId = :coSoId AND a.isDeleted = true";
            if (excludedRoleIds != null && !excludedRoleIds.isEmpty()) {
                jpql += " AND a.roleId NOT IN :excludedRoles";
            }
            jakarta.persistence.Query query = em.createQuery(jpql, TaiKhoan.class)
                .setParameter("coSoId", coSoId);
            if (excludedRoleIds != null && !excludedRoleIds.isEmpty()) {
                query.setParameter("excludedRoles", excludedRoleIds);
            }
            return query.getResultList();
        } catch (Exception e) {
            logger.error("Lỗi lấy tài khoản đã xóa theo cơ sở {} và role: {}", coSoId, e.getMessage(), e);
            return null;
        } finally {
            em.close();
        }
    }

    @Override
    public List<TaiKhoan> getAccountsByCoSoAndRoleIn(int coSoId, List<Integer> roleIds) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            String jpql = "SELECT a FROM TaiKhoan a WHERE a.coSoId = :coSoId AND a.roleId IN :roleIds";
            jakarta.persistence.Query query = em.createQuery(jpql, TaiKhoan.class)
                .setParameter("coSoId", coSoId)
                .setParameter("roleIds", roleIds);
            return query.getResultList();
        } catch (Exception e) {
            logger.error("Lỗi lấy tài khoản theo cơ sở {} và role IN: {}", coSoId, e.getMessage(), e);
            return null;
        } finally {
            em.close();
        }
    }

    @Override
    public long getTotalStaff() {
        return 0;
    }

    @Override
    public List<TaiKhoan> findAll() {
        return List.of();
    }
}


