$connString = "Server=14.225.217.109,1433;Database=QuanLiSport;User Id=sa;Password=TOP1@iyounguru!;Encrypt=true;TrustServerCertificate=true;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
try {
    $conn.Open()
    
    # Restore manager
    $cmd1 = $conn.CreateCommand()
    $cmd1.CommandText = "UPDATE Accounts SET Password = '$2a$12$mBaBJ7gq70IqSGlOlZWmMub/SctCvSKqaFXsGhFiclCoNr5UGKwU2' WHERE Username = 'nhanty00234@gmail.com'"
    $rows1 = $cmd1.ExecuteNonQuery()
    
    # Restore staff
    $cmd2 = $conn.CreateCommand()
    $cmd2.CommandText = "UPDATE Accounts SET Password = '$2a$12$6klFgAUUsnYnrT9sAJ1ixOlKgsmubR8ZdtIVhkuud3CHDjX.y6N/O' WHERE Username = 'LeTan01'"
    $rows2 = $cmd2.ExecuteNonQuery()
    
    Write-Output "Restored $rows1 manager row and $rows2 staff row passwords successfully."
} catch {
    Write-Error $_.Exception.Message
} finally {
    $conn.Close()
}
