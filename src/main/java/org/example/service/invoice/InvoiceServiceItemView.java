package org.example.service.invoice;

/** Một dòng dịch vụ/nước uống trên hóa đơn - giá và thành tiền đã CHỐT tại thời điểm bán. */
public class InvoiceServiceItemView {
    private final String name;
    private final int quantity;
    private final double unitPrice;
    private final double amount;

    public InvoiceServiceItemView(String name, int quantity, double unitPrice, double amount) {
        this.name = name;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.amount = amount;
    }

    public String getName() { return name; }
    public int getQuantity() { return quantity; }
    public double getUnitPrice() { return unitPrice; }
    public double getAmount() { return amount; }
}
