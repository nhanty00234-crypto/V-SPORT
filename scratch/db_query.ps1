$connString = "Server=14.225.217.109,1433;Database=QuanLiSport;User Id=sa;Password=TOP1@iyounguru!;Encrypt=true;TrustServerCertificate=true;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    Write-Output "=== TABLES IN DATABASE ==="
    $cmd.CommandText = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Output $reader["TABLE_NAME"]
    }
    $reader.Close()

    Write-Output "`n=== COLUMNS OF SanPham_DichVu ==="
    $cmd.CommandText = "SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SanPham_DichVu'"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Output "$($reader['COLUMN_NAME']) | $($reader['DATA_TYPE']) | Nullable:$($reader['IS_NULLABLE']) | MaxLen:$($reader['CHARACTER_MAXIMUM_LENGTH'])"
    }
    $reader.Close()

    Write-Output "`n=== COLUMNS OF DanhMucSanPham ==="
    $cmd.CommandText = "SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DanhMucSanPham'"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Output "$($reader['COLUMN_NAME']) | $($reader['DATA_TYPE']) | Nullable:$($reader['IS_NULLABLE']) | MaxLen:$($reader['CHARACTER_MAXIMUM_LENGTH'])"
    }
    $reader.Close()

    Write-Output "`n=== DATA IN SanPham_DichVu ==="
    $cmd.CommandText = "SELECT * FROM SanPham_DichVu"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Output "$($reader['SanPhamID']) | $($reader['TenSanPham']) | Price:$($reader['DonGia']) | Stock:$($reader['SoLuongTon']) | Status:$($reader['TrangThai']) | CoSo:$($reader['CoSoID']) | Category:$($reader['DanhMucID'])"
    }
    $reader.Close()
} catch {
    Write-Error $_.Exception.Message
} finally {
    $conn.Close()
}
