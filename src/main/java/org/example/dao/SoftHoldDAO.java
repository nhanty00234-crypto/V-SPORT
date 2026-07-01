package org.example.dao;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

public interface SoftHoldDAO {

    class HoldResult {
        public final boolean success;
        public final String errorMessage;
        public final LocalDateTime expiresAt;
        public HoldResult(boolean success, String errorMessage, LocalDateTime expiresAt) {
            this.success = success;
            this.errorMessage = errorMessage;
            this.expiresAt = expiresAt;
        }
    }

    HoldResult createHold(int accountId, int sanId, LocalDate ngayDat,
                           LocalTime gioBatDau, LocalTime gioKetThuc);

    void deleteExpiredHolds();

    void deleteHoldsByAccountAndSan(int accountId, int sanId, LocalDate ngayDat);
}
