package org.example.dao;

import org.example.dto.CustomerBookingHistoryItem;
import java.util.List;

public interface CustomerBookingDAO {
    List<CustomerBookingHistoryItem> getBookingHistory(int accountId);
    CustomerBookingHistoryItem getBookingByDatSanId(int datSanId, int accountId);
}
