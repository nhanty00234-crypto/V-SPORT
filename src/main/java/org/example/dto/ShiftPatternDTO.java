package org.example.dto;

/**
 * DTO đại diện cho một ca làm định kỳ (theo thứ trong tuần)
 */
public class ShiftPatternDTO {
    private int thu; // 2=Thứ 2, 3=Thứ 3, ..., 8=Chủ nhật
    private String gioBatDau; // Format: HH:mm
    private String gioKetThuc; // Format: HH:mm

    public ShiftPatternDTO() {
    }

    public ShiftPatternDTO(int thu, String gioBatDau, String gioKetThuc) {
        this.thu = thu;
        this.gioBatDau = gioBatDau;
        this.gioKetThuc = gioKetThuc;
    }

    public int getThu() {
        return thu;
    }

    public void setThu(int thu) {
        this.thu = thu;
    }

    public String getGioBatDau() {
        return gioBatDau;
    }

    public void setGioBatDau(String gioBatDau) {
        this.gioBatDau = gioBatDau;
    }

    public String getGioKetThuc() {
        return gioKetThuc;
    }

    public void setGioKetThuc(String gioKetThuc) {
        this.gioKetThuc = gioKetThuc;
    }
}
