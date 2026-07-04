package org.example.service;

import jakarta.servlet.http.HttpServletRequest;
import org.example.dao.impl.AuditLogDAOImpl;
import org.example.model.AuditLog;
import org.example.model.TaiKhoan;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AuditLogService {
    private static final Logger logger = LoggerFactory.getLogger(AuditLogService.class);
    private static final AuditLogDAOImpl dao = new AuditLogDAOImpl();

    // Action constants
    public static final String ACTION_CREATE           = "CREATE";
    public static final String ACTION_UPDATE           = "UPDATE";
    public static final String ACTION_SOFT_DELETE      = "SOFT_DELETE";
    public static final String ACTION_RESTORE          = "RESTORE";
    public static final String ACTION_PERMANENT_DELETE = "PERMANENT_DELETE";
    public static final String ACTION_ADD_STAFF        = "ADD_STAFF";
    public static final String ACTION_APPROVE          = "APPROVE";
    public static final String ACTION_REJECT           = "REJECT";

    // Entity type constants
    public static final String ENTITY_ACCOUNT    = "TaiKhoan";
    public static final String ENTITY_SAN        = "San";
    public static final String ENTITY_LOAI_SAN   = "LoaiSan";
    public static final String ENTITY_SAN_PHAM   = "SanPham";
    public static final String ENTITY_CO_SO      = "CoSo";
    public static final String ENTITY_CA_LAM     = "CaLamViec";
    public static final String ENTITY_YEU_CAU_NGHI = "YeuCauNghi";

    /**
     * Ghi một bản ghi audit log. Không ném exception ra ngoài — lỗi log không được phá request chính.
     */
    public static void log(HttpServletRequest req, TaiKhoan actor,
                           String action, String entityType,
                           String entityId, String entityName, String details) {
        try {
            AuditLog entry = new AuditLog();
            entry.setActorAccountId(actor.getAccountId());
            entry.setActorName(actor.getFullName() != null ? actor.getFullName() : actor.getUsername());
            entry.setActorRole(actor.getRoleId());
            entry.setCoSoId(actor.getCoSoId() != null && actor.getCoSoId() > 0 ? actor.getCoSoId() : null);
            entry.setAction(action);
            entry.setEntityType(entityType);
            entry.setEntityId(entityId);
            entry.setEntityName(entityName);
            entry.setDetails(details);
            entry.setIpAddress(getClientIp(req));
            dao.save(entry);
        } catch (Exception e) {
            logger.error("Không thể ghi AuditLog: {}", e.getMessage(), e);
        }
    }

    /** Overload khi coSoId cần ghi rõ (ví dụ Admin thao tác trên 1 chi nhánh cụ thể) */
    public static void log(HttpServletRequest req, TaiKhoan actor, Integer overrideCoSoId,
                           String action, String entityType,
                           String entityId, String entityName, String details) {
        try {
            AuditLog entry = new AuditLog();
            entry.setActorAccountId(actor.getAccountId());
            entry.setActorName(actor.getFullName() != null ? actor.getFullName() : actor.getUsername());
            entry.setActorRole(actor.getRoleId());
            entry.setCoSoId(overrideCoSoId);
            entry.setAction(action);
            entry.setEntityType(entityType);
            entry.setEntityId(entityId);
            entry.setEntityName(entityName);
            entry.setDetails(details);
            entry.setIpAddress(getClientIp(req));
            dao.save(entry);
        } catch (Exception e) {
            logger.error("Không thể ghi AuditLog: {}", e.getMessage(), e);
        }
    }

    private static String getClientIp(HttpServletRequest req) {
        String ip = req.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty()) ip = req.getRemoteAddr();
        // X-Forwarded-For có thể chứa nhiều IP, lấy IP đầu tiên
        if (ip != null && ip.contains(",")) ip = ip.split(",")[0].trim();
        return ip;
    }
}
