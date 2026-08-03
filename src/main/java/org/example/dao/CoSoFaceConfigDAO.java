package org.example.dao;

import org.example.model.CoSoFaceConfig;

public interface CoSoFaceConfigDAO {
    CoSoFaceConfig findByCoSo(int coSoId);
    void upsert(CoSoFaceConfig config);
}
