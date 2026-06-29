$connString = "Server=14.225.217.109,1433;Database=QuanLiSport;User Id=sa;Password=TOP1@iyounguru!;Encrypt=true;TrustServerCertificate=true;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    $cmd.CommandText = "SELECT name, is_identity FROM sys.columns WHERE object_id = OBJECT_ID('DanhMucSanPham')"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Output "$($reader['name']) | Identity:$($reader['is_identity'])"
    }
    $reader.Close()
} catch {
    Write-Error $_.Exception.Message
} finally {
    $conn.Close()
}
