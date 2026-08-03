package org.example.dao;

import org.example.model.FaceChallengeToken;

public interface FaceChallengeTokenDAO {
    void insert(FaceChallengeToken token);
    FaceChallengeToken findById(String tokenId);
    void markUsed(String tokenId);
    void deleteExpired();
}
