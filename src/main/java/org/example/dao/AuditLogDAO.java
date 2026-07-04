package org.example.dao;

import org.example.model.AuditLog;
import java.util.List;

public interface AuditLogDAO {
    void save(AuditLog log);
    List<AuditLog> findAll(int page, int pageSize);
    List<AuditLog> findByCoSo(int coSoId, int page, int pageSize);
    long countAll();
    long countByCoSo(int coSoId);
    List<AuditLog> findWithFilters(Integer coSoId, String entityType, String action, String dateFrom, String dateTo, int page, int pageSize);
    long countWithFilters(Integer coSoId, String entityType, String action, String dateFrom, String dateTo);
}
