<%-- src/main/webapp/manager/FaceSettings.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Điểm danh khuôn mặt | Manager V-SPORT</title>
  <jsp:include page="/manager/common/manager_head.jsp"/>
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
    .fs-seg label { cursor:pointer; }
    .fs-seg input { position:absolute; opacity:0; width:0; height:0; }
    .fs-seg .opt {
      border:1.5px solid #ede9fe; border-radius:.85rem; padding:.7rem .5rem; text-align:center;
      transition:all .15s; background:#fff;
    }
    .fs-seg label:hover .opt { border-color:#ddd6fe; background:#faf5ff; }
    .fs-seg input:checked + .opt { border-color:#7c3aed; background:#f5f3ff; box-shadow:0 0 0 3px rgba(124,58,237,.1); }
    .fs-seg .opt .val { font-size:1rem; font-weight:800; color:#4c1d95; line-height:1.1; }
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
            <p class="text-xs text-zinc-400">Nhân viên tự đăng ký tại portal của họ, hoặc bạn tải ảnh lên trong trang Nhân sự.</p>
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
                    <td class="text-right">
                      <form method="post" action="${pageContext.request.contextPath}/manager/face-settings" class="inline"
                            onsubmit="return confirm('Xóa đăng ký khuôn mặt của ${nv.fullName}? Nhân viên sẽ phải đăng ký lại mới điểm danh được.')">
                        <input type="hidden" name="action" value="reset-face">
                        <input type="hidden" name="accountId" value="${nv.accountId}">
                        <button type="submit"
                                class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-bold text-rose-600 bg-rose-50 hover:bg-rose-100 transition">
                          <span class="material-symbols-outlined text-[15px]">restart_alt</span>Xóa đăng ký
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
        <div class="p-5 flex flex-wrap gap-2.5">
          <c:forEach var="nv" items="${chuaDangKy}">
            <div class="flex items-center gap-2.5 pl-1.5 pr-3.5 py-1.5 bg-zinc-50 border border-zinc-100 rounded-full">
              <img class="w-7 h-7 rounded-full border border-white object-cover"
                   src="<c:choose><c:when test='${not empty nv.avatarUrl}'>${pageContext.request.contextPath}${nv.avatarUrl}</c:when><c:otherwise>https://ui-avatars.com/api/?name=${nv.fullName}&background=a1a1aa&color=fff&size=128&bold=true</c:otherwise></c:choose>"
                   alt="${nv.fullName}">
              <span class="text-xs font-bold text-zinc-600">${nv.fullName}</span>
              <span class="text-[10px] font-bold ${nv.roleId == 5 ? 'text-rose-400' : 'text-sky-400'}">
                ${nv.roleId == 5 ? 'Bảo vệ' : 'Lễ tân'}
              </span>
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
</script>

</body>
</html>
