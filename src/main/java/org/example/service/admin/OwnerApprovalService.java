package org.example.service.admin;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.model.CoSo;
import org.example.model.TaiKhoan;
import org.example.util.JPAUtil;

import java.time.LocalDateTime;

/**
 * Lõi nghiệp vụ duyệt/từ chối yêu cầu đăng ký Owner, chạy trong một
 * EntityTransaction duy nhất để đảm bảo CoSo và Account luôn đồng bộ:
 * không có tình trạng Account đã mở khóa nhưng CoSo vẫn "Chờ duyệt",
 * hoặc CoSo "Đang hoạt động" nhưng Account vẫn bị khóa.
 * Dùng chung cho cả AdminOwnerServlet và QuanLyChiNhanhServlet để
 * tránh hai luồng duyệt/từ chối lệch nhau.
 */
public class OwnerApprovalService {

    private static final Logger logger = LogManager.getLogger(OwnerApprovalService.class);

    public static class ApprovalResult {
        public final boolean success;
        public final String errorMessage;
        public final CoSo coSo;
        public final TaiKhoan account;

        private ApprovalResult(boolean success, String errorMessage, CoSo coSo, TaiKhoan account) {
            this.success = success;
            this.errorMessage = errorMessage;
            this.coSo = coSo;
            this.account = account;
        }

        static ApprovalResult ok(CoSo coSo, TaiKhoan account) {
            return new ApprovalResult(true, null, coSo, account);
        }

        static ApprovalResult fail(String message) {
            return new ApprovalResult(false, message, null, null);
        }
    }

    /**
     * Duyệt yêu cầu: CoSo chuyển "Đang hoạt động", mở khóa Account liên kết,
     * đồng thời archive (soft-delete) các CoSo "Từ chối" cũ khác của cùng
     * account để tránh trùng lặp lịch sử đăng ký.
     */
    public ApprovalResult approve(int coSoId, int adminId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            CoSo coSo = em.find(CoSo.class, coSoId);
            if (coSo == null) {
                tx.rollback();
                return ApprovalResult.fail("Không tìm thấy cơ sở.");
            }
            if (!"Chờ duyệt".equals(coSo.getTrangThai())) {
                tx.rollback();
                return ApprovalResult.fail("Cơ sở này không ở trạng thái chờ duyệt.");
            }

            coSo.setTrangThai("Đang hoạt động");

            TaiKhoan account = null;
            if (coSo.getAccountID_QuanLy() != null) {
                account = em.find(TaiKhoan.class, coSo.getAccountID_QuanLy());
                if (account != null) {
                    account.setIsLocked(false);
                }
                em.createQuery(
                        "UPDATE CoSo c SET c.isDeleted = true, c.deletedAt = :now, c.deletedBy = :actor " +
                        "WHERE c.AccountID_QuanLy = :accId AND c.TrangThai = 'Từ chối' AND c.CoSoID <> :excludeId " +
                        "AND (c.isDeleted = false OR c.isDeleted IS NULL)")
                    .setParameter("now", LocalDateTime.now())
                    .setParameter("actor", adminId)
                    .setParameter("accId", coSo.getAccountID_QuanLy())
                    .setParameter("excludeId", coSoId)
                    .executeUpdate();
            }

            tx.commit();
            return ApprovalResult.ok(coSo, account);
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            logger.error("Lỗi duyệt yêu cầu Owner coSoId={}: {}", coSoId, e.getMessage(), e);
            return ApprovalResult.fail("Lỗi hệ thống khi duyệt yêu cầu.");
        } finally {
            em.close();
        }
    }

    /**
     * Từ chối yêu cầu: CoSo chuyển "Từ chối", Account giữ nguyên trạng thái
     * khóa hiện tại (không tự mở, không tự khóa thêm).
     */
    public ApprovalResult reject(int coSoId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            CoSo coSo = em.find(CoSo.class, coSoId);
            if (coSo == null) {
                tx.rollback();
                return ApprovalResult.fail("Không tìm thấy cơ sở.");
            }
            if (!"Chờ duyệt".equals(coSo.getTrangThai())) {
                tx.rollback();
                return ApprovalResult.fail("Chỉ có thể từ chối cơ sở đang chờ duyệt.");
            }

            TaiKhoan account = coSo.getAccountID_QuanLy() != null
                    ? em.find(TaiKhoan.class, coSo.getAccountID_QuanLy())
                    : null;

            coSo.setTrangThai("Từ chối");

            tx.commit();
            return ApprovalResult.ok(coSo, account);
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            logger.error("Lỗi từ chối yêu cầu Owner coSoId={}: {}", coSoId, e.getMessage(), e);
            return ApprovalResult.fail("Lỗi hệ thống khi từ chối yêu cầu.");
        } finally {
            em.close();
        }
    }
}
