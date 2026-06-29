package org.example.model;

import java.util.Date;

public class NhatKySOSGui {
    private int nhatKySosGuiId;
    private int yeuCauSosId;
    private int accountIdNhanGui;
    private Date thoiGianGui;
    private boolean daXem;
    private String phanHoi;

    public NhatKySOSGui() {
    }

    public NhatKySOSGui(int nhatKySosGuiId, int yeuCauSosId, int accountIdNhanGui, Date thoiGianGui, boolean daXem, String phanHoi) {
        this.nhatKySosGuiId = nhatKySosGuiId;
        this.yeuCauSosId = yeuCauSosId;
        this.accountIdNhanGui = accountIdNhanGui;
        this.thoiGianGui = thoiGianGui;
        this.daXem = daXem;
        this.phanHoi = phanHoi;
    }

    public int getNhatKySosGuiId() {
        return nhatKySosGuiId;
    }

    public void setNhatKySosGuiId(int nhatKySosGuiId) {
        this.nhatKySosGuiId = nhatKySosGuiId;
    }

    public int getYeuCauSosId() {
        return yeuCauSosId;
    }

    public void setYeuCauSosId(int yeuCauSosId) {
        this.yeuCauSosId = yeuCauSosId;
    }

    public int getAccountIdNhanGui() {
        return accountIdNhanGui;
    }

    public void setAccountIdNhanGui(int accountIdNhanGui) {
        this.accountIdNhanGui = accountIdNhanGui;
    }

    public Date getThoiGianGui() {
        return thoiGianGui;
    }

    public void setThoiGianGui(Date thoiGianGui) {
        this.thoiGianGui = thoiGianGui;
    }

    public boolean getDaXem() {
        return daXem;
    }

    public void setDaXem(boolean daXem) {
        this.daXem = daXem;
    }

    public String getPhanHoi() {
        return phanHoi;
    }

    public void setPhanHoi(String phanHoi) {
        this.phanHoi = phanHoi;
    }

    @Override
    public String toString() {
        return "NhatKySOSGui{" +
                "nhatKySosGuiId=" + nhatKySosGuiId +
                ", yeuCauSosId=" + yeuCauSosId +
                ", accountIdNhanGui=" + accountIdNhanGui +
                ", thoiGianGui=" + thoiGianGui +
                ", daXem=" + daXem +
                ", phanHoi='" + phanHoi + '\'' +
                '}';
    }
}

