package org.example.dao;

import org.example.model.CaLamViecSwapRequest;
import java.util.List;

public interface CaLamViecSwapRequestDAO {
    boolean insert(CaLamViecSwapRequest request);
    boolean update(CaLamViecSwapRequest request);
    CaLamViecSwapRequest getById(int swapRequestId);
    List<CaLamViecSwapRequest> getByCoSo(int coSoId);
    List<CaLamViecSwapRequest> getByAccount(int accountId);
}
