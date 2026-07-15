package org.example.util;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

/**
 * Single entry point for turning raw, untrusted request parameters into a
 * normalized {@link PaginationRequest}. Servlets must call {@link #fromRequest}
 * instead of reading "page"/"pageSize"/"sortBy"/"sortDir" parameters themselves.
 */
public final class PaginationUtils {

    public static final int DEFAULT_PAGE = 1;
    public static final int DEFAULT_PAGE_SIZE = 20;
    public static final int[] ALLOWED_PAGE_SIZES = {10, 20, 50};
    public static final int MAX_PAGE_SIZE = 100;
    public static final String DEFAULT_SORT_DIRECTION = "DESC";

    private PaginationUtils() {
    }

    public static PaginationRequest fromRequest(HttpServletRequest request) {
        return fromRequest(request, DEFAULT_PAGE_SIZE);
    }

    public static PaginationRequest fromRequest(HttpServletRequest request, int defaultPageSize) {
        int page = parseIntOrDefault(request.getParameter("page"), DEFAULT_PAGE);
        int pageSize = parseIntOrDefault(request.getParameter("pageSize"), defaultPageSize);
        String sortBy = request.getParameter("sortBy");
        String sortDir = request.getParameter("sortDir");
        return of(page, pageSize, sortBy, sortDir, defaultPageSize);
    }

    public static PaginationRequest of(int page, int pageSize, String sortBy, String sortDirection) {
        return of(page, pageSize, sortBy, sortDirection, DEFAULT_PAGE_SIZE);
    }

    public static PaginationRequest of(int page, int pageSize, String sortBy, String sortDirection, int defaultPageSize) {
        int normalizedPage = normalizePage(page);
        int normalizedPageSize = normalizePageSize(pageSize, defaultPageSize);
        String normalizedSortDir = normalizeSortDirection(sortDirection);
        return PaginationRequest.of(normalizedPage, normalizedPageSize, sortBy, normalizedSortDir);
    }

    public static int normalizePage(int page) {
        return page < 1 ? DEFAULT_PAGE : page;
    }

    public static int normalizePageSize(int pageSize, int defaultPageSize) {
        for (int allowed : ALLOWED_PAGE_SIZES) {
            if (allowed == pageSize) {
                return Math.min(allowed, MAX_PAGE_SIZE);
            }
        }
        return Math.min(defaultPageSize, MAX_PAGE_SIZE);
    }

    public static String normalizeSortDirection(String sortDirection) {
        if ("asc".equalsIgnoreCase(sortDirection)) {
            return "ASC";
        }
        return DEFAULT_SORT_DIRECTION;
    }

    public static int clampPage(int requestedPage, int totalPages) {
        if (totalPages <= 0) {
            return 1;
        }
        if (requestedPage > totalPages) {
            return totalPages;
        }
        if (requestedPage < 1) {
            return 1;
        }
        return requestedPage;
    }

    public static String resolveSortColumn(Map<String, String> whitelist, String requestedKey, String defaultColumn) {
        if (requestedKey == null || !whitelist.containsKey(requestedKey)) {
            return defaultColumn;
        }
        return whitelist.get(requestedKey);
    }

    private static int parseIntOrDefault(String value, int defaultValue) {
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}
