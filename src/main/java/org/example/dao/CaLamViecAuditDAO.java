package org.example.dao;

import org.example.model.CaLamViecAudit;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public interface CaLamViecAuditDAO {
    boolean insert(CaLamViecAudit audit);
    boolean insertWithConnection(CaLamViecAudit audit, Connection conn) throws SQLException;
    List<CaLamViecAudit> getByCaLamViec(int caLamViecId);
    List<CaLamViecAudit> getByCoSo(int coSoId);
}
