$connString = "Server=14.225.217.109,1433;Database=QuanLiSport;User Id=sa;Password=TOP1@iyounguru!;Encrypt=true;TrustServerCertificate=true;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    # 1. Add TenCa
    $cmd.CommandText = "IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CaLamViec' AND COLUMN_NAME = 'TenCa') ALTER TABLE CaLamViec ADD TenCa NVARCHAR(50) NULL;"
    [void]$cmd.ExecuteNonQuery()
    Write-Output "TenCa column checked/added."

    # 2. Add ViTri
    $cmd.CommandText = "IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CaLamViec' AND COLUMN_NAME = 'ViTri') ALTER TABLE CaLamViec ADD ViTri NVARCHAR(50) NULL;"
    [void]$cmd.ExecuteNonQuery()
    Write-Output "ViTri column checked/added."

    # 3. Add TrangThai
    $cmd.CommandText = "IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CaLamViec' AND COLUMN_NAME = 'TrangThai') ALTER TABLE CaLamViec ADD TrangThai VARCHAR(30) NOT NULL DEFAULT 'Draft';"
    [void]$cmd.ExecuteNonQuery()
    Write-Output "TrangThai column checked/added."

    # 4. Add GioNghi
    $cmd.CommandText = "IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CaLamViec' AND COLUMN_NAME = 'GioNghi') ALTER TABLE CaLamViec ADD GioNghi INT NOT NULL DEFAULT 0;"
    [void]$cmd.ExecuteNonQuery()
    Write-Output "GioNghi column checked/added."

} catch {
    Write-Error $_.Exception.Message
} finally {
    $conn.Close()
}
