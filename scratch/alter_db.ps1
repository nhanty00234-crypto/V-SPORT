$connString = "Server=14.225.217.109,1433;Database=QuanLiSport;User Id=sa;Password=TOP1@iyounguru!;Encrypt=true;TrustServerCertificate=true;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    Write-Output "Altering table SanPham_DichVu..."
    
    # 1. Add SkuCode if not exists
    $cmd.CommandText = "IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'SkuCode' AND Object_ID = Object_ID(N'SanPham_DichVu'))
                        ALTER TABLE SanPham_DichVu ADD SkuCode NVARCHAR(50) NULL;"
    $cmd.ExecuteNonQuery()
    Write-Output "SkuCode column added or already exists."

    # 2. Add GiaNhap if not exists
    $cmd.CommandText = "IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'GiaNhap' AND Object_ID = Object_ID(N'SanPham_DichVu'))
                        ALTER TABLE SanPham_DichVu ADD GiaNhap FLOAT NULL;"
    $cmd.ExecuteNonQuery()
    Write-Output "GiaNhap column added or already exists."

    # 3. Add MoTa if not exists
    $cmd.CommandText = "IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'MoTa' AND Object_ID = Object_ID(N'SanPham_DichVu'))
                        ALTER TABLE SanPham_DichVu ADD MoTa NVARCHAR(255) NULL;"
    $cmd.ExecuteNonQuery()
    Write-Output "MoTa column added or already exists."

    Write-Output "Database update finished successfully."
} catch {
    Write-Error $_.Exception.Message
} finally {
    $conn.Close()
}
