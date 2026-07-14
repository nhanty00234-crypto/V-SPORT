package org.example.dao;

import org.example.model.AdminTrash;

import java.util.List;

public interface AdminTrashDAO {
    // Ghi một bản ghi vào thùng rác chung khi Admin soft-delete một entity
    boolean log(String entityType, int entityId, String displayName, String sourceTable,
                String oldStatus, Integer deletedBy, String reason);

    AdminTrash getById(int trashId);

    // filter: null/"all" = tất cả loại; "restored"/"not_restored" áp dụng cho trạng thái thu hồi
    List<AdminTrash> search(String entityType, String restoredFilter, Integer deletedBy);

    boolean markRestored(int trashId, int restoredBy);
}
