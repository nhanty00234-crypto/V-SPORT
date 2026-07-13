package org.example.util;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class JPAUtil {
    private static EntityManagerFactory factory;
    private static final Logger logger = LogManager.getLogger(JPAUtil.class);

    static {
        try {
            java.util.Map<String, String> properties = new java.util.HashMap<>();
            properties.put("jakarta.persistence.jdbc.url", DBUtil.getURL());
            properties.put("jakarta.persistence.jdbc.user", DBUtil.getUSER());
            properties.put("jakarta.persistence.jdbc.password", DBUtil.getPASSWORD());

            factory = Persistence.createEntityManagerFactory("SportPU", properties);
            logger.info("JPAUtil: EntityManagerFactory created successfully for SportPU");
        } catch (Throwable ex) {
            logger.error("JPAUtil: Initial EntityManagerFactory creation failed: {}", ex.getMessage(), ex);
            throw new ExceptionInInitializerError("Failed to create EntityManagerFactory for SportPU: " + ex.getMessage());
        }
    }

    public static EntityManager getEntityManager() {
        if (factory == null || !factory.isOpen()) {
            throw new IllegalStateException("EntityManagerFactory is not initialized or has been closed");
        }
        return factory.createEntityManager();
    }

    public static void close() {
        if (factory != null && factory.isOpen()) {
            factory.close();
            System.out.println("JPAUtil: EntityManagerFactory closed");
        }
    }
}
