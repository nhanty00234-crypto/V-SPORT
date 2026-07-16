-- Migration idempotent cho luồng chốt giờ/thanh toán sân (SQL Server).
USE QuanLiSport;
GO

-- Giữ cột TIME cũ để tương thích; logic mới ưu tiên DATETIME2 nhằm hỗ trợ ca qua ngày.
IF COL_LENGTH(N'LichDatSan', N'ActualStartAt') IS NULL
    ALTER TABLE LichDatSan ADD ActualStartAt DATETIME2 NULL;
IF COL_LENGTH(N'LichDatSan', N'ActualEndAt') IS NULL
    ALTER TABLE LichDatSan ADD ActualEndAt DATETIME2 NULL;
IF COL_LENGTH(N'LichDatSan', N'PricingFinalizedAt') IS NULL
    ALTER TABLE LichDatSan ADD PricingFinalizedAt DATETIME2 NULL;
GO

-- Schema V4 cũ chỉ có giờ bắt đầu lên đèn. Thiếu giờ kết thúc sẽ fallback giá không đèn.
IF COL_LENGTH(N'LoaiSan', N'GioKetThucLenDen') IS NULL
    ALTER TABLE LoaiSan ADD GioKetThucLenDen TIME NULL;
GO

IF OBJECT_ID(N'CourtChargeSegment', N'U') IS NULL
BEGIN
    CREATE TABLE CourtChargeSegment (
        SegmentID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_CourtChargeSegment PRIMARY KEY,
        HoaDonID INT NOT NULL,
        DatSanID INT NOT NULL,
        SegmentOrder INT NOT NULL,
        StartAt DATETIME2 NOT NULL,
        EndAt DATETIME2 NOT NULL,
        DurationMinutes INT NOT NULL,
        RateType NVARCHAR(30) NOT NULL,
        HourlyRate DECIMAL(18,2) NOT NULL,
        Amount DECIMAL(18,2) NOT NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_CourtChargeSegment_CreatedAt DEFAULT GETDATE(),
        CONSTRAINT FK_CourtChargeSegment_HoaDon FOREIGN KEY (HoaDonID) REFERENCES HoaDon(HoaDonID),
        CONSTRAINT FK_CourtChargeSegment_LichDatSan FOREIGN KEY (DatSanID) REFERENCES LichDatSan(DatSanID),
        CONSTRAINT CK_CourtChargeSegment_Duration CHECK (DurationMinutes > 0),
        CONSTRAINT CK_CourtChargeSegment_RateType CHECK (RateType IN (N'WITHOUT_LIGHT', N'WITH_LIGHT')),
        CONSTRAINT CK_CourtChargeSegment_Amounts CHECK (HourlyRate >= 0 AND Amount >= 0)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'CourtChargeSegment') AND name = N'UX_CourtChargeSegment_InvoiceOrder')
    CREATE UNIQUE INDEX UX_CourtChargeSegment_InvoiceOrder ON CourtChargeSegment(HoaDonID, SegmentOrder);
GO

-- Sau khi migration LoaiHoaDon đã chạy, mỗi ca chỉ được có tối đa một MAIN invoice.
IF COL_LENGTH(N'HoaDon', N'LoaiHoaDon') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'HoaDon') AND name = N'UX_HoaDon_OneMainPerBooking')
BEGIN
    IF NOT EXISTS (
        SELECT DatSanID FROM HoaDon
        WHERE DatSanID IS NOT NULL AND (LoaiHoaDon = N'MAIN' OR LoaiHoaDon IS NULL)
        GROUP BY DatSanID HAVING COUNT(*) > 1
    )
        EXEC(N'CREATE UNIQUE INDEX UX_HoaDon_OneMainPerBooking ON HoaDon(DatSanID)
               WHERE DatSanID IS NOT NULL AND LoaiHoaDon = N''MAIN'';');
    ELSE
        PRINT N'Không tạo UX_HoaDon_OneMainPerBooking vì dữ liệu hiện tại có MAIN invoice trùng; cần xử lý dữ liệu trùng trước.';
END
GO