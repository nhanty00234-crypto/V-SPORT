package org.example.dao;

import org.example.model.CaLamViecAvailability;
import java.time.LocalDate;
import java.util.List;

public interface CaLamViecAvailabilityDAO {
    boolean insert(CaLamViecAvailability avail);
    boolean delete(int availabilityId);
    List<CaLamViecAvailability> getByCoSo(int coSoId);
    List<CaLamViecAvailability> getByAccount(int accountId);
    List<CaLamViecAvailability> getByCoSoAndDateRange(int coSoId, LocalDate start, LocalDate end);
}
