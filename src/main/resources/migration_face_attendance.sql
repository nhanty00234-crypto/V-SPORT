-- migration_face_attendance.sql
-- Bước 1: Thêm cột face vào TaiKhoan
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('TaiKhoan') AND name='FaceDescriptor')
    ALTER TABLE TaiKhoan ADD FaceDescriptor NVARCHAR(MAX) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('TaiKhoan') AND name='FaceImagePath')
    ALTER TABLE TaiKhoan ADD FaceImagePath NVARCHAR(500) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('TaiKhoan') AND name='FaceEnrolledAt')
    ALTER TABLE TaiKhoan ADD FaceEnrolledAt DATETIME NULL;

-- Bước 2: Thêm cột face audit vào CaLamViec
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('CaLamViec') AND name='FaceVerified')
    ALTER TABLE CaLamViec ADD FaceVerified BIT NOT NULL DEFAULT 0;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('CaLamViec') AND name='FaceCheckInImage')
    ALTER TABLE CaLamViec ADD FaceCheckInImage NVARCHAR(500) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('CaLamViec') AND name='FaceConfidence')
    ALTER TABLE CaLamViec ADD FaceConfidence FLOAT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('CaLamViec') AND name='FaceLivenessPassed')
    ALTER TABLE CaLamViec ADD FaceLivenessPassed BIT NOT NULL DEFAULT 0;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('CaLamViec') AND name='FaceCheckOutImage')
    ALTER TABLE CaLamViec ADD FaceCheckOutImage NVARCHAR(500) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('CaLamViec') AND name='FaceCheckOutConfidence')
    ALTER TABLE CaLamViec ADD FaceCheckOutConfidence FLOAT NULL;

-- Bước 3: Tạo bảng CoSoFaceConfig
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE type='U' AND name='CoSoFaceConfig')
CREATE TABLE CoSoFaceConfig (
    CoSoID        INT PRIMARY KEY,
    FaceRequired  BIT NOT NULL DEFAULT 0,
    ConfidenceMin FLOAT NOT NULL DEFAULT 0.6,
    UpdatedAt     DATETIME NULL,
    CONSTRAINT FK_FaceConfig_CoSo FOREIGN KEY (CoSoID) REFERENCES CoSo(CoSoID)
);

-- Bước 4: Tạo bảng FaceChallengeToken
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE type='U' AND name='FaceChallengeToken')
CREATE TABLE FaceChallengeToken (
    TokenID    VARCHAR(64)   PRIMARY KEY,
    AccountID  INT           NOT NULL,
    CaLamViecID INT          NOT NULL,
    Action     VARCHAR(10)   NOT NULL DEFAULT 'checkin',  -- 'checkin' hoặc 'checkout'
    Challenges NVARCHAR(200) NOT NULL,   -- JSON: ["blink","turn_left"]
    CreatedAt  DATETIME      NOT NULL DEFAULT GETDATE(),
    ExpiresAt  DATETIME      NOT NULL,
    UsedAt     DATETIME      NULL,
    CONSTRAINT FK_FaceToken_TaiKhoan FOREIGN KEY (AccountID) REFERENCES TaiKhoan(AccountID)
);
