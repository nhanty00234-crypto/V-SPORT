package org.example.dao;

import java.util.List;

public interface CustomerBranchDAO {
    List<Object[]> getTopCustomers(int coSoId, boolean sortBySpending, int limit);
    List<Object[]> getBranchReviews(int coSoId);
    List<Object[]> getRiskBookings(int coSoId);
    List<Object[]> getHighRiskCancelers(int coSoId);
}
