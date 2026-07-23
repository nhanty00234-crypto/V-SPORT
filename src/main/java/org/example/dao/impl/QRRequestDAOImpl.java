package org.example.dao.impl;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import org.example.dao.QRRequestDAO;
import org.example.model.QRRequest;
import org.example.util.JPAUtil;

import java.util.List;

public class QRRequestDAOImpl implements QRRequestDAO {

    @Override
    public QRRequest save(QRRequest request) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            if (request.getRequestId() == 0) {
                em.persist(request);
            } else {
                request = em.merge(request);
            }
            em.getTransaction().commit();
            return request;
        } catch (RuntimeException e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    @Override
    public QRRequest findById(int requestId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.find(QRRequest.class, requestId);
        } finally {
            em.close();
        }
    }

    @Override
    public List<QRRequest> findByGuestTokenAndSan(String guestToken, int sanId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            TypedQuery<QRRequest> q = em.createQuery(
                "SELECT r FROM QRRequest r WHERE r.guestToken = :guestToken AND r.sanId = :sanId ORDER BY r.createdAt DESC",
                QRRequest.class);
            q.setParameter("guestToken", guestToken);
            q.setParameter("sanId", sanId);
            return q.getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<QRRequest> findByCoSoAndStatus(int coSoId, String status) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            String jpql = "SELECT r FROM QRRequest r WHERE r.coSoId = :coSoId"
                + (status != null ? " AND r.status = :status" : "")
                + " ORDER BY r.createdAt DESC";
            TypedQuery<QRRequest> q = em.createQuery(jpql, QRRequest.class);
            q.setParameter("coSoId", coSoId);
            if (status != null) q.setParameter("status", status);
            return q.getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public long countByCoSoAndStatus(int coSoId, String status) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            TypedQuery<Long> q = em.createQuery(
                "SELECT COUNT(r) FROM QRRequest r WHERE r.coSoId = :coSoId AND r.status = :status",
                Long.class);
            q.setParameter("coSoId", coSoId);
            q.setParameter("status", status);
            return q.getSingleResult();
        } finally {
            em.close();
        }
    }
}
