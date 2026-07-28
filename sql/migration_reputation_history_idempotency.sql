-- Migration: Bổ sung Unique Filtered Index cho CustomerReputationHistory chống trùng lặp điểm
USE QuanLiSport;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UQ_ReputationHistory_Account_DatSan_Action' AND object_id = OBJECT_ID(N'CustomerReputationHistory'))
BEGIN
    CREATE UNIQUE INDEX UQ_ReputationHistory_Account_DatSan_Action 
    ON CustomerReputationHistory(AccountID, DatSanID, ActionType) 
    WHERE DatSanID IS NOT NULL;
    PRINT N'Đã tạo UNIQUE index UQ_ReputationHistory_Account_DatSan_Action.';
END
ELSE
    PRINT N'Index UQ_ReputationHistory_Account_DatSan_Action đã tồn tại, bỏ qua.';
GO
