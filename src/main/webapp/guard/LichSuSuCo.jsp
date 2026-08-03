<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Lịch sử sự cố | GUARD V-SPORT</title>
  <jsp:include page="/guard/common/guard_head.jsp"/>
</head>
<body>

<jsp:include page="/guard/common/sidebar.jsp"/>
<jsp:include page="/guard/common/header.jsp">
  <jsp:param name="pageTitle" value="Lịch sử sự cố"/>
  <jsp:param name="pageSubtitle" value="Các sự cố bạn đã báo cáo"/>
</jsp:include>

<main class="lg:ml-[248px] mt-[60px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- Filter tabs -->
  <section class="flex items-center gap-2 flex-wrap">
    <a href="?trangThai="
       class="px-4 py-2 rounded-xl text-xs font-bold border-2 transition ${empty filterTrangThai ? 'border-rose-500 bg-rose-50 text-rose-700' : 'border-zinc-200 text-zinc-500 hover:border-rose-300'}">
      Tất cả
    </a>
    <a href="?trangThai=CHO_XU_LY"
       class="px-4 py-2 rounded-xl text-xs font-bold border-2 transition ${filterTrangThai == 'CHO_XU_LY' ? 'border-amber-500 bg-amber-50 text-amber-700' : 'border-zinc-200 text-zinc-500 hover:border-amber-300'}">
      🟡 Chờ xử lý
    </a>
    <a href="?trangThai=DANG_XU_LY"
       class="px-4 py-2 rounded-xl text-xs font-bold border-2 transition ${filterTrangThai == 'DANG_XU_LY' ? 'border-blue-500 bg-blue-50 text-blue-700' : 'border-zinc-200 text-zinc-500 hover:border-blue-300'}">
      🔵 Đang xử lý
    </a>
    <a href="?trangThai=DA_XONG"
       class="px-4 py-2 rounded-xl text-xs font-bold border-2 transition ${filterTrangThai == 'DA_XONG' ? 'border-green-500 bg-green-50 text-green-700' : 'border-zinc-200 text-zinc-500 hover:border-green-300'}">
      🟢 Đã xong
    </a>

    <a href="${pageContext.request.contextPath}/guard/bao-cao-su-co"
       class="ml-auto inline-flex items-center gap-1.5 bg-rose-600 hover:bg-rose-700 text-white font-bold text-xs px-4 py-2 rounded-xl transition">
      <span class="material-symbols-outlined text-[15px]">add</span>Báo sự cố mới
    </a>
  </section>

  <!-- List -->
  <section>
    <c:choose>
      <c:when test="${empty danhSachSuCo}">
        <div class="gd-card p-10 flex flex-col items-center justify-center text-center gap-3">
          <span class="material-symbols-outlined text-[48px] text-rose-200" style="font-variation-settings:'FILL' 1">check_shield</span>
          <p class="font-bold text-zinc-500">Không có sự cố nào</p>
          <p class="text-sm text-zinc-400">Tất cả đang bình thường!</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="flex flex-col gap-3">
          <c:forEach var="sc" items="${danhSachSuCo}">
            <c:if test="${empty filterTrangThai || sc.trangThai == filterTrangThai}">
              <div class="gd-card p-5">
                <div class="flex items-start gap-4">
                  <!-- Mức độ indicator -->
                  <div class="w-10 h-10 rounded-xl flex-shrink-0 flex items-center justify-center
                      ${sc.mucDo == 'CAO' ? 'bg-red-100' : sc.mucDo == 'TRUNG_BINH' ? 'bg-amber-100' : 'bg-green-100'}">
                    <span class="material-symbols-outlined text-[20px]
                        ${sc.mucDo == 'CAO' ? 'text-red-600' : sc.mucDo == 'TRUNG_BINH' ? 'text-amber-500' : 'text-green-500'}"
                          style="font-variation-settings:'FILL' 1">warning</span>
                  </div>

                  <div class="flex-1 min-w-0">
                    <div class="flex items-center gap-2 flex-wrap mb-1">
                      <!-- Loại -->
                      <span class="badge badge-rose">${sc.loaiSuCoDisplay}</span>
                      <!-- Mức độ -->
                      <c:choose>
                        <c:when test="${sc.mucDo == 'CAO'}"><span class="badge badge-red">🔴 Cao</span></c:when>
                        <c:when test="${sc.mucDo == 'TRUNG_BINH'}"><span class="badge badge-amber">🟡 Trung bình</span></c:when>
                        <c:otherwise><span class="badge badge-green">🟢 Thấp</span></c:otherwise>
                      </c:choose>
                      <!-- Trạng thái -->
                      <c:choose>
                        <c:when test="${sc.trangThai == 'CHO_XU_LY'}"><span class="badge badge-amber ml-auto">Chờ xử lý</span></c:when>
                        <c:when test="${sc.trangThai == 'DANG_XU_LY'}"><span class="badge badge-blue ml-auto">Đang xử lý</span></c:when>
                        <c:otherwise><span class="badge badge-green ml-auto">Đã xong</span></c:otherwise>
                      </c:choose>
                    </div>

                    <!-- Vị trí -->
                    <p class="text-xs text-rose-500 font-semibold mb-1">
                      <span class="material-symbols-outlined text-[12px] align-[-1px]">location_on</span>
                      ${sc.tenSan != null ? sc.tenSan : 'Khu vực chung'}
                    </p>

                    <!-- Mô tả -->
                    <p class="text-sm text-zinc-700 line-clamp-2">${sc.moTa}</p>

                    <!-- Thời gian -->
                    <p class="text-[11px] text-zinc-400 mt-2">
                      <span class="material-symbols-outlined text-[12px] align-[-1px]">schedule</span>
                      ${sc.thoiGianTao}
                    </p>

                    <!-- Ghi chú xử lý -->
                    <c:if test="${not empty sc.ghiChuXuLy}">
                      <div class="mt-2 bg-blue-50 border border-blue-100 rounded-lg px-3 py-2">
                        <p class="text-[11px] text-blue-700 font-semibold mb-0.5">Phản hồi từ quản lý:</p>
                        <p class="text-xs text-blue-600">${sc.ghiChuXuLy}</p>
                      </div>
                    </c:if>
                  </div>

                  <!-- Ảnh thumbnail -->
                  <c:if test="${not empty sc.anhUrl}">
                    <img src="${pageContext.request.contextPath}${sc.anhUrl}" alt="Ảnh sự cố"
                         class="w-16 h-16 rounded-xl object-cover flex-shrink-0 border border-rose-100">
                  </c:if>
                </div>
              </div>
            </c:if>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </section>

</main>
</body>
</html>
