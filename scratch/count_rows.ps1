$connString = "Server=14.225.217.109,1433;Database=QuanLiSport;User Id=sa;Password=TOP1@iyounguru!;Encrypt=true;TrustServerCertificate=true;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    $cmd.CommandText = "SELECT COUNT(*) FROM LichDatSan"
    $count1 = $cmd.ExecuteScalar()
    
    $cmd.CommandText = "SELECT COUNT(*) FROM HoaDon"
    $count2 = $cmd.ExecuteScalar()
    
    Write-Output "LichDatSan count: $count1"
    Write-Output "HoaDon count: $count2"
} catch {
    Write-Error $_.Exception.Message
} finally {
    $conn.Close()
}
