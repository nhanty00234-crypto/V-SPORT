<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%--
    V-SPORT Customer Design System (Phase 1)
    Scope: CUSTOMER pages only. Do NOT include from admin/manager/staff.
    - One accent lock: emerald "V-SPORT green" (unifies the older lime + emerald mix).
    - One radius scale. Flat surfaces, restrained shadows (minimalist-skill discipline).
    - Tokens are namespaced --vs-* to avoid clashing with page-level vars.
    - Also re-themes the shared header.jsp accent to emerald ON CUSTOMER PAGES ONLY
      (targeted !important overrides; admin/manager never load this file).
--%>
<style>
    :root {
        /* ---- V-SPORT green (emerald family), single locked accent ---- */
        --vs-primary: #047857;        /* solid buttons / white-text surfaces (AA on white) */
        --vs-primary-strong: #065f46; /* hover / pressed */
        --vs-accent: #059669;         /* icons, active states */
        --vs-primary-50: #ecfdf5;     /* chip / tint backgrounds */
        --vs-primary-100: #d1fae5;

        /* ---- neutrals ---- */
        --vs-ink: #0f172a;
        --vs-text: #1f2937;
        --vs-muted: #64748b;
        --vs-surface: #f6f7f9;
        --vs-card: #ffffff;
        --vs-border: #e5e7eb;

        /* ---- semantic ---- */
        --vs-danger: #dc2626;
        --vs-warn: #d97706;
        --vs-warn-bg: #fffbeb;
        --vs-ok-bg: #ecfdf5;

        /* ---- radius scale (one system) ---- */
        --vs-r-card: 14px;
        --vs-r-btn: 10px;
        --vs-r-chip: 9999px;

        /* ---- shell heights ---- */
        --vs-bottomnav-h: 70px;
        --vs-bottomnav-h-desktop: 80px;

        /* Re-point the shared header's var-driven accent to V-SPORT green. */
        --primary: var(--vs-accent) !important;
        --primary-hover: var(--vs-primary) !important;
    }

    /* Reserve space so the fixed bottom nav never covers content, at every width. */
    body { padding-bottom: calc(var(--vs-bottomnav-h) + env(safe-area-inset-bottom, 0px) + 6px); }
    @media (min-width: 1024px) {
        body { padding-bottom: calc(var(--vs-bottomnav-h-desktop) + env(safe-area-inset-bottom, 0px) + 6px); }
    }

    /* ================= Header accent unification (customer pages only) ============= */
    .navbar .nav-links a::after { background-color: var(--vs-accent) !important; }
    .navbar .header-icon-badge,
    .side-drawer .avatar-circle { background-color: var(--vs-accent) !important; }
    .side-drawer .drawer-link:hover { color: var(--vs-primary) !important; }
    .btn-register-shimmer {
        background: linear-gradient(135deg, var(--vs-accent) 0%, var(--vs-primary) 100%) !important;
        color: #ffffff !important;
        box-shadow: 0 4px 14px rgba(4, 120, 87, 0.22) !important;
    }
    .user-avatar { color: #ffffff !important; }

    /* ============================ Reusable components ============================== */
    .vs-card {
        background: var(--vs-card);
        border: 1px solid var(--vs-border);
        border-radius: var(--vs-r-card);
        box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
    }

    .vs-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 8px;
        font-family: 'Poppins', 'Inter', system-ui, sans-serif;
        font-weight: 600; font-size: 14px; line-height: 1;
        padding: 12px 18px; border-radius: var(--vs-r-btn);
        border: 1px solid transparent; cursor: pointer; text-decoration: none;
        transition: background-color .18s ease, transform .1s ease, border-color .18s ease;
        white-space: nowrap;
    }
    .vs-btn:active { transform: translateY(1px); }
    .vs-btn-primary { background: var(--vs-primary); color: #fff; }
    .vs-btn-primary:hover { background: var(--vs-primary-strong); color: #fff; }
    .vs-btn-ghost { background: #fff; color: var(--vs-text); border-color: var(--vs-border); }
    .vs-btn-ghost:hover { border-color: var(--vs-accent); color: var(--vs-primary); }

    /* Category / filter chips */
    .vs-chip {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 8px 14px; border-radius: var(--vs-r-chip);
        background: #fff; border: 1px solid var(--vs-border);
        color: var(--vs-text); font-size: 13.5px; font-weight: 600;
        cursor: pointer; white-space: nowrap; text-decoration: none;
        transition: all .16s ease;
    }
    .vs-chip:hover { border-color: var(--vs-accent); color: var(--vs-primary); }
    .vs-chip.is-active { background: var(--vs-primary); border-color: var(--vs-primary); color: #fff; }

    /* Search bar */
    .vs-search {
        display: flex; align-items: center; gap: 10px;
        background: #fff; border: 1px solid var(--vs-border);
        border-radius: var(--vs-r-btn); padding: 12px 14px;
    }
    .vs-search input {
        flex: 1; border: none; outline: none; background: transparent;
        font-size: 15px; color: var(--vs-text); min-width: 0;
    }
    .vs-search input::placeholder { color: var(--vs-muted); }

    /* Reputation badge */
    .vs-rep { display: inline-flex; align-items: center; gap: 6px; padding: 5px 12px; border-radius: 9999px; font-size: 12.5px; font-weight: 700; }
    .vs-rep-good  { background: var(--vs-ok-bg);  color: var(--vs-primary); }
    .vs-rep-watch { background: var(--vs-warn-bg); color: var(--vs-warn); }
    .vs-rep-bad   { background: #fef2f2; color: var(--vs-danger); }

    /* ============================== Bottom navigation ============================== */
    /* Visible at every width, full-width, no side margins. Bar height IS the full
       visual envelope (70px mobile / 84px desktop) so the raised center circle pokes
       out of the white bar itself — no gray page background gap above the bar. */
    .vs-bottomnav {
        position: fixed; left: 0; right: 0; bottom: 0; z-index: 1200;
        display: grid; grid-template-columns: repeat(5, 1fr);
        align-items: stretch;
        background: #fff; border-top: 1px solid #dbe4e1;
        height: calc(var(--vs-bottomnav-h) + env(safe-area-inset-bottom, 0px));
        padding-bottom: env(safe-area-inset-bottom, 0px);
        box-shadow: 0 -1px 4px rgba(15, 23, 42, 0.04);
    }
    .vs-bn-item {
        display: flex; flex-direction: column; align-items: center; justify-content: center;
        gap: 5px; height: 100%; min-width: 44px; min-height: 44px;
        color: #9a9a9a; text-decoration: none; font-size: 13px; font-weight: 500;
        line-height: 1.15; border: none; background: transparent; cursor: pointer;
    }
    .vs-bn-item .vs-bn-ic { font-size: 24px; line-height: 1; }
    /* Lucide inline SVG icons (bottom-nav.jsp) size via width/height, not font-size. */
    svg.vs-bn-ic { width: 25px; height: 25px; flex-shrink: 0; }
    .vs-bn-item.is-active { color: var(--vs-primary); font-weight: 700; }
    .vs-bn-item.is-active .vs-bn-ic { color: var(--vs-primary); }
    .vs-bn-item:focus-visible { outline: 2px solid var(--vs-accent); outline-offset: -2px; border-radius: 6px; }

    /* Center raised action: Ghép trận. White fill, green outline by default —
       only intensifies (darker border) when the route is actually active. */
    .vs-bn-center { position: relative; justify-content: flex-end; padding-bottom: 10px; }
    .vs-bn-fab {
        position: absolute; top: -20px; left: 50%; transform: translateX(-50%);
        width: 64px; height: 64px; border-radius: 50%;
        background: #fff; color: var(--vs-primary);
        display: flex; align-items: center; justify-content: center;
        box-shadow: 0 0 0 5px #edf9f3, 0 3px 10px rgba(15, 23, 42, 0.10);
        border: 2px solid var(--vs-primary);
    }
    .vs-bn-fab .vs-bn-ic { font-size: 27px; color: var(--vs-primary); }
    .vs-bn-fab svg.vs-bn-ic { width: 28px; height: 28px; }
    .vs-bn-center .vs-bn-fablabel { font-size: 13px; font-weight: 500; color: #9a9a9a; line-height: 1.15; }
    .vs-bn-center.is-active .vs-bn-fab { border-color: var(--vs-primary-strong); border-width: 2.5px; }
    .vs-bn-center.is-active .vs-bn-fablabel { color: var(--vs-primary); font-weight: 700; }

    /* Desktop: taller bar (80px envelope), larger circle, larger touch targets. */
    @media (min-width: 1024px) {
        .vs-bottomnav { height: var(--vs-bottomnav-h-desktop); }
        .vs-bn-item { font-size: 14px; gap: 6px; }
        .vs-bn-item .vs-bn-ic { font-size: 26px; }
        svg.vs-bn-ic { width: 27px; height: 27px; }
        .vs-bn-center { padding-bottom: 12px; }
        .vs-bn-fab { width: 72px; height: 72px; top: -22px; }
        .vs-bn-fab .vs-bn-ic { font-size: 29px; }
        .vs-bn-fab svg.vs-bn-ic { width: 31px; height: 31px; }
        .vs-bn-center .vs-bn-fablabel { font-size: 14px; }
    }
</style>
