$connString = "Server=14.225.217.109,1433;Database=QuanLiSport;User Id=sa;Password=TOP1@iyounguru!;Encrypt=true;TrustServerCertificate=true;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    Write-Output "--- CoSo ---"
    $cmd.CommandText = "SELECT CoSoID, TenCoSo, TrangThai, AccountID_QuanLy FROM CoSo"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        $id = $reader["CoSoID"]
        $ten = $reader["TenCoSo"]
        $status = $reader["TrangThai"]
        $manager = $reader["AccountID_QuanLy"]
        Write-Output "$id | $ten | $status | Manager:$manager"
    }
    $reader.Close()

    Write-Output "--- Accounts ---"
    $cmd.CommandText = "SELECT AccountID, Username, Email, FullName, RoleID, IsLocked, IsDeleted, Password FROM Accounts"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        $id = $reader["AccountID"]
        $username = $reader["Username"]
        $email = $reader["Email"]
        $fullName = $reader["FullName"]
        $roleId = $reader["RoleID"]
        $isLocked = $reader["IsLocked"]
        $isDeleted = $reader["IsDeleted"]
        $password = $reader["Password"]
        Write-Output "$id | $username | $email | $fullName | Role:$roleId | Locked:$isLocked | Deleted:$isDeleted | Pass:$password"
    }
    $reader.Close()

    Write-Output "--- LoaiSan (Court Types) ---"
    $cmd.CommandText = "SELECT LoaiSanID, TenLoai, MonTheThaoID, GiaKhongDen, GiaCoDen, CoSoID FROM LoaiSan"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        $id = $reader["LoaiSanID"]
        $ten = $reader["TenLoai"]
        $sportId = $reader["MonTheThaoID"]
        $price1 = $reader["GiaKhongDen"]
        $price2 = $reader["GiaCoDen"]
        $cosoid = $reader["CoSoID"]
        Write-Output "$id | $ten | Sport:$sportId | Price:$price1 / $price2 | CoSo:$cosoid"
    }
    $reader.Close()

    Write-Output "--- San (Courts) ---"
    $cmd.CommandText = "SELECT SanID, TenSan, LoaiSanID, CoSoID, TrangThai FROM San"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        $id = $reader["SanID"]
        $ten = $reader["TenSan"]
        $typeId = $reader["LoaiSanID"]
        $cosoid = $reader["CoSoID"]
        $status = $reader["TrangThai"]
        Write-Output "$id | $ten | Type:$typeId | CoSo:$cosoid | Status:$status"
    }
    $reader.Close()

} catch {
    Write-Error $_.Exception.Message
} finally {
    $conn.Close()
}
