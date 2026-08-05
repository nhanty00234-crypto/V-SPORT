<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>${pageTitle}</title>
<jsp:include page="/manager/common/manager_head.jsp" />
</head>
<body class="text-zinc-900 min-h-screen">

<jsp:include page="/manager/common/sidebar.jsp" />

<c:set var="headerTitle" value="Đánh giá & Phản hồi" scope="page" />
<c:set var="headerSubtitle" value="Theo dõi chất lượng dịch vụ từ người chơi tại chi nhánh" scope="page" />
<c:set var="headerIcon" value="reviews" scope="page" />
<jsp:include page="/manager/common/header.jsp" />

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- Summary Stats -->
  <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
    <div class="bg-white rounded-2xl border border-zinc-200/70 shadow-sm p-5 flex items-center gap-4">
      <div class="w-11 h-11 rounded-xl bg-amber-50 flex items-center justify-center flex-shrink-0">
        <span class="material-symbols-outlined text-amber-500 text-[22px]">star</span>
      </div>
      <div>
        <div class="text-2xl font-black text-zinc-900">
          ${avgRating}
          <c:if test="${avgRating != '—'}"><span class="text-sm font-semibold text-zinc-400">/ 5.0</span></c:if>
        </div>
        <div class="text-xs font-medium text-zinc-400 mt-0.5">Điểm đánh giá trung bình</div>
      </div>
    </div>
    <div class="bg-white rounded-2xl border border-zinc-200/70 shadow-sm p-5 flex items-center gap-4">
      <div class="w-11 h-11 rounded-xl bg-blue-50 flex items-center justify-center flex-shrink-0">
        <span class="material-symbols-outlined text-blue-500 text-[22px]">rate_review</span>
      </div>
      <div>
        <div class="text-2xl font-black text-zinc-900">${totalReviews}<c:if test="${hasMore}">+</c:if></div>
        <div class="text-xs font-medium text-zinc-400 mt-0.5">Tổng số lượt đánh giá</div>
      </div>
    </div>
    <div class="bg-white rounded-2xl border border-zinc-200/70 shadow-sm p-5 flex items-center gap-4">
      <div class="w-11 h-11 rounded-xl bg-emerald-50 flex items-center justify-center flex-shrink-0">
        <span class="material-symbols-outlined text-emerald-500 text-[22px]">verified</span>
      </div>
      <div>
        <div class="text-base font-black text-emerald-600">Đã xác minh</div>
        <div class="text-xs font-medium text-zinc-400 mt-0.5">Tự động đồng bộ từ lịch đặt sân</div>
      </div>
    </div>
  </div>

  <!-- Filter Bar -->
  <div class="bg-white rounded-2xl border border-zinc-200/70 shadow-sm p-4 flex flex-col gap-3">
    <form method="get" action="" id="filterForm" class="flex flex-wrap items-end gap-3">

      <!-- Search by name -->
      <div class="flex flex-col gap-1 flex-1 min-w-[180px]">
        <label class="text-[11px] font-semibold text-zinc-400 uppercase tracking-wide">Tên khách hàng</label>
        <div class="relative">
          <span class="material-symbols-outlined absolute left-2.5 top-1/2 -translate-y-1/2 text-zinc-400 text-[15px] pointer-events-none">search</span>
          <input type="text" name="q" value="${searchName}"
                 placeholder="Nhập tên…"
                 class="w-full pl-8 pr-3 h-9 rounded-xl text-xs border border-zinc-200 focus:outline-none focus:border-purple-400 bg-zinc-50" />
        </div>
      </div>

      <!-- Date From -->
      <div class="flex flex-col gap-1">
        <label class="text-[11px] font-semibold text-zinc-400 uppercase tracking-wide">Từ ngày</label>
        <input type="date" name="dateFrom" value="${dateFrom}"
               class="h-9 px-3 rounded-xl text-xs border border-zinc-200 focus:outline-none focus:border-purple-400 bg-zinc-50" />
      </div>

      <!-- Date To -->
      <div class="flex flex-col gap-1">
        <label class="text-[11px] font-semibold text-zinc-400 uppercase tracking-wide">Đến ngày</label>
        <input type="date" name="dateTo" value="${dateTo}"
               class="h-9 px-3 rounded-xl text-xs border border-zinc-200 focus:outline-none focus:border-purple-400 bg-zinc-50" />
      </div>

      <!-- Star filter -->
      <div class="flex flex-col gap-1">
        <label class="text-[11px] font-semibold text-zinc-400 uppercase tracking-wide">Số sao</label>
        <div class="flex items-center gap-1.5">
          <input type="hidden" name="soSao" id="soSaoInput" value="${filterSoSao}" />
          <button type="button" onclick="setStar(0)"
                  class="star-btn px-3 h-9 rounded-xl text-xs font-bold border transition-colors ${filterSoSao == 0 ? 'bg-purple-600 text-white border-purple-600' : 'bg-white text-zinc-600 border-zinc-200 hover:border-purple-400 hover:text-purple-700'}"
                  data-val="0">Tất cả</button>
          <c:forEach begin="5" end="1" step="-1" var="s">
            <button type="button" onclick="setStar(${s})"
                    class="star-btn px-2.5 h-9 rounded-xl text-xs font-bold border transition-colors flex items-center gap-0.5
                           ${filterSoSao == s ? 'bg-amber-400 text-white border-amber-400' : 'bg-white text-zinc-600 border-zinc-200 hover:border-amber-300 hover:text-amber-600'}"
                    data-val="${s}">
              ${s}<span class="material-symbols-outlined text-[13px]">star</span>
            </button>
          </c:forEach>
        </div>
      </div>

      <!-- Actions -->
      <div class="flex items-end gap-2">
        <button type="submit"
                class="h-9 px-4 rounded-xl text-xs font-bold bg-purple-600 text-white hover:bg-purple-700 transition-colors flex items-center gap-1.5">
          <span class="material-symbols-outlined text-[15px]">filter_list</span>Lọc
        </button>
        <c:if test="${not empty searchName or not empty dateFrom or not empty dateTo or filterSoSao != 0}">
          <a href="?" class="h-9 px-3 rounded-xl text-xs font-semibold border border-zinc-200 text-zinc-500 hover:border-red-300 hover:text-red-500 transition-colors flex items-center gap-1">
            <span class="material-symbols-outlined text-[14px]">close</span>Xóa bộ lọc
          </a>
        </c:if>
      </div>
    </form>
  </div>

  <script>
  function setStar(val) {
    document.getElementById('soSaoInput').value = val;
    document.querySelectorAll('.star-btn').forEach(function(btn) {
      var isActive = parseInt(btn.dataset.val) === val;
      if (val === 0) {
        btn.className = btn.className.replace(/bg-amber-400 text-white border-amber-400/g,'bg-white text-zinc-600 border-zinc-200 hover:border-amber-300 hover:text-amber-600');
        if (isActive) btn.className = btn.className.replace('bg-white text-zinc-600 border-zinc-200 hover:border-purple-400 hover:text-purple-700','bg-purple-600 text-white border-purple-600');
      } else {
        if (btn.dataset.val === '0') {
          btn.className = btn.className.replace('bg-purple-600 text-white border-purple-600','bg-white text-zinc-600 border-zinc-200 hover:border-purple-400 hover:text-purple-700');
        }
      }
    });
    // simple visual feedback — submit on click
    document.getElementById('filterForm').submit();
  }
  </script>

  <!-- Review List -->
  <div class="bg-white rounded-2xl border border-zinc-200/70 shadow-sm overflow-hidden">
    <div class="px-5 py-4 border-b border-zinc-100 flex items-center justify-between">
      <span class="font-bold text-zinc-900 text-sm">Danh sách ý kiến phản hồi</span>
      <span class="text-xs text-zinc-400 font-medium">
        <c:choose>
          <c:when test="${filterSoSao > 0}">Đang lọc ${filterSoSao}★ •</c:when>
        </c:choose>
        ${fn:length(dsDanhGia)} kết quả
      </span>
    </div>

    <c:choose>
      <c:when test="${empty dsDanhGia}">
        <div class="py-16 flex flex-col items-center justify-center">
          <span class="material-symbols-outlined text-5xl mb-3 text-zinc-200">reviews</span>
          <p class="text-sm font-medium text-zinc-400">
            <c:choose>
              <c:when test="${filterSoSao > 0}">Không có đánh giá ${filterSoSao} sao nào.</c:when>
              <c:otherwise>Chưa có đánh giá nào cho chi nhánh này.</c:otherwise>
            </c:choose>
          </p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="divide-y divide-zinc-100">
          <c:forEach var="dg" items="${dsDanhGia}">
            <div class="p-5 hover:bg-zinc-50/60 transition-colors">
              <div class="flex items-start justify-between gap-3">
                <!-- Avatar + info -->
                <div class="flex items-center gap-3 min-w-0">
                  <div class="w-9 h-9 rounded-full bg-purple-100 text-purple-700 font-black flex items-center justify-center text-sm flex-shrink-0 uppercase">
                    <c:choose>
                      <c:when test="${not empty dg.customerName}">${fn:substring(dg.customerName,0,1)}</c:when>
                      <c:otherwise>#</c:otherwise>
                    </c:choose>
                  </div>
                  <div class="min-w-0">
                    <div class="font-semibold text-zinc-900 text-sm">
                      <c:choose>
                        <c:when test="${not empty dg.customerName}"><c:out value="${dg.customerName}" /></c:when>
                        <c:otherwise>Khách hàng #${dg.accountIdNguoiDanhGia}</c:otherwise>
                      </c:choose>
                    </div>
                    <div class="text-xs text-zinc-400">
                      <c:choose>
                        <c:when test="${dg.ngayDanhGia != null}">
                          <%-- Format LocalDateTime: yyyy-MM-ddTHH:mm:ss → DD/MM/YYYY HH:mm --%>
                          <c:set var="raw" value="${dg.ngayDanhGia}" />
                          <c:set var="rawStr" value="${fn:replace(fn:substring(raw,0,16),'T',' ')}" />
                          <%-- rawStr = "YYYY-MM-DD HH:mm" → reformat to DD/MM/YYYY HH:mm --%>
                          ${fn:substring(rawStr,8,10)}/${fn:substring(rawStr,5,7)}/${fn:substring(rawStr,0,4)} ${fn:substring(rawStr,11,16)}
                        </c:when>
                        <c:otherwise>—</c:otherwise>
                      </c:choose>
                    </div>
                  </div>
                </div>
                <!-- Stars -->
                <div class="flex items-center gap-0.5 flex-shrink-0">
                  <c:forEach begin="1" end="5" var="i">
                    <c:choose>
                      <c:when test="${i <= dg.soSao}">
                        <span class="material-symbols-outlined text-amber-400 text-[18px]" style="font-variation-settings:'FILL' 1">star</span>
                      </c:when>
                      <c:otherwise>
                        <span class="material-symbols-outlined text-zinc-200 text-[18px]">star</span>
                      </c:otherwise>
                    </c:choose>
                  </c:forEach>
                  <span class="text-xs font-bold text-zinc-500 ml-1.5">${dg.soSao}.0</span>
                </div>
              </div>
              <!-- Comment -->
              <c:if test="${not empty dg.binhLuan}">
                <p class="text-zinc-600 text-sm mt-3 leading-relaxed pl-12"><c:out value="${dg.binhLuan}" /></p>
              </c:if>
            </div>
          </c:forEach>
        </div>

        <!-- Pagination -->
        <div class="px-5 py-4 border-t border-zinc-100 flex items-center justify-between">
          <c:choose>
            <c:when test="${currentPage > 1}">
              <a href="?soSao=${filterSoSao}&q=${searchName}&dateFrom=${dateFrom}&dateTo=${dateTo}&page=${currentPage - 1}" class="text-xs font-semibold text-purple-600 hover:underline flex items-center gap-1">
                <span class="material-symbols-outlined text-[14px]">arrow_back</span> Trang trước
              </a>
            </c:when>
            <c:otherwise><span></span></c:otherwise>
          </c:choose>
          <span class="text-xs text-zinc-400">Trang ${currentPage}</span>
          <c:choose>
            <c:when test="${hasMore}">
              <a href="?soSao=${filterSoSao}&q=${searchName}&dateFrom=${dateFrom}&dateTo=${dateTo}&page=${currentPage + 1}" class="text-xs font-semibold text-purple-600 hover:underline flex items-center gap-1">
                Trang sau <span class="material-symbols-outlined text-[14px]">arrow_forward</span>
              </a>
            </c:when>
            <c:otherwise><span></span></c:otherwise>
          </c:choose>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

</main>
<script>document.addEventListener('DOMContentLoaded',function(){ vsDatePicker('input[name="dateFrom"],input[name="dateTo"]'); });</script>
</body>
</html>
