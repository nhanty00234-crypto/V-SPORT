package org.example.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Một dòng lịch sử điểm danh bằng khuôn mặt, đã join sẵn tên nhân viên.
 * Chỉ dùng cho màn hình quản lý (read-only) nên không có setter thừa.
 */
public class FaceAttendanceLog {

    private int caLamViecId;
    private int accountId;
    private String fullName;
    private int roleId;
    private String tenCa;
    private LocalDate ngayLam;
    private LocalDateTime gioVaoThuc;
    private LocalDateTime gioRaThuc;
    private Double faceConfidence;
    private Double faceCheckOutConfidence;
    private boolean faceLivenessPassed;
    private String faceCheckInImage;
    private String faceCheckOutImage;

    public int getCaLamViecId() { return caLamViecId; }
    public void setCaLamViecId(int caLamViecId) { this.caLamViecId = caLamViecId; }
    public int getAccountId() { return accountId; }
    public void setAccountId(int accountId) { this.accountId = accountId; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public int getRoleId() { return roleId; }
    public void setRoleId(int roleId) { this.roleId = roleId; }
    public String getTenCa() { return tenCa; }
    public void setTenCa(String tenCa) { this.tenCa = tenCa; }
    public LocalDate getNgayLam() { return ngayLam; }
    public void setNgayLam(LocalDate ngayLam) { this.ngayLam = ngayLam; }
    public LocalDateTime getGioVaoThuc() { return gioVaoThuc; }
    public void setGioVaoThuc(LocalDateTime gioVaoThuc) { this.gioVaoThuc = gioVaoThuc; }
    public LocalDateTime getGioRaThuc() { return gioRaThuc; }
    public void setGioRaThuc(LocalDateTime gioRaThuc) { this.gioRaThuc = gioRaThuc; }
    public Double getFaceConfidence() { return faceConfidence; }
    public void setFaceConfidence(Double faceConfidence) { this.faceConfidence = faceConfidence; }
    public Double getFaceCheckOutConfidence() { return faceCheckOutConfidence; }
    public void setFaceCheckOutConfidence(Double faceCheckOutConfidence) { this.faceCheckOutConfidence = faceCheckOutConfidence; }
    public boolean isFaceLivenessPassed() { return faceLivenessPassed; }
    public void setFaceLivenessPassed(boolean faceLivenessPassed) { this.faceLivenessPassed = faceLivenessPassed; }
    public String getFaceCheckInImage() { return faceCheckInImage; }
    public void setFaceCheckInImage(String faceCheckInImage) { this.faceCheckInImage = faceCheckInImage; }
    public String getFaceCheckOutImage() { return faceCheckOutImage; }
    public void setFaceCheckOutImage(String faceCheckOutImage) { this.faceCheckOutImage = faceCheckOutImage; }
}
