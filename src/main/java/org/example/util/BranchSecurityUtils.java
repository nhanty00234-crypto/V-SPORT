package org.example.util;


/**
 * Utility class cho branch/cơ sở isolation security checks
 * Đảm bảo Manager chỉ có thể truy cập resource thuộc cơ sở của họ
 */
public final class BranchSecurityUtils {

    private BranchSecurityUtils() {
        // Private constructor
    }

    /**
     * Kiểm tra resource thuộc về branch của manager
     *
     * @param resourceCoSoId CoSoID của resource cần check
     * @param managerCoSoId CoSoID của manager hiện tại
     * @throws IllegalArgumentException nếu resource không thuộc branch của manager
     */
    public static void checkBranchAccess(Integer resourceCoSoId, Integer managerCoSoId) {
        if (resourceCoSoId == null) {
            throw new IllegalArgumentException("Resource không thuộc về cơ sở nào");
        }

        if (managerCoSoId == null) {
            throw new IllegalArgumentException("Manager chưa được liên kết với cơ sở nào");
        }

        if (!resourceCoSoId.equals(managerCoSoId)) {
            throw new IllegalArgumentException(
                String.format(
                    "Resource thuộc cơ sở %d, không có quyền truy cập từ cơ sở %d",
                    resourceCoSoId, managerCoSoId
                )
            );
        }
    }

    /**
     * Check if resource belongs to manager's branch (boolean version)
     *
     * @param resourceCoSoId CoSoID của resource
     * @param managerCoSoId CoSoID của manager
     * @return true nếu thuộc cùng branch, false nếu không
     */
    public static boolean belongsToBranch(Integer resourceCoSoId, Integer managerCoSoId) {
        if (resourceCoSoId == null || managerCoSoId == null) {
            return false;
        }
        return resourceCoSoId.equals(managerCoSoId);
    }

    /**
     * Validate và lấy entity, throw IllegalArgumentException nếu null
     *
     * @param entity Entity cần check
     * @param entityName Tên entity cho error message
     * @param <T> Type của entity
     * @return entity nếu không null
     * @throws IllegalArgumentException nếu entity == null
     */
    public static <T> T getEntityOrThrow(T entity, String entityName) {
        if (entity == null) {
            throw new IllegalArgumentException(entityName + " không tồn tại");
        }
        return entity;
    }

    /**
     * Validate và check branch access cho entity có CoSoID
     *
     * @param entityCoSoId CoSoID của entity
     * @param managerCoSoId CoSoID của manager
     * @param entityName Tên entity cho error message
     * @throws IllegalArgumentException nếu không cùng branch
     */
    public static void validateBranchAccess(Integer entityCoSoId, Integer managerCoSoId, String entityName) {
        if (entityCoSoId == null) {
            throw new IllegalArgumentException(entityName + " chưa được liên kết với cơ sở nào");
        }

        if (!entityCoSoId.equals(managerCoSoId)) {
            throw new IllegalArgumentException(
                String.format(
                    "%s thuộc cơ sở %d, bạn chỉ có quyền quản lý cơ sở %d",
                    entityName, entityCoSoId, managerCoSoId
                )
            );
        }
    }
}
