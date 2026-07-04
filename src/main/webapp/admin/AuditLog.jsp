<%-- src/main/webapp/admin/AuditLog.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Nhật Ký Thao Tác — Admin Portal</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
  body { font-family: 'Inter', sans-serif; }
  .card { background:#fff; border:1px solid #e2e8f0; border-radius:16px; transition:box-shadow .2s, transform .2s; }
  .badge { display:inline-flex; align-items:center; padding:4px 10px; border-radius:8px; font-size:11px; font-weight:600; }
  .badge-green { background:#dcfce7; border:1px solid #bbf7d0; color:#15803d; }
  .badge-blue { background:#dbeafe; border:1px solid #bfdbfe; color:#1e40af; }
  .badge-amber { background:#fef3c7; border:1px solid #fde68a; color:#b45309; }
  .badge-red { background:#fee2e2; border:1px solid #fecaca; color:#b91c1c; }
  .badge-purple { background:#f3e8ff; border:1px solid #e9d5ff; color:#7e22ce; }
  .badge-gray { background:#f1f5f9; border:1px solid #e2e8f0; color:#475569; }
  
  ::-webkit-scrollbar { width:6px; height:6px }
  ::-webkit-scrollbar-track { background:transparent }
  ::-webkit-scrollbar-thumb { background:#93c5fd; border-radius:6px }
  ::-webkit-scrollbar-thumb:hover { background:#60a5fa }
  
  @keyframes fadeUp { from { opacity:0; transform:translateY(10px); } to { opacity:1; transform:translateY(0); } }
  main > section { animation: fadeUp .35s ease both; }
</style>
</head>
<body class="bg-slate-50 text-slate-900 min-h-screen">

<!-- Sidebar Admin -->
<jsp:include page="/admin/common/sidebar.jsp" />

<!-- Header -->
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[260px] bg-white/80 backdrop-blur-lg border-b border-blue-100 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-blue-50 text-blue-600">
      <span class="material-symbols-outlined text-[20px]">menu</span>
    </button>
    <div>
      <h1 class="text-sm font-bold text-blue-900 tracking-tight">Nhật ký thao tác hệ thống</h1>
      <p class="text-xs text-blue-500 flex items-center gap-1.5">
        <span class="material-symbols-outlined text-[12px]">security</span>Quyền hạn Admin
      </p>
    </div>
  </div>
  <div class="flex items-center gap-1.5">
    <div class="text-xs font-semibold px-3 py-1 bg-blue-50 text-blue-750 rounded-lg">
      Vai trò: Quản trị viên
    </div>
    <div class="w-px h-6 bg-blue-100 mx-1"></div>
    <jsp:include page="/admin/common/profile_dropdown.jsp" />
  </div>
</header>

<!-- Main Content -->
<main class="lg:ml-[260px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- Overview Section -->
  <section class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
    <div>
      <h2 class="text-2xl font-black tracking-tight text-blue-900">Nhật Ký Thao Tác</h2>
      <p class="text-sm text-slate-550 mt-0.5">Giám sát toàn bộ hoạt động cập nhật cấu hình, nhân sự và quản trị cơ sở</p>
    </div>
    <span class="bg-blue-600 text-white text-xs font-bold px-3 py-1.5 rounded-xl shadow-sm self-start">
      Tổng cộng: ${total} bản ghi
    </span>
  </section>

  <!-- Flash Messages -->
  <c:if test="${not empty sessionScope.message}">
    <div class="p-4 bg-green-50 border border-green-200 text-green-800 rounded-2xl flex items-start gap-3 shadow-sm animation-fade">
      <span class="material-symbols-outlined text-green-600 mt-0.5">check_circle</span>
      <div>
        <p class="text-sm font-bold">Thành công</p>
        <p class="text-xs text-green-700 mt-0.5"><c:out value="${sessionScope.message}"/></p>
      </div>
    </div>
    <c:remove var="message" scope="session"/>
  </c:if>

  <c:if test="${not empty sessionScope.error}">
    <div class="p-4 bg-red-50 border border-red-200 text-red-800 rounded-2xl flex items-start gap-3 shadow-sm animation-fade">
      <span class="material-symbols-outlined text-red-600 mt-0.5">error</span>
      <div>
        <p class="text-sm font-bold">Lỗi hệ thống</p>
        <p class="text-xs text-red-700 mt-0.5"><c:out value="${sessionScope.error}"/></p>
      </div>
    </div>
    <c:remove var="error" scope="session"/>
  </c:if>

  <!-- Filter Panel -->
  <section class="card p-5 border border-blue-100 bg-white shadow-sm rounded-2xl">
    <form method="get" action="${pageContext.request.contextPath}/admin/audit-log" class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-5 gap-4 items-end" autocomplete="off">
      <div class="flex flex-col gap-1">
        <label class="text-xs font-semibold text-slate-500">Loại đối tượng</label>
        <select name="entityType" class="h-10 px-3 rounded-xl border border-slate-200 bg-white text-xs text-slate-755 focus:outline-none focus:ring-2 focus:ring-blue-500/10 focus:border-blue-600 transition-all">
          <option value="">-- Tất cả --</option>
          <option value="TaiKhoan" <c:if test="${entityType == 'TaiKhoan'}">selected</c:if>>Tài khoản</option>
          <option value="San" <c:if test="${entityType == 'San'}">selected</c:if>>Sân</option>
          <option value="LoaiSan" <c:if test="${entityType == 'LoaiSan'}">selected</c:if>>Loại sân</option>
          <option value="SanPham" <c:if test="${entityType == 'SanPham'}">selected</c:if>>Sản phẩm / Dịch vụ</option>
          <option value="CoSo" <c:if test="${entityType == 'CoSo'}">selected</c:if>>Chi nhánh cơ sở</option>
          <option value="CaLamViec" <c:if test="${entityType == 'CaLamViec'}">selected</c:if>>Ca làm việc</option>
          <option value="YeuCauNghi" <c:if test="${entityType == 'YeuCauNghi'}">selected</c:if>>Yêu cầu nghỉ</option>
        </select>
      </div>
      <div class="flex flex-col gap-1">
        <label class="text-xs font-semibold text-slate-500">Hành động</label>
        <select name="action" class="h-10 px-3 rounded-xl border border-slate-200 bg-white text-xs text-slate-755 focus:outline-none focus:ring-2 focus:ring-blue-500/10 focus:border-blue-600 transition-all">
          <option value="">-- Tất cả --</option>
          <option value="CREATE" <c:if test="${action == 'CREATE'}">selected</c:if>>Tạo mới (CREATE)</option>
          <option value="UPDATE" <c:if test="${action == 'UPDATE'}">selected</c:if>>Cập nhật (UPDATE)</option>
          <option value="SOFT_DELETE" <c:if test="${action == 'SOFT_DELETE'}">selected</c:if>>Xóa mềm (SOFT_DELETE)</option>
          <option value="RESTORE" <c:if test="${action == 'RESTORE'}">selected</c:if>>Khôi phục (RESTORE)</option>
          <option value="PERMANENT_DELETE" <c:if test="${action == 'PERMANENT_DELETE'}">selected</c:if>>Xóa vĩnh viễn (PERMANENT_DELETE)</option>
          <option value="ADD_STAFF" <c:if test="${action == 'ADD_STAFF'}">selected</c:if>>Thêm nhân sự (ADD_STAFF)</option>
          <option value="APPROVE" <c:if test="${action == 'APPROVE'}">selected</c:if>>Phê duyệt (APPROVE)</option>
          <option value="REJECT" <c:if test="${action == 'REJECT'}">selected</c:if>>Từ chối (REJECT)</option>
        </select>
      </div>
      <div class="flex flex-col gap-1">
        <label class="text-xs font-semibold text-slate-500">Từ ngày</label>
        <input type="date" name="dateFrom" value="<c:out value='${dateFrom}'/>" class="h-10 px-3 rounded-xl border border-slate-200 bg-white text-xs text-slate-755 focus:outline-none focus:ring-2 focus:ring-blue-500/10 focus:border-blue-600 transition-all">
      </div>
      <div class="flex flex-col gap-1">
        <label class="text-xs font-semibold text-slate-500">Đến ngày</label>
        <input type="date" name="dateTo" value="<c:out value='${dateTo}'/>" class="h-10 px-3 rounded-xl border border-slate-200 bg-white text-xs text-slate-755 focus:outline-none focus:ring-2 focus:ring-blue-500/10 focus:border-blue-600 transition-all">
      </div>
      <div class="flex gap-2">
        <button type="submit" class="flex-1 bg-blue-600 text-white rounded-xl h-10 px-4 flex items-center justify-center gap-1.5 text-xs font-bold shadow hover:bg-blue-700 transition-all active:scale-95 cursor-pointer">
          <span class="material-symbols-outlined text-[16px]">filter_alt</span>Lọc
        </button>
        <a href="${pageContext.request.contextPath}/admin/audit-log" class="flex-1 text-center bg-blue-50 border border-blue-100 text-blue-700 rounded-xl h-10 px-4 flex items-center justify-center gap-1.5 text-xs font-bold hover:bg-blue-100 transition-all active:scale-95">
          Xóa lọc
        </a>
      </div>
    </form>
  </section>

  <!-- Logs Table Card -->
  <section class="card overflow-hidden border border-blue-100 bg-white rounded-2xl shadow-sm">
    <div class="overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="bg-blue-50/50 border-b border-blue-100 text-blue-950 font-bold text-xs uppercase tracking-wider">
          <tr>
            <th class="px-5 py-3 text-left">Thời gian</th>
            <th class="px-5 py-3 text-left">Người thực hiện</th>
            <th class="px-5 py-3 text-left">Hành động</th>
            <th class="px-5 py-3 text-left">Đối tượng tác động</th>
            <th class="px-5 py-3 text-left">Mô tả chi tiết</th>
            <th class="px-5 py-3 text-left">Địa chỉ IP</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-blue-50 text-xs">
          <c:choose>
            <c:when test="${empty logs}">
              <tr>
                <td colspan="6" class="text-center py-16 text-blue-300">
                  <span class="material-symbols-outlined text-[36px] block mb-2 text-blue-200">history</span>
                  <p class="font-semibold text-xs text-blue-400">Không tìm thấy bản ghi nhật ký thao tác nào</p>
                </td>
              </tr>
            </c:when>
            <c:otherwise>
              <c:forEach var="log" items="${logs}">
                <tr class="hover:bg-blue-50/30 transition-colors">
                  <td class="px-5 py-4 whitespace-nowrap text-slate-500 font-medium">
                    <c:if test="${not empty log.createdAt}">
                      <fmt:parseDate value="${log.createdAt.toString().substring(0,16)}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" />
                      <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy HH:mm" var="formattedDate" />
                      ${formattedDate}
                    </c:if>
                  </td>
                  <td class="px-5 py-4">
                    <div class="flex items-center gap-2.5">
                      <div class="w-7 h-7 rounded-full bg-blue-600 text-white flex items-center justify-center font-black text-[10px] uppercase shadow-sm">
                        ${log.actorName.substring(0,1)}
                      </div>
                      <div>
                        <p class="font-extrabold text-slate-900 text-xs"><c:out value="${log.actorName}"/></p>
                        <p class="text-[9px] text-blue-500 font-bold uppercase tracking-wider">
                          <c:choose>
                            <c:when test="${log.actorRole == 1}">Admin</c:when>
                            <c:when test="${log.actorRole == 2}">Manager</c:when>
                            <c:otherwise>Role ${log.actorRole}</c:otherwise>
                          </c:choose>
                          <c:if test="${not empty log.coSoId}">
                            &middot; CS${log.coSoId}
                          </c:if>
                        </p>
                      </div>
                    </div>
                  </td>
                  <td class="px-5 py-4 whitespace-nowrap">
                    <c:choose>
                      <c:when test="${log.action == 'CREATE' || log.action == 'ADD_STAFF'}">
                        <span class="badge badge-green"><span class="w-1.5 h-1.5 rounded-full bg-green-600 mr-1.5"></span>Tạo mới</span>
                      </c:when>
                      <c:when test="${log.action == 'UPDATE' || log.action == 'APPROVE'}">
                        <span class="badge badge-blue"><span class="w-1.5 h-1.5 rounded-full bg-blue-600 mr-1.5"></span>Cập nhật</span>
                      </c:when>
                      <c:when test="${log.action == 'SOFT_DELETE' || log.action == 'REJECT'}">
                        <span class="badge badge-amber"><span class="w-1.5 h-1.5 rounded-full bg-amber-600 mr-1.5"></span>Xóa mềm</span>
                      </c:when>
                      <c:when test="${log.action == 'PERMANENT_DELETE'}">
                        <span class="badge badge-red"><span class="w-1.5 h-1.5 rounded-full bg-red-600 mr-1.5"></span>Xóa vĩnh viễn</span>
                      </c:when>
                      <c:when test="${log.action == 'RESTORE'}">
                        <span class="badge badge-purple"><span class="w-1.5 h-1.5 rounded-full bg-purple-600 mr-1.5"></span>Khôi phục</span>
                      </c:when>
                      <c:otherwise>
                        <span class="badge badge-gray"><span class="w-1.5 h-1.5 rounded-full bg-slate-500 mr-1.5"></span>${log.action}</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td class="px-5 py-4">
                    <div class="font-semibold text-slate-900 text-xs"><c:out value="${log.entityName}"/></div>
                    <div class="text-[10px] text-slate-400 mt-0.5 font-mono"><c:out value="${log.entityType}"/> #${log.entityId}</div>
                  </td>
                  <td class="px-5 py-4 text-slate-650 max-w-xs md:max-w-md break-words leading-relaxed">
                    <c:out value="${log.details}"/>
                  </td>
                  <td class="px-5 py-4 text-slate-400 font-mono text-[10px]">
                    <c:out value="${log.ipAddress}"/>
                  </td>
                </tr>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>
    </div>

    <!-- Pagination Footer -->
    <c:if test="${totalPages > 1}">
      <div class="px-5 py-4 border-t border-blue-100 flex items-center justify-between bg-blue-50/10">
        <span class="text-xs text-slate-500">Hiển thị trang <span class="font-bold text-blue-950">${currentPage}</span> trong <span class="font-bold text-blue-950">${totalPages}</span> trang</span>
        <div class="flex items-center gap-1">
          <c:if test="${currentPage > 1}">
            <c:url var="prevPageUrl" value="">
              <c:param name="page" value="${currentPage - 1}"/>
              <c:param name="entityType" value="${entityType}"/>
              <c:param name="action" value="${action}"/>
              <c:param name="dateFrom" value="${dateFrom}"/>
              <c:param name="dateTo" value="${dateTo}"/>
            </c:url>
            <a href="${prevPageUrl}" class="px-2 py-1 rounded hover:bg-blue-100 text-blue-400 flex items-center justify-center transition-colors">
              <span class="material-symbols-outlined text-[14px]">chevron_left</span>
            </a>
          </c:if>
          <c:forEach begin="1" end="${totalPages}" var="p">
            <c:if test="${p >= currentPage - 2 && p <= currentPage + 2}">
              <c:url var="pageUrl" value="">
                <c:param name="page" value="${p}"/>
                <c:param name="entityType" value="${entityType}"/>
                <c:param name="action" value="${action}"/>
                <c:param name="dateFrom" value="${dateFrom}"/>
                <c:param name="dateTo" value="${dateTo}"/>
              </c:url>
              <a href="${pageUrl}" class="px-2.5 py-1 rounded text-xs transition-all ${p == currentPage ? 'bg-blue-600 text-white font-semibold shadow-sm' : 'hover:bg-blue-100 text-blue-750'}">
                ${p}
              </a>
            </c:if>
          </c:forEach>
          <c:if test="${currentPage < totalPages}">
            <c:url var="nextPageUrl" value="">
              <c:param name="page" value="${currentPage + 1}"/>
              <c:param name="entityType" value="${entityType}"/>
              <c:param name="action" value="${action}"/>
              <c:param name="dateFrom" value="${dateFrom}"/>
              <c:param name="dateTo" value="${dateTo}"/>
            </c:url>
            <a href="${nextPageUrl}" class="px-2 py-1 rounded hover:bg-blue-100 text-blue-400 flex items-center justify-center transition-colors">
              <span class="material-symbols-outlined text-[14px]">chevron_right</span>
            </a>
          </c:if>
        </div>
      </div>
    </c:if>
  </section>
</main>

<script>
  // Mobile sidebar menu toggler
  const mobileMenuBtn = document.getElementById('mobileMenuBtn');
  const sidebar = document.getElementById('sidebar');
  if (mobileMenuBtn && sidebar) {
    mobileMenuBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      sidebar.classList.toggle('-translate-x-full');
    });
    document.addEventListener('click', (e) => {
      if (!sidebar.contains(e.target) && !mobileMenuBtn.contains(e.target)) {
        sidebar.classList.add('-translate-x-full');
      }
    });
  }
</script>
</body>
</html>
