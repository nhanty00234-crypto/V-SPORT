<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Điểm danh ca | GUARD V-SPORT</title>
  <jsp:include page="/guard/common/guard_head.jsp"/>
</head>
<body>

<jsp:include page="/guard/common/sidebar.jsp"/>
<jsp:include page="/guard/common/header.jsp">
  <jsp:param name="pageTitle" value="Điểm danh ca làm việc"/>
  <jsp:param name="pageSubtitle" value="Vào ca / Kết thúc ca hôm nay"/>
</jsp:include>

<main class="lg:ml-[248px] mt-[60px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- Ca hôm nay -->
  <section>
    <h2 class="text-base font-black text-rose-900 mb-3 flex items-center gap-2">
      <span class="material-symbols-outlined text-[20px] text-rose-500" style="font-variation-settings:'FILL' 1">today</span>
      Ca hôm nay
    </h2>

    <c:choose>
      <c:when test="${caHomNay == null}">
        <div class="gd-card p-8 flex flex-col items-center justify-center text-center gap-3">
          <div class="w-16 h-16 rounded-2xl bg-amber-50 flex items-center justify-center">
            <span class="material-symbols-outlined text-[32px] text-amber-500" style="font-variation-settings:'FILL' 1">event_busy</span>
          </div>
          <p class="font-bold text-zinc-700">Bạn chưa được phân ca hôm nay</p>
          <p class="text-sm text-zinc-400">Liên hệ quản lý để được phân ca. Lịch ca sẽ hiển thị tại đây khi được công bố.</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="gd-card p-6">
          <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <!-- Ca info -->
            <div class="flex items-center gap-4">
              <div class="w-14 h-14 rounded-2xl bg-rose-100 flex items-center justify-center">
                <span class="material-symbols-outlined text-[28px] text-rose-600" style="font-variation-settings:'FILL' 1">work</span>
              </div>
              <div>
                <p class="font-black text-rose-900 text-lg">${caHomNay.tenCa != null ? caHomNay.tenCa : 'Ca làm việc'}</p>
                <p class="text-sm text-zinc-500 mt-0.5">
                  <span class="material-symbols-outlined text-[14px] align-[-2px] mr-0.5">schedule</span>
                  ${caHomNay.gioBatDau} – ${caHomNay.gioKetThuc}
                </p>
                <c:if test="${caHomNay.viTri != null}">
                  <p class="text-xs text-rose-400 mt-0.5">Vị trí: ${caHomNay.viTri}</p>
                </c:if>
              </div>
            </div>

            <!-- Action buttons -->
            <div class="flex gap-3">
              <c:choose>
                <%-- Chưa vào ca --%>
                <c:when test="${caHomNay.gioVaoThuc == null}">
                  <form method="post" action="${pageContext.request.contextPath}/guard/diem-danh"
                        onsubmit="return confirm('Xác nhận VÀO CA lúc ' + new Date().toLocaleTimeString('vi-VN') + '?')">
                    <input type="hidden" name="action" value="checkin">
                    <input type="hidden" name="caLamViecId" value="${caHomNay.caLamViecId}">
                    <button type="submit"
                            class="inline-flex items-center gap-2 bg-rose-600 hover:bg-rose-700 text-white font-bold text-sm px-6 py-3 rounded-xl shadow-lg shadow-rose-200 transition">
                      <span class="material-symbols-outlined text-[18px]" style="font-variation-settings:'FILL' 1">login</span>
                      VÀO CA
                    </button>
                  </form>
                </c:when>
                <%-- Đã vào ca, chưa ra --%>
                <c:when test="${caHomNay.gioVaoThuc != null && caHomNay.gioRaThuc == null}">
                  <div class="text-right">
                    <p class="text-xs text-green-600 font-semibold mb-2 flex items-center gap-1">
                      <span class="w-1.5 h-1.5 rounded-full bg-green-500 inline-block live-dot"></span>
                      Đang trong ca — vào lúc ${caHomNay.gioVaoThuc}
                    </p>
                    <form method="post" action="${pageContext.request.contextPath}/guard/diem-danh"
                          onsubmit="return confirm('Xác nhận KẾT THÚC CA lúc ' + new Date().toLocaleTimeString('vi-VN') + '?')">
                      <input type="hidden" name="action" value="checkout">
                      <input type="hidden" name="caLamViecId" value="${caHomNay.caLamViecId}">
                      <button type="submit"
                              class="inline-flex items-center gap-2 bg-zinc-700 hover:bg-zinc-800 text-white font-bold text-sm px-6 py-3 rounded-xl transition">
                        <span class="material-symbols-outlined text-[18px]" style="font-variation-settings:'FILL' 1">logout</span>
                        KẾT THÚC CA
                      </button>
                    </form>
                  </div>
                </c:when>
                <%-- Đã hoàn thành --%>
                <c:otherwise>
                  <div class="text-right">
                    <span class="badge badge-blue text-sm px-4 py-2">
                      <span class="material-symbols-outlined text-[16px] mr-1" style="font-variation-settings:'FILL' 1">check_circle</span>
                      Ca hoàn thành
                    </span>
                    <p class="text-xs text-zinc-400 mt-2">
                      Vào: ${caHomNay.gioVaoThuc} — Ra: ${caHomNay.gioRaThuc}
                    </p>
                  </div>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>
      </c:otherwise>
    </c:choose>
  </section>

  <!-- Lịch sử 7 ngày -->
  <section>
    <h2 class="text-base font-black text-rose-900 mb-3 flex items-center gap-2">
      <span class="material-symbols-outlined text-[20px] text-rose-500" style="font-variation-settings:'FILL' 1">history</span>
      Lịch sử 7 ngày gần đây
    </h2>

    <c:choose>
      <c:when test="${empty lichSuCa}">
        <div class="gd-card p-6 text-center text-zinc-400 text-sm">Không có lịch sử ca trong 7 ngày qua.</div>
      </c:when>
      <c:otherwise>
        <div class="flex flex-col gap-3">
          <c:forEach var="ca" items="${lichSuCa}">
            <div class="gd-card p-4 flex items-center justify-between gap-3">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-rose-50 flex items-center justify-center flex-shrink-0">
                  <span class="material-symbols-outlined text-[18px] text-rose-500" style="font-variation-settings:'FILL' 1">calendar_today</span>
                </div>
                <div>
                  <p class="font-bold text-zinc-800 text-sm">${ca.tenCa != null ? ca.tenCa : 'Ca làm việc'}</p>
                  <p class="text-xs text-zinc-400">
                    ${ca.ngayLam} — ${ca.gioBatDau} – ${ca.gioKetThuc}
                  </p>
                </div>
              </div>
              <div class="text-right flex-shrink-0">
                <c:choose>
                  <c:when test="${ca.trangThai == 'CheckedOut'}">
                    <span class="badge badge-blue text-[10px]">Hoàn thành</span>
                    <p class="text-[10px] text-zinc-400 mt-1">
                      ${ca.gioVaoThuc} → ${ca.gioRaThuc}
                    </p>
                  </c:when>
                  <c:when test="${ca.trangThai == 'CheckedIn'}">
                    <span class="badge badge-green text-[10px]">Đang trực</span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge badge-gray text-[10px]">Không điểm danh</span>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </section>

</main>
</body>
</html>
