<%@ tag description="Shared server-side pagination footer (item-range text, page-size select, compact numbered pager)" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%@ attribute name="pageResult" required="true" type="org.example.util.PageResult" %>
<%@ attribute name="baseUrl" required="true" type="java.lang.String" %>
<%@ attribute name="extraParams" required="false" type="java.util.Map" %>
<%@ attribute name="ariaLabel" required="true" type="java.lang.String" %>

<c:if test="${pageResult.totalItems > 0}">
  <nav class="flex flex-col sm:flex-row items-center justify-between gap-3 px-4 py-3 border-t border-gray-200 text-sm text-gray-600" aria-label="${ariaLabel}">

    <div>
      Hiển thị <span class="font-medium text-gray-800">${pageResult.fromItem}</span>–<span class="font-medium text-gray-800">${pageResult.toItem}</span>
      trong <span class="font-medium text-gray-800">${pageResult.totalItems}</span> kết quả
    </div>

    <div class="flex items-center gap-4">

      <form method="get" action="${pageContext.request.contextPath}${baseUrl}" class="flex items-center gap-2">
        <c:forEach var="entry" items="${extraParams}">
          <c:if test="${not empty entry.value}">
            <input type="hidden" name="<c:out value="${entry.key}"/>" value="<c:out value="${entry.value}"/>" />
          </c:if>
        </c:forEach>
        <input type="hidden" name="page" value="1" />
        <label for="pageSizeSelect" class="text-gray-500">Mỗi trang:</label>
        <select id="pageSizeSelect" name="pageSize" onchange="this.form.submit()"
                class="border border-gray-300 rounded-md text-sm px-2 py-1 focus:outline-none focus:ring-2 focus:ring-purple-500">
          <option value="10" ${pageResult.pageSize == 10 ? 'selected' : ''}>10</option>
          <option value="20" ${pageResult.pageSize == 20 ? 'selected' : ''}>20</option>
          <option value="50" ${pageResult.pageSize == 50 ? 'selected' : ''}>50</option>
        </select>
      </form>

      <c:if test="${pageResult.totalPages > 1}">
        <ul class="flex items-center gap-1">

          <li>
            <c:choose>
              <c:when test="${pageResult.hasPrevious}">
                <c:url var="prevUrl" value="${baseUrl}">
                  <c:param name="page" value="${pageResult.page - 1}" />
                  <c:param name="pageSize" value="${pageResult.pageSize}" />
                  <c:forEach var="entry" items="${extraParams}">
                    <c:if test="${not empty entry.value}">
                      <c:param name="${entry.key}" value="${entry.value}" />
                    </c:if>
                  </c:forEach>
                </c:url>
                <a href="${prevUrl}" class="px-2 py-1 rounded-md hover:bg-purple-100 text-purple-700">‹ Trước</a>
              </c:when>
              <c:otherwise>
                <span class="px-2 py-1 rounded-md text-gray-300" aria-disabled="true">‹ Trước</span>
              </c:otherwise>
            </c:choose>
          </li>

          <c:choose>
            <c:when test="${pageResult.totalPages <= 7}">
              <c:forEach var="p" begin="1" end="${pageResult.totalPages}">
                <li>
                  <c:url var="pUrl" value="${baseUrl}">
                    <c:param name="page" value="${p}" />
                    <c:param name="pageSize" value="${pageResult.pageSize}" />
                    <c:forEach var="entry" items="${extraParams}">
                      <c:if test="${not empty entry.value}">
                        <c:param name="${entry.key}" value="${entry.value}" />
                      </c:if>
                    </c:forEach>
                  </c:url>
                  <c:choose>
                    <c:when test="${p == pageResult.page}">
                      <span class="px-3 py-1 rounded-md bg-purple-600 text-white font-semibold" aria-current="page">${p}</span>
                    </c:when>
                    <c:otherwise>
                      <a href="${pUrl}" class="px-3 py-1 rounded-md hover:bg-purple-100 text-purple-700" aria-label="Đi đến trang ${p}">${p}</a>
                    </c:otherwise>
                  </c:choose>
                </li>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <c:set var="lastRendered" value="${0}" />
              <c:forEach var="p" begin="1" end="${pageResult.totalPages}">
                <c:if test="${p == 1 or p == pageResult.totalPages or (p >= pageResult.page - 2 and p <= pageResult.page + 2)}">
                  <c:if test="${p - lastRendered > 1}">
                    <li><span class="px-2 text-gray-400">…</span></li>
                  </c:if>
                  <li>
                    <c:url var="pUrl" value="${baseUrl}">
                      <c:param name="page" value="${p}" />
                      <c:param name="pageSize" value="${pageResult.pageSize}" />
                      <c:forEach var="entry" items="${extraParams}">
                        <c:if test="${not empty entry.value}">
                          <c:param name="${entry.key}" value="${entry.value}" />
                        </c:if>
                      </c:forEach>
                    </c:url>
                    <c:choose>
                      <c:when test="${p == pageResult.page}">
                        <span class="px-3 py-1 rounded-md bg-purple-600 text-white font-semibold" aria-current="page">${p}</span>
                      </c:when>
                      <c:otherwise>
                        <a href="${pUrl}" class="px-3 py-1 rounded-md hover:bg-purple-100 text-purple-700" aria-label="Đi đến trang ${p}">${p}</a>
                      </c:otherwise>
                    </c:choose>
                  </li>
                  <c:set var="lastRendered" value="${p}" />
                </c:if>
              </c:forEach>
            </c:otherwise>
          </c:choose>

          <li>
            <c:choose>
              <c:when test="${pageResult.hasNext}">
                <c:url var="nextUrl" value="${baseUrl}">
                  <c:param name="page" value="${pageResult.page + 1}" />
                  <c:param name="pageSize" value="${pageResult.pageSize}" />
                  <c:forEach var="entry" items="${extraParams}">
                    <c:if test="${not empty entry.value}">
                      <c:param name="${entry.key}" value="${entry.value}" />
                    </c:if>
                  </c:forEach>
                </c:url>
                <a href="${nextUrl}" class="px-2 py-1 rounded-md hover:bg-purple-100 text-purple-700">Sau ›</a>
              </c:when>
              <c:otherwise>
                <span class="px-2 py-1 rounded-md text-gray-300" aria-disabled="true">Sau ›</span>
              </c:otherwise>
            </c:choose>
          </li>

        </ul>
      </c:if>

    </div>
  </nav>
</c:if>
