package org.example.dto.booking;

/**
 * Result DTO for booking approval and rejection decisions by Manager/Staff.
 */
public class BookingDecisionResult {
    private final boolean success;
    private final int datSanId;
    private final int customerAccountId;
    private final int coSoId;
    private final String previousStatus;
    private final String newStatus;
    private final String message;

    public BookingDecisionResult(boolean success, int datSanId, int customerAccountId, int coSoId,
                                 String previousStatus, String newStatus, String message) {
        this.success = success;
        this.datSanId = datSanId;
        this.customerAccountId = customerAccountId;
        this.coSoId = coSoId;
        this.previousStatus = previousStatus;
        this.newStatus = newStatus;
        this.message = message;
    }

    public boolean isSuccess() {
        return success;
    }

    public int getDatSanId() {
        return datSanId;
    }

    public int getCustomerAccountId() {
        return customerAccountId;
    }

    public int getCoSoId() {
        return coSoId;
    }

    public String getPreviousStatus() {
        return previousStatus;
    }

    public String getNewStatus() {
        return newStatus;
    }

    public String getMessage() {
        return message;
    }
}
