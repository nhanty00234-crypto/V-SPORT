/* V-SPORT ERD — rendering engine. Pure vanilla JS, no dependencies.
 * Reads structured data from erd-data.js (ERD_ENTITIES, ERD_VIEWS) and
 * renders entity cards + orthogonal SVG connectors, derived purely from
 * field-level FK metadata (thamChieu). No manual edge list exists anywhere
 * in this file — this is required to keep the data and the diagram from
 * ever contradicting each other.
 */
(function () {
  'use strict';

  var entityByKey = new Map(ERD_ENTITIES.map((e) => [e.tableKey, e]));

  function allFields(entity) {
    return (entity.cotChinh || []).concat(entity.cotMoRong || []);
  }

  function visibleFields(entity, showExtended) {
    return showExtended ? allFields(entity) : entity.cotChinh || [];
  }

  // ---------------------------------------------------------------------
  // Derive all relationships once from field metadata (single source).
  // Fields with fk !== true or without thamChieu (including fkLogic-only
  // fields) are skipped automatically — no real connector is ever drawn
  // for logical FKs (AuditLog, AdminTrash).
  // ---------------------------------------------------------------------
  function deriveRelationships() {
    const rels = [];
    ERD_ENTITIES.forEach((entity) => {
      allFields(entity).forEach((field) => {
        if (!field.fk || !field.thamChieu) return;
        const parts = field.thamChieu.split('.');
        const targetKey = parts[0];
        const targetColumnKey = parts[1];
        if (!entityByKey.has(targetKey)) return;

        const isOneToOne = !!field.pk || !!field.unique;
        const selfRef = targetKey === entity.tableKey && targetColumnKey !== field.columnKey;

        rels.push({
          fromEntity: entity.tableKey,
          fromField: field.columnKey,
          toEntity: targetKey,
          toField: targetColumnKey,
          oneToOne: isOneToOne,
          nullable: !!field.nullable,
          selfRef: selfRef,
          vaiTro: field.vaiTro || '',
        });
      });
    });
    return rels;
  }

  const ALL_RELATIONSHIPS = deriveRelationships();

  // ---------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------
  const state = {
    viewId: 'overview',
    zoom: 1,
    screenshotMode: false,
    extendedColumns: false,
    searchTerm: '',
    hoverEntity: null,
    hoverField: null, // { entity, field }
  };

  const els = {
    navList: document.getElementById('navList'),
    groupTitle: document.getElementById('groupTitle'),
    ssGroupTitle: document.getElementById('ssGroupTitle'),
    canvasViewport: document.getElementById('canvasViewport'),
    canvasStage: document.getElementById('canvasStage'),
    zoomReadout: document.getElementById('zoomReadout'),
    tableSearch: document.getElementById('tableSearch'),
    screenshotToggle: document.getElementById('screenshotToggle'),
    extendedToggle: document.getElementById('extendedToggle'),
  };

  // ---------------------------------------------------------------------
  // Navigator
  // ---------------------------------------------------------------------
  function buildNav() {
    ERD_VIEWS.forEach((v) => {
      const li = document.createElement('li');
      const btn = document.createElement('button');
      btn.className = 'nav-item';
      btn.dataset.view = v.id;
      btn.innerHTML = '<span class="nav-code">Group ' + v.code + '</span>' + v.title;
      btn.addEventListener('click', () => setView(v.id));
      li.appendChild(btn);
      els.navList.appendChild(li);
    });
    els.navList.querySelector('[data-view="overview"]').addEventListener('click', () => setView('overview'));
  }

  function updateNavActive() {
    document.querySelectorAll('.nav-item').forEach((btn) => {
      btn.classList.toggle('active', btn.dataset.view === state.viewId);
    });
  }

  // ---------------------------------------------------------------------
  // View rendering
  // ---------------------------------------------------------------------
  function setView(viewId) {
    state.viewId = viewId;
    state.hoverEntity = null;
    state.hoverField = null;
    render();
    updateNavActive();
  }

  function getViewIndex(viewId) {
    return ERD_VIEWS.findIndex((v) => v.id === viewId);
  }

  function goPrev() {
    if (state.viewId === 'overview') return;
    const idx = getViewIndex(state.viewId);
    if (idx <= 0) {
      setView('overview');
    } else {
      setView(ERD_VIEWS[idx - 1].id);
    }
  }

  function goNext() {
    if (state.viewId === 'overview') {
      setView(ERD_VIEWS[0].id);
      return;
    }
    const idx = getViewIndex(state.viewId);
    if (idx >= 0 && idx < ERD_VIEWS.length - 1) {
      setView(ERD_VIEWS[idx + 1].id);
    }
  }

  function render() {
    if (state.viewId === 'overview') {
      renderOverview();
      els.groupTitle.textContent = 'OVERVIEW';
      els.ssGroupTitle.textContent = 'OVERVIEW';
    } else {
      const view = ERD_VIEWS.find((v) => v.id === state.viewId);
      renderGroupView(view);
      els.groupTitle.textContent = 'Group ' + view.code + ' — ' + view.title;
      els.ssGroupTitle.textContent = 'Group ' + view.code + ' — ' + view.title;
    }
  }

  function renderOverview() {
    els.canvasStage.style.width = '';
    els.canvasStage.style.height = '';
    els.canvasStage.style.transform = 'none';
    const grid = document.createElement('div');
    grid.className = 'overview-grid';
    ERD_VIEWS.forEach((v) => {
      const tile = document.createElement('button');
      tile.className = 'overview-tile';
      const entityNames = v.entities.map((key) => entityByKey.get(key).tenHienThi);
      tile.innerHTML =
        '<div class="tile-code">GROUP ' + v.code + '</div>' +
        '<div class="tile-title">' + v.title + '</div>' +
        '<div class="tile-entities">' + entityNames.join(' · ') + '</div>';
      tile.addEventListener('click', () => setView(v.id));
      grid.appendChild(tile);
    });
    els.canvasStage.innerHTML = '';
    els.canvasStage.appendChild(grid);
  }

  function badgeHtml(field) {
    let out = '';
    if (field.pk) out += '<span class="badge pk">PK</span>';
    if (field.fk) out += '<span class="badge fk">FK</span>';
    else if (field.fkLogic) out += '<span class="badge fk-logic" title="Logical FK — no real connector drawn">FK*</span>';
    if (field.unique && !field.pk) out += '<span class="badge uq">UQ</span>';
    if (field.nullable) out += '<span class="badge nullable">NULL</span>';
    return out;
  }

  function fkTargetLabel(field) {
    if (!field.fk || !field.thamChieu) return '';
    const parts = field.thamChieu.split('.');
    const targetEntity = entityByKey.get(parts[0]);
    if (!targetEntity) return '';
    const targetField = allFields(targetEntity).find((f) => f.columnKey === parts[1]);
    return targetEntity.tenHienThi + '.' + (targetField ? targetField.tenHienThi : parts[1]);
  }

  // ---------------------------------------------------------------------
  // Manual layout overrides (drag-to-reposition), persisted per view.
  // ---------------------------------------------------------------------
  function layoutStorageKey(viewId) {
    return 'erd-layout-' + viewId;
  }

  function loadLayoutOverrides(viewId) {
    try {
      const raw = localStorage.getItem(layoutStorageKey(viewId));
      return raw ? JSON.parse(raw) : {};
    } catch (e) {
      return {};
    }
  }

  function saveLayoutOverride(viewId, entityKey, x, y) {
    const overrides = loadLayoutOverrides(viewId);
    overrides[entityKey] = { x: x, y: y };
    try {
      localStorage.setItem(layoutStorageKey(viewId), JSON.stringify(overrides));
    } catch (e) {
      /* ignore quota errors */
    }
  }

  function resetLayoutOverrides(viewId) {
    try {
      localStorage.removeItem(layoutStorageKey(viewId));
    } catch (e) {
      /* ignore */
    }
  }

  function makeCardDraggable(card, view, entityKey) {
    const header = card.querySelector('.entity-header');
    header.classList.add('draggable-handle');
    let dragging = false;
    let startPointer = { x: 0, y: 0 };
    let startPos = { x: 0, y: 0 };

    header.addEventListener('pointerdown', (e) => {
      if (e.button !== 0) return;
      dragging = true;
      card.classList.add('dragging');
      startPointer = { x: e.clientX, y: e.clientY };
      startPos = { x: parseFloat(card.style.left) || 0, y: parseFloat(card.style.top) || 0 };
      header.setPointerCapture(e.pointerId);
      e.preventDefault();
    });

    header.addEventListener('pointermove', (e) => {
      if (!dragging) return;
      const dx = (e.clientX - startPointer.x) / state.zoom;
      const dy = (e.clientY - startPointer.y) / state.zoom;
      const newX = Math.max(0, startPos.x + dx);
      const newY = Math.max(0, startPos.y + dy);
      card.style.left = newX + 'px';
      card.style.top = newY + 'px';
      recomputeConnectors();
    });

    function endDrag(e) {
      if (!dragging) return;
      dragging = false;
      card.classList.remove('dragging');
      const x = parseFloat(card.style.left) || 0;
      const y = parseFloat(card.style.top) || 0;
      saveLayoutOverride(view.id, entityKey, x, y);
      recomputeConnectors();
    }
    header.addEventListener('pointerup', endDrag);
    header.addEventListener('pointercancel', endDrag);
  }

  function renderGroupView(view) {
    els.canvasStage.innerHTML = '';
    const viewEntitySet = new Set(view.entities);
    const layoutOverrides = loadLayoutOverrides(view.id);
    const showExtended = state.extendedColumns && !state.screenshotMode;

    els.canvasStage.style.width = view.canvas.w + 'px';
    els.canvasStage.style.height = view.canvas.h + 'px';

    const svgNS = 'http://www.w3.org/2000/svg';
    const svg = document.createElementNS(svgNS, 'svg');
    svg.setAttribute('class', 'relation-layer');
    svg.setAttribute('width', view.canvas.w);
    svg.setAttribute('height', view.canvas.h);
    svg.setAttribute('viewBox', '0 0 ' + view.canvas.w + ' ' + view.canvas.h);

    const defs = document.createElementNS(svgNS, 'defs');
    const marker = document.createElementNS(svgNS, 'marker');
    marker.setAttribute('id', 'arrowhead-' + view.id);
    marker.setAttribute('markerWidth', '8');
    marker.setAttribute('markerHeight', '8');
    marker.setAttribute('refX', '6');
    marker.setAttribute('refY', '3');
    marker.setAttribute('orient', 'auto');
    const arrowPath = document.createElementNS(svgNS, 'path');
    arrowPath.setAttribute('d', 'M0,0 L6,3 L0,6 Z');
    arrowPath.setAttribute('class', 'relation-arrow');
    marker.appendChild(arrowPath);
    defs.appendChild(marker);
    svg.appendChild(defs);

    els.canvasStage.appendChild(svg);

    // Render entity cards.
    const cardEls = {};
    view.entities.forEach((entityKey) => {
      const entity = entityByKey.get(entityKey);
      const basePos = view.layout[entityKey] || { x: 40, y: 40 };
      const override = layoutOverrides[entityKey];
      const pos = override ? { x: override.x, y: override.y } : basePos;
      const fields = visibleFields(entity, showExtended);

      const card = document.createElement('div');
      card.className = 'entity-card';
      card.style.left = pos.x + 'px';
      card.style.top = pos.y + 'px';
      card.dataset.entity = entityKey;

      const header = document.createElement('div');
      header.className = 'entity-header';
      header.innerHTML =
        '<span>' + entity.tenHienThi + '</span><span class="entity-badge">' + fields.length + ' cols</span>';
      card.appendChild(header);

      if (entity.ghiChu) {
        const purposeEl = document.createElement('div');
        purposeEl.className = 'entity-purpose';
        purposeEl.textContent = entity.ghiChu;
        card.appendChild(purposeEl);
      }

      fields.forEach((field) => {
        const row = document.createElement('div');
        row.className = 'field-row' + (field.fk ? ' fk-row' : '') + (allFields(entity).indexOf(field) >= (entity.cotChinh || []).length ? ' extended-row' : '');
        row.dataset.field = field.columnKey;
        row.dataset.entity = entityKey;
        row.tabIndex = 0;
        row.setAttribute('role', 'button');
        const target = fkTargetLabel(field);
        row.setAttribute(
          'aria-label',
          field.tenHienThi + ' ' + field.kieu + (field.fk ? ' — khóa ngoại tham chiếu tới ' + target : '')
        );
        const roleLabel = field.vaiTro ? '<span class="field-role">' + field.vaiTro + '</span>' : '';
        row.innerHTML =
          '<span class="field-name">' + field.tenHienThi + roleLabel + '</span>' +
          '<span class="field-meta">' + badgeHtml(field) + '<span class="field-type">' + field.kieu + '</span></span>';
        row.addEventListener('mouseenter', () => {
          state.hoverField = { entity: entityKey, field: field.columnKey };
          state.hoverEntity = null;
          applyHighlight(view);
        });
        row.addEventListener('mouseleave', () => {
          state.hoverField = null;
          applyHighlight(view);
        });
        row.addEventListener('focus', () => {
          state.hoverField = { entity: entityKey, field: field.columnKey };
          applyHighlight(view);
        });
        row.addEventListener('blur', () => {
          state.hoverField = null;
          applyHighlight(view);
        });
        card.appendChild(row);
      });

      card.addEventListener('mouseenter', () => {
        if (!state.hoverField) {
          state.hoverEntity = entityKey;
          applyHighlight(view);
        }
      });
      card.addEventListener('mouseleave', () => {
        state.hoverEntity = null;
        applyHighlight(view);
      });

      els.canvasStage.appendChild(card);
      cardEls[entityKey] = card;
      makeCardDraggable(card, view, entityKey);
    });

    // Compute relationships relevant to this view only (both ends present).
    const viewRels = ALL_RELATIONSHIPS.filter(
      (r) => viewEntitySet.has(r.fromEntity) && viewEntitySet.has(r.toEntity)
    );

    requestAnimationFrame(() => drawConnectors(view, svg, cardEls, viewRels));
    // store for resize/zoom recompute
    els.canvasStage._lastView = view;
    els.canvasStage._lastCardEls = cardEls;
    els.canvasStage._lastRels = viewRels;
    els.canvasStage._lastSvg = svg;
  }

  function fieldRowCenter(cardEl, fieldKey, stageRect) {
    const row = cardEl.querySelector('.field-row[data-field="' + CSS.escape(fieldKey) + '"]');
    const target = row || cardEl.querySelector('.entity-header');
    const r = target.getBoundingClientRect();
    return {
      top: r.top - stageRect.top,
      bottom: r.bottom - stageRect.top,
      left: r.left - stageRect.left,
      right: r.right - stageRect.left,
      midY: r.top - stageRect.top + r.height / 2,
    };
  }

  function cardinalityLabel(rel, isSourceEnd) {
    if (isSourceEnd) {
      if (rel.oneToOne) return rel.nullable ? '0..1' : '1';
      return 'N';
    }
    return '1';
  }

  function drawConnectors(view, svg, cardEls, viewRels) {
    // clear previous paths (keep defs)
    Array.from(svg.querySelectorAll('.relation-path, .relation-label, .relation-hit')).forEach((n) => n.remove());
    const stageRect = els.canvasStage.getBoundingClientRect();
    const svgNS = 'http://www.w3.org/2000/svg';

    viewRels.forEach((rel) => {
      const srcCard = cardEls[rel.fromEntity];
      const dstCard = cardEls[rel.toEntity];
      if (!srcCard || !dstCard) return;
      // A card may be showing collapsed columns — if the field row for this
      // relation isn't currently rendered (e.g. it lives in cotMoRong and
      // extended columns are off), fall back to the header anchor, which
      // fieldRowCenter already does.

      if (rel.selfRef) {
        // short loop beside the card
        const srcInfo = fieldRowCenter(srcCard, rel.fromField, stageRect);
        const dstInfo = fieldRowCenter(dstCard, rel.toField, stageRect);
        const loopX = srcInfo.right + 46;
        const d =
          'M' + srcInfo.right + ',' + srcInfo.midY +
          ' H' + loopX +
          ' V' + dstInfo.midY +
          ' H' + dstInfo.right;
        const path = document.createElementNS(svgNS, 'path');
        path.setAttribute('d', d);
        path.setAttribute('class', 'relation-path');
        path.dataset.from = rel.fromEntity;
        path.dataset.to = rel.toEntity;
        path.dataset.fromField = rel.fromField;
        path.dataset.toField = rel.toField;
        path.setAttribute('marker-end', 'url(#arrowhead-' + view.id + ')');
        svg.appendChild(path);

        const label = document.createElementNS(svgNS, 'text');
        label.setAttribute('x', loopX + 4);
        label.setAttribute('y', (srcInfo.midY + dstInfo.midY) / 2);
        label.setAttribute('class', 'relation-label');
        label.dataset.from = rel.fromEntity;
        label.dataset.to = rel.toEntity;
        label.textContent = 'tự tham chiếu 0..1 : 1' + (rel.vaiTro ? ' (' + rel.vaiTro + ')' : '');
        svg.appendChild(label);
        return;
      }

      const srcInfo = fieldRowCenter(srcCard, rel.fromField, stageRect);
      const dstInfo = fieldRowCenter(dstCard, rel.toField, stageRect);

      const srcOnLeft = srcInfo.left < dstInfo.left;
      const x1 = srcOnLeft ? srcInfo.right : srcInfo.left;
      const y1 = srcInfo.midY;
      const x2 = srcOnLeft ? dstInfo.left : dstInfo.right;
      const y2 = dstInfo.midY;
      const midX = (x1 + x2) / 2;

      const d = 'M' + x1 + ',' + y1 + ' H' + midX + ' V' + y2 + ' H' + x2;

      const path = document.createElementNS(svgNS, 'path');
      path.setAttribute('d', d);
      path.setAttribute('class', 'relation-path');
      path.dataset.from = rel.fromEntity;
      path.dataset.to = rel.toEntity;
      path.dataset.fromField = rel.fromField;
      path.dataset.toField = rel.toField;
      path.setAttribute('marker-end', 'url(#arrowhead-' + view.id + ')');
      svg.appendChild(path);

      const srcLabelText = cardinalityLabel(rel, true) + (rel.vaiTro ? ' · ' + rel.vaiTro : '');
      const srcLabel = document.createElementNS(svgNS, 'text');
      srcLabel.setAttribute('x', x1 + (srcOnLeft ? 6 : -18));
      srcLabel.setAttribute('y', y1 - 4);
      srcLabel.setAttribute('class', 'relation-label');
      srcLabel.dataset.from = rel.fromEntity;
      srcLabel.dataset.to = rel.toEntity;
      srcLabel.textContent = srcLabelText;
      svg.appendChild(srcLabel);

      const dstLabel = document.createElementNS(svgNS, 'text');
      dstLabel.setAttribute('x', x2 + (srcOnLeft ? -18 : 6));
      dstLabel.setAttribute('y', y2 - 4);
      dstLabel.setAttribute('class', 'relation-label');
      dstLabel.dataset.from = rel.fromEntity;
      dstLabel.dataset.to = rel.toEntity;
      dstLabel.textContent = cardinalityLabel(rel, false);
      svg.appendChild(dstLabel);
    });

    applyHighlight(view);
  }

  function applyHighlight(view) {
    const cardEls = els.canvasStage._lastCardEls;
    const svg = els.canvasStage._lastSvg;
    if (!cardEls || !svg) return;

    const activeEntity = state.hoverField ? state.hoverField.entity : state.hoverEntity;
    if (!activeEntity) {
      Object.values(cardEls).forEach((c) => c.classList.remove('dimmed', 'highlighted'));
      svg.querySelectorAll('.relation-path, .relation-label').forEach((p) => p.classList.remove('dimmed', 'highlighted'));
      return;
    }

    const rels = els.canvasStage._lastRels || [];
    let related;
    if (state.hoverField) {
      related = rels.filter(
        (r) =>
          (r.fromEntity === state.hoverField.entity && r.fromField === state.hoverField.field) ||
          (r.toEntity === state.hoverField.entity && r.toField === state.hoverField.field)
      );
    } else {
      related = rels.filter((r) => r.fromEntity === activeEntity || r.toEntity === activeEntity);
    }
    const relatedEntities = new Set([activeEntity]);
    related.forEach((r) => {
      relatedEntities.add(r.fromEntity);
      relatedEntities.add(r.toEntity);
    });

    Object.entries(cardEls).forEach(([name, card]) => {
      card.classList.toggle('dimmed', !relatedEntities.has(name));
      card.classList.toggle('highlighted', name === activeEntity);
    });

    svg.querySelectorAll('.relation-path, .relation-label').forEach((p) => {
      const isRelated = related.some(
        (r) =>
          r.fromEntity === p.dataset.from &&
          r.toEntity === p.dataset.to &&
          (!state.hoverField ||
            ((p.dataset.fromField === state.hoverField.field && p.dataset.from === state.hoverField.entity) ||
              (p.dataset.toField === state.hoverField.field && p.dataset.to === state.hoverField.entity)))
      );
      p.classList.toggle('highlighted', isRelated);
      p.classList.toggle('dimmed', !isRelated);
    });
  }

  // ---------------------------------------------------------------------
  // Zoom / fit
  // ---------------------------------------------------------------------
  function applyZoom() {
    els.canvasStage.style.transform = 'scale(' + state.zoom + ')';
    els.zoomReadout.textContent = Math.round(state.zoom * 100) + '%';
    recomputeConnectors();
  }

  function setZoom(z) {
    state.zoom = Math.min(2.5, Math.max(0.3, z));
    applyZoom();
  }

  function fitToCanvas() {
    if (state.viewId === 'overview') return;
    const view = ERD_VIEWS.find((v) => v.id === state.viewId);
    const vpRect = els.canvasViewport.getBoundingClientRect();
    const scaleX = (vpRect.width - 32) / view.canvas.w;
    const scaleY = (vpRect.height - 32) / view.canvas.h;
    setZoom(Math.min(scaleX, scaleY, 1.5));
  }

  function recomputeConnectors() {
    const view = els.canvasStage._lastView;
    const svg = els.canvasStage._lastSvg;
    const cardEls = els.canvasStage._lastCardEls;
    const rels = els.canvasStage._lastRels;
    if (view && svg && cardEls) {
      requestAnimationFrame(() => drawConnectors(view, svg, cardEls, rels));
    }
  }

  // ---------------------------------------------------------------------
  // Screenshot mode — forces extended columns off while active.
  // ---------------------------------------------------------------------
  function setScreenshotMode(on) {
    state.screenshotMode = on;
    document.body.classList.toggle('screenshot-mode', on);
    els.screenshotToggle.setAttribute('aria-pressed', String(on));
    if (els.extendedToggle) {
      els.extendedToggle.setAttribute('aria-pressed', String(state.extendedColumns && !on));
      els.extendedToggle.disabled = on;
    }
    render();
  }

  // ---------------------------------------------------------------------
  // Extended columns toggle ("Xem cột mở rộng")
  // ---------------------------------------------------------------------
  function setExtendedColumns(on) {
    if (state.screenshotMode) return; // forced off while screenshot mode is active
    state.extendedColumns = on;
    if (els.extendedToggle) {
      els.extendedToggle.setAttribute('aria-pressed', String(on));
    }
    render();
  }

  // ---------------------------------------------------------------------
  // Search — matches Vietnamese display name AND physical table name.
  // ---------------------------------------------------------------------
  function handleSearch(term) {
    state.searchTerm = term.trim().toLowerCase();
    if (!state.searchTerm) return;
    const match = ERD_VIEWS.find((v) =>
      v.entities.some((key) => {
        const entity = entityByKey.get(key);
        return (
          entity.tenHienThi.toLowerCase().includes(state.searchTerm) ||
          entity.tenVatLy.toLowerCase().includes(state.searchTerm) ||
          entity.tableKey.toLowerCase().includes(state.searchTerm)
        );
      })
    );
    if (match) setView(match.id);
  }

  // ---------------------------------------------------------------------
  // Keyboard nav
  // ---------------------------------------------------------------------
  function handleKeydown(e) {
    const tag = (e.target && e.target.tagName) || '';
    if (tag === 'INPUT' || tag === 'TEXTAREA') return;
    if (e.key === 'ArrowLeft') { goPrev(); }
    else if (e.key === 'ArrowRight') { goNext(); }
    else if (e.key === 's' || e.key === 'S') { setScreenshotMode(!state.screenshotMode); }
    else if (e.key === 'e' || e.key === 'E') { setExtendedColumns(!state.extendedColumns); }
    else if (e.key === '0') { fitToCanvas(); }
  }

  // ---------------------------------------------------------------------
  // Wire up
  // ---------------------------------------------------------------------
  function init() {
    buildNav();
    updateNavActive();
    render();

    document.getElementById('prevBtn').addEventListener('click', goPrev);
    document.getElementById('nextBtn').addEventListener('click', goNext);
    document.getElementById('zoomIn').addEventListener('click', () => setZoom(state.zoom + 0.1));
    document.getElementById('zoomOut').addEventListener('click', () => setZoom(state.zoom - 0.1));
    document.getElementById('fitBtn').addEventListener('click', fitToCanvas);
    document.getElementById('resetZoomBtn').addEventListener('click', () => setZoom(1));
    document.getElementById('resetLayoutBtn').addEventListener('click', () => {
      if (state.viewId === 'overview') return;
      resetLayoutOverrides(state.viewId);
      render();
    });
    els.screenshotToggle.addEventListener('click', () => setScreenshotMode(!state.screenshotMode));
    if (els.extendedToggle) {
      els.extendedToggle.addEventListener('click', () => setExtendedColumns(!state.extendedColumns));
    }
    els.tableSearch.addEventListener('input', (e) => handleSearch(e.target.value));

    document.addEventListener('keydown', handleKeydown);

    if (window.ResizeObserver) {
      const ro = new ResizeObserver(() => recomputeConnectors());
      ro.observe(els.canvasViewport);
    } else {
      window.addEventListener('resize', recomputeConnectors);
    }

    applyZoom();
  }

  document.addEventListener('DOMContentLoaded', init);
})();
