$connString = "Server=14.225.217.109,1433;Database=QuanLiSport;User Id=sa;Password=TOP1@iyounguru!;Encrypt=true;TrustServerCertificate=true;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    Write-Output "=== COLUMNS OF DanhGia ==="
    $cmd.CommandText = "SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DanhGia'"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Output "$($reader['COLUMN_NAME']) | $($reader['DATA_TYPE']) | Nullable:$($reader['IS_NULLABLE'])"
    }
    $reader.Close()

    Write-Output "`n=== DATA IN DanhGia ==="
    $cmd.CommandText = "SELECT * FROM DanhGia"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Output "$($reader['DanhGiaID']) | Stars:$($reader['SoSao']) | Comment:$($reader['BinhLuan'])"
    }
    $reader.Close()
} catch {
    Write-Error $_.Exception.Message
} finally {
    $conn.Close()
}
