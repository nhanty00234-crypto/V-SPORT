package org.example.dao;

import org.example.model.CaLamViecAudit;
import java.util.List;

public interface CaLamViecAuditDAO {
    boolean insert(CaLamViecAudit audit);
    List<CaLamViecAudit> getByCaLamViec(int caLamViecId);
    List<CaLamViecAudit> getByCoSo(int coSoId);
}
