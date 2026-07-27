-- =============================================================================
-- V-SPORT: READ-ONLY verification script for court / facility data consistency
-- Run against SQL Server. No UPDATE/DELETE/INSERT.
-- =============================================================================

-- ─── 1. Full relationship dump (filter by "Long Điền", Tennis, or "tennis") ──
SELECT
    c.CoSoID,
    c.TenCoSo,
    c.AccountID_QuanLy,
    c.TrangThai   AS CoSoTrangThai,
    c.IsDeleted   AS CoSoIsDeleted,
    s.SanID,
    s.TenSan,
    s.TrangThai   AS SanTrangThai,
    s.IsDeleted   AS SanIsDeleted,
    ls.LoaiSanID,
    ls.TenLoai,
    ls.IsDeleted  AS LoaiSanIsDeleted,
    mt.MonTheThaoID,
    mt.TenMon
FROM CoSo c
LEFT JOIN San    s  ON s.CoSoID    = c.CoSoID
LEFT JOIN LoaiSan ls ON ls.LoaiSanID = s.LoaiSanID
LEFT JOIN MonTheThao mt ON mt.MonTheThaoID = ls.MonTheThaoID
WHERE
    c.TenCoSo LIKE N'%Long Điền%'
    OR mt.TenMon  = N'Tennis'
    OR s.TenSan   LIKE N'%tennis%'
ORDER BY c.CoSoID, s.SanID;


-- ─── 2. All Tennis courts NOT soft-deleted (visible to Customer) ─────────────
SELECT
    c.CoSoID, c.TenCoSo, c.TrangThai AS CoSoTrangThai,
    s.SanID, s.TenSan, s.TrangThai AS SanTrangThai, s.IsDeleted AS SanIsDeleted,
    ls.LoaiSanID, ls.TenLoai, ls.IsDeleted AS LoaiSanIsDeleted,
    mt.TenMon
FROM San s
JOIN LoaiSan    ls ON ls.LoaiSanID    = s.LoaiSanID
JOIN MonTheThao mt ON mt.MonTheThaoID = ls.MonTheThaoID
JOIN CoSo        c ON c.CoSoID        = s.CoSoID
WHERE mt.TenMon = N'Tennis'
  AND (s.IsDeleted  = 0 OR s.IsDeleted  IS NULL)
  AND (ls.IsDeleted = 0 OR ls.IsDeleted IS NULL)
  AND (c.IsDeleted  = 0 OR c.IsDeleted  IS NULL)
ORDER BY c.CoSoID, s.SanID;


-- ─── 3. All Tennis courts that ARE soft-deleted (should NOT appear to Customer) ──
SELECT
    c.CoSoID, c.TenCoSo,
    s.SanID, s.TenSan, s.TrangThai AS SanTrangThai,
    s.IsDeleted AS SanIsDeleted, s.DeletedAt,
    ls.IsDeleted AS LoaiSanIsDeleted, ls.DeletedAt AS LoaiSanDeletedAt,
    mt.TenMon
FROM San s
JOIN LoaiSan    ls ON ls.LoaiSanID    = s.LoaiSanID
JOIN MonTheThao mt ON mt.MonTheThaoID = ls.MonTheThaoID
JOIN CoSo        c ON c.CoSoID        = s.CoSoID
WHERE mt.TenMon = N'Tennis'
  AND (s.IsDeleted = 1 OR ls.IsDeleted = 1)
ORDER BY c.CoSoID, s.SanID;


-- ─── 4. All LoaiSan of type Tennis that are soft-deleted ─────────────────────
SELECT
    ls.LoaiSanID, ls.TenLoai, ls.CoSoID, ls.IsDeleted, ls.DeletedAt,
    mt.TenMon,
    c.TenCoSo
FROM LoaiSan ls
JOIN MonTheThao mt ON mt.MonTheThaoID = ls.MonTheThaoID
JOIN CoSo       c  ON c.CoSoID        = ls.CoSoID
WHERE mt.TenMon = N'Tennis'
  AND ls.IsDeleted = 1
ORDER BY ls.CoSoID, ls.LoaiSanID;


-- ─── 5. CoSo of currently-logged-in Manager (replace ? with AccountID_QuanLy) ─
-- Replace <MANAGER_ACCOUNT_ID> with the actual AccountID before running.
-- SELECT CoSoID, TenCoSo, TrangThai, IsDeleted, AccountID_QuanLy
-- FROM CoSo
-- WHERE AccountID_QuanLy = <MANAGER_ACCOUNT_ID>
--   AND (IsDeleted = 0 OR IsDeleted IS NULL);


-- ─── 6. Facilities returned by the OLD Customer query (NOT IN logic) ──────────
-- These are facilities that used to appear (may include inactive/wrong-sport ones).
SELECT DISTINCT
    c.CoSoID, c.TenCoSo, c.TrangThai
FROM CoSo c
WHERE (c.IsDeleted = 0 OR c.IsDeleted IS NULL)
  AND c.TrangThai NOT IN (N'Chờ duyệt', N'Từ chối')
  AND EXISTS (
      SELECT 1 FROM San s
      JOIN LoaiSan ls ON ls.LoaiSanID = s.LoaiSanID
      WHERE s.CoSoID = c.CoSoID
        AND (s.IsDeleted = 0 OR s.IsDeleted IS NULL)
        AND ls.MonTheThaoID = (SELECT MonTheThaoID FROM MonTheThao WHERE TenMon = N'Tennis')
  )
ORDER BY c.CoSoID;


-- ─── 7. Facilities returned by the NEW (fixed) Customer query ─────────────────
SELECT DISTINCT
    c.CoSoID, c.TenCoSo, c.TrangThai
FROM CoSo c
WHERE (c.IsDeleted = 0 OR c.IsDeleted IS NULL)
  AND c.TrangThai = N'Đang hoạt động'
  AND EXISTS (
      SELECT 1 FROM San s
      JOIN LoaiSan ls ON ls.LoaiSanID = s.LoaiSanID
      WHERE s.CoSoID  = c.CoSoID
        AND (s.IsDeleted  = 0 OR s.IsDeleted  IS NULL)
        AND (ls.IsDeleted = 0 OR ls.IsDeleted IS NULL)
        AND s.TrangThai   = N'Sẵn sàng'
        AND ls.MonTheThaoID = (SELECT MonTheThaoID FROM MonTheThao WHERE TenMon = N'Tennis')
  )
ORDER BY c.CoSoID;


-- ─── 8. Sanity check: "Sân tennis người giàu – Sân 1" specific record ─────────
SELECT
    c.CoSoID, c.TenCoSo, c.TrangThai AS CoSoTrangThai, c.IsDeleted AS CoSoIsDeleted,
    s.SanID, s.TenSan, s.TrangThai AS SanTrangThai, s.IsDeleted AS SanIsDeleted,
    ls.LoaiSanID, ls.TenLoai, ls.IsDeleted AS LoaiSanIsDeleted,
    mt.TenMon
FROM San s
JOIN LoaiSan    ls ON ls.LoaiSanID    = s.LoaiSanID
JOIN MonTheThao mt ON mt.MonTheThaoID = ls.MonTheThaoID
JOIN CoSo        c ON c.CoSoID        = s.CoSoID
WHERE s.TenSan LIKE N'%tennis người giàu%'
   OR s.TenSan LIKE N'%tennis ngư%';


-- ─── 9. Cross-CoSo LoaiSan check: LoaiSan whose CoSoID ≠ San.CoSoID ──────────
-- These rows indicate data corruption. Should return 0 rows in a healthy DB.
SELECT
    s.SanID, s.TenSan, s.CoSoID AS SanCoSoID,
    ls.LoaiSanID, ls.TenLoai, ls.CoSoID AS LoaiSanCoSoID,
    c.TenCoSo AS SanFacility
FROM San s
JOIN LoaiSan ls ON ls.LoaiSanID = s.LoaiSanID
JOIN CoSo c ON c.CoSoID = s.CoSoID
WHERE ls.CoSoID <> s.CoSoID
ORDER BY s.CoSoID, s.SanID;


-- ─── 10. Customer search result (no sport filter) — active facilities ─────────
-- Mirror of the fixed Java query: should show all "Đang hoạt động" facilities
-- that have at least one non-deleted, Sẵn sàng court.
SELECT DISTINCT
    c.CoSoID, c.TenCoSo, c.TrangThai
FROM CoSo c
WHERE (c.IsDeleted = 0 OR c.IsDeleted IS NULL)
  AND c.TrangThai = N'Đang hoạt động'
  AND EXISTS (
      SELECT 1 FROM San s
      JOIN LoaiSan ls ON ls.LoaiSanID = s.LoaiSanID AND ls.CoSoID = s.CoSoID
      WHERE s.CoSoID = c.CoSoID
        AND (s.IsDeleted  = 0 OR s.IsDeleted  IS NULL)
        AND (ls.IsDeleted = 0 OR ls.IsDeleted IS NULL)
        AND s.TrangThai = N'Sẵn sàng'
  )
ORDER BY c.CoSoID;


-- ─── 11. Manager vs Customer facility set comparison ──────────────────────────
-- Replace <MANAGER_ACCOUNT_ID> before running.
-- Left side: all non-deleted CoSo owned by this Manager (incl. inactive).
-- Right side: subset visible to Customer (active + has bookable court).
-- Rows appearing only on the left are hidden from Customer correctly.
SELECT
    m.CoSoID,
    m.TenCoSo,
    m.TrangThai AS ManagerSeesTrangThai,
    CASE
        WHEN c_vis.CoSoID IS NOT NULL THEN 'Visible to Customer'
        ELSE 'Hidden from Customer'
    END AS CustomerVisibility
FROM CoSo m
LEFT JOIN (
    SELECT c.CoSoID FROM CoSo c
    WHERE (c.IsDeleted = 0 OR c.IsDeleted IS NULL)
      AND c.TrangThai = N'Đang hoạt động'
      AND EXISTS (
          SELECT 1 FROM San s
          JOIN LoaiSan ls ON ls.LoaiSanID = s.LoaiSanID AND ls.CoSoID = s.CoSoID
          WHERE s.CoSoID = c.CoSoID
            AND (s.IsDeleted  = 0 OR s.IsDeleted  IS NULL)
            AND (ls.IsDeleted = 0 OR ls.IsDeleted IS NULL)
            AND s.TrangThai = N'Sẵn sàng'
      )
) c_vis ON c_vis.CoSoID = m.CoSoID
-- WHERE m.AccountID_QuanLy = <MANAGER_ACCOUNT_ID>
WHERE (m.IsDeleted = 0 OR m.IsDeleted IS NULL)
ORDER BY m.CoSoID;
