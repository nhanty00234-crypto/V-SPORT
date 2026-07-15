# System-Wide Pagination — Phase 2 Priority Modules — Progress Ledger

Plan: docs/superpowers/plans/2026-07-15-system-wide-pagination-phase2-priority-modules.md
Branch: feature/pagination-phase2-priority-modules (base commit: 1400e7d, includes merged Phase 1)
Prereq: Phase 1 foundation (PaginationRequest/PageResult/PaginationUtils/pagination.tag) merged to main.

## Baseline notes (carried over from Phase 1)
- `mvn test` has 7 PRE-EXISTING failures unrelated to this work: ad-hoc ops scripts
  (FindActiveCheckinsTest, FindTestAccountsTest, ListTablesTest, ResetSessionStateTest,
  ResetTestPasswordTest, RunMigrationTest, VerifyCoSoConfigTest) that need live DB
  connectivity this sandbox's TLS trust doesn't have. Run targeted `-Dtest=ClassName`.
- Live full-app browser verification (real DB data, real login) is NOT possible in this
  sandbox (Windows-only start_server.bat + TLS-broken DB connection). Embedded
  Tomcat+Jasper (tomcat-embed-jasper from ~/.m2) CAN be used for isolated JSP/JSTL
  syntax+rendering checks that don't need live DB data — used successfully in Phase 1
  Task 4's re-review.
- pagination.tag has NO dedicated sortBy/sortDir attributes — every module below that
  accepts sortBy/sortDir must add them to its paginationExtraParams map (Phase 2 plan
  Global Constraints, amended after Phase 1 final review).

## Tasks
- [ ] Task 1: Invoice management (HoaDonManagerServlet / QuanLyHoaDon.jsp)
- [ ] Task 2: Customer booking history (DatSanServlet / DatSan.jsp)
- [ ] Task 3: Audit Log standardization (admin + manager)
- [ ] Task 4: Customer management (CustomerManagerServlet / KhachHang.jsp, 3 lists)
- [ ] Task 5a: Staff/account directory (admin, QuanLyNguoiDungServlet / NhanSu.jsp)
- [ ] Task 5b: Staff list AJAX (manager, NhanSuManagerServlet / NhanSu.jsp)
- [ ] Task 6: Inventory/service catalog (KhoDichVuManagerServlet / KhoDichVu.jsp)
- [ ] Task 7: Phase 2 full verification
