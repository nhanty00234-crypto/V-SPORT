<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    if (request.getAttribute("email") == null && request.getParameter("email") != null) {
        request.setAttribute("email", request.getParameter("email"));
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Xác minh OTP - V-SPORT</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@600;700;800&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet"/>
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; }
        .otp-font { font-family: 'JetBrains Mono', monospace; }
        .otp-input-field {
            text-align: center;
            font-size: 1.75rem;
            letter-spacing: 0.45em;
            font-weight: 800;
            padding-left: 0.45em;
        }
        .live-dot { animation: pulse-dot 1.6s ease-in-out infinite; }
        @keyframes pulse-dot { 0%,100%{box-shadow:0 0 0 0 rgba(220,38,38,.4);} 50%{box-shadow:0 0 0 6px rgba(220,38,38,0);} }
        .glass-card {
            background: rgba(255, 255, 255, 0.94);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
        }
    </style>
</head>
<c:set var="isDashboardFlow" value="${sessionScope.authType eq 'ADMIN_ADD' or sessionScope.authType eq 'ADMIN_EDIT' or sessionScope.authType eq 'MANAGER_EDIT'}" />
<c:set var="isAdminFlow" value="${sessionScope.authType eq 'ADMIN_ADD' or sessionScope.authType eq 'ADMIN_EDIT'}" />
<c:set var="isManagerFlow" value="${sessionScope.authType eq 'MANAGER_EDIT'}" />

<body class="${isDashboardFlow ? (isAdminFlow ? 'bg-zinc-50 text-zinc-900 min-h-screen' : 'bg-violet-50/20 text-zinc-900 min-h-screen') : 'min-h-screen flex items-center justify-center p-4 relative overflow-hidden'}">

    <c:choose>
        <c:when test="${isDashboardFlow}">
            <!-- Show Dashboard Sidebar and Header -->
            <c:choose>
                <c:when test="${isAdminFlow}">
                    <jsp:include page="/admin/common/sidebar.jsp" />
                    <header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[248px] bg-white/80 backdrop-blur-lg border-b border-zinc-200 z-20 flex items-center justify-between px-4 lg:px-6">
                      <div class="flex items-center gap-3">
                        <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-zinc-100 text-zinc-500"><span class="material-symbols-outlined text-[20px]">menu</span></button>
                        <div>
                          <h1 class="text-sm font-bold text-zinc-900 tracking-tight">Quản lý nhân sự cấp cao</h1>
                          <p class="text-xs text-zinc-500 flex items-center gap-1.5"><span class="material-symbols-outlined text-[12px]">security</span>Quyền hạn Admin</p>
                        </div>
                      </div>
                      <div class="flex items-center gap-1.5">
                        <button onclick="location.href='${pageContext.request.contextPath}/admin/HoTro.jsp'" class="hidden sm:flex items-center gap-1.5 h-9 px-3 rounded-lg border border-zinc-200 hover:bg-zinc-50 text-zinc-600 text-xs font-medium">
                          <span class="material-symbols-outlined text-[15px]">help</span>Hỗ trợ
                        </button>
                        <button class="relative p-2 rounded-lg hover:bg-zinc-100 text-zinc-500">
                          <span class="material-symbols-outlined text-[20px]">notifications</span>
                          <span class="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-red-500 live-dot"></span>
                        </button>
                        <div class="w-px h-6 bg-zinc-200 mx-1"></div>
                        <jsp:include page="/admin/common/profile_dropdown.jsp" />
                      </div>
                    </header>
                </c:when>
                <c:when test="${isManagerFlow}">
                    <jsp:include page="/manager/common/sidebar.jsp" />
                    <header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[248px] bg-white/80 backdrop-blur-lg border-b border-violet-100 z-20 flex items-center justify-between px-4 lg:px-6">
                      <div class="flex items-center gap-3">
                        <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-violet-50 text-violet-700"><span class="material-symbols-outlined text-[20px]">menu</span></button>
                        <div>
                          <h1 class="text-sm font-bold text-violet-900 tracking-tight">Quản lý nhân sự cơ sở</h1>
                          <p class="text-xs text-violet-500 flex items-center gap-1.5"><span class="material-symbols-outlined text-[12px]">security</span>Quyền hạn Quản lý · Cơ sở CS${sessionScope.user.coSoId}</p>
                        </div>
                      </div>
                      <div class="flex items-center gap-1.5">
                        <button class="relative p-2 rounded-lg hover:bg-violet-50 text-violet-500">
                          <span class="material-symbols-outlined text-[20px]">notifications</span>
                          <span class="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-violet-600 live-dot"></span>
                        </button>
                        <div class="w-px h-6 bg-violet-100 mx-1"></div>
                        <jsp:include page="/manager/common/profile_dropdown.jsp" />
                      </div>
                    </header>
                </c:when>
            </c:choose>

            <!-- Centered OTP Card within main workspace -->
            <main class="lg:ml-[248px] mt-[64px] p-6 min-h-[calc(100vh-64px)] flex items-center justify-center">
                <div class="bg-white rounded-3xl w-full max-w-[460px] p-8 shadow-2xl border border-slate-200/80 flex flex-col relative overflow-hidden">
                    <!-- Top Gradient Line -->
                    <div class="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-blue-600 via-cyan-500 to-orange-500"></div>

                    <!-- Close Button -->
                    <a href="${pageContext.request.contextPath}/${isAdminFlow ? 'admin/nhan-su' : 'manager/nhan-su'}" class="absolute top-5 right-5 text-slate-400 hover:text-slate-700 transition-colors z-[130] w-9 h-9 rounded-full flex items-center justify-center bg-slate-100 hover:bg-slate-200">
                        <span class="material-symbols-outlined text-[20px]">close</span>
                    </a>

                    <!-- Header -->
                    <div class="mb-6 pt-2">
                        <div class="inline-flex items-center gap-2 bg-blue-50 border border-blue-200 text-blue-700 rounded-full py-1 px-3.5 text-[11px] font-extrabold w-fit shadow-xs mb-3.5">
                            <span class="material-symbols-outlined text-[14px]">verified</span>
                            <span class="tracking-wider uppercase">Xác minh bảo mật</span>
                        </div>
                        <h2 class="text-2xl font-extrabold tracking-tight text-slate-900 mb-1.5">Nhập mã xác thực OTP</h2>
                        <p class="text-[13px] text-slate-500 font-medium leading-relaxed">
                            Mã xác nhận 6 chữ số vừa được gửi tới email <b class="text-slate-900 font-semibold">${email}</b>.
                        </p>
                    </div>

                    <!-- Error Banner -->
                    <c:if test="${not empty loi}">
                        <div id="error-banner" class="mb-5 p-4 bg-rose-50 text-rose-700 border border-rose-200 rounded-2xl text-xs font-semibold flex items-center gap-3 shadow-xs">
                            <span class="material-symbols-outlined text-[20px] text-rose-500 shrink-0">error</span>
                            <span>${loi}</span>
                        </div>
                    </c:if>

                    <!-- Success Banner -->
                    <c:if test="${not empty thongbao}">
                        <div id="success-banner" class="mb-5 p-4 bg-emerald-50 text-emerald-700 border border-emerald-200 rounded-2xl text-xs font-semibold flex items-center gap-3 shadow-xs">
                            <span class="material-symbols-outlined text-[20px] text-emerald-500 shrink-0">check_circle</span>
                            <span>${thongbao}</span>
                        </div>
                    </c:if>

                    <!-- Form -->
                    <form id="otp-form-dashboard" action="${pageContext.request.contextPath}/nhapma" method="POST" class="flex flex-col" autocomplete="off">
                        <input type="hidden" name="email" value="${email}">
                        <div class="mb-6">
                            <label class="text-[12px] font-bold text-slate-700 mb-2 block uppercase tracking-wider">Mã OTP 6 chữ số</label>
                            <div class="relative">
                                <input type="text" name="otp" required maxlength="6" placeholder="••••••" 
                                       class="w-full h-16 border-2 border-slate-200 rounded-2xl otp-font otp-input-field text-slate-900 bg-slate-50/50 focus:bg-white focus:border-blue-600 focus:ring-4 focus:ring-blue-100 transition-all outline-none">
                            </div>
                        </div>
                        <button type="submit" id="submit-btn-dashboard" class="w-full h-13 bg-gradient-to-r from-blue-600 via-blue-700 to-indigo-700 hover:from-blue-700 hover:to-indigo-800 text-white rounded-2xl font-bold text-[15px] flex items-center justify-center gap-2 transition-all relative overflow-hidden shadow-lg shadow-blue-500/25 active:scale-[0.99]">
                            <span class="btn-text flex items-center gap-2">
                                Xác minh ngay
                                <span class="material-symbols-outlined text-[20px]">arrow_forward</span>
                            </span>
                            <div class="loading-spinner hidden absolute inset-0 bg-blue-700 flex items-center justify-center">
                                <div class="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                            </div>
                        </button>
                    </form>

                    <!-- Footer -->
                    <div class="mt-6 text-center border-t border-slate-100 pt-4">
                        <p class="text-[13px] text-slate-500 font-medium">
                            Chưa nhận được mã? 
                            <a href="${pageContext.request.contextPath}/resend-otp" class="font-bold text-blue-600 hover:text-blue-700 hover:underline ml-1">
                                Gửi lại mã ngay
                            </a>
                        </p>
                    </div>
                </div>
            </main>
        </c:when>
        
        <c:otherwise>
            <%-- ══ GUEST OTP — V-SPORT Brand ══ --%>
            <style>
                :root { --vs-green: #01e281; --vs-green-dark: #00b865; --vs-green-glow: rgba(1,226,129,.18); }

                .vs-bg {
                    background: radial-gradient(ellipse 80% 60% at 20% 10%, rgba(1,226,129,.12) 0%, transparent 55%),
                                radial-gradient(ellipse 60% 50% at 80% 80%, rgba(1,170,100,.08) 0%, transparent 55%),
                                linear-gradient(160deg, #071510 0%, #0a1f15 40%, #060e0a 100%);
                }
                .vs-card {
                    background: #fff;
                    border-radius: 28px;
                    box-shadow: 0 32px 80px rgba(0,0,0,.45), 0 0 0 1px rgba(1,226,129,.12);
                }
                .vs-accent-bar {
                    background: linear-gradient(90deg, var(--vs-green) 0%, #00d4a0 50%, #00c8f0 100%);
                }

                /* OTP digit boxes */
                .otp-box {
                    width: 56px; height: 68px;
                    border: 2px solid #e2e8f0;
                    border-radius: 16px;
                    font-family: 'JetBrains Mono', monospace;
                    font-size: 1.6rem; font-weight: 800;
                    color: #0f172a;
                    text-align: center;
                    background: #f8fafc;
                    outline: none;
                    transition: border-color .15s, box-shadow .15s, background .15s, transform .1s;
                    caret-color: transparent;
                }
                .otp-box:focus {
                    border-color: var(--vs-green);
                    box-shadow: 0 0 0 4px var(--vs-green-glow);
                    background: #fff;
                    transform: scale(1.05);
                }
                .otp-box.filled {
                    border-color: var(--vs-green);
                    background: #f0fff8;
                    color: #065f46;
                }
                .otp-box.shake {
                    animation: otp-shake .4s ease;
                    border-color: #dc2626 !important;
                    box-shadow: 0 0 0 4px rgba(220,38,38,.15) !important;
                }
                @keyframes otp-shake {
                    0%,100%{transform:translateX(0)} 20%{transform:translateX(-5px)} 40%{transform:translateX(5px)} 60%{transform:translateX(-3px)} 80%{transform:translateX(3px)}
                }

                /* Submit button */
                .vs-btn {
                    background: linear-gradient(135deg, #01e281 0%, #00c875 100%);
                    color: #042d1a;
                    border: none;
                    border-radius: 16px;
                    font-size: 15px; font-weight: 800;
                    height: 56px; width: 100%;
                    display: flex; align-items: center; justify-content: center; gap: 8px;
                    cursor: pointer;
                    box-shadow: 0 4px 20px rgba(1,226,129,.35);
                    transition: transform .15s, box-shadow .15s, opacity .15s;
                    position: relative; overflow: hidden;
                }
                .vs-btn:hover  { transform: translateY(-2px); box-shadow: 0 8px 28px rgba(1,226,129,.45); }
                .vs-btn:active { transform: scale(.98); }
                .vs-btn:disabled { opacity: .6; cursor: not-allowed; transform: none; }

                /* Logo mark */
                .vs-logo {
                    width: 52px; height: 52px; border-radius: 14px;
                    background: linear-gradient(135deg, #042d1a 0%, #0a4a2b 100%);
                    display: flex; align-items: center; justify-content: center;
                    box-shadow: 0 4px 16px rgba(1,226,129,.25);
                }

                /* Progress dots */
                .step-dot { width: 8px; height: 8px; border-radius: 50%; background: #e2e8f0; }
                .step-dot.done { background: var(--vs-green); }
                .step-dot.active { background: var(--vs-green); box-shadow: 0 0 0 3px var(--vs-green-glow); width: 24px; border-radius: 4px; }
            </style>

            <%-- Ambient background --%>
            <div class="vs-bg fixed inset-0 z-0"></div>

            <%-- Card --%>
            <div class="vs-card w-full max-w-[460px] relative z-10 overflow-hidden flex flex-col">

                <%-- Accent bar --%>
                <div class="vs-accent-bar h-1.5 w-full shrink-0"></div>

                <div class="px-8 pt-7 pb-8 flex flex-col">

                    <%-- Brand header --%>
                    <div class="flex items-center justify-between mb-6">
                        <div class="flex items-center gap-3">
                            <div class="vs-logo">
                                <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
                                    <path d="M14 3L24 8.5V19.5L14 25L4 19.5V8.5L14 3Z" fill="#01e281" opacity=".9"/>
                                    <path d="M14 7L20.5 10.5V17.5L14 21L7.5 17.5V10.5L14 7Z" fill="#042d1a"/>
                                    <path d="M11 12.5L13.5 18L17 10.5" stroke="#01e281" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                                </svg>
                            </div>
                            <div>
                                <p class="text-[10px] font-black text-slate-400 tracking-[.12em] uppercase">V-SPORT</p>
                                <p class="text-sm font-black text-slate-800 tracking-tight leading-tight">Xác minh tài khoản</p>
                            </div>
                        </div>

                        <%-- Step progress --%>
                        <div class="flex items-center gap-1.5">
                            <div class="step-dot done"></div>
                            <div class="step-dot active"></div>
                            <div class="step-dot"></div>
                        </div>
                    </div>

                    <%-- Title block --%>
                    <div class="mb-6">
                        <div class="inline-flex items-center gap-1.5 bg-emerald-50 border border-emerald-200 text-emerald-700 rounded-full py-1 px-3 text-[10.5px] font-extrabold tracking-wider uppercase mb-3">
                            <span class="material-symbols-outlined text-[13px]" style="font-variation-settings:'FILL' 1">shield_lock</span>
                            Bảo mật OTP
                        </div>
                        <h2 class="text-[1.6rem] font-black text-slate-900 tracking-tight leading-tight mb-2">Nhập mã xác thực</h2>
                        <p class="text-[13px] text-slate-500 font-medium leading-relaxed">
                            Chúng tôi đã gửi mã gồm <strong class="text-slate-700">6 chữ số</strong> tới email
                        </p>
                        <p class="text-[13px] font-black text-emerald-600 mt-0.5 truncate">${email}</p>
                    </div>

                    <%-- Error / Success banners --%>
                    <c:if test="${not empty loi}">
                        <div class="mb-5 p-3.5 bg-rose-50 text-rose-700 border border-rose-200 rounded-2xl text-xs font-semibold flex items-center gap-3">
                            <span class="material-symbols-outlined text-[18px] text-rose-500 shrink-0" style="font-variation-settings:'FILL' 1">error</span>
                            <span>${loi}</span>
                        </div>
                    </c:if>
                    <c:if test="${not empty thongbao}">
                        <div class="mb-5 p-3.5 bg-emerald-50 text-emerald-700 border border-emerald-200 rounded-2xl text-xs font-semibold flex items-center gap-3">
                            <span class="material-symbols-outlined text-[18px] text-emerald-500 shrink-0" style="font-variation-settings:'FILL' 1">check_circle</span>
                            <span>${thongbao}</span>
                        </div>
                    </c:if>

                    <%-- OTP Form --%>
                    <form id="otp-form" action="${pageContext.request.contextPath}/nhapma" method="POST" autocomplete="off">
                        <input type="hidden" name="email" value="${email}">
                        <input type="hidden" name="otp" id="otp-hidden">

                        <label class="text-[11px] font-black text-slate-500 uppercase tracking-[.1em] mb-3 block">Mã xác thực</label>

                        <%-- 6 digit boxes --%>
                        <div class="flex gap-2.5 justify-between mb-6" id="otp-boxes">
                            <input class="otp-box" type="text" inputmode="numeric" maxlength="1" pattern="[0-9]" autocomplete="one-time-code" data-index="0">
                            <input class="otp-box" type="text" inputmode="numeric" maxlength="1" pattern="[0-9]" data-index="1">
                            <input class="otp-box" type="text" inputmode="numeric" maxlength="1" pattern="[0-9]" data-index="2">
                            <input class="otp-box" type="text" inputmode="numeric" maxlength="1" pattern="[0-9]" data-index="3">
                            <input class="otp-box" type="text" inputmode="numeric" maxlength="1" pattern="[0-9]" data-index="4">
                            <input class="otp-box" type="text" inputmode="numeric" maxlength="1" pattern="[0-9]" data-index="5">
                        </div>

                        <%-- Expiry hint --%>
                        <p class="text-[11px] text-slate-400 font-semibold text-center mb-5">
                            <span class="material-symbols-outlined text-[13px] align-middle">timer</span>
                            Mã có hiệu lực trong <span id="otp-timer" class="text-emerald-600 font-black">5:00</span>
                        </p>

                        <button type="submit" id="submit-btn" class="vs-btn" disabled>
                            <span class="btn-text flex items-center gap-2">
                                Xác minh ngay
                                <span class="material-symbols-outlined text-[20px]">arrow_forward</span>
                            </span>
                            <div class="loading-spinner hidden absolute inset-0 flex items-center justify-center" style="background:linear-gradient(135deg,#01e281,#00c875)">
                                <div class="w-5 h-5 border-2 border-emerald-900/30 border-t-emerald-900 rounded-full animate-spin"></div>
                            </div>
                        </button>
                    </form>

                    <%-- Resend --%>
                    <div class="mt-5 pt-5 border-t border-slate-100 text-center">
                        <p class="text-[13px] text-slate-500 font-medium">
                            Không nhận được mã?
                            <a id="resend-link" href="${pageContext.request.contextPath}/resend-otp"
                               class="font-black ml-1 text-emerald-600 hover:text-emerald-700 hover:underline pointer-events-none opacity-40 transition-opacity" id="resend-link">
                                Gửi lại ngay
                            </a>
                        </p>
                        <p id="resend-timer" class="text-[11px] text-slate-400 font-semibold mt-1">Có thể gửi lại sau <span id="resend-countdown">60</span>s</p>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>

    <script>
        /* ── Dashboard form loading spinner ── */
        const setupForm = (formId, btnId) => {
            const form = document.getElementById(formId);
            const btn  = document.getElementById(btnId);
            if (form && btn) {
                form.addEventListener('submit', () => {
                    const spinner = btn.querySelector('.loading-spinner');
                    const btnText = btn.querySelector('.btn-text');
                    if (spinner && btnText) {
                        spinner.classList.remove('hidden');
                        btnText.style.opacity = '0';
                        btn.style.pointerEvents = 'none';
                    }
                });
            }
        };
        setupForm('otp-form-dashboard', 'submit-btn-dashboard');

        /* ── Guest OTP boxes logic ── */
        (function () {
            const boxes    = Array.from(document.querySelectorAll('.otp-box'));
            const hidden   = document.getElementById('otp-hidden');
            const submitBtn = document.getElementById('submit-btn');
            const form     = document.getElementById('otp-form');
            if (!boxes.length || !form) return;

            function getValue() { return boxes.map(b => b.value).join(''); }

            function updateState() {
                const val = getValue();
                if (hidden) hidden.value = val;
                if (submitBtn) submitBtn.disabled = val.length < 6;
                boxes.forEach((b, i) => {
                    b.classList.toggle('filled', b.value.length === 1);
                });
            }

            boxes.forEach((box, i) => {
                box.addEventListener('keydown', e => {
                    if (e.key === 'Backspace') {
                        if (!box.value && i > 0) { boxes[i-1].focus(); boxes[i-1].value = ''; }
                        else box.value = '';
                        updateState();
                        e.preventDefault();
                    } else if (e.key === 'ArrowLeft' && i > 0) { boxes[i-1].focus(); e.preventDefault(); }
                    else if (e.key === 'ArrowRight' && i < 5) { boxes[i+1].focus(); e.preventDefault(); }
                });

                box.addEventListener('input', e => {
                    const raw = box.value.replace(/\D/g, '').slice(-1);
                    box.value = raw;
                    updateState();
                    if (raw && i < 5) boxes[i+1].focus();
                    if (getValue().length === 6) submitBtn && submitBtn.focus();
                });

                box.addEventListener('paste', e => {
                    e.preventDefault();
                    const text = (e.clipboardData || window.clipboardData).getData('text').replace(/\D/g,'');
                    text.split('').slice(0, 6).forEach((ch, idx) => {
                        if (boxes[idx]) boxes[idx].value = ch;
                    });
                    updateState();
                    const nextEmpty = boxes.findIndex(b => !b.value);
                    (boxes[nextEmpty] || boxes[5]).focus();
                });

                box.addEventListener('focus', () => { box.select(); });
            });

            /* Submit loading */
            form.addEventListener('submit', e => {
                if (getValue().length < 6) { e.preventDefault(); shakeBoxes(); return; }
                if (submitBtn) {
                    submitBtn.querySelector('.loading-spinner').classList.remove('hidden');
                    submitBtn.querySelector('.btn-text').style.opacity = '0';
                    submitBtn.disabled = true;
                }
            });

            function shakeBoxes() {
                boxes.forEach(b => { b.classList.add('shake'); setTimeout(() => b.classList.remove('shake'), 500); });
            }

            /* Auto-focus first box */
            if (boxes[0]) boxes[0].focus();

            /* ── OTP expiry countdown (5 min) ── */
            const timerEl = document.getElementById('otp-timer');
            if (timerEl) {
                let secs = 5 * 60;
                const tick = setInterval(() => {
                    secs--;
                    if (secs <= 0) { clearInterval(tick); timerEl.textContent = 'Hết hạn'; timerEl.style.color = '#dc2626'; return; }
                    timerEl.textContent = Math.floor(secs/60) + ':' + String(secs%60).padStart(2,'0');
                    if (secs <= 30) timerEl.style.color = '#dc2626';
                }, 1000);
            }

            /* ── Resend cooldown (60s) ── */
            const resendLink      = document.getElementById('resend-link');
            const resendTimerEl   = document.getElementById('resend-timer');
            const resendCountdown = document.getElementById('resend-countdown');
            if (resendLink && resendCountdown) {
                let cd = 60;
                const cdTick = setInterval(() => {
                    cd--;
                    if (resendCountdown) resendCountdown.textContent = cd;
                    if (cd <= 0) {
                        clearInterval(cdTick);
                        resendLink.classList.remove('pointer-events-none','opacity-40');
                        if (resendTimerEl) resendTimerEl.style.display = 'none';
                    }
                }, 1000);
            }
        })();
    </script>
</body>
</html>