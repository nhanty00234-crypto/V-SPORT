/* =============================================================
   V-SPORT · home-commerce.js  — loaded defer in index.jsp
   ============================================================= */

'use strict';

/* ── Utility ────────────────────────────────────────────── */
const qs  = (s, root = document) => root.querySelector(s);
const qsa = (s, root = document) => [...root.querySelectorAll(s)];

/* ══════════════════════════════════════════════════════════
   ANNOUNCEMENT BAR
   ══════════════════════════════════════════════════════════ */
function initAnnBar() {
  const bar = qs('.vs-ann-bar');
  if (!bar) return;

  if (sessionStorage.getItem('vsAnnClosed')) {
    bar.remove();
    return;
  }

  const msgs = qsa('.vs-ann-bar__msg', bar);
  if (!msgs.length) return;

  let cur = 0;
  msgs[0].classList.add('is-active');

  if (msgs.length > 1) {
    setInterval(() => {
      msgs[cur].classList.remove('is-active');
      msgs[cur].classList.add('is-leaving');
      const prev = cur;
      cur = (cur + 1) % msgs.length;
      msgs[cur].classList.add('is-active');
      setTimeout(() => msgs[prev].classList.remove('is-leaving'), 400);
    }, 4500);
  }

  const closeBtn = qs('.vs-ann-bar__close', bar);
  if (closeBtn) {
    closeBtn.addEventListener('click', () => {
      bar.style.maxHeight = bar.offsetHeight + 'px';
      requestAnimationFrame(() => {
        bar.style.transition = 'max-height .3s, opacity .3s';
        bar.style.maxHeight = '0';
        bar.style.opacity = '0';
        bar.style.overflow = 'hidden';
      });
      setTimeout(() => bar.remove(), 320);
      sessionStorage.setItem('vsAnnClosed', '1');
    });
  }
}

/* ══════════════════════════════════════════════════════════
   STICKY HEADER
   ══════════════════════════════════════════════════════════ */
function initStickyHeader() {
  const wrap = qs('.vs-header-wrap');
  if (!wrap) return;

  let ticking = false;
  window.addEventListener('scroll', () => {
    if (!ticking) {
      requestAnimationFrame(() => {
        wrap.classList.toggle('is-scrolled', window.scrollY > 20);
        ticking = false;
      });
      ticking = true;
    }
  }, { passive: true });
}

/* ══════════════════════════════════════════════════════════
   NAV ACTIVE LINK
   ══════════════════════════════════════════════════════════ */
function initNavActive() {
  const path = location.pathname;

  function shouldBeActive(href) {
    if (!href || href === '#') return false;
    const clean = href.replace(/^.*contextPath\}/, '');
    // Skip root/home href (e.g. "/Backend_java/" or "/") — would match every URL
    const segments = clean.replace(/^\//, '').split('/').filter(Boolean);
    if (segments.length <= 1) return false;
    return path.includes(clean);
  }

  qsa('.vs-nav__link').forEach(a => {
    if (shouldBeActive(a.getAttribute('href'))) a.classList.add('is-active');
  });
  qsa('.vs-mob-nav a').forEach(a => {
    if (shouldBeActive(a.getAttribute('href'))) a.classList.add('is-active');
  });
}

/* ══════════════════════════════════════════════════════════
   MEGA MENU (keyboard nav)
   ══════════════════════════════════════════════════════════ */
function initMegaMenu() {
  qsa('.vs-nav__item').forEach(item => {
    const link = qs('.vs-nav__link', item);
    const menu = qs('.vs-mega-menu', item);
    if (!menu) return;

    link.setAttribute('aria-haspopup', 'true');
    link.setAttribute('aria-expanded', 'false');

    item.addEventListener('mouseenter', () => link.setAttribute('aria-expanded', 'true'));
    item.addEventListener('mouseleave', () => link.setAttribute('aria-expanded', 'false'));

    link.addEventListener('keydown', e => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        const open = item.classList.toggle('is-open');
        link.setAttribute('aria-expanded', open ? 'true' : 'false');
        if (open) qs('a', menu)?.focus();
      }
      if (e.key === 'Escape') {
        item.classList.remove('is-open');
        link.setAttribute('aria-expanded', 'false');
        link.focus();
      }
    });

    document.addEventListener('click', e => {
      if (!item.contains(e.target)) {
        item.classList.remove('is-open');
        link.setAttribute('aria-expanded', 'false');
      }
    });
  });
}

/* ══════════════════════════════════════════════════════════
   MOBILE NAV DRAWER
   ══════════════════════════════════════════════════════════ */
function initMobileNav() {
  const hamburger = qs('.vs-hamburger');
  const drawer    = qs('.vs-mob-drawer');
  const overlay   = qs('.vs-mob-overlay');
  const closeBtn  = qs('.vs-mob-drawer__close');
  if (!hamburger || !drawer) return;

  function openDrawer() {
    drawer.classList.add('is-open');
    overlay?.classList.add('is-open');
    document.body.classList.add('vs-scroll-locked');
    closeBtn?.focus();
  }
  function closeDrawer() {
    drawer.classList.remove('is-open');
    overlay?.classList.remove('is-open');
    document.body.classList.remove('vs-scroll-locked');
    hamburger.focus();
  }

  hamburger.addEventListener('click', openDrawer);
  closeBtn?.addEventListener('click', closeDrawer);
  overlay?.addEventListener('click', closeDrawer);

  drawer.addEventListener('keydown', e => {
    if (e.key === 'Escape') closeDrawer();
  });
}

/* ══════════════════════════════════════════════════════════
   MOBILE SEARCH OVERLAY
   ══════════════════════════════════════════════════════════ */
function initMobileSearch() {
  const searchToggle = qs('.vs-hdr-search');
  const overlay      = qs('.vs-mob-search');
  const closeBtn     = qs('.vs-mob-search__close');
  if (!searchToggle || !overlay) return;

  searchToggle.addEventListener('click', () => {
    overlay.classList.add('is-open');
    qs('input', overlay)?.focus();
  });
  closeBtn?.addEventListener('click', () => overlay.classList.remove('is-open'));
  overlay.addEventListener('keydown', e => { if (e.key === 'Escape') overlay.classList.remove('is-open'); });
}

/* ══════════════════════════════════════════════════════════
   CART DRAWER
   ══════════════════════════════════════════════════════════ */
function initCartDrawer() {
  const cartIcon  = qs('.vs-hdr-cart');
  const drawer    = qs('.vs-cart-drawer');
  const overlay   = qs('.vs-cart-overlay');
  const closeBtn  = qs('.vs-cart-drawer__close');
  if (!cartIcon || !drawer) return;

  function openCart() {
    drawer.classList.add('is-open');
    overlay?.classList.add('is-open');
    document.body.classList.add('vs-scroll-locked');
  }
  function closeCart() {
    drawer.classList.remove('is-open');
    overlay?.classList.remove('is-open');
    document.body.classList.remove('vs-scroll-locked');
  }

  cartIcon.addEventListener('click', e => { e.preventDefault(); openCart(); });
  closeBtn?.addEventListener('click', closeCart);
  overlay?.addEventListener('click', closeCart);
}

/* ══════════════════════════════════════════════════════════
   HERO SLIDER
   ══════════════════════════════════════════════════════════ */
function initHeroSlider() {
  const hero   = qs('.vs-hero');
  if (!hero) return;

  const track  = qs('.vs-hero__track', hero);
  const slides = qsa('.vs-slide', hero);
  const dots   = qsa('.vs-hero__dot', hero);
  const arrowL = qs('.vs-hero__arrow--l', hero);
  const arrowR = qs('.vs-hero__arrow--r', hero);
  if (!slides.length) return;

  let current = 0;
  let timer   = null;
  let startX  = 0;
  let isDrag  = false;

  function goTo(idx) {
    slides[current].classList.remove('is-active');
    dots[current]?.classList.remove('is-active');
    current = (idx + slides.length) % slides.length;
    slides[current].classList.add('is-active');
    dots[current]?.classList.add('is-active');
    track.style.transform = `translateX(-${current * 100}%)`;
  }

  function startAuto() {
    clearInterval(timer);
    timer = setInterval(() => goTo(current + 1), 6500);
  }

  goTo(0);
  startAuto();

  arrowL?.addEventListener('click', () => { goTo(current - 1); startAuto(); });
  arrowR?.addEventListener('click', () => { goTo(current + 1); startAuto(); });
  dots.forEach((d, i) => d.addEventListener('click', () => { goTo(i); startAuto(); }));

  hero.addEventListener('mouseenter', () => clearInterval(timer));
  hero.addEventListener('mouseleave', startAuto);

  /* Keyboard */
  hero.setAttribute('tabindex', '0');
  hero.addEventListener('keydown', e => {
    if (e.key === 'ArrowLeft')  { goTo(current - 1); startAuto(); }
    if (e.key === 'ArrowRight') { goTo(current + 1); startAuto(); }
  });

  /* Touch / drag */
  function onStart(x) { startX = x; isDrag = false; }
  function onMove(x)  { if (Math.abs(x - startX) > 8) isDrag = true; }
  function onEnd(x) {
    if (!isDrag) return;
    const dx = x - startX;
    if (dx < -40)      { goTo(current + 1); startAuto(); }
    else if (dx > 40)  { goTo(current - 1); startAuto(); }
  }

  hero.addEventListener('touchstart', e => onStart(e.touches[0].clientX), { passive: true });
  hero.addEventListener('touchmove',  e => onMove(e.touches[0].clientX),  { passive: true });
  hero.addEventListener('touchend',   e => onEnd(e.changedTouches[0].clientX));
  hero.addEventListener('mousedown',  e => { onStart(e.clientX); hero.style.cursor = 'grabbing'; });
  hero.addEventListener('mousemove',  e => { if (e.buttons) onMove(e.clientX); });
  hero.addEventListener('mouseup',    e => { onEnd(e.clientX); hero.style.cursor = ''; });
}

/* ══════════════════════════════════════════════════════════
   PRODUCT TABS
   ══════════════════════════════════════════════════════════ */
function initProductTabs() {
  const pills = qsa('.vs-pill[data-tab]');
  const grids = qsa('.vs-tab-panel');
  if (!pills.length) return;

  pills.forEach(pill => {
    pill.addEventListener('click', () => {
      pills.forEach(p => p.classList.remove('is-active'));
      pill.classList.add('is-active');
      const target = pill.dataset.tab;
      grids.forEach(g => {
        g.hidden = g.dataset.panel !== target;
      });
    });
  });
}

/* ══════════════════════════════════════════════════════════
   CATEGORY SIDEBAR
   ══════════════════════════════════════════════════════════ */
function initCategorySection() {
  const items  = qsa('.vs-cat-item');
  const images = qsa('.vs-cat-panel__img');
  if (!items.length) return;

  function activate(item) {
    items.forEach(i => i.classList.remove('is-active'));
    item.classList.add('is-active');
    const target = item.dataset.cat;
    images.forEach(img => {
      img.classList.toggle('is-visible', img.dataset.cat === target);
    });
    // update overlay text
    const overlay = qs('.vs-cat-panel__overlay');
    if (overlay) {
      const titleEl = qs('.vs-cat-panel__title', overlay);
      const subEl   = qs('.vs-cat-panel__sub', overlay);
      const btnEl   = qs('.vs-cat-panel__btn', overlay);
      if (titleEl) titleEl.textContent = item.dataset.title || '';
      if (subEl)   subEl.textContent   = item.dataset.sub   || '';
      if (btnEl)   btnEl.href          = item.dataset.link  || '#';
    }
  }

  items.forEach(item => {
    item.addEventListener('mouseenter', () => activate(item));
    item.addEventListener('click', () => activate(item));
  });

  // activate first
  if (items[0]) activate(items[0]);
}

/* ══════════════════════════════════════════════════════════
   HOW IT WORKS
   ══════════════════════════════════════════════════════════ */
function initHowItWorks() {
  const steps  = qsa('.vs-howto-step');
  const images = qsa('.vs-howto-img-wrap img');
  if (!steps.length) return;

  function activate(step) {
    steps.forEach(s => s.classList.remove('is-active'));
    step.classList.add('is-active');
    const target = step.dataset.step;
    images.forEach(img => {
      img.classList.toggle('is-visible', img.dataset.step === target);
    });
  }

  steps.forEach(step => {
    step.addEventListener('click', () => activate(step));
    step.addEventListener('mouseenter', () => activate(step));
  });

  if (steps[0]) activate(steps[0]);
}

/* ══════════════════════════════════════════════════════════
   COURT CAROUSEL (drag)
   ══════════════════════════════════════════════════════════ */
function initCarousel() {
  const carousel = qs('.vs-carousel');
  const arrowL   = qs('.vs-c-arrow--l');
  const arrowR   = qs('.vs-c-arrow--r');
  if (!carousel) return;

  let startX = 0, startScroll = 0, isDragging = false;

  carousel.addEventListener('mousedown', e => {
    isDragging = true;
    startX = e.pageX;
    startScroll = carousel.scrollLeft;
    carousel.style.userSelect = 'none';
  });
  document.addEventListener('mousemove', e => {
    if (!isDragging) return;
    carousel.scrollLeft = startScroll - (e.pageX - startX);
  });
  document.addEventListener('mouseup', () => {
    isDragging = false;
    carousel.style.userSelect = '';
  });

  function scrollBy(dir) {
    const card = qs('.vs-court-card', carousel) || qs('.vs-blog-card', carousel);
    const step = card ? card.offsetWidth + 20 : 290;
    carousel.scrollBy({ left: dir * step, behavior: 'smooth' });
  }

  arrowL?.addEventListener('click', () => scrollBy(-1));
  arrowR?.addEventListener('click', () => scrollBy(1));
}

/* ══════════════════════════════════════════════════════════
   SCROLL REVEAL
   ══════════════════════════════════════════════════════════ */
function initScrollReveal() {
  const els = qsa('.vs-reveal');
  if (!els.length) return;

  if (!('IntersectionObserver' in window)) {
    els.forEach(el => el.classList.add('is-visible'));
    return;
  }

  const obs = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible');
        obs.unobserve(entry.target);
      }
    });
  }, { threshold: 0.14, rootMargin: '0px 0px -40px 0px' });

  els.forEach(el => obs.observe(el));
}

/* ══════════════════════════════════════════════════════════
   SCROLL-TO-TOP with SVG progress
   ══════════════════════════════════════════════════════════ */
function initScrollTop() {
  const btn  = qs('.vs-scroll-top');
  const ring = qs('.vs-scroll-top__progress', btn);
  if (!btn) return;

  const C = 131; // ≈ 2π × 20.8  (circumference for r=20.8)

  window.addEventListener('scroll', () => {
    const max     = document.documentElement.scrollHeight - window.innerHeight;
    const pct     = max > 0 ? Math.min(window.scrollY / max, 1) : 0;
    const visible = window.scrollY > 300;

    btn.classList.toggle('is-visible', visible);
    if (ring) ring.style.strokeDashoffset = (C - C * pct).toFixed(2);
  }, { passive: true });

  btn.addEventListener('click', () => window.scrollTo({ top: 0, behavior: 'smooth' }));
}

/* ══════════════════════════════════════════════════════════
   NEWSLETTER
   ══════════════════════════════════════════════════════════ */
function initNewsletter() {
  const form = qs('.vs-nl-form');
  if (!form) return;

  form.addEventListener('submit', e => {
    e.preventDefault();
    const input = qs('input[type="email"]', form);
    const email = input?.value.trim();
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      input?.focus();
      return;
    }
    const btn = qs('button', form);
    if (btn) { btn.textContent = 'Đã đăng ký!'; btn.disabled = true; }
    setTimeout(() => {
      if (btn) { btn.textContent = 'Đăng ký'; btn.disabled = false; }
      if (input) input.value = '';
    }, 3500);
  });
}

/* ══════════════════════════════════════════════════════════
   BOOTSTRAP
   ══════════════════════════════════════════════════════════ */
function init() {
  initAnnBar();
  initStickyHeader();
  initNavActive();
  initMegaMenu();
  initMobileNav();
  initMobileSearch();
  initCartDrawer();
  initHeroSlider();
  initProductTabs();
  initCategorySection();
  initHowItWorks();
  initCarousel();
  initScrollReveal();
  initScrollTop();
  initNewsletter();
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}
