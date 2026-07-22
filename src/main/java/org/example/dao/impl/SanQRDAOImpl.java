package org.example.dao.impl;

import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.SanQRDAO;
import org.example.model.SanQR;
import org.example.util.JPAUtil;

import java.util.UUID;

/**
 * Mọi truy vấn ở đây fail-safe (không ném exception ra ngoài) - lớp này có thể được
 * gọi từ endpoint resolve QR công khai (Customer quét bằng camera), không được sập
 * theo nếu DB có sự cố tạm thời. Mặc định an toàn: trả về null (coi như không tìm
 * thấy/không hợp lệ) khi có lỗi, không bao giờ suy luận thành "hợp lệ".
 */
public class SanQRDAOImpl implements SanQRDAO {

    private static final Logger logger = LogManager.getLogger(SanQRDAOImpl.class);

    @Override
    public SanQR findBySanId(int sanId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT q FROM SanQR q WHERE q.sanId = :sanId", SanQR.class)
                    .setParameter("sanId", sanId)
                    .getSingleResult();
        } catch (NoResultException e) {
            return null;
        } catch (Exception e) {
            logger.error("Lỗi truy vấn SanQR.findBySanId(sanId={}): {}", sanId, e.getMessage(), e);
            return null;
        } finally {
            em.close();
        }
    }

    @Override
    public SanQR findByToken(UUID token) {
        if (token == null) return null;
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT q FROM SanQR q WHERE q.token = :token", SanQR.class)
                    .setParameter("token", token)
                    .getSingleResult();
        } catch (NoResultException e) {
            return null;
        } catch (Exception e) {
            logger.error("Lỗi truy vấn SanQR.findByToken(token={}): {}", token, e.getMessage(), e);
            return null;
        } finally {
            em.close();
        }
    }

    @Override
    public SanQR findById(int sanQRId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.find(SanQR.class, sanQRId);
        } catch (Exception e) {
            logger.error("Lỗi truy vấn SanQR.findById(sanQRId={}): {}", sanQRId, e.getMessage(), e);
            return null;
        } finally {
            em.close();
        }
    }
}
