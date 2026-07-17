<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
  Component: Thẻ điểm uy tín khách hàng.
  Yêu cầu biến scope "request" đã có sẵn: account (org.example.model.TaiKhoan).
  Ngôn ngữ hiển thị luôn nhẹ nhàng, không dùng từ nặng nề (không có "rủi ro cao"/"khách xấu").
--%>
<c:set var="repScore" value="${account.diemUyTin}" />
<c:choose>
    <c:when test="${repScore >= 80}">
        <c:set var="repLabel" value="Uy tín tốt" />
        <c:set var="repColorBg" value="#EDF3EC" />
        <c:set var="repColorText" value="#346538" />
        <c:set var="repBarColor" value="#10b981" />
    </c:when>
    <c:when test="${repScore >= 50}">
        <c:set var="repLabel" value="Cần theo dõi" />
        <c:set var="repColorBg" value="#FBF3DB" />
        <c:set var="repColorText" value="#956400" />
        <c:set var="repBarColor" value="#d99a1b" />
    </c:when>
    <c:otherwise>
        <c:set var="repLabel" value="Cần cải thiện" />
        <c:set var="repColorBg" value="#FDEBEC" />
        <c:set var="repColorText" value="#9F2F2D" />
        <c:set var="repBarColor" value="#e15a5a" />
    </c:otherwise>
</c:choose>

<div class="acc-card p-6 scroll-mt-24" id="uyTinCuaToi">
    <div class="flex items-start justify-between gap-4 mb-5 flex-wrap">
        <h3 class="text-sm font-extrabold text-slate-900 flex items-center gap-2">
            <span class="material-symbols-outlined text-emerald-600 text-[18px]">verified</span>
            Điểm uy tín của bạn
        </h3>
        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-bold"
              style="background-color: ${repColorBg}; color: ${repColorText};">
            <span class="w-1.5 h-1.5 rounded-full inline-block" style="background-color: ${repBarColor};"></span>
            ${repLabel}
        </span>
    </div>

    <div class="flex items-end gap-3 mb-2">
        <span class="text-4xl font-black text-slate-900 leading-none">${repScore}</span>
        <span class="text-sm font-bold text-slate-400 mb-1">/ 100</span>
    </div>
    <div class="w-full h-2 rounded-full bg-slate-100 overflow-hidden mb-6">
        <div class="h-full rounded-full" style="width: ${repScore}%; background-color: ${repBarColor};"></div>
    </div>

    <div class="grid grid-cols-3 gap-3 mb-6">
        <div class="text-center bg-slate-50 rounded-xl p-3 border border-slate-100">
            <span class="text-lg font-black text-slate-800 block">${account.completedBookingCount}</span>
            <span class="text-[10px] text-slate-500 font-bold uppercase tracking-wide">Đã hoàn thành</span>
        </div>
        <div class="text-center bg-slate-50 rounded-xl p-3 border border-slate-100">
            <span class="text-lg font-black text-slate-800 block">${account.lateCancelCount}</span>
            <span class="text-[10px] text-slate-500 font-bold uppercase tracking-wide">Hủy sát giờ</span>
        </div>
        <div class="text-center bg-slate-50 rounded-xl p-3 border border-slate-100">
            <span class="text-lg font-black text-slate-800 block">${account.noShowCount}</span>
            <span class="text-[10px] text-slate-500 font-bold uppercase tracking-wide">Không đến</span>
        </div>
    </div>

    <div class="bg-slate-50 border border-slate-100 rounded-xl p-4 space-y-2">
        <p class="text-[11px] font-extrabold text-slate-500 uppercase tracking-wide mb-1">Điểm uy tín được tính thế nào?</p>
        <p class="text-xs text-slate-600 flex items-start gap-2"><span class="material-symbols-outlined text-emerald-600 text-[15px] mt-0.5">check_circle</span> Hủy sớm (trước 6 tiếng) không bị trừ điểm.</p>
        <p class="text-xs text-slate-600 flex items-start gap-2"><span class="material-symbols-outlined text-amber-500 text-[15px] mt-0.5">warning</span> Hủy sát giờ có thể ảnh hưởng điểm uy tín.</p>
        <p class="text-xs text-slate-600 flex items-start gap-2"><span class="material-symbols-outlined text-rose-500 text-[15px] mt-0.5">error</span> Không đến sân bị trừ điểm nhiều hơn hủy sát giờ.</p>
        <p class="text-xs text-slate-600 flex items-start gap-2"><span class="material-symbols-outlined text-emerald-600 text-[15px] mt-0.5">add_circle</span> Hoàn thành trận đấu sẽ được cộng điểm.</p>
    </div>
</div>
