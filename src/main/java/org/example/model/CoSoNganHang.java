package org.example.model;

/** Cấu hình tài khoản ngân hàng nhận chuyển khoản của một cơ sở (CoSo). Chỉ đọc, không qua JPA. */
public class CoSoNganHang {
    private final int coSoId;
    private final String bankName;
    private final String bankShortCode;
    private final String accountName;
    private final String accountNumber;

    public CoSoNganHang(int coSoId, String bankName, String bankShortCode, String accountName, String accountNumber) {
        this.coSoId = coSoId;
        this.bankName = bankName;
        this.bankShortCode = bankShortCode;
        this.accountName = accountName;
        this.accountNumber = accountNumber;
    }

    public int getCoSoId() { return coSoId; }
    public String getBankName() { return bankName; }
    public String getBankShortCode() { return bankShortCode; }
    public String getAccountName() { return accountName; }
    public String getAccountNumber() { return accountNumber; }

    public boolean isConfigured() {
        return bankName != null && !bankName.isBlank()
                && bankShortCode != null && !bankShortCode.isBlank()
                && accountName != null && !accountName.isBlank()
                && accountNumber != null && !accountNumber.isBlank();
    }
}
