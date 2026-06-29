$connString = "Server=14.225.217.109,1433;Database=QuanLiSport;User Id=sa;Password=TOP1@iyounguru!;Encrypt=true;TrustServerCertificate=true;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    Write-Output "=== UNIQUE BOOKING STATUSES IN LichDatSan ==="
    $cmd.CommandText = "SELECT DISTINCT TrangThai FROM LichDatSan"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Output $reader["TrangThai"]
    }
    $reader.Close()
    
    Write-Output "`n=== UNIQUE PAYMENT STATUSES IN HoaDon ==="
    $cmd.CommandText = "SELECT DISTINCT TrangThaiThanhToan FROM HoaDon"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Output $reader["TrangThaiThanhToan"]
    }
    $reader.Close()
} catch {
    Write-Error $_.Exception.Message
} finally {
    $conn.Close()
}
