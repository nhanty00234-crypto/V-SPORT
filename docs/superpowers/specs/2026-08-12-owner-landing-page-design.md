# Owner Landing Page — Design Spec

> Ngày: 2026-08-12 | Dự án: V-SPORT | Route: `/owner` (hoặc `/ownerLanding`)

---

## 1. Mục tiêu

Xây dựng trang marketing dành cho **chủ cơ sở thể thao** (Owner) muốn đăng ký đưa sân lên nền tảng V-Sport. Trang chỉ phục vụ khách chưa đăng nhập, tập trung vào thuyết phục và chuyển đổi (conversion).

---

## 2. Audience & CTA

- **Đối tượng**: Chủ sân thể thao (cá nhân/doanh nghiệp) chưa dùng V-Sport
- **Primary CTA**: "Đăng ký ngay" → dẫn tới `/owner-register`
- **Secondary CTA**: "Liên hệ tư vấn" → mở `ContactModal` (popup form)
- **Không có** trang pricing / bảng phí

---

## 3. Approach: Narrative Flow

Dẫn dắt chủ sân qua hành trình:

```
Vấn đề → Giải pháp → Tính năng → Bằng chứng (stats + testimonials) → Hành động
```

---

## 4. Cấu trúc trang (9 sections theo thứ tự)

| # | Section | Mục đích |
|---|---|---|
| 1 | Navbar | Navigation + quick access CTA |
| 2 | Hero | Tagline + Dual CTA + visual |
| 3 | Pain Points | 3 vấn đề chủ sân thường gặp |
| 4 | Solution | V-Sport giải quyết tất cả |
| 5 | Features | 5 tính năng nổi bật |
| 6 | Stats | Số liệu thực từ API, animated |
| 7 | Testimonials | Đánh giá từ chủ sân (dữ liệu tĩnh) |
| 8 | Final CTA | Banner kêu gọi cuối trang |
| 9 | Footer | Links + thông tin liên hệ |

---

## 5. File Structure

```
app/
└── owner/
    └── page.tsx                      ← Server Component, route /owner

components/owner-landing/
    ├── Navbar.tsx                    ← Sticky, blur backdrop
    ├── HeroSection.tsx               ← Full viewport, gradient
    ├── PainPointsSection.tsx         ← 3 card ngang
    ├── SolutionSection.tsx           ← 2 cột text + visual
    ├── FeaturesSection.tsx           ← Grid 2-3 cột
    │   └── FeatureCard.tsx
    ├── StatsSection.tsx              ← Animated counters
    │   └── AnimatedCounter.tsx       ← Client Component (Intersection Observer)
    ├── TestimonialsSection.tsx       ← Carousel
    │   └── TestimonialCard.tsx
    ├── FinalCTASection.tsx           ← Gradient banner
    ├── ContactModal.tsx              ← Client Component (popup form)
    └── Footer.tsx

lib/
└── api/owner-landing.ts             ← fetch OwnerStats từ backend

types/
└── owner-landing.ts                 ← TypeScript interfaces
```

---

## 6. Data Flow

### Rendering strategy
- `app/owner/page.tsx` là **Server Component**
- Fetch `OwnerStats` tại server (ISR, revalidate 3600s)
- Chỉ `AnimatedCounter` và `ContactModal` là Client Components

### API
- **Endpoint**: `GET /api/v1/home` (HomeApiServlet, backend đã có)
- **Auth**: Không cần — trang public
- **Fallback**: Nếu fetch thất bại, hiển thị placeholder `--` thay vì crash

### TypeScript Interfaces

```ts
// types/owner-landing.ts

interface OwnerStats {
  totalFacilities: number   // tổng cơ sở đang hoạt động
  totalCourts: number       // tổng số sân
  totalBookings: number     // tổng lượt đặt
  totalCustomers: number    // tổng khách hàng
}

interface Testimonial {
  id: number
  ownerName: string
  facilityName: string
  avatarUrl: string
  content: string
  rating: number            // 1-5
}
```

### Fetch pattern

```ts
// lib/api/owner-landing.ts
const BACKEND = process.env.NEXT_PUBLIC_BACKEND_URL

export async function getOwnerStats(): Promise<OwnerStats | null> {
  try {
    const res = await fetch(`${BACKEND}/api/v1/home`, {
      next: { revalidate: 3600 },
    })
    if (!res.ok) return null
    const data = await res.json()
    return {
      totalFacilities: data.totalFacilities ?? 0,
      totalCourts: data.totalCourts ?? 0,
      totalBookings: data.totalBookings ?? 0,
      totalCustomers: data.totalCustomers ?? 0,
    }
  } catch {
    return null
  }
}
```

---

## 7. UI/UX Chi Tiết

### Design Tokens (kế thừa V-Sport brand)
- **Font**: Be Vietnam Pro
- **Màu chính**: Navy `#0f172a`, Blue `#2563eb`, Cyan `#06b6d4`
- **Màu phụ**: Slate `#64748b` (text mô tả), White `#ffffff`

### Section details

**Navbar** — sticky top, `backdrop-blur`, border-bottom khi scroll
- Logo trái | Links giữa (`Tính năng`, `Thống kê`, `Liên hệ`) | `Đăng nhập` (ghost) + `Đăng ký` (primary) phải

**Hero** — `min-h-screen`, gradient `navy → blue`
- Headline: *"Đưa sân thể thao của bạn lên tầm cao mới"*
- Subtitle 1 dòng ngắn
- Nút primary `Đăng ký ngay →` + nút outline `Liên hệ tư vấn`
- Visual: mockup dashboard (SVG illustration hoặc ảnh tĩnh) bên phải

**Pain Points** — nền white, 3 card ngang với icon + tiêu đề + mô tả
- "Quản lý lịch bằng sổ tay — dễ nhầm lẫn, thất thoát"
- "Thu tiền thủ công — khó kiểm soát doanh thu"
- "Không biết giờ nào sân đông, giờ nào vắng"

**Solution** — nền `slate-50`, layout 2 cột
- Trái: heading + danh sách check-mark
- Phải: illustration/screenshot

**Features** — nền white, grid `2 cols md → 3 cols lg`, mỗi FeatureCard:
- Icon (Lucide React) + tiêu đề + mô tả 2 dòng
- 5 features: Quản lý lịch đặt | Thanh toán QR/PayOS | Báo cáo doanh thu | Khuyến mãi | App mobile

**Stats** — nền `navy`, 4 số lớn (`AnimatedCounter` count-up khi scroll vào viewport qua Intersection Observer)
- `X+ Cơ sở` | `X+ Sân` | `X+ Lượt đặt` | `X+ Khách hàng`

**Testimonials** — nền white, carousel (Embla Carousel)
- Avatar + tên chủ sân + tên cơ sở + rating sao + quote
- Dữ liệu tĩnh (hardcode), thay bằng API khi backend sẵn sàng

**Final CTA** — gradient banner giống Hero, headline + 2 nút

**Footer** — nền navy, 3-4 cột: Logo/tagline | Links | Liên hệ | Copyright

---

## 8. Dependencies bổ sung cần cài

| Package | Mục đích |
|---|---|
| `embla-carousel-react` | Carousel testimonials |
| `lucide-react` | Icons |
| `@/lib/utils` (cn) | Tailwind class merge |

---

## 9. Out of Scope

- Trang pricing / bảng phí
- Nội dung cá nhân hóa (auth-aware)
- Form liên hệ gửi email thực (ContactModal chỉ hiển thị thông tin liên hệ hoặc mock submit)
- Đa ngôn ngữ (i18n)
