<%-- src/main/webapp/manager/FaceSettings.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Điểm danh khuôn mặt | Manager V-SPORT</title>
  <jsp:include page="/manager/common/manager_head.jsp"/>
  <script src="https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js"></script>
  <style>
    .fs-card { background:#fff; border:1px solid #ede9fe; border-radius:1rem; box-shadow:0 1px 2px rgba(124,58,237,.04); }
    .fs-tab {
      display:flex; align-items:center; gap:.4rem; height:2.5rem; padding:0 1.15rem;
      border-radius:.75rem; font-size:.825rem; font-weight:700; color:#6b7280;
      background:#fff; border:1px solid #ede9fe; cursor:pointer; transition:all .15s;
    }
    .fs-tab:hover { color:#7c3aed; border-color:#ddd6fe; }
    .fs-tab.active { background:#7c3aed; color:#fff; border-color:#7c3aed; box-shadow:0 4px 10px -2px rgba(124,58,237,.35); }
    .fs-stat-ico { width:2.75rem; height:2.75rem; border-radius:.85rem; display:flex; align-items:center; justify-content:center; }
    /* Toggle switch */
    .fs-switch { position:relative; display:inline-flex; align-items:center; cursor:pointer; }
    .fs-switch input { position:absolute; opacity:0; width:0; height:0; }
    .fs-switch .track {
      width:3.25rem; height:1.75rem; border-radius:9999px; background:#e4e4e7; transition:background .2s; position:relative;
    }
    .fs-switch .track::after {
      content:''; position:absolute; top:.1875rem; left:.1875rem; width:1.375rem; height:1.375rem;
      border-radius:9999px; background:#fff; box-shadow:0 1px 3px rgba(0,0,0,.2); transition:transform .2s;
    }
    .fs-switch input:checked + .track { background:#7c3aed; }
    .fs-switch input:checked + .track::after { transform:translateX(1.5rem); }
    .fs-switch input:focus-visible + .track { box-shadow:0 0 0 3px rgba(124,58,237,.25); }
    /* Segmented threshold picker */
    .fs-seg { display:grid; grid-template-columns:repeat(4,1fr); gap:.5rem; }
    .fs-seg label { cursor:pointer; display:block; position:relative; }
    .fs-seg input { position:absolute; inset:0; opacity:0; margin:0; cursor:pointer; }
    .fs-seg .opt {
      display:block; border:1.5px solid #ede9fe; border-radius:.85rem; padding:.7rem .5rem; text-align:center;
      transition:all .15s; background:#fff;
    }
    .fs-seg label:hover .opt { border-color:#ddd6fe; background:#faf5ff; }
    .fs-seg input:checked + .opt { border-color:#7c3aed; background:#f5f3ff; box-shadow:0 0 0 3px rgba(124,58,237,.1); }
    .fs-seg .opt .val { display:block; font-size:1rem; font-weight:800; color:#4c1d95; line-height:1.1; }
    .fs-seg input:checked + .opt .val { color:#7c3aed; }
    .fs-seg .opt .lbl { font-size:.65rem; font-weight:600; color:#a1a1aa; margin-top:.15rem; display:block; }
    table.fs-table { width:100%; border-collapse:collapse; font-size:.8125rem; }
    table.fs-table thead th {
      background:#faf5ff; color:#4c1d95; font-weight:700; text-align:left;
      padding:.7rem .9rem; font-size:.7rem; text-transform:uppercase; letter-spacing:.03em; white-space:nowrap;
    }
    table.fs-table tbody td { padding:.7rem .9rem; border-top:1px solid #f5f3ff; vertical-align:middle; }
    table.fs-table tbody tr:hover { background:#fdfaff; }
    .fs-badge { display:inline-flex; align-items:center; gap:.2rem; padding:.15rem .55rem; border-radius:9999px; font-size:.6875rem; font-weight:700; }
  </style>
</head>
<body class="bg-[#fbfaff]">
<jsp:include page="/manager/common/sidebar.jsp"/>
<c:set var="headerTitle" value="Điểm danh khuôn mặt" scope="page"/>
<c:set var="headerSubtitle" value="Quyền hạn Quản lý · Cơ sở CS${sessionScope.user.coSoId}" scope="page"/>
<c:set var="headerIcon" value="face" scope="page"/>
<jsp:include page="/manager/common/header.jsp"/>

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <%-- ── Flash messages ── --%>
  <c:if test="${not empty sessionScope.flashSuccess}">
    <div class="p-4 bg-violet-50 border border-violet-100 rounded-xl text-violet-700 text-sm flex items-start gap-3">
      <span class="material-symbols-outlined text-[20px] text-violet-600" style="font-variation-settings:'FILL' 1">check_circle</span>
      <span>${sessionScope.flashSuccess}</span>
    </div>
    <c:remove var="flashSuccess" scope="session"/>
  </c:if>
  <c:if test="${not empty sessionScope.flashError}">
    <div class="p-4 bg-rose-50 border border-rose-100 rounded-xl text-rose-700 text-sm flex items-start gap-3">
      <span class="material-symbols-outlined text-[20px] text-rose-500" style="font-variation-settings:'FILL' 1">error</span>
      <span>${sessionScope.flashError}</span>
    </div>
    <c:remove var="flashError" scope="session"/>
  </c:if>

  <%-- ── Stat cards ── --%>
  <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
    <div class="fs-card p-5 flex items-center justify-between">
      <div>
        <p class="text-xs font-semibold text-zinc-400 mb-1">Trạng thái</p>
        <p class="text-base font-extrabold ${faceConfig.faceRequired ? 'text-violet-700' : 'text-zinc-500'}">
          ${faceConfig.faceRequired ? 'Bắt buộc' : 'Tùy chọn'}
        </p>
      </div>
      <div class="fs-stat-ico ${faceConfig.faceRequired ? 'bg-violet-50 text-violet-600' : 'bg-zinc-100 text-zinc-400'}">
        <span class="material-symbols-outlined text-[22px]" style="font-variation-settings:'FILL' 1">shield_person</span>
      </div>
    </div>
    <div class="fs-card p-5 flex items-center justify-between">
      <div>
        <p class="text-xs font-semibold text-zinc-400 mb-1">Đã đăng ký khuôn mặt</p>
        <p class="text-xl font-extrabold text-violet-950">
          ${daDangKy.size()}<span class="text-sm font-bold text-zinc-300"> / ${tongNhanSu}</span>
        </p>
      </div>
      <div class="fs-stat-ico bg-emerald-50 text-emerald-600">
        <span class="material-symbols-outlined text-[22px]" style="font-variation-settings:'FILL' 1">how_to_reg</span>
      </div>
    </div>
    <div class="fs-card p-5 flex items-center justify-between">
      <div>
        <p class="text-xs font-semibold text-zinc-400 mb-1">Chưa đăng ký</p>
        <p class="text-xl font-extrabold ${chuaDangKy.size() > 0 ? 'text-amber-600' : 'text-violet-950'}">${chuaDangKy.size()}</p>
      </div>
      <div class="fs-stat-ico ${chuaDangKy.size() > 0 ? 'bg-amber-50 text-amber-500' : 'bg-zinc-100 text-zinc-400'}">
        <span class="material-symbols-outlined text-[22px]" style="font-variation-settings:'FILL' 1">person_alert</span>
      </div>
    </div>
    <div class="fs-card p-5 flex items-center justify-between">
      <div>
        <p class="text-xs font-semibold text-zinc-400 mb-1">Lượt điểm danh</p>
        <p class="text-xl font-extrabold text-violet-950">${lichSuDiemDanh.size()}</p>
      </div>
      <div class="fs-stat-ico bg-violet-50 text-violet-600">
        <span class="material-symbols-outlined text-[22px]" style="font-variation-settings:'FILL' 1">history</span>
      </div>
    </div>
  </div>

  <%-- ── Tabs ── --%>
  <div class="flex gap-2 flex-wrap">
    <button type="button" class="fs-tab active" data-tab="pane-nhansu" onclick="fsSwitch(this)">
      <span class="material-symbols-outlined text-[17px]">groups</span>Khuôn mặt nhân sự
    </button>
    <button type="button" class="fs-tab" data-tab="pane-lichsu" onclick="fsSwitch(this)">
      <span class="material-symbols-outlined text-[17px]">history</span>Lịch sử điểm danh
    </button>
    <button type="button" class="fs-tab" data-tab="pane-caidat" onclick="fsSwitch(this)">
      <span class="material-symbols-outlined text-[17px]">tune</span>Cài đặt
    </button>
  </div>

  <%-- ══════════════ TAB 1: Khuôn mặt nhân sự ══════════════ --%>
  <section id="pane-nhansu" class="fs-pane flex flex-col gap-4">

    <div class="fs-card overflow-hidden">
      <div class="px-5 py-4 border-b border-violet-50 flex items-center gap-2">
        <span class="material-symbols-outlined text-[20px] text-emerald-500" style="font-variation-settings:'FILL' 1">verified_user</span>
        <h2 class="text-sm font-bold text-violet-950">Đã đăng ký khuôn mặt</h2>
        <span class="text-xs bg-emerald-50 text-emerald-700 px-2 py-0.5 rounded-full font-bold">${daDangKy.size()}</span>
      </div>

      <c:choose>
        <c:when test="${empty daDangKy}">
          <div class="px-5 py-10 flex flex-col items-center gap-2 text-center">
            <span class="material-symbols-outlined text-[40px] text-violet-200">face_retouching_off</span>
            <p class="text-sm font-semibold text-zinc-500">Chưa có nhân viên nào đăng ký khuôn mặt</p>
            <p class="text-xs text-zinc-400">Gọi nhân viên đến quầy và bấm <b class="text-violet-600">Đăng ký</b> ở danh sách bên dưới để chụp khuôn mặt.</p>
          </div>
        </c:when>
        <c:otherwise>
          <div class="overflow-x-auto">
            <table class="fs-table">
              <thead>
                <tr>
                  <th>Nhân viên</th>
                  <th>Vai trò</th>
                  <th>Ảnh khuôn mặt</th>
                  <th>Ngày đăng ký</th>
                  <th class="text-right">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="nv" items="${daDangKy}">
                  <tr>
                    <td>
                      <div class="flex items-center gap-2.5">
                        <img class="w-9 h-9 rounded-full border border-violet-100 object-cover shrink-0"
                             src="<c:choose><c:when test='${not empty nv.avatarUrl}'>${pageContext.request.contextPath}${nv.avatarUrl}</c:when><c:otherwise>https://ui-avatars.com/api/?name=${nv.fullName}&background=7c3aed&color=fff&size=128&bold=true</c:otherwise></c:choose>"
                             alt="${nv.fullName}">
                        <div class="min-w-0">
                          <p class="font-bold text-violet-950 truncate">${nv.fullName}</p>
                          <p class="text-[11px] text-zinc-400 truncate">${nv.email}</p>
                        </div>
                      </div>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${nv.roleId == 5}">
                          <span class="fs-badge bg-rose-50 text-rose-600">Bảo vệ</span>
                        </c:when>
                        <c:otherwise>
                          <span class="fs-badge bg-sky-50 text-sky-600">Lễ tân</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${not empty nv.faceImagePath}">
                          <img src="${pageContext.request.contextPath}${nv.faceImagePath}" alt="Khuôn mặt"
                               class="w-11 h-11 rounded-lg object-cover border border-violet-100 cursor-zoom-in"
                               onclick="fsPreview(this.src, '${nv.fullName}')">
                        </c:when>
                        <c:otherwise>
                          <span class="text-xs text-zinc-300">—</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td class="text-zinc-500 whitespace-nowrap">
                      <c:choose>
                        <c:when test="${not empty nv.faceEnrolledAt}">
                          <fmt:parseDate value="${nv.faceEnrolledAt}" pattern="yyyy-MM-dd'T'HH:mm" var="pEnroll" type="both"/>
                          <fmt:formatDate value="${pEnroll}" pattern="dd/MM/yyyy HH:mm"/>
                        </c:when>
                        <c:otherwise>—</c:otherwise>
                      </c:choose>
                    </td>
                    <td class="text-right whitespace-nowrap">
                      <button type="button" onclick="fsOpenEnroll(${nv.accountId}, '${nv.fullName}')"
                              class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-bold text-violet-700 bg-violet-50 hover:bg-violet-100 transition mr-1">
                        <span class="material-symbols-outlined text-[15px]">photo_camera</span>Chụp lại
                      </button>
                      <form method="post" action="${pageContext.request.contextPath}/manager/face-settings" class="inline"
                            onsubmit="return confirm('Xóa đăng ký khuôn mặt của ${nv.fullName}? Nhân viên sẽ không điểm danh được cho tới khi đăng ký lại.')">
                        <input type="hidden" name="action" value="reset-face">
                        <input type="hidden" name="accountId" value="${nv.accountId}">
                        <button type="submit"
                                class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-bold text-rose-600 bg-rose-50 hover:bg-rose-100 transition">
                          <span class="material-symbols-outlined text-[15px]">delete</span>Xóa
                        </button>
                      </form>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

    <%-- Chưa đăng ký --%>
    <c:if test="${not empty chuaDangKy}">
      <div class="fs-card overflow-hidden">
        <div class="px-5 py-4 border-b border-violet-50 flex items-center gap-2">
          <span class="material-symbols-outlined text-[20px] text-amber-500" style="font-variation-settings:'FILL' 1">warning</span>
          <h2 class="text-sm font-bold text-violet-950">Chưa đăng ký khuôn mặt</h2>
          <span class="text-xs bg-amber-50 text-amber-700 px-2 py-0.5 rounded-full font-bold">${chuaDangKy.size()}</span>
        </div>
        <c:if test="${faceConfig.faceRequired}">
          <div class="mx-5 mt-4 p-3 bg-amber-50 border border-amber-100 rounded-xl text-xs text-amber-700 flex items-start gap-2">
            <span class="material-symbols-outlined text-[16px] mt-px">info</span>
            <span>Đang bật chế độ <b>bắt buộc</b> — những nhân viên dưới đây sẽ không thể vào ca cho tới khi đăng ký khuôn mặt.</span>
          </div>
        </c:if>
        <div class="p-5 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
          <c:forEach var="nv" items="${chuaDangKy}">
            <div class="flex items-center gap-3 p-3 bg-zinc-50 border border-zinc-100 rounded-xl">
              <img class="w-9 h-9 rounded-full border border-white object-cover shrink-0"
                   src="<c:choose><c:when test='${not empty nv.avatarUrl}'>${pageContext.request.contextPath}${nv.avatarUrl}</c:when><c:otherwise>https://ui-avatars.com/api/?name=${nv.fullName}&background=a1a1aa&color=fff&size=128&bold=true</c:otherwise></c:choose>"
                   alt="${nv.fullName}">
              <div class="min-w-0 flex-1">
                <p class="text-xs font-bold text-zinc-700 truncate">${nv.fullName}</p>
                <span class="text-[10px] font-bold ${nv.roleId == 5 ? 'text-rose-400' : 'text-sky-400'}">
                  ${nv.roleId == 5 ? 'Bảo vệ' : 'Lễ tân'}
                </span>
              </div>
              <button type="button" onclick="fsOpenEnroll(${nv.accountId}, '${nv.fullName}')"
                      class="shrink-0 inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-bold text-white bg-violet-600 hover:bg-violet-700 transition">
                <span class="material-symbols-outlined text-[15px]">photo_camera</span>Đăng ký
              </button>
            </div>
          </c:forEach>
        </div>
      </div>
    </c:if>
  </section>

  <%-- ══════════════ TAB 2: Lịch sử điểm danh ══════════════ --%>
  <section id="pane-lichsu" class="fs-pane hidden">
    <div class="fs-card overflow-hidden">
      <div class="px-5 py-4 border-b border-violet-50 flex items-center justify-between gap-3 flex-wrap">
        <div class="flex items-center gap-2">
          <span class="material-symbols-outlined text-[20px] text-violet-500" style="font-variation-settings:'FILL' 1">fact_check</span>
          <h2 class="text-sm font-bold text-violet-950">Lịch sử điểm danh khuôn mặt</h2>
          <span class="text-xs bg-violet-100 text-violet-700 px-2 py-0.5 rounded-full font-bold">${lichSuDiemDanh.size()}</span>
        </div>
        <p class="text-[11px] text-zinc-400">50 lượt gần nhất · độ khớp càng thấp càng giống</p>
      </div>

      <c:choose>
        <c:when test="${empty lichSuDiemDanh}">
          <div class="px-5 py-10 flex flex-col items-center gap-2 text-center">
            <span class="material-symbols-outlined text-[40px] text-violet-200">history_toggle_off</span>
            <p class="text-sm font-semibold text-zinc-500">Chưa có lượt điểm danh khuôn mặt nào</p>
            <p class="text-xs text-zinc-400">Lịch sử sẽ xuất hiện khi nhân viên vào ca bằng nhận diện khuôn mặt.</p>
          </div>
        </c:when>
        <c:otherwise>
          <div class="overflow-x-auto">
            <table class="fs-table">
              <thead>
                <tr>
                  <th>Nhân viên</th>
                  <th>Ca làm</th>
                  <th>Vào ca</th>
                  <th>Ra ca</th>
                  <th>Độ khớp</th>
                  <th>Chống giả mạo</th>
                  <th>Ảnh chụp</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="log" items="${lichSuDiemDanh}">
                  <tr>
                    <td>
                      <p class="font-bold text-violet-950 whitespace-nowrap">${log.fullName}</p>
                      <span class="text-[10px] font-bold ${log.roleId == 5 ? 'text-rose-400' : 'text-sky-400'}">
                        ${log.roleId == 5 ? 'Bảo vệ' : 'Lễ tân'}
                      </span>
                    </td>
                    <td class="whitespace-nowrap">
                      <p class="font-semibold text-zinc-700">${not empty log.tenCa ? log.tenCa : 'Ca làm việc'}</p>
                      <p class="text-[11px] text-zinc-400">
                        <fmt:parseDate value="${log.ngayLam}" pattern="yyyy-MM-dd" var="pNgay" type="date"/>
                        <fmt:formatDate value="${pNgay}" pattern="dd/MM/yyyy"/>
                      </p>
                    </td>
                    <td class="whitespace-nowrap">
                      <c:choose>
                        <c:when test="${not empty log.gioVaoThuc}">
                          <fmt:parseDate value="${log.gioVaoThuc}" pattern="yyyy-MM-dd'T'HH:mm" var="pVao" type="both"/>
                          <span class="fs-badge bg-emerald-50 text-emerald-600">
                            <span class="material-symbols-outlined text-[13px]">login</span>
                            <fmt:formatDate value="${pVao}" pattern="HH:mm"/>
                          </span>
                        </c:when>
                        <c:otherwise><span class="text-zinc-300">—</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td class="whitespace-nowrap">
                      <c:choose>
                        <c:when test="${not empty log.gioRaThuc}">
                          <fmt:parseDate value="${log.gioRaThuc}" pattern="yyyy-MM-dd'T'HH:mm" var="pRa" type="both"/>
                          <span class="fs-badge bg-zinc-100 text-zinc-600">
                            <span class="material-symbols-outlined text-[13px]">logout</span>
                            <fmt:formatDate value="${pRa}" pattern="HH:mm"/>
                          </span>
                        </c:when>
                        <c:otherwise><span class="fs-badge bg-amber-50 text-amber-600">Đang trong ca</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td class="whitespace-nowrap">
                      <c:choose>
                        <c:when test="${not empty log.faceConfidence}">
                          <span class="fs-badge ${log.faceConfidence <= faceConfig.confidenceMin ? 'bg-violet-100 text-violet-700' : 'bg-amber-50 text-amber-600'}">
                            <fmt:formatNumber value="${log.faceConfidence}" maxFractionDigits="3" minFractionDigits="3"/>
                          </span>
                        </c:when>
                        <c:otherwise><span class="text-zinc-300">—</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${log.faceLivenessPassed}">
                          <span class="fs-badge bg-emerald-50 text-emerald-600">
                            <span class="material-symbols-outlined text-[13px]" style="font-variation-settings:'FILL' 1">verified</span>Đạt
                          </span>
                        </c:when>
                        <c:otherwise>
                          <span class="fs-badge bg-zinc-100 text-zinc-400">Không có</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <div class="flex items-center gap-1.5">
                        <c:if test="${not empty log.faceCheckInImage}">
                          <img src="${pageContext.request.contextPath}${log.faceCheckInImage}" alt="Ảnh vào ca"
                               title="Ảnh vào ca"
                               class="w-9 h-9 rounded-lg object-cover border border-emerald-100 cursor-zoom-in"
                               onclick="fsPreview(this.src, 'Vào ca — ${log.fullName}')">
                        </c:if>
                        <c:if test="${not empty log.faceCheckOutImage}">
                          <img src="${pageContext.request.contextPath}${log.faceCheckOutImage}" alt="Ảnh ra ca"
                               title="Ảnh ra ca"
                               class="w-9 h-9 rounded-lg object-cover border border-zinc-200 cursor-zoom-in"
                               onclick="fsPreview(this.src, 'Ra ca — ${log.fullName}')">
                        </c:if>
                        <c:if test="${empty log.faceCheckInImage and empty log.faceCheckOutImage}">
                          <span class="text-zinc-300">—</span>
                        </c:if>
                      </div>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </div>
        </c:otherwise>
      </c:choose>
    </div>
  </section>

  <%-- ══════════════ TAB 3: Cài đặt ══════════════ --%>
  <section id="pane-caidat" class="fs-pane hidden">
    <div class="fs-card p-6 max-w-2xl">
      <h2 class="text-base font-bold text-violet-950 mb-1">Cài đặt điểm danh khuôn mặt</h2>
      <p class="text-xs text-zinc-400 mb-6">Áp dụng cho toàn bộ Lễ tân và Bảo vệ tại cơ sở của bạn.</p>

      <form method="post" action="${pageContext.request.contextPath}/manager/face-settings" class="flex flex-col gap-6">

        <div class="flex items-center justify-between gap-4 p-4 bg-violet-50/60 border border-violet-100 rounded-xl">
          <div>
            <p class="font-bold text-violet-950 text-sm">Bắt buộc điểm danh bằng khuôn mặt</p>
            <p class="text-xs text-zinc-500 mt-0.5">Bật: nhân viên chỉ vào/ra ca qua nhận diện. Tắt: vẫn cho điểm danh thủ công.</p>
          </div>
          <label class="fs-switch shrink-0">
            <input type="checkbox" name="faceRequired" ${faceConfig.faceRequired ? 'checked' : ''}>
            <span class="track"></span>
          </label>
        </div>

        <div>
          <p class="text-sm font-bold text-violet-950 mb-1">Ngưỡng nhận diện</p>
          <p class="text-xs text-zinc-400 mb-3">Khoảng cách Euclidean tối đa giữa khuôn mặt quét và ảnh đã đăng ký — số càng nhỏ càng nghiêm ngặt.</p>
          <div class="fs-seg">
            <label>
              <input type="radio" name="confidenceMin" value="0.4" ${faceConfig.confidenceMin <= 0.45 ? 'checked' : ''}>
              <span class="opt"><span class="val">0.4</span><span class="lbl">Rất nghiêm ngặt</span></span>
            </label>
            <label>
              <input type="radio" name="confidenceMin" value="0.5" ${faceConfig.confidenceMin > 0.45 and faceConfig.confidenceMin <= 0.55 ? 'checked' : ''}>
              <span class="opt"><span class="val">0.5</span><span class="lbl">Nghiêm ngặt</span></span>
            </label>
            <label>
              <input type="radio" name="confidenceMin" value="0.6" ${faceConfig.confidenceMin > 0.55 and faceConfig.confidenceMin <= 0.65 ? 'checked' : ''}>
              <span class="opt"><span class="val">0.6</span><span class="lbl">Khuyến nghị</span></span>
            </label>
            <label>
              <input type="radio" name="confidenceMin" value="0.7" ${faceConfig.confidenceMin > 0.65 ? 'checked' : ''}>
              <span class="opt"><span class="val">0.7</span><span class="lbl">Thoải mái</span></span>
            </label>
          </div>
          <p class="text-xs text-zinc-400 mt-2.5 flex items-start gap-1.5">
            <span class="material-symbols-outlined text-[15px] text-violet-400 mt-px">lightbulb</span>
            Nên để <b class="text-violet-600">0.6</b> — phù hợp hầu hết điều kiện ánh sáng. Hạ xuống 0.4–0.5 nếu cần bảo mật cao hơn.
          </p>
        </div>

        <button type="submit"
                class="h-11 rounded-xl bg-violet-600 hover:bg-violet-700 text-white font-bold text-sm transition shadow-md shadow-violet-100 flex items-center justify-center gap-2">
          <span class="material-symbols-outlined text-[18px]">save</span>Lưu cài đặt
        </button>
      </form>
    </div>
  </section>
</main>

<%-- ── Enroll modal: manager chụp khuôn mặt cho nhân viên ── --%>
<div id="fsEnrollModal" class="fixed inset-0 bg-black/70 z-[60] hidden items-center justify-center p-4">
  <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md flex flex-col max-h-[92vh]">
    <div class="flex items-center justify-between px-5 py-4 border-b border-violet-50 shrink-0">
      <div class="min-w-0">
        <p class="text-sm font-bold text-violet-950">Đăng ký khuôn mặt</p>
        <p id="fsEnrollName" class="text-xs text-zinc-400 truncate"></p>
      </div>
      <button onclick="fsCloseEnroll()" class="p-1.5 rounded-lg hover:bg-violet-50 shrink-0">
        <span class="material-symbols-outlined text-[18px] text-zinc-500">close</span>
      </button>
    </div>

    <div class="p-5 flex flex-col gap-4 overflow-y-auto">
      <div class="relative w-full aspect-square bg-zinc-900 rounded-xl overflow-hidden">
        <video id="fsVideo" class="w-full h-full object-cover scale-x-[-1]" autoplay muted playsinline></video>
        <img id="fsShot" class="hidden absolute inset-0 w-full h-full object-cover scale-x-[-1]" alt="Ảnh đã chụp">
      </div>
      <canvas id="fsCanvas" class="hidden"></canvas>

      <%-- Các mẫu đã chụp --%>
      <div>
        <div class="flex items-baseline justify-between mb-1.5">
          <span class="text-xs font-semibold text-zinc-500">Mẫu đã chụp</span>
          <span id="fsSampleCount" class="text-violet-600 font-black text-sm">0 / 3</span>
        </div>
        <div id="fsSampleStrip" class="flex gap-2"></div>
        <p class="text-[11px] text-zinc-400 mt-1.5">
          Chụp 3 mẫu ở góc và ánh sáng khác nhau để nhận diện ổn định hơn. Tối thiểu 1 mẫu.
        </p>
      </div>

      <p id="fsEnrollStatus" class="text-sm text-center text-zinc-500 font-medium min-h-[2.5rem]">
        Nhấn "Mở camera" để bắt đầu
      </p>
    </div>

    <div class="px-5 pb-5 flex gap-2 shrink-0">
      <button type="button" id="fsBtnStart" onclick="fsStartCamera()"
              class="flex-1 h-11 rounded-xl bg-violet-600 hover:bg-violet-700 text-white font-bold text-sm transition flex items-center justify-center gap-2">
        <span class="material-symbols-outlined text-[18px]">videocam</span>Mở camera
      </button>
      <button type="button" id="fsBtnCapture" onclick="fsCaptureSample()" disabled
              class="flex-1 h-11 rounded-xl bg-amber-500 hover:bg-amber-600 disabled:bg-zinc-200 disabled:text-zinc-400 text-white font-bold text-sm transition flex items-center justify-center gap-2">
        <span class="material-symbols-outlined text-[18px]">photo_camera</span>Chụp mẫu
      </button>
      <button type="button" id="fsBtnSave" onclick="fsSaveEnroll()" disabled
              class="flex-1 h-11 rounded-xl bg-emerald-600 hover:bg-emerald-700 disabled:bg-zinc-200 disabled:text-zinc-400 text-white font-bold text-sm transition flex items-center justify-center gap-2">
        <span class="material-symbols-outlined text-[18px]">save</span>Lưu
      </button>
    </div>
  </div>
</div>

<%-- ── Image preview modal ── --%>
<div id="fsPreviewModal" class="fixed inset-0 bg-black/70 z-[60] hidden items-center justify-center p-4" onclick="fsClosePreview()">
  <div class="bg-white rounded-2xl overflow-hidden max-w-sm w-full" onclick="event.stopPropagation()">
    <div class="flex items-center justify-between px-4 py-3 border-b border-violet-50">
      <p id="fsPreviewTitle" class="text-sm font-bold text-violet-950 truncate"></p>
      <button onclick="fsClosePreview()" class="p-1 rounded-lg hover:bg-violet-50">
        <span class="material-symbols-outlined text-[18px] text-zinc-500">close</span>
      </button>
    </div>
    <img id="fsPreviewImg" src="" alt="" class="w-full object-contain bg-zinc-900 max-h-[70vh]">
  </div>
</div>

<script>
  function fsSwitch(btn) {
    document.querySelectorAll('.fs-tab').forEach(function (t) { t.classList.remove('active'); });
    btn.classList.add('active');
    document.querySelectorAll('.fs-pane').forEach(function (p) { p.classList.add('hidden'); });
    document.getElementById(btn.dataset.tab).classList.remove('hidden');
  }

  function fsPreview(src, title) {
    document.getElementById('fsPreviewImg').src = src;
    document.getElementById('fsPreviewTitle').textContent = title;
    var m = document.getElementById('fsPreviewModal');
    m.classList.remove('hidden');
    m.classList.add('flex');
  }

  function fsClosePreview() {
    var m = document.getElementById('fsPreviewModal');
    m.classList.add('hidden');
    m.classList.remove('flex');
    document.getElementById('fsPreviewImg').src = '';
  }

  document.addEventListener('keydown', function (e) { if (e.key === 'Escape') fsClosePreview(); });

  /* ═══════════ Đăng ký khuôn mặt (manager chụp hộ nhân viên) ═══════════ */
  var FS_CTX = '${pageContext.request.contextPath}';
  var FS_MODEL_URL = FS_CTX + '/assets/face-models';
  var FS_MAX_DISTANCE = 0.8;
  var FS_THRESHOLD = ${faceConfig.confidenceMin};
  // Ngưỡng Euclidean của cơ sở quy đổi sang % — dùng chung thang đo với màn điểm danh
  var FS_REQUIRED = Math.round(Math.max(0, Math.min(100, (1 - FS_THRESHOLD / FS_MAX_DISTANCE) * 100)));

  var FS_RECOMMENDED_SAMPLES = 3;
  var FS_MIN_DETECT_SCORE = 0.7;   // điểm tin cậy tối thiểu của bộ phát hiện để chụp
  var FS_DUP_DISTANCE = 0.2;       // gần hơn mức này coi như trùng mẫu cũ
  var FS_DIFF_DISTANCE = 0.6;      // xa hơn mức này có thể là người khác

  var _fsTargetId = null;
  var _fsStream = null;
  var _fsLoopId = null;
  var _fsModelsLoaded = false;
  var _fsSamples = [];      // [{descriptor: [...], snapshot: dataUrl}]
  var _fsLiveDetection = null;  // detection của frame mới nhất, dùng khi bấm Chụp mẫu

  function fsEuclidean(a, b) {
    var sum = 0;
    for (var i = 0; i < Math.min(a.length, b.length); i++) {
      var d = a[i] - b[i];
      sum += d * d;
    }
    return Math.sqrt(sum);
  }

  function fsRenderSamples() {
    var strip = document.getElementById('fsSampleStrip');
    strip.innerHTML = '';
    _fsSamples.forEach(function (s, idx) {
      var wrap = document.createElement('div');
      wrap.className = 'relative w-14 h-14 rounded-lg overflow-hidden bg-zinc-100 shrink-0';
      var img = document.createElement('img');
      img.src = s.snapshot;
      img.className = 'w-full h-full object-cover scale-x-[-1]';
      img.alt = 'Mẫu ' + (idx + 1);
      var del = document.createElement('button');
      del.type = 'button';
      del.className = 'absolute top-0 right-0 bg-black/60 text-white text-[10px] leading-none px-1 py-0.5';
      del.textContent = '×';
      del.onclick = function () { _fsSamples.splice(idx, 1); fsRenderSamples(); };
      wrap.appendChild(img);
      wrap.appendChild(del);
      strip.appendChild(wrap);
    });
    document.getElementById('fsSampleCount').textContent =
      _fsSamples.length + ' / ' + FS_RECOMMENDED_SAMPLES;
    document.getElementById('fsBtnSave').disabled = _fsSamples.length === 0;
  }

  function fsOpenEnroll(accountId, fullName) {
    _fsTargetId = accountId;
    _fsSamples = [];
    document.getElementById('fsEnrollName').textContent = fullName;
    document.getElementById('fsShot').classList.add('hidden');
    document.getElementById('fsBtnSave').disabled = true;
    document.getElementById('fsBtnCapture').disabled = true;
    fsRenderSamples();
    fsStatus('Nhấn "Mở camera" để bắt đầu', 'text-zinc-500');
    var m = document.getElementById('fsEnrollModal');
    m.classList.remove('hidden');
    m.classList.add('flex');
  }

  function fsCloseEnroll() {
    fsStopCamera();
    var m = document.getElementById('fsEnrollModal');
    m.classList.add('hidden');
    m.classList.remove('flex');
  }

  function fsStopCamera() {
    if (_fsLoopId) { clearInterval(_fsLoopId); _fsLoopId = null; }
    if (_fsStream) { _fsStream.getTracks().forEach(function (t) { t.stop(); }); _fsStream = null; }
  }

  function fsStatus(msg, cls) {
    var el = document.getElementById('fsEnrollStatus');
    el.textContent = msg;
    el.className = 'text-sm text-center font-medium min-h-[2.5rem] ' + (cls || 'text-zinc-500');
  }

  async function fsStartCamera() {
    fsStopCamera();
    document.getElementById('fsShot').classList.add('hidden');
    _fsLiveDetection = null;

    try {
      if (!_fsModelsLoaded) {
        fsStatus('Đang tải model nhận diện...', 'text-zinc-500');
        await Promise.all([
          faceapi.nets.tinyFaceDetector.loadFromUri(FS_MODEL_URL),
          faceapi.nets.faceLandmark68TinyNet.loadFromUri(FS_MODEL_URL),
          faceapi.nets.faceRecognitionNet.loadFromUri(FS_MODEL_URL)
        ]);
        _fsModelsLoaded = true;
      }

      var video = document.getElementById('fsVideo');
      _fsStream = await navigator.mediaDevices.getUserMedia({ video: { width: 640, height: 480, facingMode: 'user' } });
      video.srcObject = _fsStream;
      await new Promise(function (r) { video.onloadedmetadata = r; });
      await video.play();

      fsStatus('Nhân viên nhìn thẳng vào camera, giữ yên...', 'text-violet-600');
      _fsLoopId = setInterval(fsDetectLoop, 150);
    } catch (e) {
      fsStatus('Không mở được camera: ' + e.message, 'text-red-600');
    }
  }

  async function fsDetectLoop() {
    var video = document.getElementById('fsVideo');
    var det = await faceapi
      .detectSingleFace(video, new faceapi.TinyFaceDetectorOptions({ inputSize: 320 }))
      .withFaceLandmarks(true)
      .withFaceDescriptor();

    if (!det || det.detection.score < FS_MIN_DETECT_SCORE) {
      _fsLiveDetection = null;
      document.getElementById('fsBtnCapture').disabled = true;
      fsStatus('Chưa thấy khuôn mặt rõ — đưa mặt vào giữa khung, đủ sáng', 'text-zinc-500');
      return;
    }

    _fsLiveDetection = det;
    document.getElementById('fsBtnCapture').disabled = false;
    fsStatus('Đã sẵn sàng — nhấn "Chụp mẫu"', 'text-green-600 font-semibold');
  }

  /** Chụp frame hiện tại thành một mẫu, kèm cảnh báo trùng lặp / khác người. */
  function fsCaptureSample() {
    if (!_fsLiveDetection) return;
    var descriptor = Array.from(_fsLiveDetection.descriptor);
    var video = document.getElementById('fsVideo');

    var warning = '';
    if (_fsSamples.length > 0) {
      var best = Infinity;
      _fsSamples.forEach(function (s) {
        var d = fsEuclidean(s.descriptor, descriptor);
        if (d < best) best = d;
      });
      if (best < FS_DUP_DISTANCE) {
        warning = ' Mẫu gần trùng mẫu đã có, hãy chụp ở góc hoặc ánh sáng khác.';
      } else if (best > FS_DIFF_DISTANCE) {
        warning = ' Ảnh này có thể không phải cùng một người.';
      }
    }

    _fsSamples.push({ descriptor: descriptor, snapshot: fsCapture(video) });
    fsRenderSamples();
    fsStatus('✓ Đã thêm mẫu ' + _fsSamples.length + '.' + warning,
             warning ? 'text-amber-600 font-semibold' : 'text-green-600 font-bold');
  }

  function fsCapture(video) {
    var canvas = document.getElementById('fsCanvas');
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    canvas.getContext('2d').drawImage(video, 0, 0);
    return canvas.toDataURL('image/jpeg', 0.85);
  }

  async function fsSaveEnroll() {
    if (!_fsSamples.length || !_fsTargetId) return;
    document.getElementById('fsBtnSave').disabled = true;
    fsStatus('Đang lưu...', 'text-zinc-500');

    var csrf = document.querySelector('meta[name="csrf-token"]');
    try {
      var res = await fetch(FS_CTX + '/face/enroll?targetAccountId=' + _fsTargetId, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          descriptors: _fsSamples.map(function (s) { return s.descriptor; }),
          photo: _fsSamples[0].snapshot,
          _csrf: csrf ? csrf.content : ''
        })
      });
      var data = await res.json();
      if (data.success) {
        fsStatus('✓ Đã lưu ' + _fsSamples.length + ' mẫu! Đang tải lại...', 'text-green-600 font-bold');
        setTimeout(function () { location.reload(); }, 900);
      } else {
        fsStatus('Lỗi: ' + (data.error || 'Không thể lưu'), 'text-red-600 font-bold');
        document.getElementById('fsBtnSave').disabled = false;
      }
    } catch (e) {
      fsStatus('Lỗi kết nối: ' + e.message, 'text-red-600 font-bold');
      document.getElementById('fsBtnSave').disabled = false;
    }
  }
</script>

</body>
</html>
