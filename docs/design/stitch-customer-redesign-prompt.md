# V-SPORT — Customer App Full Redesign — Master Prompt for Google Stitch (v2)

## How to use this file (read this first — v1 failed because of these two mistakes)

1. **Paste ONE fenced block at a time into Stitch, in this order: Design System → Global Navigation → Trang chủ → Auth → then the remaining screens one by one.** Do not paste the whole file in one shot — that is why v1 only rendered a hero fragment for the home page and produced a generic, thin result everywhere: Stitch was spreading limited generation effort across 19 screens' worth of instructions at once. One focused prompt per screen produces far more detail per screen.
2. **Every screen prompt below repeats the exact color tokens and the exact Vietnamese label list it needs.** This redundancy is intentional — v1's single shared reference section got lost by the time Stitch reached the nav, and it invented English labels ("Venues," "Leagues," "Coaching") instead of using the real ones. Do not let Stitch "improve" or translate any Vietnamese string in quotes below. Copy it character-for-character.
3. If a generated screen ever comes back feeling like a generic dark-mode template (black background, one neon accent color, centered hero text over a stock photo) — that is the single most common AI-design failure mode. Reject it and regenerate, explicitly telling Stitch: "this looks like a generic template, follow the court line-marking motif and scoreboard-digit signature described below instead."

---

## PROJECT CONTEXT (include with every prompt)

V-SPORT is a Vietnamese sports-facility booking platform (football, badminton, pickleball, tennis, basketball, volleyball courts) operating in Vũng Tàu and nearby areas. Beyond booking, it has a social matchmaking feature ("Ghép Kèo") for finding teammates/opponents, a persistent-team/club feature ("Đội nhóm"), a small sports-gear marketplace, promotions, QR-based payment, and a loyalty/trust-score system ("Điểm uy tín"). It is a mobile-first responsive web app.

The current product has 8 different, uncoordinated color systems across its ~23 screens (mint-green here, navy-blue-cyan there, all-blue somewhere else) and drifting fonts. It reads like several apps stapled together. Your job is ONE cohesive, distinctive design system applied consistently everywhere.

**Do not default to a generic dark UI with a single neon accent color, and do not default to a warm cream-and-serif look either — both are overused AI-design templates.** The design below is grounded in a specific, real idea: actual court surfaces, line-markings, and stadium scoreboards. Follow that concept's own logic, not a generic "sporty dark app" mood board.

---

## BLOCK 1 — DESIGN SYSTEM (paste first, ask Stitch to render as a single style-guide/reference sheet)

**Concept name: "Line & Scoreboard."** The product's visual world is built from two real, physical things found at every court in this product: the painted boundary lines on a court surface, and a stadium scoreboard. Structural dividers, card borders, and section breaks borrow the geometry of court line-markings (boundary corners, service-line ticks, a dashed halfway line) instead of generic hairlines or gradients. Every number that matters to the user — price, countdown, step count, trust score — is set in a distinct tabular "scoreboard digit" face, as if it's lit up on a stadium board. This is the memorable signature: reuse it on every price, timer, and stat in the product, nowhere else.

**Color tokens — define exactly these 8, do not introduce others:**
- `court-teal` `#0E6E6A` — primary brand color (hard-court acrylic surface teal). Used for primary buttons, active nav state, primary icons, brand mark.
- `court-teal-dark` `#0A5652` — hover/pressed state of primary buttons.
- `clay-orange` `#D6572B` — secondary/urgency color (synthetic rubber court flooring orange). Used for promo badges, "hot"/urgent indicators, secondary CTA accents. Never used as a large background fill — always a smaller accent, badge, or icon.
- `line-white` `#FCFAF4` — chalk-line white. Used for line-marking motifs on dark surfaces, and as text color on `night-ink`.
- `apron-stone` `#E9EDE7` — default page background (the concrete apron color around an outdoor court — cool, light, slightly green-gray, NOT a warm cream). This is the default background for the majority of screens (search, cart, account, lists) — most of the product is light, not dark.
- `apron-card` `#FFFFFF` — card surface on top of `apron-stone`.
- `night-ink` `#10241F` — dark teal-black, used sparingly and deliberately: the header bar, the footer, and specific "under the lights" moments (auth hero, the live booking-timeline screen). Never the default background of a content-dense list page.
- `text-ink` `#12201B` — primary text color (near-black with a whisper of green, not pure black).
- `text-muted` `#5C6B64` — secondary/muted text.
- Semantic (reserved, never reused for branding): `success #1E8E5A` / bg `#E4F3EA`, `warning #C98A1E` / bg `#FBF0DC`, `danger #C23B2E` / bg `#FBE7E3`.
- Booking-status pill vocabulary, consistent everywhere: Chờ duyệt = warning, Chờ thanh toán = clay-orange, Đã duyệt/Đang đá = court-teal, Đã hoàn thành = success, Đã hủy = text-muted/neutral.

**Typography — three roles, do not mix in other fonts:**
- **Display (headlines, section titles):** Be Vietnam Pro, weight 800/900 (ExtraBold/Black), tight letter-spacing (-1%), sentence case or capitalized as natural Vietnamese requires — NOT forced all-caps everywhere (all-caps Vietnamese with diacritics gets visually noisy; reserve all-caps for short 1-3 word CTAs/badges only). This guarantees correct Vietnamese diacritic rendering.
- **Scoreboard digits (numbers ONLY — prices, countdown timers, step numbers, stat figures, trust-score number):** a bold tabular monospace, e.g. `Space Mono` Bold or `Roboto Mono` Bold, set inside small individual rounded-rect cells with a subtle inset shadow — literally styled like segments on an LED/flip scoreboard. Applies only to digit characters, never to Vietnamese words (so diacritic support is irrelevant here).
- **Body/UI (paragraphs, labels, buttons, forms, nav):** Be Vietnam Pro, weights 400/500/600/700 — the only body font anywhere in the product.

**Signature structural motif — apply consistently:**
- Card corners get a small L-shaped bracket mark (2 short line segments meeting at a right angle, `court-teal` or `line-white` depending on surface) echoing a court boundary corner — used on hero cards, featured cards, and modal corners, not on every minor list row (reserve it for moments that deserve emphasis).
- Section dividers on light pages use a dashed horizontal rule reminiscent of a court halfway line, not a plain solid `<hr>`.
- Any place that shows a live/ticking/in-progress state (countdown, live availability count, "N người đang xem sân này") uses the scoreboard-digit face plus a small pulsing dot, echoing a scoreboard clock — this is the "alive" signal of the product, used sparingly for genuinely time-sensitive data only.

**Shape & elevation:**
- Radius: `12px` cards, `10px` buttons/inputs, `999px` pills/chips/avatars — one scale everywhere.
- Light surfaces: flat, restrained shadow (`0 1px 2px rgba(18,32,27,.08)` resting, slightly larger on hover). No heavy drop shadows.
- Dark (`night-ink`) surfaces: use a soft `court-teal` glow instead of a shadow behind primary CTAs and live indicators.

**Iconography & photography:**
- One consistent line-icon set, ~1.75px stroke, rounded joins. Simplified bold pictograms per sport (football, badminton racquet, pickleball paddle, tennis racquet, basketball, volleyball) — not photo-realistic icons, not mixed icon-font styles.
- Photography: real action shots of Vietnamese amateur players mid-play, natural court lighting (daylight for most shots, actual floodlights only for night/hero moments) — avoid the generic staged "smiling person pointing at phone" stock photo and avoid the generic "silhouetted athlete cutout on black" cliché. Show real courts, real gear, real texture (turf, hard court, net).

**Self-check before generating any screen:** does this screen's background default to light `apron-stone`, with `night-ink` used only where justified (header/footer/auth hero/live booking moment)? Does every number use the scoreboard-digit treatment? Do card/section corners use the line-marking bracket motif instead of a generic gradient or shadow? If any answer is no, revise before finalizing.

---

## BLOCK 2 — GLOBAL NAVIGATION SHELL

**Desktop header** — background `night-ink`, height 72px, full-width, sticky, a single hairline `line-white`-at-8%-opacity along the bottom edge (not a shadow).
- Left: a simple geometric ball-and-net mark (not a stock sports icon) sized ~32px, next to the wordmark "V-SPORT" set in the Display face at ~20px weight 900, letter-spaced, in `line-white`, with only the segment "SPORT" colored `court-teal`. Logo lockup total height matches the 72px bar with generous vertical padding — it must look considered, not cramped against the edges.
- Center nav, Be Vietnam Pro SemiBold 15px, `line-white` at 78% opacity, `line-white` 100% + a 2px `court-teal` underline on hover/active. **Use exactly these six labels, in this exact order, verbatim, do not translate or replace them:** `Trang chủ`, `Bản đồ`, `Đặt sân`, `Ưu đãi`, `Ghép Kèo` (with a small `clay-orange` pill reading "HOT" attached top-right of the label), `Tin tức`.
- Right side, left to right: search icon button, cart icon button with a `clay-orange` count badge (small circle, top-right of icon), notification bell icon button with a `court-teal` unread dot, then either (a) logged-out: a `line-white`-outline ghost button "Đăng nhập" + a solid `court-teal` filled button "Đăng ký", or (b) logged-in: a circular avatar with a small chevron opening a dropdown (`Thông tin cá nhân`, `Lịch sử đặt sân`, `Yêu cầu hoàn tiền`, `Đăng xuất`). Finally, always-visible, a solid `court-teal` pill button "Đặt sân" with 20px horizontal padding, sitting slightly apart from the icon cluster (extra 16px gap) so it reads as the header's primary action, not just another icon.
- Everything in the right cluster is vertically centered and evenly spaced (20px gaps between icon buttons) — this row must look deliberately composed, not a loose row of default-sized icons jammed together (this was the specific failure in the previous version).

**Mobile bottom nav** — fixed, `apron-card` white background, 70px height, top hairline border `#E2E5E0`, 5 items: `Trang chủ`, `Bản đồ`, **`Ghép Trận`** (center, raised circular FAB, `night-ink` fill, `court-teal` ring + soft glow — the visual signature of the app, keep prominent), `Nổi bật`, `Tài khoản`. Active item: icon + label in `court-teal`, with a small `court-teal` dot beneath (not a filled-lime block — keep the bar mostly white/quiet, this is not a moment for the scoreboard motif).

---

## BLOCK 3 — TRANG CHỦ (HOME) — generate the ENTIRE page, all 11 sections below in one continuous vertical scroll. Do not stop after the hero.

**Hero (section 1 of 11) — reject the "centered text over dark photo" cliché.** Asymmetric split layout, full-bleed `night-ink` background: right ~55% is a real action photo of a match, masked into an angled panel shape reminiscent of a stadium jumbotron (a slightly trapezoidal/skewed rectangle, not a plain rectangle crop) with a subtle `court-teal` glow at its edge. Left ~45%: eyebrow label "V-SPORT · Đặt sân thông minh" in `clay-orange`, a two-line Display headline "Đặt Sân Nhanh / Chơi Ngay Hôm Nay" (weight 900, `line-white`, ~56px desktop), one-line description in `line-white` at 70% opacity, a solid `court-teal` pill CTA "Đặt sân ngay" with arrow icon, and below that a **small live-stat scoreboard row** — 2-3 tiny stat tiles in the scoreboard-digit face (e.g. "1,204" over label "Sân đã đặt hôm nay", "128" over "Trận đang diễn ra") with pulsing dots, grounding the "alive" concept immediately. Slide dots + arrow controls at the bottom of the hero, small and unobtrusive.

**Section 2 — announcement ticker:** thin `night-ink` bar directly under the hero, scrolling promo text in `line-white`, dismissible close icon on the right.

**Section 3 — "Sản phẩm & dịch vụ nổi bật":** `apron-stone` background. Section head with Display title + "Xem tất cả" link. Pill-tab filter row (Tất cả/Dụng cụ/Trang phục/Dịch vụ/Phụ kiện), active tab filled `court-teal`. Horizontal card carousel: each card on `apron-card` white, product image, heart-favorite toggle top-right, a `clay-orange` "Hot"/"Mới" badge when relevant, category label in `text-muted`, product name, star rating row, price in scoreboard-digit face (with a struck-through old price beside it when discounted, in `text-muted`), ghost "Xem chi tiết" button.

**Section 4 — "Khám phá môn thể thao":** two-column layout — left is a vertical list of 6 sport rows (icon + label + chevron; active row gets a light `court-teal`-tinted background and left accent bar echoing a court sideline); right is a large image panel that swaps per active sport, with an overlay gradient at the bottom holding a title, one-line stat ("70+ sân tại Vũng Tàu"), and a `court-teal` "Xem sân ngay" CTA.

**Section 5 — "Vì sao chọn V-SPORT":** `apron-card` background, 4-card icon grid (đặt sân nhanh / thanh toán an toàn / ghép kèo thông minh / hỗ trợ tận tâm), each card: icon in a `court-teal`-tinted circle, title, one-line description. Card corners use the L-bracket line-marking motif on hover.

**Section 6 — "Sân được đặt nhiều nhất":** horizontal court-card carousel — photo (with a small "Còn sân" pill, `success` color, top-left), sport-tag chip, court name, address, star rating, price/hr in scoreboard-digit face, "Đặt sân ngay" CTA.

**Section 7 — "4 bước đơn giản" how-it-works:** full-bleed `night-ink` band. Big Display step numbers (1-4) rendered in the scoreboard-digit face (this is a genuine sequence, so numbering is justified here). Left: an image that swaps per active step. Right: 4-item vertical step list (tìm sân phù hợp / chọn giờ & thanh toán / nhận xác nhận tức thì / check-in & thi đấu), active step highlighted with a `court-teal` left border.

**Section 8 — "Ghép kèo cùng cộng đồng":** `apron-stone` background. Card grid of open matches: sport-tag chip, match title, 3 meta rows (date/time, location, skill level) each with a small icon, avatar stack of joined players, a "Còn N chỗ trống" indicator in `clay-orange` (urgency), "Tham gia ngay" `court-teal` CTA.

**Section 9 — partner logo strip:** a quiet single row, small grayscale/muted logos, `text-muted` label above ("Đối tác & cơ sở uy tín trên V-SPORT").

**Section 10 — blog/tips carousel:** "Tin tức & kinh nghiệm thể thao" — cards with image, category tag, date, title, excerpt, "Đọc tiếp" link.

**Section 11 — footer:** `night-ink`, standard multi-column footer (about, quick links, contact, social, newsletter email-capture with a `court-teal` submit button), copyright line.

---

## BLOCK 4 — CUSTOMER AUTHENTICATION (Đăng nhập / Đăng ký)

This must feel like the dedicated front door of a consumer sports app — no admin/dashboard visual language anywhere, no role selector. (Backend note, ignore for the visual design: one shared login endpoint actually serves every role behind the scenes and redirects post-login — the customer-facing screen must give zero indication of that.)

**Layout:** full-screen, split in two on desktop (roughly 50/50), single column on mobile (photo band collapses to ~35vh above the form).

**Left/top panel — photography, not flat color:** a real action photo (players mid-match under evening light), `night-ink` gradient scrim from the bottom for legibility. Overlaid: Display headline "Tham gia V-SPORT" in `line-white`, one-line subtext, and — echoing the scoreboard-digit signature — a small live counter overlay near the bottom of the photo, e.g. "12,450" over "Người chơi đang hoạt động", reinforcing the concept and making this panel feel alive rather than decorative.

**Right/bottom panel — the form, on `apron-card` white, generous padding (48px desktop):**
- Tab switcher, two tabs `Đăng nhập` / `Đăng ký`, active tab in `text-ink` with a 3px `court-teal` underline, inactive tab in `text-muted`.
- Optional dismissible banner slot at the top (amber `warning` background) for the "Vui lòng đăng nhập để tiếp tục thao tác này" login-required message — show this variant as a second frame.
- **Đăng nhập tab, full field list:** label "Email hoặc số điện thoại" + input (placeholder "you@email.com hoặc 0912345678"); label "Mật khẩu" + password input with an eye-icon show/hide toggle on the right edge; a row with "Ghi nhớ đăng nhập" checkbox on the left and "Quên mật khẩu?" `court-teal` link on the right; full-width solid `court-teal` submit button "Đăng nhập"; a centered "hoặc" divider with hairlines on each side; a closing line "Chưa có tài khoản? Đăng ký ngay" linking to the register tab.
- **Đăng ký tab, full field list:** "Họ và tên" input; "Số điện thoại" input; "Email" input; "Mật khẩu" input with a **live requirement checklist directly beneath it** — 4 small rows (8+ ký tự / chữ hoa & chữ thường / có số / có ký tự đặc biệt), each with a circle that fills `success` green with a checkmark the instant that rule is met — render one frame with 2 of 4 met and one frame with all 4 met, to show the state changing; "Xác nhận mật khẩu" input with a live match indicator (small check/cross icon at the field's right edge); a terms checkbox ("Tôi đồng ý với Điều khoản sử dụng"); full-width solid `court-teal` submit "Tạo tài khoản".
- **Quên mật khẩu, as a separate frame:** centered modal card over a dimmed backdrop, small lock icon, title "Khôi phục mật khẩu", one email input, submit button, a secondary "Quay lại đăng nhập" link.
- **OTP verification, as a separate frame (this single design is reused everywhere a 6-digit code is needed — registration, email change):** centered card on `night-ink` background, shield icon, headline "Nhập mã xác thực", subtext showing the masked destination ("Mã đã gửi tới ****89@gmail.com"), a scoreboard-digit-style countdown timer (5:00 counting down, switches to `danger` red under 30s), 6 individual digit-box inputs (each a bordered square, `court-teal` glow on the currently-focused box), a disabled-until-complete submit button, and a "Gửi lại mã (60s)" resend link that becomes active after its cooldown.
- Every state above (default, filled, error, success, disabled, loading-spinner-on-submit) should be at least sketched as an annotation even if only the default state is rendered at full fidelity — this screen was the thinnest in the previous pass and needs to visibly cover the real form logic, not just a bare two-field mockup.

---

## BLOCK 5 — REMAINING SCREENS (generate one at a time; each still gets its own full prompt using the tokens/type/motif from BLOCK 1 — do not let any of these regress to a generic look either)

For each screen below, apply: `apron-stone`/`apron-card` as the default light background unless marked dark; `night-ink` only for the specific dark moments named; `court-teal` primary actions; `clay-orange` for urgency/promo only; scoreboard-digit face for every price/timer/count; line-marking corner brackets on hero/featured cards; the exact status-pill color vocabulary from Block 1.

**Đặt sân trực quan (visual booking flow):** full-screen app-like flow, `night-ink` chrome throughout (this is one of the deliberate dark "under the lights" moments) — sticky header with back button, facility name, date navigator, 2-step progress (Chọn sân → Chọn giờ, `court-teal` for current/complete step). Step 1: grid of court cards on dark surface, sport icon tile, name, type badge, price/hr, pulsing dot for availability. Step 2: sticky sub-bar with selected court, legend row (Trống/Đang chọn/Đã đặt/Giữ chỗ/Không khả dụng, each a distinct fill per Block 1 tokens), horizontally scrollable 30-min timeline with sticky time header, a `clay-orange` "now" marker line, drag-select range highlighted with a `court-teal` glow, live duration/price in scoreboard-digit face. Sticky bottom bar: duration, total price (scoreboard digits), CTA (disabled = muted, enabled = solid `court-teal` with glow).

**Chi tiết sân (court detail):** light `apron-stone`. Breadcrumb. Bento gallery (1 large + 2 small photos with line-marking corner brackets on the large one), status pill. Two-column: left — title, facility/address, tag chips, description, amenities icon-grid, embedded map; right (sticky) — price/hr + status, date stepper, draggable timeline bar (`court-teal` selected range), price breakdown card, solid CTA. Below: "Sân tương tự" carousel. Mobile: sticky bottom bar with price + CTA.

**Tìm kiếm (search/browse):** light. Filter-chip row + active-filters strip. Results grid of facility cards (image, sport badge, `clay-orange` promo badge when applicable, name, address, hours, "Đặt lịch" CTA). Empty/error states with icon + retry/reset. "Bộ lọc chuyên sâu" modal. Tapping a card opens a facility detail bottom sheet (image carousel, tag row, tabbed content: Tổng quan/Sân & bảng giá/Ưu đãi/Dịch vụ/Cửa hàng/Hình ảnh/Chính sách, bottom action bar).

**Bản đồ (map):** full-screen, footer hidden. Floating search bar + filter toggle over the map, sport-chip row, floating circular action buttons (layers/results-count/list-view/locate-me) in `apron-card` white with soft shadow, map pins in `court-teal` (default) / `clay-orange` (selected). Draggable facility bottom sheet on tap.

**Giỏ hàng / Lịch sử / Hoàn tiền (3-tab hub):** `night-ink` hero banner (breadcrumb, title) + 3 tabs with live counts (Giỏ hàng, Lịch sử đặt sân, Yêu cầu hoàn tiền). Booking cards below on light surface: name, status pill, date/time/ID, price (scoreboard digits), conditional action buttons. Empty states, filter chips + search on history tab, 7-state refund status list on the refund tab. Modals for service order and cancel-booking (loading → options → confirm).

**Thanh toán QR:** dark `night-ink` distraction-free page, minimal header. 4 states: WAITING (QR card with pulsing status pill + scoreboard-digit countdown, bank-transfer detail card with copy buttons, 3 stacked actions), PAID (success glow ring, summary, redirect countdown), EXPIRED (warning tones, retry CTAs), CANCELLED (danger tones, restart CTAs).

**Xác nhận đặt sân:** `night-ink` header with 3-step text progress, light two-column card body — left: facility summary, schedule grid, price breakdown (scoreboard digits), promo-code card; right: booker-info card, payment-method radio cards (`court-teal` selected border), policy notes, submit CTA.

**Tài khoản / Hồ sơ / Đổi mật khẩu / Điểm uy tín (shared account shell):** `night-ink` profile hero (avatar, name, "Uy tín: X/100" scoreboard-digit chip, contact row, 2 CTAs) + light sidebar nav card (Tổng quan/Nhóm của tôi/Cập nhật hồ sơ/Điểm uy tín/Đổi mật khẩu/Đăng xuất). Dashboard: 4-tile stat grid (scoreboard digits for counts), recent-bookings list with empty state, quick-access 4-tile grid. Hồ sơ: grouped form (personal/sport-preferences/additional-info), OTP modal for email change. Đổi mật khẩu: 3-field form. Điểm uy tín: vertical timeline of point changes (+green/-orange deltas in scoreboard digits).

**Hoàn tiền chi tiết:** light card page, status badge, stat strip (scoreboard digits for money amounts), cancellation-reason quote, editable bank-details form with live VietQR preview.

**Ghép Kèo (matchmaking hub):** `night-ink` hero (title, subtitle, "Tạo kèo mới" solid CTA + "Kèo của tôi" ghost CTA with `clay-orange` unread badge). 3 tabs: Khám phá (filter panel, sort, card grid matching the home-page match-card style), Tạo kèo mới (booking-select, stepper, selects, notes, live preview), Kèo của tôi (created/joined sub-lists). Match detail bottom sheet with participant list + owner actions.

**Đội nhóm (teams — list/detail/create):** list: header + 2 stat tiles, 3 tabs (Đội của bạn/Tìm đội tham gia/Lời mời), card grid with role tags. Detail: cover + avatar, role-conditional action bar, member list, "Kèo đội" mini form + match lists, invite dialog. Create/edit: avatar + cover upload with preview, name/khu vực/mô tả fields with char counters, sport select, max-members stepper.

**Thông báo + Cài đặt thông báo:** unify into ONE visual language (currently two unrelated apps — fix that). List: unread badge, mark-all-read, type-colored notification rows, empty state, pagination. Settings: same account-page chrome as the rest of the app (not a standalone gradient page) — "Bắt buộc" locked-on toggles section, "Tùy chọn" real-toggle section (`court-teal` track when on), save button.

**Ưu đãi (promotions):** light. Toolbar (search, sport select, sort, "sắp hết hạn" toggle). Skeleton → card grid or empty/error. Promo card: media, `clay-orange` discount badge, program name, facility, condition text, copy-code button, "Dùng ngay" CTA.

**Quét QR tại sân (in-venue kiosk):** standalone (no shared nav), `night-ink` background with soft `court-teal` ambient glow. 3 large option buttons (Gọi nhân viên/Gọi món/Thanh toán) expanding into accordion panels — product list with qty steppers, payment method cards, request-history list with 4 status badges.

**Nhập mã OTP:** as fully specified in Block 4 — this exact screen is reused everywhere a 6-digit code appears; do not design a second variant.

---

## SHARED COMPONENT LIBRARY (mention explicitly when generating any screen, so Stitch reuses rather than reinvents)

- Buttons: primary (`court-teal` fill, `line-white` text, glow on dark bg), secondary (outline `court-teal`), ghost (transparent, `line-200` border), danger-text (`danger` color) — each with disabled/loading/pressed states.
- Status pills: the single vocabulary from Block 1, reused identically on every booking/refund/history surface.
- Cards: product, court, facility, match, team, blog, notification row — one shared radius/padding/elevation system, line-marking corner bracket reserved for featured/hero cards only.
- Chips: filter chip (idle/hover/active), status chip, sport-tag chip.
- Modals & sheets: generic confirm dialog, full-screen loading overlay (mark + spinner on `night-ink`), toast (info/success/warning/danger), drag-handle bottom sheet.
- Forms: text input, select, textarea with char counter, stepper, toggle switch, OTP boxes, image upload with preview.
- Empty/loading/error states: skeleton shimmer, error (icon+message+retry), empty (icon+message+CTA) — required on every list/grid screen, never a blank gap.

---

## RESPONSIVE & ACCESSIBILITY

- Mobile-first; desktop breakpoint at 1024px (2-column layouts, sidebar account shell, desktop header).
- Minimum 44×44px touch targets.
- `court-teal` on `apron-stone`/white meets AA text contrast; `clay-orange` as text also passes AA — both are safe as text colors (unlike a neon-lime would be), but still prefer them as fills/accents for primary actions.
- Visible focus states everywhere: 2–3px `court-teal` outline, offset from the element.

Every screen must look like it was designed by the same team in the same week, working from the same real-world concept (court lines + scoreboard) — that coherence, not any single screen's polish, is the actual success criterion.
