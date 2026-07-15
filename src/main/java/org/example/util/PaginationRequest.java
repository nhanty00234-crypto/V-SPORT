package org.example.util;

/**
 * Normalized, immutable pagination input. Always construct via
 * {@link PaginationUtils} so page/pageSize/sortDirection are guaranteed valid —
 * never call {@link #of} directly from a servlet/DAO with raw request params.
 */
public final class PaginationRequest {

    private final int page;
    private final int pageSize;
    private final String sortBy;
    private final String sortDirection;

    private PaginationRequest(int page, int pageSize, String sortBy, String sortDirection) {
        this.page = page;
        this.pageSize = pageSize;
        this.sortBy = sortBy;
        this.sortDirection = sortDirection;
    }

    static PaginationRequest of(int page, int pageSize, String sortBy, String sortDirection) {
        return new PaginationRequest(page, pageSize, sortBy, sortDirection);
    }

    public int getPage() {
        return page;
    }

    public int getPageSize() {
        return pageSize;
    }

    public long getOffset() {
        return (long) (page - 1) * (long) pageSize;
    }

    public String getSortBy() {
        return sortBy;
    }

    public String getSortDirection() {
        return sortDirection;
    }

    public PaginationRequest withPage(int newPage) {
        return new PaginationRequest(newPage, pageSize, sortBy, sortDirection);
    }
}
