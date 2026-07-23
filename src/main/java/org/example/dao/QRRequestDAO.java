package org.example.dao;

import org.example.model.QRRequest;
import java.util.List;

public interface QRRequestDAO {
    QRRequest save(QRRequest request);
    QRRequest findById(int requestId);
    List<QRRequest> findByGuestTokenAndSan(String guestToken, int sanId);
    List<QRRequest> findByCoSoAndStatus(int coSoId, String status);
    long countByCoSoAndStatus(int coSoId, String status);
}
