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
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/dist/tabler-icons.min.css"/>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200"/>
<style>
  body { font-family: 'Inter', sans-serif; }
  .badge { display:inline-flex; align-items:center; padding:3px 10px; border-radius:99px; font-size:11px; font-weight:700; letter-spacing:.02em; }
  .badge-green  { background:#dcfce7; border:1px solid #bbf7d0; color:#15803d; }
  .badge-blue   { background:#dbeafe; border:1px solid #bfdbfe; color:#1e40af; }
  .badge-amber  { background:#fef3c7; border:1px solid #fde68a; color:#b45309; }
  .badge-red    { background:#fee2e2; border:1px solid #fecaca; color:#b91c1c; }
  .badge-purple { background:#f3e8ff; border:1px solid #e9d5ff; color:#7e22ce; }
  .badge-gray   { background:#f1f5f9; border:1px solid #e2e8f0; color:#475569; }

  /* Log Row Card */
  .log-card {
    background:#fff;border:1px solid #e4e4e7;border-radius:18px;
    transition:box-shadow .22s, transform .22s;
  }
  .log-card:hover { box-shadow:0 8px 24px -6px rgba(0,0,0,.06); transform:translateY(-1px); }

  /* Avatar styling based on actor role */
  .actor-avatar-admin {
    background: linear-gradient(135deg,#eff6ff,#dbeafe); color:#2563eb; border: 1px solid #bfdbfe;
  }
  .actor-avatar-manager {
    background: linear-gradient(135deg,#f3e8ff,#e9d5ff); color:#7e22ce; border: 1px solid #e9d5ff;
  }

  /* Entity Type Icon styling */
  .entity-icon {
    width:32px; height:32px; border-radius:10px; display:inline-flex; align-items:center; justify-content:center; flex-shrink:0;
  }

  /* Audit filter controls */
  .filter-panel {
    background:linear-gradient(180deg,#ffffff 0%,#f8fafc 100%);
    border:1px solid #e2e8f0;
    box-shadow:0 18px 44px -34px rgba(15,23,42,.32);
  }
  .filter-field { position:relative; display:flex; flex-direction:column; gap:7px; }
  .filter-label {
    display:flex; align-items:center; gap:6px;
    font-size:11px; font-weight:800; color:#475569; letter-spacing:.01em;
  }
  .control-shell {
    position:relative; height:42px;
    display:flex; align-items:center;
    border:1px solid #dbe3ef;
    border-radius:10px;
    background:#f8fafc;
    transition:border-color .16s ease, box-shadow .16s ease, background-color .16s ease;
  }
  .control-shell:focus-within {
    background:#fff;
    border-color:#2563eb;
    box-shadow:0 0 0 3px rgba(37,99,235,.10);
  }
  .control-icon {
    position:absolute; left:12px; top:50%; transform:translateY(-50%);
    color:#64748b; font-size:16px; pointer-events:none;
  }
  .control-caret {
    position:absolute; right:12px; top:50%; transform:translateY(-50%);
    color:#94a3b8; font-size:16px; pointer-events:none;
  }
  .audit-control {
    width:100%; height:100%;
    padding:0 36px 0 38px;
    border:0; outline:0; background:transparent;
    color:#0f172a; font-size:12px; font-weight:650;
  }
  select.audit-control { appearance:none; -webkit-appearance:none; cursor:pointer; }
  input[type="date"].audit-control { cursor:pointer; }
  input[type="date"].audit-control::-webkit-calendar-picker-indicator { opacity:0; cursor:pointer; }
  .filter-action {
    height:42px; border-radius:10px;
    display:inline-flex; align-items:center; justify-content:center; gap:7px;
    font-size:12px; font-weight:800; transition:transform .12s ease, background-color .15s ease, box-shadow .15s ease;
  }
  .filter-action:active { transform:scale(.98); }

  /* Scroll reveal */
  .reveal{opacity:0;transform:translateY(15px);transition:opacity .5s cubic-bezier(.22,1,.36,1),transform .5s cubic-bezier(.22,1,.36,1)}
  .reveal.visible{opacity:1;transform:translateY(0)}
  .d0{transition-delay:0ms}.d1{transition-delay:50ms}.d2{transition-delay:100ms}.d3{transition-delay:150ms}
  .d4{transition-delay:200ms}.d5{transition-delay:250ms}

  @keyframes contentZoomIn { from{opacity:0;transform:scale(.98)} to{opacity:1;transform:scale(1)} }
  main { animation:contentZoomIn .35s cubic-bezier(.34,1.56,.64,1) forwards; transform-origin:center top; }

  ::-webkit-scrollbar { width:6px; height:6px }
  ::-webkit-scrollbar-track { background:transparent }
  ::-webkit-scrollbar-thumb { background:#cbd5e1; border-radius:6px }
</style>
</head>
<body class="bg-slate-50 text-slate-900 min-h-screen">

<!-- Sidebar Admin -->
<jsp:include page="/admin/common/sidebar.jsp" />

<!-- Header -->
<jsp:include page="/admin/common/header.jsp">
  <jsp:param name="pageTitle" value="Nhật ký thao tác hệ thống"/>
</jsp:include>

<!-- Main Content -->
<main class="lg:ml-[260px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- Overview Section -->
  <section class="reveal d0 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
    <div>
      <h2 class="text-xl font-black tracking-tight text-zinc-900">Nhật Ký Thao Tác</h2>
      <p class="text-xs text-zinc-500 mt-0.5">Giám sát toàn bộ hoạt động cập nhật cấu hình, nhân sự và quản trị cơ sở</p>
    </div>
    <span class="bg-zinc-900 text-white text-xs font-bold px-3 py-1.5 rounded-xl shadow-sm self-start flex items-center gap-1.5">
      <i class="ti ti-database text-sm"></i> Tổng cộng: ${total} bản ghi
    </span>
  </section>

  <!-- Flash Messages -->
  <c:if test="${not empty sessionScope.message}">
    <div class="reveal flex items-start gap-3 p-4 bg-green-50 border border-green-100 rounded-2xl text-green-600 text-sm">
      <i class="ti ti-circle-check text-xl shrink-0 mt-0.5"></i>
      <div>
        <span class="font-bold block text-green-700">Thành công</span>
        <span class="text-green-600/90 mt-0.5 block"><c:out value="${sessionScope.message}"/></span>
      </div>
    </div>
    <c:remove var="message" scope="session"/>
  </c:if>

  <c:if test="${not empty sessionScope.error}">
    <div class="reveal flex items-start gap-3 p-4 bg-red-50 border border-red-100 rounded-2xl text-red-600 text-sm">
      <i class="ti ti-alert-circle text-xl shrink-0 mt-0.5"></i>
      <div>
        <span class="font-bold block text-red-700">Lỗi hệ thống</span>
        <span class="text-red-600/90 mt-0.5 block"><c:out value="${sessionScope.error}"/></span>
      </div>
    </div>
    <c:remove var="error" scope="session"/>
  </c:if>

  <!-- Filter Panel -->
  <section class="reveal d1 filter-panel rounded-2xl p-5">
    <form method="get" action="${pageContext.request.contextPath}/admin/audit-log" class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-5 gap-4 items-end" autocomplete="off">
      <div class="filter-field">
        <label class="filter-label"><i class="ti ti-stack-2 text-blue-600"></i>Loại đối tượng</label>
        <div class="control-shell">
          <i class="ti ti-category-2 control-icon"></i>
          <select name="entityType" class="audit-control">
            <option value="">Tất cả đối tượng</option>
            <option value="TaiKhoan" <c:if test="${entityType == 'TaiKhoan'}">selected</c:if>>Tài khoản</option>
            <option value="San" <c:if test="${entityType == 'San'}">selected</c:if>>Sân</option>
            <option value="LoaiSan" <c:if test="${entityType == 'LoaiSan'}">selected</c:if>>Loại sân</option>
            <option value="SanPham" <c:if test="${entityType == 'SanPham'}">selected</c:if>>Sản phẩm / Dịch vụ</option>
            <option value="CoSo" <c:if test="${entityType == 'CoSo'}">selected</c:if>>Chi nhánh cơ sở</option>
            <option value="YeuCauNghi" <c:if test="${entityType == 'YeuCauNghi'}">selected</c:if>>Yêu cầu nghỉ</option>
          </select>
          <i class="ti ti-chevron-down control-caret"></i>
        </div>
      </div>
      <div class="filter-field">
        <label class="filter-label"><i class="ti ti-activity text-indigo-600"></i>Hành động</label>
        <div class="control-shell">
          <i class="ti ti-bolt control-icon"></i>
          <select name="action" class="audit-control">
            <option value="">Tất cả hành động</option>
            <option value="CREATE" <c:if test="${action == 'CREATE'}">selected</c:if>>Tạo mới</option>
            <option value="UPDATE" <c:if test="${action == 'UPDATE'}">selected</c:if>>Cập nhật</option>
            <option value="SOFT_DELETE" <c:if test="${action == 'SOFT_DELETE'}">selected</c:if>>Xóa mềm</option>
            <option value="RESTORE" <c:if test="${action == 'RESTORE'}">selected</c:if>>Khôi phục</option>
            <option value="PERMANENT_DELETE" <c:if test="${action == 'PERMANENT_DELETE'}">selected</c:if>>Xóa vĩnh viễn</option>
            <option value="ADD_STAFF" <c:if test="${action == 'ADD_STAFF'}">selected</c:if>>Thêm nhân sự</option>
            <option value="APPROVE" <c:if test="${action == 'APPROVE'}">selected</c:if>>Phê duyệt</option>
            <option value="REJECT" <c:if test="${action == 'REJECT'}">selected</c:if>>Từ chối</option>
          </select>
          <i class="ti ti-chevron-down control-caret"></i>
        </div>
      </div>
      <div class="filter-field">
        <label class="filter-label"><i class="ti ti-calendar-minus text-emerald-600"></i>Từ ngày</label>
        <div class="control-shell">
          <i class="ti ti-calendar-event control-icon"></i>
          <input type="date" name="dateFrom" value="<c:out value='${dateFrom}'/>" class="audit-control">
          <i class="ti ti-calendar control-caret"></i>
        </div>
      </div>
      <div class="filter-field">
        <label class="filter-label"><i class="ti ti-calendar-plus text-rose-600"></i>Đến ngày</label>
        <div class="control-shell">
          <i class="ti ti-calendar-stats control-icon"></i>
          <input type="date" name="dateTo" value="<c:out value='${dateTo}'/>" class="audit-control">
          <i class="ti ti-calendar control-caret"></i>
        </div>
      </div>
      <div class="flex gap-2">
        <button type="submit" class="filter-action flex-1 bg-blue-600 text-white px-4 shadow-md shadow-blue-200/70 hover:bg-blue-700 cursor-pointer">
          <i class="ti ti-filter text-sm"></i> Lọc
        </button>
        <a href="${pageContext.request.contextPath}/admin/audit-log" class="filter-action flex-1 text-center bg-white border border-zinc-200 text-zinc-600 px-4 hover:bg-zinc-100">
          <i class="ti ti-eraser text-sm"></i>Xóa lọc
        </a>
      </div>
    </form>
  </section>

  <!-- Logs Feed/Timeline List -->
  <section class="reveal d2 flex flex-col gap-3.5">
    <c:choose>
      <c:when test="${empty logs}">
        <div class="flex flex-col items-center justify-center py-20 text-zinc-450 bg-white border border-zinc-200 rounded-2xl shadow-xs">
          <i class="ti ti-history text-5xl mb-3 opacity-30"></i>
          <p class="text-sm font-semibold">Không tìm thấy bản ghi nhật ký thao tác nào</p>
        </div>
      </c:when>
      <c:otherwise>
        <c:forEach var="log" items="${logs}" varStatus="st">
          <c:set var="delay" value="${st.index < 8 ? st.index : 7}"/>
          <div class="log-card reveal d${delay} p-4 md:p-5 flex flex-col md:flex-row md:items-start gap-4 hover:border-zinc-350">
            
            <!-- Column 1: Actor Avatar & Info -->
            <div class="flex items-center md:items-start gap-3 w-full md:w-52 shrink-0 border-b md:border-b-0 pb-3 md:pb-0 border-zinc-100">
              <div class="w-9 h-9 rounded-xl flex items-center justify-center font-extrabold text-sm uppercase shadow-xs shrink-0
                          ${log.actorRole == 1 ? 'actor-avatar-admin' : 'actor-avatar-manager'}">
                ${log.actorName.substring(0,1)}
              </div>
              <div class="min-w-0">
                <p class="font-bold text-zinc-900 text-xs md:text-sm truncate"><c:out value="${log.actorName}"/></p>
                <p class="text-[10px] font-bold uppercase tracking-wide mt-0.5 flex items-center gap-1
                          ${log.actorRole == 1 ? 'text-blue-600' : 'text-purple-600'}">
                  <c:choose>
                    <c:when test="${log.actorRole == 1}">Admin</c:when>
                    <c:when test="${log.actorRole == 2}">Manager</c:when>
                    <c:otherwise>Nhân viên</c:otherwise>
                  </c:choose>
                  <c:if test="${not empty log.coSoId}">
                    <span class="text-zinc-300 font-normal">|</span> Chi nhánh ${log.coSoId}
                  </c:if>
                </p>
              </div>
            </div>

            <!-- Column 2: Action details (Main block) -->
            <div class="flex-1 flex flex-col gap-2">
              
              <!-- Badges & Time -->
              <div class="flex flex-wrap items-center gap-2">
                <!-- Action Badge -->
                <c:choose>
                  <c:when test="${log.action == 'CREATE' || log.action == 'ADD_STAFF'}">
                    <span class="badge badge-green"><i class="ti ti-circle-plus mr-1"></i>Tạo mới</span>
                  </c:when>
                  <c:when test="${log.action == 'UPDATE' || log.action == 'APPROVE'}">
                    <span class="badge badge-blue"><i class="ti ti-edit mr-1"></i>Cập nhật</span>
                  </c:when>
                  <c:when test="${log.action == 'SOFT_DELETE' || log.action == 'REJECT'}">
                    <span class="badge badge-amber"><i class="ti ti-trash-x mr-1"></i>Xóa mềm</span>
                  </c:when>
                  <c:when test="${log.action == 'PERMANENT_DELETE'}">
                    <span class="badge badge-red"><i class="ti ti-trash mr-1"></i>Xóa vĩnh viễn</span>
                  </c:when>
                  <c:when test="${log.action == 'RESTORE'}">
                    <span class="badge badge-purple"><i class="ti ti-rotate-dot mr-1"></i>Khôi phục</span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge badge-gray"><i class="ti ti-settings-automation mr-1"></i>Thao tác khác</span>
                  </c:otherwise>
                </c:choose>

                <!-- Time format display -->
                <c:if test="${not empty log.createdAt}">
                  <fmt:parseDate value="${log.createdAt.toString().substring(0,16)}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" />
                  <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy HH:mm" var="formattedDate" />
                  <span class="text-[11px] text-zinc-400 font-semibold flex items-center gap-1 ml-1">
                    <i class="ti ti-clock text-sm"></i> ${formattedDate}
                  </span>
                </c:if>
              </div>

              <!-- Log Description Details -->
              <p class="text-xs text-zinc-700 leading-relaxed font-medium bg-zinc-50 p-2.5 rounded-xl border border-zinc-100 mt-1">
                <c:out value="${log.details}"/>
              </p>

              <!-- Affected Target Entity -->
              <div class="flex items-center gap-2 mt-0.5">
                <!-- Dynamic entity type icon -->
                <div class="entity-icon bg-zinc-100 text-zinc-600">
                  <c:choose>
                    <c:when test="${log.entityType == 'CoSo'}"><i class="ti ti-building-stadium text-blue-500 text-sm"></i></c:when>
                    <c:when test="${log.entityType == 'TaiKhoan'}"><i class="ti ti-user text-indigo-500 text-sm"></i></c:when>
                    <c:when test="${log.entityType == 'San'}"><i class="ti ti-stadium text-emerald-500 text-sm"></i></c:when>
                    <c:when test="${log.entityType == 'LoaiSan'}"><i class="ti ti-ball-tennis text-cyan-500 text-sm"></i></c:when>
                    <c:when test="${log.entityType == 'SanPham'}"><i class="ti ti-package text-amber-500 text-sm"></i></c:when>
                    <c:when test="${log.entityType == 'YeuCauNghi'}"><i class="ti ti-clipboard-list text-rose-500 text-sm"></i></c:when>
                    <c:otherwise><i class="ti ti-hash text-slate-500 text-sm"></i></c:otherwise>
                  </c:choose>
                </div>
                <div>
                  <span class="text-xs font-bold text-zinc-800 js-entity-name"><c:out value="${log.entityName}"/></span>
                  <span class="text-[10px] text-zinc-400 ml-1.5">
                    <c:choose>
                      <c:when test="${log.entityType == 'TaiKhoan'}">Tài khoản</c:when>
                      <c:when test="${log.entityType == 'San'}">Sân</c:when>
                      <c:when test="${log.entityType == 'LoaiSan'}">Loại sân</c:when>
                      <c:when test="${log.entityType == 'SanPham'}">Sản phẩm</c:when>
                      <c:when test="${log.entityType == 'CoSo'}">Chi nhánh</c:when>
                      <c:when test="${log.entityType == 'CaLamViec'}">Ca làm việc</c:when>
                      <c:when test="${log.entityType == 'YeuCauNghi'}">Yêu cầu nghỉ</c:when>
                      <c:when test="${not empty log.entityType}"><c:out value="${log.entityType}"/></c:when>
                    </c:choose>
                  </span>
                </div>
              </div>

            </div>

            <!-- Column 3: Metadata (IP Address) -->
            <div class="shrink-0 flex items-center md:items-start md:flex-col justify-between md:justify-start gap-2 pt-2 md:pt-0 border-t md:border-t-0 border-zinc-50">
              <span class="text-[11px] font-mono text-zinc-400 bg-zinc-100 border border-zinc-200/60 px-2.5 py-1 rounded-lg flex items-center gap-1.5">
                <i class="ti ti-device-desktop text-sm"></i> IP: <c:out value="${log.ipAddress}"/>
              </span>
            </div>

          </div>
        </c:forEach>
      </c:otherwise>
    </c:choose>
  </section>

  <!-- Pagination Footer -->
  <c:if test="${totalPages > 1}">
    <section class="reveal flex items-center justify-between border-t border-zinc-250/60 pt-4 bg-transparent">
      <span class="text-xs text-zinc-500">Hiển thị trang <span class="font-bold text-zinc-850">${currentPage}</span> trong <span class="font-bold text-zinc-850">${totalPages}</span> trang</span>
      <div class="flex items-center gap-1">
        <c:if test="${currentPage > 1}">
          <c:url var="prevPageUrl" value="">
            <c:param name="page" value="${currentPage - 1}"/>
            <c:param name="entityType" value="${entityType}"/>
            <c:param name="action" value="${action}"/>
            <c:param name="dateFrom" value="${dateFrom}"/>
            <c:param name="dateTo" value="${dateTo}"/>
          </c:url>
          <a href="${prevPageUrl}" class="px-2 py-1 rounded-lg border border-zinc-200 hover:bg-zinc-150 text-zinc-500 flex items-center justify-center transition-colors">
            <i class="ti ti-chevron-left text-sm"></i>
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
            <a href="${pageUrl}" class="px-3 py-1 rounded-lg text-xs font-semibold border transition-all ${p == currentPage ? 'bg-blue-600 border-blue-600 text-white shadow-sm' : 'border-zinc-200 hover:bg-zinc-100 text-zinc-650'}">
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
          <a href="${nextPageUrl}" class="px-2 py-1 rounded-lg border border-zinc-200 hover:bg-zinc-150 text-zinc-500 flex items-center justify-center transition-colors">
            <i class="ti ti-chevron-right text-sm"></i>
          </a>
        </c:if>
      </div>
    </section>
  </c:if>
</main>

<script>
  // Clean up raw DB-style entity names stored in old audit records
  document.querySelectorAll('.js-entity-name').forEach(function(el) {
    var t = el.textContent;
    var m = t.match(/AccountID=\d+\s+ngay=(\d{4})-(\d{2})-(\d{2})/);
    if (m) { el.textContent = 'Ca làm ngày ' + m[3] + '/' + m[2] + '/' + m[1]; return; }
    if (/\w+=/.test(t)) {
      el.textContent = t.replace(/\w+=/g, '').replace(/\s+/g, ' ').trim();
    }
  });

  // Mobile sidebar menu toggler
  const mobileMenuBtn = document.getElementById('mobileMenuBtn');
  const sidebar = document.getElementById('sidebar');
  if (mobileMenuBtn && sidebar) {
    mobileMenuBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      sidebar.classList.toggle('-translate-x-full');
    });
  }

  // Scroll reveal loader
  (function() {
    var io = new IntersectionObserver(function(entries) {
      entries.forEach(function(e) {
        if (e.isIntersecting) {
          e.target.classList.add('visible');
          io.unobserve(e.target);
        }
      });
    }, { threshold: 0.05 });
    document.querySelectorAll('.reveal').forEach(function(el) { io.observe(el); });
  })();
</script>
</body>
</html>
