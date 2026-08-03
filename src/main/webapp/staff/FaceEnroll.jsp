<%-- src/main/webapp/staff/FaceEnroll.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Đăng ký khuôn mặt | Staff V-SPORT</title>
  <jsp:include page="/staff/common/staff_head.jsp"/>
  <script src="https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js"></script>
</head>
<body>
<jsp:include page="/staff/common/sidebar.jsp"/>
<jsp:include page="/staff/common/header.jsp">
  <jsp:param name="pageTitle" value="Đăng ký khuôn mặt"/>
  <jsp:param name="pageSubtitle" value="Dùng cho điểm danh sinh trắc học"/>
</jsp:include>

<main class="lg:ml-[248px] mt-[60px] p-4 lg:p-6 max-w-lg">

  <!-- Trạng thái hiện tại -->
  <c:choose>
    <c:when test="${faceData != null && faceData.faceEnrolled}">
      <div class="gd-card p-5 mb-5 flex items-center gap-4">
        <div class="w-12 h-12 rounded-2xl bg-green-100 flex items-center justify-center">
          <span class="material-symbols-outlined text-[24px] text-green-600" style="font-variation-settings:'FILL' 1">face</span>
        </div>
        <div>
          <p class="font-bold text-green-700">Đã đăng ký khuôn mặt</p>
          <p class="text-xs text-zinc-400">Cập nhật lần cuối: ${faceData.faceEnrolledAt}</p>
        </div>
      </div>
    </c:when>
    <c:otherwise>
      <div class="gd-card p-5 mb-5 flex items-center gap-4 border-amber-200 bg-amber-50">
        <span class="material-symbols-outlined text-[28px] text-amber-500" style="font-variation-settings:'FILL' 1">warning</span>
        <p class="text-sm text-amber-700 font-semibold">Bạn chưa đăng ký khuôn mặt. Hãy hoàn thành để điểm danh.</p>
      </div>
    </c:otherwise>
  </c:choose>

  <!-- Camera section -->
  <div class="gd-card p-6 flex flex-col items-center gap-4">
    <div class="relative w-full max-w-xs aspect-square bg-zinc-900 rounded-2xl overflow-hidden">
      <video id="enrollVideo" class="w-full h-full object-cover scale-x-[-1]" autoplay muted playsinline></video>
      <canvas id="enrollCanvas" class="absolute inset-0 w-full h-full scale-x-[-1]" style="display:none"></canvas>
    </div>

    <p id="enrollStatus" class="text-zinc-500 text-sm text-center min-h-[2rem]">Nhấn "Bắt đầu" để mở camera</p>

    <div id="enrollPreview" class="hidden w-32 h-32 rounded-2xl overflow-hidden border-4 border-green-400">
      <img id="enrollPreviewImg" class="w-full h-full object-cover" alt="Preview khuôn mặt"/>
    </div>

    <div class="flex gap-3 w-full">
      <button id="btnStart" onclick="startEnroll()"
              class="flex-1 bg-rose-600 hover:bg-rose-700 text-white font-bold py-3 rounded-xl text-sm transition">
        📷 Bắt đầu
      </button>
      <button id="btnSave" onclick="saveEnroll()" disabled
              class="flex-1 bg-green-600 hover:bg-green-700 disabled:bg-zinc-200 disabled:text-zinc-400 text-white font-bold py-3 rounded-xl text-sm transition">
        ✓ Lưu khuôn mặt
      </button>
    </div>
  </div>
</main>

<script src="${pageContext.request.contextPath}/assets/js/face-enroll.js"></script>
<script>
  const CONTEXT_PATH = '${pageContext.request.contextPath}';
  const MODEL_URL = CONTEXT_PATH + '/assets/face-models';
</script>
</body>
</html>
