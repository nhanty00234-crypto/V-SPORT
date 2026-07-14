package org.example.dao;

import org.example.model.CoSo;
import java.util.List;

public interface CoSoDAO {
    List<CoSo> getAllCoSo();
    CoSo getCoSoById(int id);
    boolean addCoSo(CoSo coSo);
    boolean updateCoSo(CoSo coSo);
    boolean deleteCoSo(int id);

    // Soft-delete support (Task 5)
    boolean softDelete(int coSoId, int actorId);
    boolean restore(int coSoId);
    boolean hardDeleteCascade(int coSoId);
    List<CoSo> findDeleted();
    List<Integer> findDeletedIdsOlderThan(int days);

    // Soft-archive all rejected CoSo for an account except the one being approved
    boolean archiveRejectedForAccount(int accountId, int excludeCoSoId, int actorId);
}
