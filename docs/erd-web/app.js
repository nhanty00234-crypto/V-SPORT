/* V-SPORT ERD — rendering engine. Pure vanilla JS, no dependencies.
 * Reads structured data from erd-data.js (ERD_ENTITIES, ERD_VIEWS) and
 * renders entity cards + orthogonal SVG connectors, derived purely from
 * field-level FK metadata.
 */
(function () {
  'use strict';

  const entityByName = new Map(ERD_ENTITIES.map((e) => [e.name, e]));

  // ---------------------------------------------------------------------
  // Derive all relationships once from field metadata (single source).
  // ---------------------------------------------------------------------
  function deriveRelationships() {
    const rels = [];
    ERD_ENTITIES.forEach((entity) => {
      entity.fields.forEach((field) => {
        if (!field.fk) return;
        const [targetEntity, targetField] = field.fk.split('.');
        if (!entityByName.has(targetEntity)) return;

        const isIdentifying = !!field.pk; // PK + FK => identifying one-to-one/junction
        const isOneToOne = isIdentifying || !!field.unique;
        const selfRef = targetEntity === entity.name && targetField !== field.name;

        rels.push({
          fromEntity: entity.name,
          fromField: field.name,
          toEntity: targetEntity,
          toField: targetField,
          oneToOne: isOneToOne,
          nullable: !!field.nullable,
          selfRef,
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
      btn.innerHTML = '<span class="nav-code">' + v.code + '</span>' + v.title;
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
      els.groupTitle.textContent = view.code + ' — ' + view.title;
      els.ssGroupTitle.textContent = view.code + ' — ' + view.title;
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
      tile.innerHTML =
        '<div class="tile-code">' + v.code + '</div>' +
        '<div class="tile-title">' + v.title + '</div>' +
        '<div class="tile-entities">' + v.entities.join(' · ') + '</div>';
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
    if (field.unique && !field.pk) out += '<span class="badge uq">UQ</span>';
    if (field.nullable) out += '<span class="badge nullable">NULL</span>';
    return out;
  }

  function isFieldRelevantCompact(entityName, field, viewEntitySet) {
    if (field.pk) return true;
    if (field.fk) {
      const [target] = field.fk.split('.');
      if (viewEntitySet.has(target)) return true;
    }
    // referenced by another entity in this view
    const referenced = ALL_RELATIONSHIPS.some(
      (r) => r.toEntity === entityName && r.toField === field.name && viewEntitySet.has(r.fromEntity)
    );
    return referenced;
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

  function saveLayoutOverride(viewId, entityName, x, y) {
    const overrides = loadLayoutOverrides(viewId);
    overrides[entityName] = { x: x, y: y };
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

  function makeCardDraggable(card, view, entityName) {
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
      saveLayoutOverride(view.id, entityName, x, y);
      recomputeConnectors();
    }
    header.addEventListener('pointerup', endDrag);
    header.addEventListener('pointercancel', endDrag);
  }

  function renderGroupView(view) {
    els.canvasStage.innerHTML = '';
    const viewEntitySet = new Set(view.entities);
    const layoutOverrides = loadLayoutOverrides(view.id);

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

    // Render entity cards
    const cardEls = {};
    view.entities.forEach((entityName) => {
      const entity = entityByName.get(entityName);
      const basePos = view.layout[entityName] || { x: 40, y: 40 };
      const override = layoutOverrides[entityName];
      const pos = override ? { x: override.x, y: override.y, compact: basePos.compact } : basePos;
      const compact = !!pos.compact;

      const card = document.createElement('div');
      card.className = 'entity-card' + (compact ? ' compact' : '');
      card.style.left = pos.x + 'px';
      card.style.top = pos.y + 'px';
      card.dataset.entity = entityName;

      const header = document.createElement('div');
      header.className = 'entity-header';
      header.innerHTML =
        '<span>' + entityName + '</span><span class="entity-badge">' + entity.fields.length + ' fields</span>';
      card.appendChild(header);

      const fields = compact
        ? entity.fields.filter((f) => isFieldRelevantCompact(entityName, f, viewEntitySet))
        : entity.fields;

      fields.forEach((field) => {
        const row = document.createElement('div');
        row.className = 'field-row' + (field.fk ? ' fk-row' : '');
        row.dataset.field = field.name;
        row.dataset.entity = entityName;
        row.tabIndex = 0;
        row.setAttribute('role', 'button');
        row.setAttribute(
          'aria-label',
          field.name + ' ' + field.type + (field.fk ? ' foreign key referencing ' + field.fk : '')
        );
        row.innerHTML =
          '<span class="field-name">' + field.name + '</span>' +
          '<span class="field-meta">' + badgeHtml(field) + '<span class="field-type">' + field.type + '</span></span>';
        row.addEventListener('mouseenter', () => {
          state.hoverField = { entity: entityName, field: field.name };
          state.hoverEntity = null;
          applyHighlight(view);
        });
        row.addEventListener('mouseleave', () => {
          state.hoverField = null;
          applyHighlight(view);
        });
        row.addEventListener('focus', () => {
          state.hoverField = { entity: entityName, field: field.name };
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
          state.hoverEntity = entityName;
          applyHighlight(view);
        }
      });
      card.addEventListener('mouseleave', () => {
        state.hoverEntity = null;
        applyHighlight(view);
      });

      els.canvasStage.appendChild(card);
      cardEls[entityName] = card;
      makeCardDraggable(card, view, entityName);
    });

    // Compute relationships relevant to this view
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

  function fieldRowCenter(cardEl, fieldName, stageRect) {
    const row = cardEl.querySelector('.field-row[data-field="' + CSS.escape(fieldName) + '"]');
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

    viewRels.forEach((rel, idx) => {
      const srcCard = cardEls[rel.fromEntity];
      const dstCard = cardEls[rel.toEntity];
      if (!srcCard || !dstCard) return;

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
        label.textContent = 'self 0..1 : 1';
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

      const srcLabel = document.createElementNS(svgNS, 'text');
      srcLabel.setAttribute('x', x1 + (srcOnLeft ? 6 : -18));
      srcLabel.setAttribute('y', y1 - 4);
      srcLabel.setAttribute('class', 'relation-label');
      srcLabel.dataset.from = rel.fromEntity;
      srcLabel.dataset.to = rel.toEntity;
      srcLabel.textContent = cardinalityLabel(rel, true);
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
  // Screenshot mode
  // ---------------------------------------------------------------------
  function setScreenshotMode(on) {
    state.screenshotMode = on;
    document.body.classList.toggle('screenshot-mode', on);
    els.screenshotToggle.setAttribute('aria-pressed', String(on));
    recomputeConnectors();
  }

  // ---------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------
  function handleSearch(term) {
    state.searchTerm = term.trim().toLowerCase();
    if (!state.searchTerm) return;
    const match = ERD_VIEWS.find((v) =>
      v.entities.some((en) => en.toLowerCase().includes(state.searchTerm))
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
    else if (e.key === '0') { setZoom(1); }
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
