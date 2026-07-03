$connString = "Server=14.225.217.109,1433;Database=QuanLiSport;User Id=sa;Password=TOP1@iyounguru!;Encrypt=true;TrustServerCertificate=true;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    $sql = Get-Content -Raw -Path "d:\New folder\V-SPORT\sql\migration_soft_delete.sql"
    
    Write-Output "Executing migration_soft_delete.sql..."
    $cmd.CommandText = $sql
    $cmd.ExecuteNonQuery()
    Write-Output "Migration executed successfully."
} catch {
    Write-Error $_.Exception.Message
} finally {
    $conn.Close()
}
