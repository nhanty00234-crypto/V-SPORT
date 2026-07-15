package org.example.util;

import java.util.Collections;
import java.util.List;

/**
 * Immutable server-side pagination result envelope. Build only via {@link #of}
 * so fromItem/toItem/totalPages/hasPrevious/hasNext stay internally consistent.
 */
public final class PageResult<T> {

    private final List<T> items;
    private final int page;
    private final int pageSize;
    private final long totalItems;
    private final int totalPages;
    private final boolean hasPrevious;
    private final boolean hasNext;
    private final long fromItem;
    private final long toItem;

    private PageResult(List<T> items, int page, int pageSize, long totalItems,
                        int totalPages, boolean hasPrevious, boolean hasNext,
                        long fromItem, long toItem) {
        this.items = items;
        this.page = page;
        this.pageSize = pageSize;
        this.totalItems = totalItems;
        this.totalPages = totalPages;
        this.hasPrevious = hasPrevious;
        this.hasNext = hasNext;
        this.fromItem = fromItem;
        this.toItem = toItem;
    }

    public static <T> PageResult<T> of(List<T> items, int page, int pageSize, long totalItems) {
        int totalPages = totalItems == 0 ? 0 : (int) Math.ceil((double) totalItems / (double) pageSize);
        long fromItem = totalItems == 0 ? 0L : (long) (page - 1) * (long) pageSize + 1L;
        long toItem = totalItems == 0 ? 0L : Math.min((long) page * (long) pageSize, totalItems);
        boolean hasNext = totalItems > (long) (page - 1) * (long) pageSize + (long) items.size();
        return new PageResult<>(
                Collections.unmodifiableList(items),
                page,
                pageSize,
                totalItems,
                totalPages,
                page > 1,
                hasNext,
                fromItem,
                toItem
        );
    }

    public List<T> getItems() {
        return items;
    }

    public int getPage() {
        return page;
    }

    public int getPageSize() {
        return pageSize;
    }

    public long getTotalItems() {
        return totalItems;
    }

    public int getTotalPages() {
        return totalPages;
    }

    public boolean isHasPrevious() {
        return hasPrevious;
    }

    public boolean isHasNext() {
        return hasNext;
    }

    public long getFromItem() {
        return fromItem;
    }

    public long getToItem() {
        return toItem;
    }
}
