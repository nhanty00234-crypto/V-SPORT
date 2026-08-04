# 10 — Quan hệ suy luận (KHÔNG phải Foreign Key vật lý)

Các cột dưới đây được source code dùng như khóa ngoại nhưng **không có FK vật lý**
trong snapshot DB 2026-08-02 và cũng không có trong migration SQL.
Tất cả đều có `IsPhysicalFK = false`. Không trộn với 04-foreign-keys.csv.

## `Accounts.DeletedBy` → `Accounts.AccountID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (0..N → 1)
- **Cột nguồn**: `Accounts.DeletedBy` (INT, NULL)
- **Bảng đích**: `Accounts`
- **Bằng chứng source**: `src/main/java/org/example/dao/CustomerProfileDAO.java`, `src/main/java/org/example/dao/CheckInDAO.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `Accounts` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Trung bình
- **Nên bổ sung FK thật?**: Cân nhắc — cột cho phép NULL, có thể là quan hệ tùy chọn

## `AdminTrash.DeletedBy` → `Accounts.AccountID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (0..N → 1)
- **Cột nguồn**: `AdminTrash.DeletedBy` (INT, NULL)
- **Bảng đích**: `Accounts`
- **Bằng chứng source**: `src/main/java/org/example/dao/AdminTrashDAO.java`, `src/main/java/org/example/dao/impl/AdminTrashDAOImpl.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `Accounts` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Trung bình
- **Nên bổ sung FK thật?**: Cân nhắc — cột cho phép NULL, có thể là quan hệ tùy chọn

## `AuditLog.CoSoID` → `CoSo.CoSoID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (0..N → 1)
- **Cột nguồn**: `AuditLog.CoSoID` (INT, NULL)
- **Bảng đích**: `CoSo`
- **Bằng chứng source**: `src/main/java/org/example/dao/AuditLogDAO.java`, `src/main/java/org/example/dao/impl/AuditLogDAOImpl.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `CoSo` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Cao
- **Nên bổ sung FK thật?**: Cân nhắc — cột cho phép NULL, có thể là quan hệ tùy chọn

## `CaLamViec.DeletedBy` → `Accounts.AccountID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (0..N → 1)
- **Cột nguồn**: `CaLamViec.DeletedBy` (INT, NULL)
- **Bảng đích**: `Accounts`
- **Bằng chứng source**: `src/main/java/org/example/dao/CaLamViecDAO.java`, `src/main/java/org/example/dao/impl/CaLamViecAuditDAOImpl.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `Accounts` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Trung bình
- **Nên bổ sung FK thật?**: Cân nhắc — cột cho phép NULL, có thể là quan hệ tùy chọn

## `CaLamViec_Audit.CaLamViecID` → `CaLamViec.CaLamViecID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (1..N → 1)
- **Cột nguồn**: `CaLamViec_Audit.CaLamViecID` (INT, NOT NULL)
- **Bảng đích**: `CaLamViec`
- **Bằng chứng source**: `src/main/java/org/example/dao/CaLamViecAuditDAO.java`, `src/main/java/org/example/dao/impl/CaLamViecAuditDAOImpl.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `CaLamViec` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Cao
- **Nên bổ sung FK thật?**: Nên — cột bắt buộc, thiếu FK dễ sinh dữ liệu mồ côi

## `CoSo.DeletedBy` → `Accounts.AccountID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (0..N → 1)
- **Cột nguồn**: `CoSo.DeletedBy` (INT, NULL)
- **Bảng đích**: `Accounts`
- **Bằng chứng source**: `src/main/java/org/example/dao/PayOSConfigDAO.java`, `src/main/java/org/example/dao/GhepKeoDAO.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `Accounts` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Trung bình
- **Nên bổ sung FK thật?**: Cân nhắc — cột cho phép NULL, có thể là quan hệ tùy chọn

## `FaceChallengeToken.CaLamViecID` → `CaLamViec.CaLamViecID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (1..N → 1)
- **Cột nguồn**: `FaceChallengeToken.CaLamViecID` (INT, NOT NULL)
- **Bảng đích**: `CaLamViec`
- **Bằng chứng source**: `src/main/java/org/example/dao/FaceChallengeTokenDAO.java`, `src/main/java/org/example/dao/impl/FaceChallengeTokenDAOImpl.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `CaLamViec` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Cao
- **Nên bổ sung FK thật?**: Nên — cột bắt buộc, thiếu FK dễ sinh dữ liệu mồ côi

## `HoanTien.DatSanID` → `LichDatSan.DatSanID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (0..N → 1)
- **Cột nguồn**: `HoanTien.DatSanID` (INT, NULL)
- **Bảng đích**: `LichDatSan`
- **Bằng chứng source**: `src/main/java/org/example/dao/HoanTienDAO.java`, `src/main/java/org/example/dao/HoaDonDAO.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `LichDatSan` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Cao
- **Nên bổ sung FK thật?**: Cân nhắc — cột cho phép NULL, có thể là quan hệ tùy chọn

## `HoanTien.CoSoID` → `CoSo.CoSoID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (0..N → 1)
- **Cột nguồn**: `HoanTien.CoSoID` (INT, NULL)
- **Bảng đích**: `CoSo`
- **Bằng chứng source**: `src/main/java/org/example/dao/HoanTienDAO.java`, `src/main/java/org/example/dao/HoaDonDAO.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `CoSo` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Cao
- **Nên bổ sung FK thật?**: Cân nhắc — cột cho phép NULL, có thể là quan hệ tùy chọn

## `LichDatSan.DeletedBy` → `Accounts.AccountID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (0..N → 1)
- **Cột nguồn**: `LichDatSan.DeletedBy` (INT, NULL)
- **Bảng đích**: `Accounts`
- **Bằng chứng source**: `src/main/java/org/example/dao/CheckInDAO.java`, `src/main/java/org/example/dao/GhepKeoDAO.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `Accounts` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Trung bình
- **Nên bổ sung FK thật?**: Cân nhắc — cột cho phép NULL, có thể là quan hệ tùy chọn

## `LichSuKhuyenMai.DatSanID` → `LichDatSan.DatSanID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (0..N → 1)
- **Cột nguồn**: `LichSuKhuyenMai.DatSanID` (INT, NULL)
- **Bảng đích**: `LichDatSan`
- **Bằng chứng source**: `src/main/java/org/example/service/customer/PromotionService.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `LichDatSan` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Cao
- **Nên bổ sung FK thật?**: Cân nhắc — cột cho phép NULL, có thể là quan hệ tùy chọn

## `LoaiSan.DeletedBy` → `Accounts.AccountID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (0..N → 1)
- **Cột nguồn**: `LoaiSan.DeletedBy` (INT, NULL)
- **Bảng đích**: `Accounts`
- **Bằng chứng source**: `src/main/java/org/example/dao/CheckInDAO.java`, `src/main/java/org/example/dao/CoSoDAO.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `Accounts` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Trung bình
- **Nên bổ sung FK thật?**: Cân nhắc — cột cho phép NULL, có thể là quan hệ tùy chọn

## `LoaiSan_KhungGioDen_Backup.LoaiSanID` → `LoaiSan.LoaiSanID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (1..N → 1)
- **Cột nguồn**: `LoaiSan_KhungGioDen_Backup.LoaiSanID` (INT, NOT NULL)
- **Bảng đích**: `LoaiSan`
- **Bằng chứng source**: _không tìm thấy file tham chiếu trực tiếp_
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `LoaiSan` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Cao
- **Nên bổ sung FK thật?**: Nên — cột bắt buộc, thiếu FK dễ sinh dữ liệu mồ côi

## `LoaiSan_KhungGioDen_Backup.DeletedBy` → `Accounts.AccountID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (0..N → 1)
- **Cột nguồn**: `LoaiSan_KhungGioDen_Backup.DeletedBy` (INT, NULL)
- **Bảng đích**: `Accounts`
- **Bằng chứng source**: _không tìm thấy file tham chiếu trực tiếp_
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `Accounts` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Trung bình
- **Nên bổ sung FK thật?**: Cân nhắc — cột cho phép NULL, có thể là quan hệ tùy chọn

## `San.DeletedBy` → `Accounts.AccountID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (0..N → 1)
- **Cột nguồn**: `San.DeletedBy` (INT, NULL)
- **Bảng đích**: `Accounts`
- **Bằng chứng source**: `src/main/java/org/example/dao/SanDAO.java`, `src/main/java/org/example/dao/CheckInDAO.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `Accounts` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Trung bình
- **Nên bổ sung FK thật?**: Cân nhắc — cột cho phép NULL, có thể là quan hệ tùy chọn

## `SanPham_DichVu.DeletedBy` → `Accounts.AccountID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (0..N → 1)
- **Cột nguồn**: `SanPham_DichVu.DeletedBy` (INT, NULL)
- **Bảng đích**: `Accounts`
- **Bằng chứng source**: `src/main/java/org/example/dao/SanPhamDichVuDAO.java`, `src/main/java/org/example/dao/CheckInDAO.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `Accounts` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Trung bình
- **Nên bổ sung FK thật?**: Cân nhắc — cột cho phép NULL, có thể là quan hệ tùy chọn

## `SuCo.SanID` → `San.SanID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (0..N → 1)
- **Cột nguồn**: `SuCo.SanID` (INT, NULL)
- **Bảng đích**: `San`
- **Bằng chứng source**: `src/main/java/org/example/dao/SuCoDAO.java`, `src/main/java/org/example/dao/impl/SuCoDAOImpl.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `San` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Cao
- **Nên bổ sung FK thật?**: Cân nhắc — cột cho phép NULL, có thể là quan hệ tùy chọn

## `SuCo.XuLyBoi` → `Accounts.AccountID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (0..N → 1)
- **Cột nguồn**: `SuCo.XuLyBoi` (INT, NULL)
- **Bảng đích**: `Accounts`
- **Bằng chứng source**: `src/main/java/org/example/dao/SuCoDAO.java`, `src/main/java/org/example/dao/impl/SuCoDAOImpl.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `Accounts` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Trung bình
- **Nên bổ sung FK thật?**: Cân nhắc — cột cho phép NULL, có thể là quan hệ tùy chọn

## `Teams.DeletedBy` → `Accounts.AccountID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (0..N → 1)
- **Cột nguồn**: `Teams.DeletedBy` (INT, NULL)
- **Bảng đích**: `Accounts`
- **Bằng chứng source**: `src/main/java/org/example/dao/TeamDAO.java`, `src/main/java/org/example/dao/TeamMatchDAO.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `Accounts` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Trung bình
- **Nên bổ sung FK thật?**: Cân nhắc — cột cho phép NULL, có thể là quan hệ tùy chọn

## `ThongBao.DeletedBy` → `Accounts.AccountID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (0..N → 1)
- **Cột nguồn**: `ThongBao.DeletedBy` (INT, NULL)
- **Bảng đích**: `Accounts`
- **Bằng chứng source**: `src/main/java/org/example/dao/ThongBaoDAO.java`, `src/main/java/org/example/dao/impl/ThongBaoDAOImpl.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `Accounts` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Trung bình
- **Nên bổ sung FK thật?**: Cân nhắc — cột cho phép NULL, có thể là quan hệ tùy chọn

## `YeuCauNghi.DeletedBy` → `Accounts.AccountID`

- **IsPhysicalFK**: false
- **Loại quan hệ dự kiến**: ONE_TO_MANY (0..N → 1)
- **Cột nguồn**: `YeuCauNghi.DeletedBy` (INT, NULL)
- **Bảng đích**: `Accounts`
- **Bằng chứng source**: `src/main/java/org/example/dao/YeuCauNghiDAO.java`, `src/main/java/org/example/dao/impl/YeuCauNghiDAOImpl.java`
- **Logic liên quan**: cột được đọc/ghi kèm join hoặc lookup sang `Accounts` trong DAO/Service tương ứng.
- **Mức độ tin cậy**: Trung bình
- **Nên bổ sung FK thật?**: Cân nhắc — cột cho phép NULL, có thể là quan hệ tùy chọn

---

Tổng số quan hệ suy luận: **21**.
