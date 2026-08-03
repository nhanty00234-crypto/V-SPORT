<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Điểm danh ca | GUARD V-SPORT</title>
  <jsp:include page="/guard/common/guard_head.jsp"/>
  <script src="https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js"></script>
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
                  <%-- Face check-in button (ưu tiên) --%>
                  <button type="button" id="btnFaceCheckIn"
                          onclick="openFaceModal('checkin', ${caHomNay.caLamViecId})"
                          class="inline-flex items-center gap-2 bg-rose-600 hover:bg-rose-700 text-white font-bold text-sm px-6 py-3 rounded-xl shadow-lg shadow-rose-200 transition">
                    <span class="material-symbols-outlined text-[18px]" style="font-variation-settings:'FILL' 1">face</span>
                    ĐIỂM DANH KHUÔN MẶT
                  </button>
                  <%-- Fallback thủ công nếu faceRequired=false --%>
                  <c:if test="${!faceConfig.faceRequired}">
                    <form method="post" action="${pageContext.request.contextPath}/guard/diem-danh"
                          onsubmit="return confirm('Xác nhận VÀO CA thủ công lúc ' + new Date().toLocaleTimeString('vi-VN') + '?')">
                      <input type="hidden" name="action" value="checkin">
                      <input type="hidden" name="caLamViecId" value="${caHomNay.caLamViecId}">
                      <button type="submit"
                              class="inline-flex items-center gap-2 bg-zinc-100 hover:bg-zinc-200 text-zinc-700 font-semibold text-sm px-4 py-3 rounded-xl transition">
                        <span class="material-symbols-outlined text-[16px]">login</span>
                        Thủ công
                      </button>
                    </form>
                  </c:if>
                </c:when>
                <%-- Đã vào ca, chưa ra --%>
                <c:when test="${caHomNay.gioVaoThuc != null && caHomNay.gioRaThuc == null}">
                  <div class="text-right">
                    <p class="text-xs text-green-600 font-semibold mb-1 flex items-center gap-1">
                      <span class="w-1.5 h-1.5 rounded-full bg-green-500 inline-block live-dot"></span>
                      Đang trong ca — vào lúc ${caHomNay.gioVaoThuc}
                      <c:if test="${caHomNay.faceVerified}">
                        <span class="ml-1 text-[10px] bg-green-100 text-green-700 px-1.5 py-0.5 rounded-full">
                          👁 <fmt:formatNumber value="${caHomNay.faceConfidence}" maxFractionDigits="0"/>%
                        </span>
                      </c:if>
                    </p>
                    <button type="button" onclick="openFaceModal('checkout', ${caHomNay.caLamViecId})"
                            class="inline-flex items-center gap-2 bg-zinc-700 hover:bg-zinc-800 text-white font-bold text-sm px-6 py-3 rounded-xl transition">
                      <span class="material-symbols-outlined text-[18px]" style="font-variation-settings:'FILL' 1">face</span>
                      KẾT THÚC CA
                    </button>
                    <c:if test="${!faceConfig.faceRequired}">
                      <form method="post" action="${pageContext.request.contextPath}/guard/diem-danh" class="inline ml-2"
                            onsubmit="return confirm('Kết thúc ca thủ công?')">
                        <input type="hidden" name="action" value="checkout">
                        <input type="hidden" name="caLamViecId" value="${caHomNay.caLamViecId}">
                        <button type="submit" class="text-xs text-zinc-400 hover:text-zinc-600 underline">Thủ công</button>
                      </form>
                    </c:if>
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
                      <c:if test="${caHomNay.faceVerified}">
                        | 👁 <fmt:formatNumber value="${caHomNay.faceConfidence}" maxFractionDigits="0"/>%
                      </c:if>
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

  <!-- Ca sắp tới -->
  <c:if test="${not empty caSapToi}">
  <section>
    <h2 class="text-base font-black text-rose-900 mb-3 flex items-center gap-2">
      <span class="material-symbols-outlined text-[20px] text-rose-500" style="font-variation-settings:'FILL' 1">upcoming</span>
      Ca sắp tới (7 ngày)
    </h2>
    <div class="flex flex-col gap-3">
      <c:forEach var="ca" items="${caSapToi}">
        <div class="gd-card p-4 flex items-center justify-between gap-3">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center flex-shrink-0">
              <span class="material-symbols-outlined text-[18px] text-blue-500" style="font-variation-settings:'FILL' 1">event</span>
            </div>
            <div>
              <p class="font-bold text-zinc-800 text-sm">${ca.tenCa != null ? ca.tenCa : 'Ca làm việc'}</p>
              <p class="text-xs text-zinc-400">
                ${ca.ngayLam} — ${ca.gioBatDau} – ${ca.gioKetThuc}
              </p>
              <c:if test="${ca.viTri != null}">
                <p class="text-xs text-rose-400">Vị trí: ${ca.viTri}</p>
              </c:if>
            </div>
          </div>
          <div class="flex-shrink-0">
            <c:choose>
              <c:when test="${ca.trangThai == 'Confirmed'}">
                <span class="badge badge-green text-[10px]">Đã xác nhận</span>
              </c:when>
              <c:when test="${ca.trangThai == 'Published'}">
                <span class="badge badge-blue text-[10px]">Đã công bố</span>
              </c:when>
              <c:otherwise>
                <span class="badge badge-gray text-[10px]">${ca.trangThai}</span>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </c:forEach>
    </div>
  </section>
  </c:if>

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

<!-- Face Attendance Modal -->
<div id="faceModal" class="fixed inset-0 bg-black/70 z-50 flex items-center justify-center hidden">
  <div class="bg-white rounded-3xl shadow-2xl p-6 w-full max-w-sm mx-4 flex flex-col items-center gap-4">
    <h3 class="font-black text-rose-900 text-lg" id="faceModalTitle">Điểm danh khuôn mặt</h3>

    <div class="relative w-full aspect-square bg-zinc-900 rounded-2xl overflow-hidden">
      <video id="faceVideo" class="w-full h-full object-cover scale-x-[-1]" autoplay muted playsinline></video>
    </div>

    <p id="faceStatus" class="text-zinc-600 text-sm text-center font-medium min-h-[2.5rem]">
      Đang khởi động camera...
    </p>

    <div class="w-full bg-zinc-100 rounded-full h-2">
      <div id="faceProgress" class="bg-rose-500 h-2 rounded-full transition-all duration-300" style="width:0%"></div>
    </div>

    <button onclick="closeFaceModal()"
            class="w-full bg-zinc-100 hover:bg-zinc-200 text-zinc-700 font-semibold py-3 rounded-xl text-sm transition">
      Hủy
    </button>
  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/face-attendance.js"></script>
<script>
const CONTEXT_PATH = '${pageContext.request.contextPath}';
let _currentCaId = null;
let _currentAction = null;

function openFaceModal(action, caId) {
  _currentCaId = caId;
  _currentAction = action;
  document.getElementById('faceModal').classList.remove('hidden');
  document.getElementById('faceModalTitle').textContent =
    action === 'checkin' ? 'Điểm danh VÀO CA' : 'Điểm danh KẾT THÚC CA';
  startFaceAttendance(action, caId);
}

function closeFaceModal() {
  FaceAttendance.stop();
  document.getElementById('faceModal').classList.add('hidden');
}

async function startFaceAttendance(action, caId) {
  const statusEl = document.getElementById('faceStatus');
  const progressEl = document.getElementById('faceProgress');

  await FaceAttendance.init({
    videoEl: document.getElementById('faceVideo'),
    statusEl: statusEl,
    contextPath: CONTEXT_PATH,
    caLamViecId: caId,
    action: action,
    onSuccess: function(data) {
      progressEl.style.width = '100%';
      statusEl.textContent = '✓ Thành công! Độ khớp: ' + data.confidence.toFixed(1) + '%';
      statusEl.className = 'text-green-600 font-bold text-sm text-center';
      setTimeout(() => { closeFaceModal(); location.reload(); }, 1500);
    },
    onError: function(msg) {
      statusEl.textContent = '✗ ' + (msg || 'Lỗi nhận diện');
      statusEl.className = 'text-red-600 font-bold text-sm text-center';
    }
  });

  await FaceAttendance.start();
}
</script>

</body>
</html>
