$connString = "Server=14.225.217.109,1433;Database=QuanLiSport;User Id=sa;Password=TOP1@iyounguru!;Encrypt=true;TrustServerCertificate=true;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
try {
    $conn.Open()
    
    # Hash matching '123456'
    $hash123456 = '$2a$12$mBaBJ7gq70IqSGlOlZWmMub/SctCvSKqaFXsGhFiclCoNr5UGKwU2'
    
    # Restore admin
    $cmd0 = $conn.CreateCommand()
    $cmd0.CommandText = "UPDATE Accounts SET Password = '$hash123456' WHERE Username = 'nhan111'"
    $rows0 = $cmd0.ExecuteNonQuery()

    # Restore manager
    $cmd1 = $conn.CreateCommand()
    $cmd1.CommandText = "UPDATE Accounts SET Password = '$hash123456' WHERE Username = 'nhanty00234@gmail.com'"
    $rows1 = $cmd1.ExecuteNonQuery()
    
    # Restore staff
    $cmd2 = $conn.CreateCommand()
    $cmd2.CommandText = "UPDATE Accounts SET Password = '$hash123456' WHERE Username = 'LeTan01'"
    $rows2 = $cmd2.ExecuteNonQuery()

    # Restore customer
    $cmd3 = $conn.CreateCommand()
    $cmd3.CommandText = "UPDATE Accounts SET Password = '$hash123456' WHERE Username = 'BaoKhachHang'"
    $rows3 = $cmd3.ExecuteNonQuery()
    
    Write-Output "Successfully updated passwords to '123456':"
    Write-Output "Admin (nhan111): $rows0 row(s)"
    Write-Output "Manager (nhanty00234@gmail.com): $rows1 row(s)"
    Write-Output "Staff (LeTan01): $rows2 row(s)"
    Write-Output "Customer (BaoKhachHang): $rows3 row(s)"
} catch {
    Write-Error $_.Exception.Message
} finally {
    $conn.Close()
}

