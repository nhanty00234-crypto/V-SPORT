package org.example.dao;

import org.example.model.SanQR;

import java.util.UUID;

public interface SanQRDAO {
    SanQR findBySanId(int sanId);
    SanQR findByToken(UUID token);
    SanQR findById(int sanQRId);
}
