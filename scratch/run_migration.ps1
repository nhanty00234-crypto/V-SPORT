$connString = "Server=14.225.217.109,1433;Database=QuanLiSport;User Id=sa;Password=TOP1@iyounguru!;Encrypt=true;TrustServerCertificate=true;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    Write-Output "Running migration to add DuyetTrangThai and PhanHoi..."
    $cmd.CommandText = "ALTER TABLE CaLamViec_Availability ADD DuyetTrangThai VARCHAR(20) DEFAULT 'DaDuyet', PhanHoi NVARCHAR(255) NULL"
    $cmd.ExecuteNonQuery()
    Write-Output "Migration columns added successfully."
    
    $cmd.CommandText = "UPDATE CaLamViec_Availability SET DuyetTrangThai = 'DaDuyet' WHERE DuyetTrangThai IS NULL"
    $rows = $cmd.ExecuteNonQuery()
    Write-Output "Updated $rows existing records."
} catch {
    Write-Error $_.Exception.Message
} finally {
    $conn.Close()
}
