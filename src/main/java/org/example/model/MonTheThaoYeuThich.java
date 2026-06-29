package org.example.model;

import java.util.Date;

public class MonTheThaoYeuThich {
    private int AccountID;
    private int MonTheThaoID;
    private Date NgayThem;

    public MonTheThaoYeuThich() {
    }

    public MonTheThaoYeuThich(int accountID, int monTheThaoID, Date ngayThem) {
        AccountID = accountID;
        MonTheThaoID = monTheThaoID;
        NgayThem = ngayThem;
    }

    public int getAccountID() {
        return AccountID;
    }

    public void setAccountID(int accountID) {
        AccountID = accountID;
    }

    public int getMonTheThaoID() {
        return MonTheThaoID;
    }

    public void setMonTheThaoID(int monTheThaoID) {
        MonTheThaoID = monTheThaoID;
    }

    public Date getNgayThem() {
        return NgayThem;
    }

    public void setNgayThem(Date ngayThem) {
        NgayThem = ngayThem;
    }

    @Override
    public String toString() {
        return "MonTheThaoYeuThich{" +
                "AccountID=" + AccountID +
                ", MonTheThaoID=" + MonTheThaoID +
                ", NgayThem=" + NgayThem +
                '}';
    }
}
