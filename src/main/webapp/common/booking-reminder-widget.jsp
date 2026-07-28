<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%--
    Ultra-Premium Mascot Assistant & Notification Center (V-SPORT Light Theme)
    - Mascot FAB: Emerald Gradient (#10b981 -> #059669) + Glowing Ring Pulse + Cute Mascot Avatar.
    - Notification Card: Light Theme Glassmorphism, Emerald Gradient Header, Pastel Status Badges, Gradient Buttons.
--%>
<style>
    .vs-mascot-widget {
        position: fixed;
        top: 50%;
        right: 28px;
        transform: translateY(-50%);
        z-index: 9999;
        font-family: 'Outfit', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
    }

    /* Ultra-Premium Mascot FAB Button */
    .vs-mascot-fab {
        width: 68px;
        height: 68px;
        border-radius: 50%;
        background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        color: #ffffff;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        box-shadow: 0 10px 30px rgba(16, 185, 129, 0.5), inset 0 2px 4px rgba(255, 255, 255, 0.3);
        position: relative;
        animation: vsMascotPulseBounce 2.5s cubic-bezier(0.28, 0.84, 0.42, 1) infinite;
        transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
        border: 3.5px solid #ffffff;
    }

    .vs-mascot-fab:hover {
        transform: scale(1.14) rotate(8deg);
        box-shadow: 0 14px 38px rgba(16, 185, 129, 0.65), inset 0 2px 6px rgba(255, 255, 255, 0.4);
    }

    /* Outer Glowing Ring Pulse */
    @keyframes vsMascotPulseBounce {
        0% {
            box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.5), 0 10px 28px rgba(16, 185, 129, 0.4);
            transform: translateY(0);
        }
        50% {
            box-shadow: 0 0 0 14px rgba(16, 185, 129, 0), 0 14px 34px rgba(16, 185, 129, 0.55);
            transform: translateY(-8px);
        }
        100% {
            box-shadow: 0 0 0 0 rgba(16, 185, 129, 0), 0 10px 28px rgba(16, 185, 129, 0.4);
            transform: translateY(0);
        }
    }

    .vs-mascot-badge {
        position: absolute;
        top: -3px;
        right: -3px;
        background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
        color: #ffffff;
        font-size: 12px;
        font-weight: 800;
        min-width: 24px;
        height: 24px;
        border-radius: 12px;
        padding: 0 6px;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 2.5px solid #ffffff;
        box-shadow: 0 4px 12px rgba(239, 68, 68, 0.5);
    }

    .vs-mascot-avatar {
        width: 38px;
        height: 38px;
        fill: #ffffff;
        filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
    }

    /* Notification Center Card Container */
    .vs-reminder-dropdown {
        position: absolute;
        top: 50%;
        right: 86px;
        transform: translateY(-50%) scale(0.92);
        width: 420px;
        max-width: calc(100vw - 110px);
        background: #ffffff;
        border: 1px solid rgba(226, 232, 240, 0.9);
        border-radius: 24px;
        box-shadow: 0 24px 60px -12px rgba(15, 23, 42, 0.22), 0 0 1px 1px rgba(15, 23, 42, 0.05);
        overflow: hidden;
        display: none;
        flex-direction: column;
        transform-origin: right center;
        animation: vsDropdownPopLeft 0.28s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;
    }

    .vs-reminder-dropdown.is-open {
        display: flex;
    }

    /* Header - Gradient Emerald & Clean Typography */
    .vs-dropdown-head {
        background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        color: #ffffff;
        padding: 18px 22px;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    .vs-dropdown-head-title {
        font-size: 16px;
        font-weight: 800;
        display: flex;
        align-items: center;
        gap: 10px;
        letter-spacing: -0.01em;
    }

    .vs-dropdown-head-count {
        background: rgba(255, 255, 255, 0.22);
        backdrop-filter: blur(4px);
        color: #ffffff;
        font-size: 12px;
        font-weight: 800;
        padding: 4px 12px;
        border-radius: 999px;
        border: 1px solid rgba(255, 255, 255, 0.3);
    }

    .vs-dropdown-close {
        background: rgba(255, 255, 255, 0.15);
        border: none;
        color: #ffffff;
        width: 30px;
        height: 30px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
        cursor: pointer;
        transition: all 0.2s ease;
    }

    .vs-dropdown-close:hover {
        background: rgba(255, 255, 255, 0.3);
        transform: scale(1.08);
    }

    /* Notification Items Body */
    .vs-dropdown-list {
        max-height: 460px;
        overflow-y: auto;
        padding: 16px;
        display: flex;
        flex-direction: column;
        gap: 14px;
        background: #f8fafc;
    }

    .vs-dropdown-item {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 18px;
        padding: 18px;
        transition: all 0.25s ease;
        box-shadow: 0 4px 12px rgba(15, 23, 42, 0.03);
    }

    .vs-dropdown-item:hover {
        border-color: #cbd5e1;
        box-shadow: 0 10px 24px rgba(15, 23, 42, 0.08);
        transform: translateY(-2px);
    }

    .vs-dropdown-item.type-payment {
        border-left: 5px solid #f59e0b;
    }

    .vs-dropdown-item.type-upcoming {
        border-left: 5px solid #0284c7;
    }

    .vs-item-tag-row {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 10px;
    }

    .vs-item-pill {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        font-size: 11px;
        font-weight: 800;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        padding: 4px 10px;
        border-radius: 999px;
    }

    .type-payment .vs-item-pill {
        background: #fffbeb;
        color: #d97706;
        border: 1px solid #fde68a;
    }

    .type-upcoming .vs-item-pill {
        background: #f0f9ff;
        color: #0284c7;
        border: 1px solid #bae6fd;
    }

    .vs-item-code {
        font-size: 12px;
        font-weight: 800;
        color: #64748b;
        background: #f1f5f9;
        padding: 3px 9px;
        border-radius: 8px;
    }

    .vs-item-desc {
        font-size: 15.5px;
        font-weight: 800;
        color: #0f172a;
        line-height: 1.4;
        font-family: 'Outfit', sans-serif;
    }

    .vs-item-sub {
        font-size: 13.5px;
        color: #64748b;
        margin-top: 6px;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .vs-item-footer {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-top: 14px;
        padding-top: 12px;
        border-top: 1px dashed #e2e8f0;
    }

    .vs-item-timer {
        font-size: 13px;
        color: #475569;
        font-weight: 600;
    }

    .vs-item-timer b {
        font-size: 15px;
        font-weight: 800;
        font-variant-numeric: tabular-nums;
    }

    .type-payment .vs-item-timer b { color: #d97706; }
    .type-upcoming .vs-item-timer b { color: #0284c7; }

    .vs-item-btn {
        padding: 9px 18px;
        border-radius: 12px;
        font-size: 13px;
        font-weight: 800;
        text-decoration: none;
        transition: all 0.2s ease;
        display: inline-flex;
        align-items: center;
        gap: 7px;
    }

    .type-payment .vs-item-btn {
        background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        color: #ffffff;
        box-shadow: 0 4px 14px rgba(16, 185, 129, 0.35);
    }
    .type-payment .vs-item-btn:hover {
        box-shadow: 0 6px 18px rgba(16, 185, 129, 0.5);
        transform: translateY(-1px);
    }

    .type-upcoming .vs-item-btn {
        background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%);
        color: #ffffff;
        box-shadow: 0 4px 14px rgba(2, 132, 199, 0.35);
    }
    .type-upcoming .vs-item-btn:hover {
        box-shadow: 0 6px 18px rgba(2, 132, 199, 0.5);
        transform: translateY(-1px);
    }

    @keyframes vsDropdownPopLeft {
        from {
            opacity: 0;
            transform: translateY(-50%) scale(0.88) translateX(16px);
        }
        to {
            opacity: 1;
            transform: translateY(-50%) scale(1) translateX(0);
        }
    }

    @media (max-width: 640px) {
        .vs-mascot-widget {
            top: auto;
            bottom: 84px;
            transform: none;
            right: 16px;
        }
        .vs-mascot-fab {
            width: 58px;
            height: 58px;
            animation: none;
        }
        .vs-reminder-dropdown {
            top: auto;
            bottom: 72px;
            right: 0;
            transform: none;
            width: calc(100vw - 32px);
            transform-origin: bottom right;
            animation: vsDropdownPopLeft 0.2s ease forwards;
        }
    }
</style>

<div class="vs-mascot-widget" id="vsMascotWidget" style="display: none;">
    <!-- Ultra-Premium Cute Floating Mascot Button (68px) -->
    <div class="vs-mascot-fab" id="vsMascotFab" title="Nhấn để xem thông báo đặt sân quan trọng">
        <svg class="vs-mascot-avatar" viewBox="0 0 24 24" aria-hidden="true">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 3c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3zm0 14.2c-2.5 0-4.71-1.28-6-3.22.03-1.99 4-3.08 6-3.08 1.99 0 5.97 1.09 6 3.08-1.29 1.94-3.5 3.22-6 3.22z"/>
        </svg>
        <span class="vs-mascot-badge" id="vsMascotBadge">0</span>
    </div>

    <!-- Dropdown List of All Reminders -->
    <div class="vs-reminder-dropdown" id="vsReminderDropdown">
        <div class="vs-dropdown-head">
            <div class="vs-dropdown-head-title">
                <i class="fa-solid fa-bell"></i> Thông báo quan trọng
            </div>
            <div style="display:flex;align-items:center;gap:10px;">
                <span class="vs-dropdown-head-count" id="vsDropdownCount">0</span>
                <button type="button" class="vs-dropdown-close" id="vsDropdownCloseBtn" title="Đóng">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>
        </div>

        <div class="vs-dropdown-list" id="vsDropdownList">
            <!-- Rendered dynamically by JS -->
        </div>
    </div>
</div>

<script>
(function () {
    const CTX = '${pageContext.request.contextPath}';
    let activeData = null;
    let timerInterval = null;

    const widget = document.getElementById('vsMascotWidget');
    const fab = document.getElementById('vsMascotFab');
    const badge = document.getElementById('vsMascotBadge');
    const dropdown = document.getElementById('vsReminderDropdown');
    const dropdownList = document.getElementById('vsDropdownList');
    const dropdownCount = document.getElementById('vsDropdownCount');
    const closeBtn = document.getElementById('vsDropdownCloseBtn');

    function pad(n) { return (n < 10 ? '0' : '') + n; }

    function fetchReminders() {
        fetch(CTX + '/api/customer/active-reminders', { headers: { 'Cache-Control': 'no-cache' } })
            .then(res => res.json())
            .then(data => {
                if (!data || !data.loggedIn || data.totalCount === 0) {
                    widget.style.display = 'none';
                    dropdown.classList.remove('is-open');
                    return;
                }
                activeData = data;
                renderWidget();
            })
            .catch(() => { widget.style.display = 'none'; });
    }

    function renderWidget() {
        if (!activeData || activeData.totalCount === 0) {
            widget.style.display = 'none';
            return;
        }

        widget.style.display = 'block';
        badge.textContent = activeData.totalCount;
        dropdownCount.textContent = activeData.totalCount + ' đơn';

        let html = '';

        // Render tất cả các đơn Chờ thanh toán
        if (activeData.pendingPayments && activeData.pendingPayments.length > 0) {
            activeData.pendingPayments.forEach(p => {
                html += `
                    <div class="vs-dropdown-item type-payment">
                        <div class="vs-item-tag-row">
                            <span class="vs-item-pill"><i class="fa-solid fa-circle-exclamation"></i> Chưa thanh toán</span>
                            <span class="vs-item-code">#` + p.datSanId + `</span>
                        </div>
                        <div class="vs-item-desc">` + escapeHtml(p.tenCoSo) + ` · ` + escapeHtml(p.tenSan) + `</div>
                        <div class="vs-item-sub"><i class="fa-regular fa-calendar" style="color:#f59e0b;"></i> ` + p.ngayDat + ` (` + p.gioBatDau + ` - ` + p.gioKetThuc + `)</div>
                        <div class="vs-item-footer">
                            <div class="vs-item-timer">Trạng thái: <b class="vs-timer-val" data-target="` + p.expiresAtEpochMs + `" data-type="payment">Đang chờ thanh toán</b></div>
                            <a href="` + CTX + `/customer/thanh-toan-qr?datSanId=` + p.datSanId + `" class="vs-item-btn">
                                <span>Thanh toán</span> <i class="fa-solid fa-arrow-right"></i>
                            </a>
                        </div>
                    </div>
                `;
            });
        }

        // Render tất cả các đơn Sắp tới giờ chơi
        if (activeData.upcomingBookings && activeData.upcomingBookings.length > 0) {
            activeData.upcomingBookings.forEach(u => {
                html += `
                    <div class="vs-dropdown-item type-upcoming">
                        <div class="vs-item-tag-row">
                            <span class="vs-item-pill"><i class="fa-solid fa-person-running"></i> Sắp tới giờ đến sân</span>
                            <span class="vs-item-code">#` + u.datSanId + `</span>
                        </div>
                        <div class="vs-item-desc">` + escapeHtml(u.tenCoSo) + ` · ` + escapeHtml(u.tenSan) + `</div>
                        <div class="vs-item-sub"><i class="fa-regular fa-calendar" style="color:#0284c7;"></i> ` + u.ngayDat + ` (` + u.gioBatDau + ` - ` + u.gioKetThuc + `)</div>
                        <div class="vs-item-footer">
                            <div class="vs-item-timer">Bắt đầu sau: <b class="vs-timer-val" data-target="` + u.startEpochMs + `" data-type="upcoming">--:--</b></div>
                            <a href="` + CTX + `/customer/lich-su-dat-san?highlightDatSanId=` + u.datSanId + `" class="vs-item-btn">
                                <span>Xem lịch</span> <i class="fa-solid fa-arrow-right"></i>
                            </a>
                        </div>
                    </div>
                `;
            });
        }

        dropdownList.innerHTML = html;
        startCountdownTimers();
    }

    function startCountdownTimers() {
        clearInterval(timerInterval);

        function updateAll() {
            const timerEls = dropdownList.querySelectorAll('.vs-timer-val');
            if (timerEls.length === 0) return;

            const now = Date.now();
            timerEls.forEach(el => {
                const target = parseInt(el.getAttribute('data-target') || '0', 10);
                const type = el.getAttribute('data-type');

                if (type === 'payment') {
                    if (target > 0) {
                        const diff = target - now;
                        if (diff > 0) {
                            const totalSec = Math.floor(diff / 1000);
                            const mins = Math.floor(totalSec / 60);
                            const secs = totalSec % 60;
                            el.textContent = 'Còn ' + pad(mins) + ':' + pad(secs);
                            return;
                        }
                    }
                    el.textContent = 'Đang chờ thanh toán';
                    return;
                }

                if (type === 'upcoming') {
                    const diff = target - now;
                    if (diff <= 0) {
                        el.textContent = 'Đang trong giờ chơi!';
                        return;
                    }
                    const totalSec = Math.floor(diff / 1000);
                    const hours = Math.floor(totalSec / 3600);
                    const mins = Math.floor((totalSec % 3600) / 60);
                    const secs = totalSec % 60;
                    if (hours > 0) {
                        el.textContent = hours + 'h ' + pad(mins) + 'm';
                    } else {
                        el.textContent = pad(mins) + ':' + pad(secs);
                    }
                }
            });
        }

        updateAll();
        timerInterval = setInterval(updateAll, 1000);
    }

    function escapeHtml(str) {
        if (!str) return '';
        return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
    }

    // CLICK-ONLY Mode
    fab.addEventListener('click', function (e) {
        e.stopPropagation();
        dropdown.classList.toggle('is-open');
    });

    closeBtn.addEventListener('click', function (e) {
        e.stopPropagation();
        dropdown.classList.remove('is-open');
    });

    // Close when clicking outside
    document.addEventListener('click', function (e) {
        if (!widget.contains(e.target)) {
            dropdown.classList.remove('is-open');
        }
    });

    // Run check on page load & refresh every 30s
    fetchReminders();
    setInterval(fetchReminders, 30000);
})();
</script>
