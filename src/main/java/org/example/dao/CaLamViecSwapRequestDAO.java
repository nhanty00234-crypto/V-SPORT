package org.example.dao;

import org.example.model.CaLamViecSwapRequest;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public interface CaLamViecSwapRequestDAO {
    boolean insert(CaLamViecSwapRequest request);
    boolean update(CaLamViecSwapRequest request);
    CaLamViecSwapRequest getById(int swapRequestId);
    List<CaLamViecSwapRequest> getByCoSo(int coSoId);
    List<CaLamViecSwapRequest> getByAccount(int accountId);

    /**
     * Update swap request trong một transaction hiện có.
     */
    boolean updateWithConnection(CaLamViecSwapRequest sr, Connection conn) throws SQLException;

    /**
     * Kiểm tra có pending swap request nào cho ca này không (ChoXacNhan hoặc ChoQuanLyDuyet).
     */
    boolean hasPendingForShift(int caLamViecId);
}
