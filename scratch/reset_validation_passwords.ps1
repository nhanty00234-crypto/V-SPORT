$connString = "Server=14.225.217.109,1433;Database=QuanLiSport;User Id=sa;Password=TOP1@iyounguru!;Encrypt=true;TrustServerCertificate=true;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    # Hash for password 'Password123!'
    $hash = '$2a$12$HmQZRPLMecf/idT9Kn20vOplJTQkcRvwfwZiyuaP9Orup2PUe89le'
    
    $cmd.CommandText = "UPDATE Accounts SET Password = '$hash' WHERE Username IN ('nhan111', 'nhanty00234@gmail.com', 'LeTan01', 'BaoKhachHang')"
    $rows = $cmd.ExecuteNonQuery()
    Write-Output "Updated $rows user accounts to 'Password123!'"
} catch {
    Write-Error $_.Exception.Message
} finally {
    $conn.Close()
}
