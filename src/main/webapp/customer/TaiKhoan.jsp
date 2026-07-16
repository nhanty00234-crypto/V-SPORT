<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tài khoản của tôi - V-SPORT</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <jsp:include page="/common/head.jsp" />
    <style>
        body {
            font-family: 'Inter', system-ui, -apple-system, sans-serif !important;
            background-color: #f8fafc !important;
            color: #0f172a !important;
        }
        .acc-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
        }
        .acc-field-view dt { font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.03em; margin-bottom: 4px; }
        .acc-field-view dd { font-size: 14px; font-weight: 600; color: #0f172a; }
        .acc-input {
            width: 100%; height: 42px; padding: 0 14px; border-radius: 10px;
            border: 1px solid #cbd5e1; background: #fff; font-size: 14px; color: #0f172a;
            transition: border-color .15s ease, box-shadow .15s ease;
        }
        .acc-input:focus { outline: none; border-color: #10b981; box-shadow: 0 0 0 3px rgba(16,185,129,.12); }
        .acc-label { display:block; font-size: 12px; font-weight: 700; color: #475569; margin-bottom: 6px; }
        .btn-primary {
            display:inline-flex; align-items:center; justify-content:center; gap:6px;
            background:#059669; color:#fff; font-weight:700; font-size:13px;
            padding: 10px 18px; border-radius: 10px; transition: background .15s ease, transform .1s ease;
        }
        .btn-primary:hover { background:#047857; }
        .btn-primary:active { transform: scale(.97); }
        .btn-primary:disabled { opacity:.6; cursor:not-allowed; }
        .btn-secondary {
            display:inline-flex; align-items:center; justify-content:center; gap:6px;
            background:#fff; color:#334155; font-weight:700; font-size:13px;
            padding: 10px 18px; border-radius: 10px; border:1px solid #cbd5e1; transition: background .15s ease;
        }
        .btn-secondary:hover { background:#f8fafc; }
        #accToast { transition: opacity .25s ease, transform .25s ease; }
    </style>
</head>
<body class="min-h-screen flex flex-col antialiased">

<jsp:include page="/common/header.jsp" />

<main class="flex-grow pt-24 pb-20">
    <div class="max-w-[1180px] mx-auto px-4 sm:px-6 lg:px-8">

        <!-- Breadcrumb -->
        <nav class="text-xs text-slate-500 mb-4 flex items-center gap-1.5" aria-label="Breadcrumb">
            <a href="${pageContext.request.contextPath}/index.jsp" class="hover:text-emerald-600 transition-colors">Trang chủ</a>
            <span class="material-symbols-outlined text-[13px] text-slate-300">chevron_right</span>
            <span class="text-slate-700 font-semibold">Tài khoản</span>
        </nav>

        <!-- Page header -->
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-7">
            <div>
                <h1 class="text-2xl sm:text-[28px] font-extrabold text-slate-900 tracking-tight">Tài khoản của tôi</h1>
                <p class="text-sm text-slate-500 mt-1.5 max-w-xl">Quản lý thông tin cá nhân, bảo mật và hoạt động đặt sân của bạn.</p>
            </div>
            <a href="${pageContext.request.contextPath}/customer/dat-san" class="btn-primary shrink-0 w-full sm:w-auto">
                <span class="material-symbols-outlined text-[18px]">add</span>
                Đặt sân mới
            </a>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

            <!-- LEFT COLUMN -->
            <div class="lg:col-span-1 space-y-6">

                <!-- Profile summary -->
                <div class="acc-card p-6 flex flex-col items-center text-center">
                    <div class="relative">
                        <c:choose>
                            <c:when test="${not empty account.avatarUrl}">
                                <img id="accAvatarPreview" src="${pageContext.request.contextPath}${account.avatarUrl}" alt="Ảnh đại diện" class="w-20 h-20 rounded-full object-cover ring-2 ring-emerald-500/30">
                            </c:when>
                            <c:otherwise>
                                <div id="accAvatarInitial" class="w-20 h-20 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center font-extrabold text-2xl ring-2 ring-emerald-500/20">
                                    <c:choose>
                                        <c:when test="${not empty account.fullName}">${fn:escapeXml(fn:substring(account.fullName, 0, 1))}</c:when>
                                        <c:otherwise>${fn:escapeXml(fn:substring(account.username, 0, 1))}</c:otherwise>
                                    </c:choose>
                                </div>
                                <img id="accAvatarPreview" src="" alt="Ảnh đại diện" class="hidden w-20 h-20 rounded-full object-cover ring-2 ring-emerald-500/30">
                            </c:otherwise>
                        </c:choose>
                        <label for="accAvatarInput" class="absolute bottom-0 right-0 w-7 h-7 rounded-full bg-emerald-600 text-white flex items-center justify-center cursor-pointer shadow hover:bg-emerald-700 transition-colors">
                            <span class="material-symbols-outlined text-[14px]">photo_camera</span>
                        </label>
                        <input id="accAvatarInput" type="file" accept="image/jpeg,image/png,image/webp,image/gif" class="hidden">
                    </div>
                    <p id="accAvatarError" class="hidden mt-3 text-[11px] font-semibold text-red-600 bg-red-50 border border-red-100 rounded-lg px-3 py-1.5"></p>

                    <h3 id="accSummaryName" class="font-extrabold text-slate-900 text-base leading-tight mt-4">${fn:escapeXml(not empty account.fullName ? account.fullName : account.username)}</h3>
                    <p id="accSummaryEmail" class="text-slate-500 text-xs mt-1 font-medium">${not empty account.email ? fn:escapeXml(account.email) : 'Chưa cập nhật email'}</p>
                    <p id="accSummaryPhone" class="text-slate-500 text-xs mt-0.5 font-medium">${not empty account.phoneNumber ? fn:escapeXml(account.phoneNumber) : 'Chưa cập nhật số điện thoại'}</p>

                    <div class="flex items-center gap-2 mt-3">
                        <span class="inline-flex items-center gap-1 text-[11px] font-bold text-emerald-700 bg-emerald-50 border border-emerald-100 px-2.5 py-1 rounded-full">
                            <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 inline-block"></span> Đang hoạt động
                        </span>
                    </div>

                    <c:if test="${account.createdAt != null}">
                        <p class="text-[11px] text-slate-400 mt-3">Tham gia từ <fmt:formatDate value="${account.createdAt}" pattern="dd/MM/yyyy"/></p>
                    </c:if>

                    <button type="button" onclick="enterEditMode(true)" class="btn-secondary w-full mt-5">
                        <span class="material-symbols-outlined text-[16px]">edit</span>
                        Chỉnh sửa hồ sơ
                    </button>
                </div>

                <!-- Security -->
                <div class="acc-card p-6">
                    <h3 class="text-sm font-extrabold text-slate-900 flex items-center gap-2 mb-4">
                        <span class="material-symbols-outlined text-emerald-600 text-[18px]">shield</span>
                        Bảo mật
                    </h3>
                    <div class="flex items-start gap-3">
                        <span class="material-symbols-outlined text-slate-400 text-[20px] mt-0.5">password</span>
                        <div class="flex-1">
                            <p class="text-sm font-bold text-slate-800">Mật khẩu</p>
                            <p class="text-xs text-slate-500 mt-0.5">Được bảo vệ bằng mã hóa BCrypt.</p>
                        </div>
                    </div>
                    <button type="button" onclick="openPwModal()" class="btn-secondary w-full mt-4">
                        <span class="material-symbols-outlined text-[16px]">lock_reset</span>
                        Đổi mật khẩu
                    </button>
                </div>

                <!-- Quick links -->
                <div class="acc-card p-4">
                    <a href="${pageContext.request.contextPath}/customer/dat-san" class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-slate-50 transition-colors">
                        <span class="material-symbols-outlined text-[18px] text-slate-400">calendar_add_on</span>
                        <span class="text-sm font-semibold text-slate-700">Đặt sân mới</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/dat-san?openHistory=true" class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-slate-50 transition-colors">
                        <span class="material-symbols-outlined text-[18px] text-slate-400">history</span>
                        <span class="text-sm font-semibold text-slate-700">Lịch sử đặt sân</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/index.jsp" class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-slate-50 transition-colors">
                        <span class="material-symbols-outlined text-[18px] text-slate-400">home</span>
                        <span class="text-sm font-semibold text-slate-700">Trang chủ</span>
                    </a>
                </div>
            </div>

            <!-- RIGHT COLUMN -->
            <div class="lg:col-span-2 space-y-6">

                <!-- Quick statistics -->
                <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
                    <div class="acc-card px-4 py-4 text-center">
                        <p class="text-2xl font-extrabold text-emerald-600">${upcomingCount}</p>
                        <p class="text-[11px] font-bold text-slate-500 mt-1 uppercase tracking-wide">Lịch sắp tới</p>
                    </div>
                    <div class="acc-card px-4 py-4 text-center">
                        <p class="text-2xl font-extrabold text-slate-800">${completedCount}</p>
                        <p class="text-[11px] font-bold text-slate-500 mt-1 uppercase tracking-wide">Đã hoàn thành</p>
                    </div>
                    <div class="acc-card px-4 py-4 text-center">
                        <p class="text-2xl font-extrabold text-red-500">${cancelledCount}</p>
                        <p class="text-[11px] font-bold text-slate-500 mt-1 uppercase tracking-wide">Đã hủy</p>
                    </div>
                    <div class="acc-card px-4 py-4 text-center">
                        <p class="text-2xl font-extrabold text-slate-800">${totalBookings}</p>
                        <p class="text-[11px] font-bold text-slate-500 mt-1 uppercase tracking-wide">Tổng lịch đặt</p>
                    </div>
                </div>

                <!-- Upcoming booking -->
                <div class="acc-card p-6">
                    <h3 class="text-sm font-extrabold text-slate-900 flex items-center gap-2 mb-4">
                        <span class="material-symbols-outlined text-emerald-600 text-[18px]">event_upcoming</span>
                        Lịch đặt gần nhất
                    </h3>

                    <c:choose>
                        <c:when test="${nearestBooking != null}">
                            <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-4 rounded-xl border border-slate-100 bg-slate-50/60">
                                <div class="flex-1 min-w-0">
                                    <div class="flex items-center gap-2 flex-wrap mb-1.5">
                                        <span class="font-extrabold text-slate-900 text-sm">
                                            <c:choose>
                                                <c:when test="${nearestSan != null}">${fn:escapeXml(nearestSan.tenSan)}</c:when>
                                                <c:otherwise>Sân #${nearestBooking.sanId}</c:otherwise>
                                            </c:choose>
                                        </span>
                                        <c:choose>
                                            <c:when test="${nearestBooking.trangThai == 'Chờ xác nhận' || nearestBooking.trangThai == 'Chờ thanh toán'}">
                                                <span class="bg-amber-50 text-amber-700 border border-amber-200 px-2 py-0.5 rounded-lg text-[10px] font-bold">${fn:escapeXml(nearestBooking.trangThai)}</span>
                                            </c:when>
                                            <c:when test="${nearestBooking.trangThai == 'Đã xác nhận' || nearestBooking.trangThai == 'Đã đặt' || nearestBooking.trangThai == 'Đã thanh toán' || nearestBooking.trangThai == 'Đã cọc'}">
                                                <span class="bg-emerald-50 text-emerald-700 border border-emerald-200 px-2 py-0.5 rounded-lg text-[10px] font-bold">${fn:escapeXml(nearestBooking.trangThai)}</span>
                                            </c:when>
                                            <c:when test="${nearestBooking.trangThai == 'Đang sử dụng'}">
                                                <span class="bg-purple-50 text-purple-700 border border-purple-200 px-2 py-0.5 rounded-lg text-[10px] font-bold">Đang sử dụng</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="bg-slate-100 text-slate-500 border border-slate-200 px-2 py-0.5 rounded-lg text-[10px] font-bold">${fn:escapeXml(nearestBooking.trangThai)}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <p class="text-xs text-slate-500 flex items-center gap-1 flex-wrap">
                                        <c:if test="${nearestCoSo != null}">
                                            <span class="material-symbols-outlined text-[13px] text-slate-400">location_on</span>${fn:escapeXml(nearestCoSo.tenCoSo)}<span>&middot;</span>
                                        </c:if>
                                        <c:if test="${nearestLoaiSan != null}">${fn:escapeXml(nearestLoaiSan.tenLoai)}<span>&middot;</span></c:if>
                                        Mã: #${nearestBooking.datSanId}
                                    </p>
                                    <p class="text-xs font-bold text-slate-700 mt-1.5 flex items-center gap-1.5">
                                        <span class="material-symbols-outlined text-[14px] text-emerald-600">calendar_month</span>
                                        ${fn:substring(nearestBooking.ngayDat, 8, 10)}/${fn:substring(nearestBooking.ngayDat, 5, 7)}/${fn:substring(nearestBooking.ngayDat, 0, 4)}
                                        <span class="text-slate-300">|</span>
                                        <span class="material-symbols-outlined text-[14px] text-emerald-600">schedule</span>
                                        ${fn:substring(nearestBooking.gioBatDau, 0, 5)} - ${fn:substring(nearestBooking.gioKetThuc, 0, 5)}
                                    </p>
                                </div>
                                <div class="flex sm:flex-col gap-2 shrink-0">
                                    <a href="${pageContext.request.contextPath}/customer/dat-san?openHistory=true" class="btn-secondary text-[12px] px-4 py-2 whitespace-nowrap">Xem chi tiết</a>
                                    <a href="${pageContext.request.contextPath}/customer/dat-san?openHistory=true" class="text-emerald-600 text-[12px] font-bold text-center hover:underline whitespace-nowrap">Xem tất cả lịch đặt</a>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-10">
                                <span class="material-symbols-outlined text-[40px] text-slate-200 block mb-3">event_busy</span>
                                <p class="text-sm text-slate-400 font-semibold mb-4">Bạn chưa có lịch đặt sân sắp tới.</p>
                                <a href="${pageContext.request.contextPath}/customer/dat-san" class="btn-primary inline-flex">
                                    <span class="material-symbols-outlined text-[16px]">add</span>
                                    Đặt sân ngay
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Personal information -->
                <div class="acc-card p-6" id="personalInfoCard">
                    <div class="flex items-center justify-between mb-5">
                        <h3 class="text-sm font-extrabold text-slate-900 flex items-center gap-2">
                            <span class="material-symbols-outlined text-emerald-600 text-[18px]">badge</span>
                            Thông tin cá nhân
                        </h3>
                        <button type="button" id="editToggleBtn" onclick="enterEditMode(true)" class="text-emerald-600 text-xs font-bold hover:underline flex items-center gap-1">
                            <span class="material-symbols-outlined text-[15px]">edit</span> Chỉnh sửa
                        </button>
                    </div>

                    <!-- View mode -->
                    <dl id="infoViewMode" class="acc-field-view grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-4">
                        <div>
                            <dt>Họ và tên</dt>
                            <dd id="viewFullName">${not empty account.fullName ? fn:escapeXml(account.fullName) : '—'}</dd>
                        </div>
                        <div>
                            <dt>Email</dt>
                            <dd id="viewEmail">${not empty account.email ? fn:escapeXml(account.email) : '—'}</dd>
                        </div>
                        <div>
                            <dt>Số điện thoại</dt>
                            <dd id="viewPhone">${not empty account.phoneNumber ? fn:escapeXml(account.phoneNumber) : '—'}</dd>
                        </div>
                        <div>
                            <dt>Ngày sinh</dt>
                            <dd id="viewBirthday">
                                <c:choose>
                                    <c:when test="${account.ngaySinh != null}"><fmt:formatDate value="${account.ngaySinh}" pattern="dd/MM/yyyy"/></c:when>
                                    <c:otherwise>—</c:otherwise>
                                </c:choose>
                            </dd>
                        </div>
                        <div>
                            <dt>Giới tính</dt>
                            <dd id="viewGender">${not empty account.gioiTinh ? fn:escapeXml(account.gioiTinh) : '—'}</dd>
                        </div>
                    </dl>

                    <!-- Edit mode -->
                    <form id="infoEditForm" class="hidden grid grid-cols-1 sm:grid-cols-2 gap-4" onsubmit="return false;" autocomplete="off">
                        <div>
                            <label class="acc-label" for="editFullName">Họ và tên</label>
                            <input id="editFullName" type="text" class="acc-input" value="${fn:escapeXml(account.fullName)}" maxlength="100">
                            <p class="hidden text-[11px] text-red-600 font-semibold mt-1" data-error-for="fullName"></p>
                        </div>
                        <div>
                            <label class="acc-label" for="editEmail">Email</label>
                            <input id="editEmail" type="email" class="acc-input" value="${fn:escapeXml(account.email)}">
                            <p class="hidden text-[11px] text-red-600 font-semibold mt-1" data-error-for="email"></p>
                        </div>
                        <div>
                            <label class="acc-label" for="editPhone">Số điện thoại</label>
                            <input id="editPhone" type="tel" class="acc-input" value="${fn:escapeXml(account.phoneNumber)}">
                            <p class="hidden text-[11px] text-red-600 font-semibold mt-1" data-error-for="phone"></p>
                        </div>
                        <div>
                            <label class="acc-label" for="editBirthday">Ngày sinh</label>
                            <input id="editBirthday" type="date" class="acc-input" value="<c:if test="${account.ngaySinh != null}"><fmt:formatDate value="${account.ngaySinh}" pattern="yyyy-MM-dd"/></c:if>">
                            <p class="hidden text-[11px] text-red-600 font-semibold mt-1" data-error-for="birthday"></p>
                        </div>
                        <div>
                            <label class="acc-label" for="editGender">Giới tính</label>
                            <select id="editGender" class="acc-input">
                                <option value="" ${empty account.gioiTinh ? 'selected' : ''}>-- Không chọn --</option>
                                <option value="Nam" ${account.gioiTinh == 'Nam' ? 'selected' : ''}>Nam</option>
                                <option value="Nữ" ${account.gioiTinh == 'Nữ' ? 'selected' : ''}>Nữ</option>
                                <option value="Khác" ${account.gioiTinh == 'Khác' ? 'selected' : ''}>Khác</option>
                            </select>
                            <p class="hidden text-[11px] text-red-600 font-semibold mt-1" data-error-for="gender"></p>
                        </div>
                        <div class="sm:col-span-2 flex justify-end gap-3 pt-2">
                            <button type="button" onclick="enterEditMode(false)" class="btn-secondary">Hủy</button>
                            <button type="button" id="saveInfoBtn" onclick="saveProfileInfo()" class="btn-primary">Lưu thay đổi</button>
                        </div>
                    </form>
                </div>

            </div>
        </div>
    </div>
</main>

<jsp:include page="/common/footer.jsp" />

<!-- Toast -->
<div id="accToast" class="hidden fixed bottom-6 right-6 z-[999] max-w-sm bg-white border border-slate-200 shadow-lg rounded-xl px-4 py-3 flex items-start gap-3 opacity-0 translate-y-3">
    <span id="accToastIcon" class="material-symbols-outlined text-emerald-600 text-[20px] mt-0.5">check_circle</span>
    <div>
        <p id="accToastTitle" class="text-sm font-bold text-slate-900">Thành công</p>
        <p id="accToastMessage" class="text-xs text-slate-500 mt-0.5"></p>
    </div>
</div>

<!-- Email OTP modal -->
<div id="emailOtpModal" class="hidden fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-[300] flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl shadow-2xl w-full max-w-[400px] border border-slate-200">
        <div class="px-6 py-4 border-b border-slate-100 flex items-center justify-between">
            <h3 class="text-sm font-extrabold text-slate-900 flex items-center gap-2">
                <span class="material-symbols-outlined text-emerald-600 text-[18px]">mark_email_read</span>
                Xác thực email mới
            </h3>
            <button type="button" onclick="closeModal('emailOtpModal')" class="w-8 h-8 rounded-full hover:bg-slate-100 flex items-center justify-center">
                <span class="material-symbols-outlined text-[18px] text-slate-500">close</span>
            </button>
        </div>
        <div class="px-6 py-5">
            <p class="text-sm text-slate-600">Mã OTP đã được gửi đến <strong id="otpTargetEmail" class="text-slate-900"></strong>. Nhập mã để hoàn tất thay đổi.</p>
            <input id="otpInput" type="text" maxlength="6" inputmode="numeric" placeholder="••••••" class="acc-input mt-4 text-center text-xl font-black tracking-[0.3em]">
            <p id="otpError" class="hidden mt-2 text-[11px] font-semibold text-red-600"></p>
        </div>
        <div class="px-6 pb-5 flex justify-end gap-3">
            <button type="button" onclick="closeModal('emailOtpModal')" class="btn-secondary">Hủy</button>
            <button type="button" id="otpConfirmBtn" onclick="verifyEmailOtp()" class="btn-primary">Xác thực</button>
        </div>
    </div>
</div>

<!-- Change password modal -->
<div id="pwModal" class="hidden fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-[300] flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl shadow-2xl w-full max-w-[420px] border border-slate-200">
        <div class="px-6 py-4 border-b border-slate-100 flex items-center justify-between">
            <h3 class="text-sm font-extrabold text-slate-900 flex items-center gap-2">
                <span class="material-symbols-outlined text-emerald-600 text-[18px]">lock_reset</span>
                Đổi mật khẩu
            </h3>
            <button type="button" onclick="closeModal('pwModal')" class="w-8 h-8 rounded-full hover:bg-slate-100 flex items-center justify-center">
                <span class="material-symbols-outlined text-[18px] text-slate-500">close</span>
            </button>
        </div>
        <form id="pwForm" class="px-6 py-5 flex flex-col gap-4" onsubmit="return false;" autocomplete="off">
            <div>
                <label class="acc-label" for="pwCurrent">Mật khẩu hiện tại</label>
                <div class="relative">
                    <input type="password" id="pwCurrent" class="acc-input pr-10" autocomplete="new-password">
                    <button type="button" onclick="togglePw('pwCurrent', this)" class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
                        <span class="material-symbols-outlined text-[18px]">visibility_off</span>
                    </button>
                </div>
                <p class="hidden text-[11px] text-red-600 font-semibold mt-1" data-error-for="currentPassword"></p>
            </div>
            <div>
                <label class="acc-label" for="pwNew">Mật khẩu mới</label>
                <div class="relative">
                    <input type="password" id="pwNew" class="acc-input pr-10" autocomplete="new-password" oninput="updatePwStrength()">
                    <button type="button" onclick="togglePw('pwNew', this)" class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
                        <span class="material-symbols-outlined text-[18px]">visibility_off</span>
                    </button>
                </div>
                <div class="flex gap-1 mt-2">
                    <div class="h-1 flex-1 rounded-full bg-slate-100" id="pwStr1"></div>
                    <div class="h-1 flex-1 rounded-full bg-slate-100" id="pwStr2"></div>
                    <div class="h-1 flex-1 rounded-full bg-slate-100" id="pwStr3"></div>
                    <div class="h-1 flex-1 rounded-full bg-slate-100" id="pwStr4"></div>
                </div>
                <p id="pwStrengthLabel" class="text-[11px] text-slate-400 mt-1"></p>
                <p class="hidden text-[11px] text-red-600 font-semibold mt-1" data-error-for="newPassword"></p>
            </div>
            <div>
                <label class="acc-label" for="pwConfirm">Xác nhận mật khẩu mới</label>
                <div class="relative">
                    <input type="password" id="pwConfirm" class="acc-input pr-10" autocomplete="new-password">
                    <button type="button" onclick="togglePw('pwConfirm', this)" class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
                        <span class="material-symbols-outlined text-[18px]">visibility_off</span>
                    </button>
                </div>
                <p class="hidden text-[11px] text-red-600 font-semibold mt-1" data-error-for="confirmPassword"></p>
            </div>
        </form>
        <div class="px-6 pb-5 flex justify-end gap-3">
            <button type="button" onclick="closeModal('pwModal')" class="btn-secondary">Hủy</button>
            <button type="button" id="pwSaveBtn" onclick="savePassword()" class="btn-primary">Đổi mật khẩu</button>
        </div>
    </div>
</div>

<script>
    const CTX = '${pageContext.request.contextPath}';
    document.getElementById('editBirthday').max = new Date().toISOString().split('T')[0];

    function showToast(title, message, isError) {
        const toast = document.getElementById('accToast');
        const icon = document.getElementById('accToastIcon');
        document.getElementById('accToastTitle').textContent = title;
        document.getElementById('accToastMessage').textContent = message || '';
        icon.textContent = isError ? 'error' : 'check_circle';
        icon.className = 'material-symbols-outlined text-[20px] mt-0.5 ' + (isError ? 'text-red-500' : 'text-emerald-600');
        toast.classList.remove('hidden');
        requestAnimationFrame(() => { toast.classList.remove('opacity-0', 'translate-y-3'); });
        clearTimeout(window.__accToastTimer);
        window.__accToastTimer = setTimeout(() => {
            toast.classList.add('opacity-0', 'translate-y-3');
            setTimeout(() => toast.classList.add('hidden'), 250);
        }, 4000);
    }

    function openModal(id) {
        document.getElementById(id).classList.remove('hidden');
    }
    function closeModal(id) {
        document.getElementById(id).classList.add('hidden');
    }
    document.querySelectorAll('#pwModal, #emailOtpModal').forEach(overlay => {
        overlay.addEventListener('click', (e) => { if (e.target === overlay) closeModal(overlay.id); });
    });
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            closeModal('pwModal');
            closeModal('emailOtpModal');
        }
    });

    function clearFieldErrors(scopeEl) {
        scopeEl.querySelectorAll('[data-error-for]').forEach(el => { el.textContent = ''; el.classList.add('hidden'); });
    }
    function showFieldErrors(scopeEl, fieldErrors) {
        clearFieldErrors(scopeEl);
        if (!fieldErrors) return;
        Object.keys(fieldErrors).forEach(key => {
            const el = scopeEl.querySelector('[data-error-for="' + key + '"]');
            if (el) { el.textContent = fieldErrors[key]; el.classList.remove('hidden'); }
        });
    }

    // ---- Edit mode toggle ----
    function enterEditMode(on) {
        const viewMode = document.getElementById('infoViewMode');
        const editForm = document.getElementById('infoEditForm');
        const toggleBtn = document.getElementById('editToggleBtn');
        if (on) {
            viewMode.classList.add('hidden');
            editForm.classList.remove('hidden');
            toggleBtn.classList.add('hidden');
            document.getElementById('personalInfoCard').scrollIntoView({ behavior: 'smooth', block: 'center' });
        } else {
            viewMode.classList.remove('hidden');
            editForm.classList.add('hidden');
            toggleBtn.classList.remove('hidden');
            clearFieldErrors(editForm);
        }
    }

    // ---- Save profile info ----
    function saveProfileInfo() {
        const fullName = document.getElementById('editFullName').value;
        const email = document.getElementById('editEmail').value;
        const phone = document.getElementById('editPhone').value;
        const birthday = document.getElementById('editBirthday').value;
        const gender = document.getElementById('editGender').value;

        const btn = document.getElementById('saveInfoBtn');
        btn.disabled = true;
        const originalText = btn.textContent;
        btn.textContent = 'Đang lưu...';

        const params = new URLSearchParams();
        params.append('action', 'updateInfo');
        params.append('fullName', fullName);
        params.append('email', email);
        params.append('phoneNumber', phone);
        params.append('birthday', birthday);
        params.append('gender', gender);

        fetch(CTX + '/account/update-profile', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            body: params
        })
            .then(r => r.json())
            .then(data => {
                btn.disabled = false;
                btn.textContent = originalText;
                if (data.success) {
                    if (data.requiresOtp) {
                        document.getElementById('otpTargetEmail').textContent = data.email || email;
                        document.getElementById('otpInput').value = '';
                        document.getElementById('otpError').classList.add('hidden');
                        openModal('emailOtpModal');
                        showToast('Đã gửi mã OTP', data.message);
                        return;
                    }
                    syncProfileUi(data);
                    enterEditMode(false);
                    showToast('Thành công', 'Đã cập nhật thông tin cá nhân.');
                } else if (data.code === 'VALIDATION_ERROR') {
                    showFieldErrors(document.getElementById('infoEditForm'), data.fieldErrors);
                } else {
                    showToast('Không thể cập nhật', data.message, true);
                }
            })
            .catch(() => {
                btn.disabled = false;
                btn.textContent = originalText;
                showToast('Lỗi kết nối', 'Không thể kết nối máy chủ. Vui lòng thử lại.', true);
            });
    }

    function verifyEmailOtp() {
        const otp = document.getElementById('otpInput').value.trim();
        const err = document.getElementById('otpError');
        if (!/^\d{6}$/.test(otp)) {
            err.textContent = 'Vui lòng nhập mã OTP gồm 6 chữ số.';
            err.classList.remove('hidden');
            return;
        }
        const btn = document.getElementById('otpConfirmBtn');
        btn.disabled = true;

        const params = new URLSearchParams();
        params.append('action', 'verifyEmailOtp');
        params.append('otp', otp);

        fetch(CTX + '/account/update-profile', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            body: params
        })
            .then(r => r.json())
            .then(data => {
                btn.disabled = false;
                if (data.success) {
                    syncProfileUi(data);
                    closeModal('emailOtpModal');
                    enterEditMode(false);
                    showToast('Thành công', 'Đã cập nhật thông tin cá nhân.');
                } else {
                    err.textContent = data.message || 'Không thể xác thực OTP.';
                    err.classList.remove('hidden');
                }
            })
            .catch(() => {
                btn.disabled = false;
                err.textContent = 'Lỗi kết nối. Vui lòng thử lại.';
                err.classList.remove('hidden');
            });
    }

    function syncProfileUi(data) {
        document.getElementById('viewFullName').textContent = data.fullName || '—';
        document.getElementById('viewEmail').textContent = data.email || '—';
        document.getElementById('viewPhone').textContent = data.phoneNumber || '—';
        document.getElementById('viewBirthday').textContent = data.birthday ? formatDateVn(data.birthday) : '—';
        document.getElementById('viewGender').textContent = data.gender || '—';

        document.getElementById('editFullName').value = data.fullName || '';
        document.getElementById('editEmail').value = data.email || '';
        document.getElementById('editPhone').value = data.phoneNumber || '';
        document.getElementById('editBirthday').value = data.birthday || '';
        document.getElementById('editGender').value = data.gender || '';

        document.getElementById('accSummaryName').textContent = data.fullName || '';
        document.getElementById('accSummaryEmail').textContent = data.email || 'Chưa cập nhật email';
        document.getElementById('accSummaryPhone').textContent = data.phoneNumber || 'Chưa cập nhật số điện thoại';
    }

    function formatDateVn(iso) {
        const parts = iso.split('-');
        return parts.length === 3 ? (parts[2] + '/' + parts[1] + '/' + parts[0]) : iso;
    }

    // ---- Avatar upload ----
    document.getElementById('accAvatarInput').addEventListener('change', function () {
        const file = this.files && this.files[0];
        const errEl = document.getElementById('accAvatarError');
        errEl.classList.add('hidden');
        if (!file) return;

        if (file.size > 2 * 1024 * 1024) {
            errEl.textContent = 'Ảnh quá lớn. Vui lòng chọn ảnh dưới 2MB.';
            errEl.classList.remove('hidden');
            this.value = '';
            return;
        }
        if (!['image/jpeg', 'image/png', 'image/webp', 'image/gif'].includes(file.type)) {
            errEl.textContent = 'Chỉ hỗ trợ định dạng JPG, PNG, WEBP hoặc GIF.';
            errEl.classList.remove('hidden');
            this.value = '';
            return;
        }

        const fd = new FormData();
        fd.append('action', 'updateAvatar');
        fd.append('avatar', file);

        fetch(CTX + '/account/update-profile', { method: 'POST', body: fd })
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    document.querySelectorAll('#accAvatarPreview').forEach(img => { img.src = data.avatarUrl; img.classList.remove('hidden'); });
                    const initial = document.getElementById('accAvatarInitial');
                    if (initial) initial.classList.add('hidden');
                    showToast('Thành công', 'Đã cập nhật ảnh đại diện.');
                } else {
                    errEl.textContent = data.message || 'Không thể tải ảnh lên.';
                    errEl.classList.remove('hidden');
                }
            })
            .catch(() => {
                errEl.textContent = 'Lỗi kết nối khi tải ảnh. Vui lòng thử lại.';
                errEl.classList.remove('hidden');
            });
    });

    // ---- Change password ----
    function openPwModal() {
        document.getElementById('pwForm').reset();
        clearFieldErrors(document.getElementById('pwForm'));
        ['pwStr1', 'pwStr2', 'pwStr3', 'pwStr4'].forEach(id => { document.getElementById(id).style.backgroundColor = ''; });
        document.getElementById('pwStrengthLabel').textContent = '';
        openModal('pwModal');
    }

    function togglePw(id, btn) {
        const input = document.getElementById(id);
        const icon = btn.querySelector('.material-symbols-outlined');
        if (input.type === 'password') { input.type = 'text'; icon.textContent = 'visibility'; }
        else { input.type = 'password'; icon.textContent = 'visibility_off'; }
    }

    function updatePwStrength() {
        const v = document.getElementById('pwNew').value;
        let score = 0;
        if (v.length >= 8) score++;
        if (/[A-Z]/.test(v)) score++;
        if (/[0-9]/.test(v)) score++;
        if (/[^A-Za-z0-9]/.test(v)) score++;
        const colors = ['#ef4444', '#f59e0b', '#3b82f6', '#10b981'];
        const labels = ['', 'Yếu', 'Trung bình', 'Mạnh', 'Rất mạnh'];
        for (let i = 1; i <= 4; i++) {
            document.getElementById('pwStr' + i).style.backgroundColor = i <= score ? colors[score - 1] : '';
        }
        document.getElementById('pwStrengthLabel').textContent = v.length ? labels[score] : '';
    }

    function savePassword() {
        const form = document.getElementById('pwForm');
        const currentPassword = document.getElementById('pwCurrent').value;
        const newPassword = document.getElementById('pwNew').value;
        const confirmPassword = document.getElementById('pwConfirm').value;
        clearFieldErrors(form);

        let hasError = false;
        if (!currentPassword) {
            form.querySelector('[data-error-for="currentPassword"]').textContent = 'Vui lòng nhập mật khẩu hiện tại.';
            form.querySelector('[data-error-for="currentPassword"]').classList.remove('hidden');
            hasError = true;
        }
        if (!newPassword) {
            form.querySelector('[data-error-for="newPassword"]').textContent = 'Vui lòng nhập mật khẩu mới.';
            form.querySelector('[data-error-for="newPassword"]').classList.remove('hidden');
            hasError = true;
        }
        if (newPassword && newPassword !== confirmPassword) {
            form.querySelector('[data-error-for="confirmPassword"]').textContent = 'Xác nhận mật khẩu mới không khớp.';
            form.querySelector('[data-error-for="confirmPassword"]').classList.remove('hidden');
            hasError = true;
        }
        if (hasError) return;

        const btn = document.getElementById('pwSaveBtn');
        btn.disabled = true;
        const originalText = btn.textContent;
        btn.textContent = 'Đang lưu...';

        const params = new URLSearchParams();
        params.append('action', 'changePassword');
        params.append('currentPassword', currentPassword);
        params.append('newPassword', newPassword);
        params.append('confirmPassword', confirmPassword);

        fetch(CTX + '/account/update-profile', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            body: params
        })
            .then(r => r.json())
            .then(data => {
                btn.disabled = false;
                btn.textContent = originalText;
                if (data.success) {
                    form.reset();
                    closeModal('pwModal');
                    showToast('Thành công', 'Mật khẩu đã được cập nhật.');
                } else {
                    form.querySelector('[data-error-for="currentPassword"]').textContent = data.message || 'Không thể đổi mật khẩu.';
                    form.querySelector('[data-error-for="currentPassword"]').classList.remove('hidden');
                }
            })
            .catch(() => {
                btn.disabled = false;
                btn.textContent = originalText;
                showToast('Lỗi kết nối', 'Không thể kết nối máy chủ. Vui lòng thử lại.', true);
            })
            .finally(() => {
                document.getElementById('pwCurrent').value = '';
                document.getElementById('pwNew').value = '';
                document.getElementById('pwConfirm').value = '';
            });
    }
</script>
</body>
</html>
