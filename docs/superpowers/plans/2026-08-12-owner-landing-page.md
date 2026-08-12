# Owner Landing Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a public-facing Owner Landing Page at `/owner` that markets the V-Sport platform to sports facility owners and drives registrations via dual CTA (Đăng ký ngay + Liên hệ tư vấn).

**Architecture:** Next.js 14 App Router in `vsport_frontend/` directory. `app/owner/page.tsx` is a Server Component that fetches `OwnerStats` from `/api/v1/home` with ISR (revalidate 3600s). Only `AnimatedCounter` and `ContactModal` are Client Components. All landing components live under `components/owner-landing/`.

**Tech Stack:** Next.js 14 (App Router), TypeScript 5, Tailwind CSS 3, Embla Carousel, Lucide React, Jest 29 + React Testing Library 14

## Global Constraints

- Working directory for all commands: `vsport_frontend/` (inside repo root)
- Font: Be Vietnam Pro — loaded via `next/font/google`, variable `--font-be-vietnam-pro`
- Brand colors: Navy `#0f172a`, Blue `#2563eb`, Cyan `#06b6d4`, Slate `#64748b`
- All user-facing text in Vietnamese
- Backend URL from env var `NEXT_PUBLIC_BACKEND_URL` (default `http://localhost:8080/Backend_java`)
- No authentication required — fully public page
- Route: `/owner`
- `ContactModal` shows contact info only — does NOT send email

---

## File Map

| File | Responsibility |
|---|---|
| `app/layout.tsx` | Root layout — font, metadata |
| `app/globals.css` | Base styles, Tailwind directives |
| `app/owner/page.tsx` | Server Component — fetch stats, assemble sections |
| `types/owner-landing.ts` | `OwnerStats`, `Testimonial` interfaces |
| `lib/api/owner-landing.ts` | `getOwnerStats()` — fetch + map from backend |
| `components/owner-landing/Navbar.tsx` | Sticky nav, scroll-aware blur |
| `components/owner-landing/HeroSection.tsx` | Full-viewport hero, dual CTA |
| `components/owner-landing/PainPointsSection.tsx` | 3-card pain point grid |
| `components/owner-landing/SolutionSection.tsx` | 2-column solution layout |
| `components/owner-landing/FeatureCard.tsx` | Single feature card (icon + title + desc) |
| `components/owner-landing/FeaturesSection.tsx` | 5-feature grid using FeatureCard |
| `components/owner-landing/AnimatedCounter.tsx` | Client — count-up on scroll (Intersection Observer) |
| `components/owner-landing/StatsSection.tsx` | 4-stat navy banner using AnimatedCounter |
| `components/owner-landing/TestimonialCard.tsx` | Single testimonial (avatar + quote + stars) |
| `components/owner-landing/TestimonialsSection.tsx` | Client — Embla carousel of TestimonialCards |
| `components/owner-landing/FinalCTASection.tsx` | Gradient banner + dual CTA |
| `components/owner-landing/ContactModal.tsx` | Client — modal with contact info |
| `components/owner-landing/Footer.tsx` | Footer with links + copyright |
| `__tests__/api/owner-landing.test.ts` | Unit tests for `getOwnerStats` |
| `__tests__/components/Navbar.test.tsx` | Render + scroll tests |
| `__tests__/components/AnimatedCounter.test.tsx` | Counter logic tests |
| `__tests__/components/ContactModal.test.tsx` | Open/close interaction tests |
| `tailwind.config.ts` | Brand color + font extension |
| `jest.config.ts` | Jest + Next.js + jsdom config |
| `jest.setup.ts` | `@testing-library/jest-dom` import |

---

## Task 1: Scaffold Next.js Project

**Files:**
- Create: `vsport_frontend/` (entire project)
- Create: `tailwind.config.ts`
- Create: `app/layout.tsx`
- Create: `app/globals.css`
- Create: `jest.config.ts`
- Create: `jest.setup.ts`
- Create: `.env.local`

**Interfaces:**
- Produces: working dev server at `localhost:3000`, Jest test runner

- [ ] **Step 1: Scaffold project from repo root**

```bash
cd /home/nhan/Downloads/V-SPORT
npx create-next-app@14 vsport_frontend \
  --typescript \
  --tailwind \
  --app \
  --no-src-dir \
  --import-alias "@/*" \
  --no-eslint
```

- [ ] **Step 2: Install additional dependencies**

```bash
cd vsport_frontend
npm install embla-carousel-react lucide-react
npm install --save-dev jest jest-environment-jsdom @testing-library/react @testing-library/jest-dom @testing-library/user-event ts-jest @types/jest
```

- [ ] **Step 3: Configure Tailwind with V-Sport brand tokens**

Replace `tailwind.config.ts` with:

```ts
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        'vs-navy':  '#0f172a',
        'vs-blue':  '#2563eb',
        'vs-cyan':  '#06b6d4',
        'vs-slate': '#64748b',
      },
      fontFamily: {
        sans: ['var(--font-be-vietnam-pro)', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
export default config
```

- [ ] **Step 4: Set up root layout with Be Vietnam Pro font**

Replace `app/layout.tsx` with:

```tsx
import type { Metadata } from 'next'
import { Be_Vietnam_Pro } from 'next/font/google'
import './globals.css'

const beVietnamPro = Be_Vietnam_Pro({
  subsets: ['vietnamese', 'latin'],
  weight: ['400', '500', '600', '700', '800'],
  variable: '--font-be-vietnam-pro',
  display: 'swap',
})

export const metadata: Metadata = {
  title: 'V-Sport — Nền tảng quản lý sân thể thao',
  description: 'Đưa sân thể thao của bạn lên tầm cao mới với V-Sport',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="vi" className={beVietnamPro.variable}>
      <body className="bg-white antialiased font-sans">{children}</body>
    </html>
  )
}
```

- [ ] **Step 5: Replace globals.css**

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

html {
  scroll-behavior: smooth;
}
```

- [ ] **Step 6: Configure Jest**

Create `jest.config.ts`:

```ts
import type { Config } from 'jest'
import nextJest from 'next/jest.js'

const createJestConfig = nextJest({ dir: './' })

const config: Config = {
  testEnvironment: 'jsdom',
  setupFilesAfterFramework: ['<rootDir>/jest.setup.ts'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/$1',
  },
}

export default createJestConfig(config)
```

Create `jest.setup.ts`:

```ts
import '@testing-library/jest-dom'
```

Add to `package.json` scripts:

```json
"test": "jest",
"test:watch": "jest --watch"
```

- [ ] **Step 7: Create env file**

Create `.env.local`:

```
NEXT_PUBLIC_BACKEND_URL=http://localhost:8080/Backend_java
```

- [ ] **Step 8: Verify dev server starts**

```bash
npm run dev
```

Expected: server running at `http://localhost:3000`

- [ ] **Step 9: Verify Jest runs**

```bash
npm test -- --passWithNoTests
```

Expected: `Test Suites: 0 passed`

- [ ] **Step 10: Commit**

```bash
cd /home/nhan/Downloads/V-SPORT
git add vsport_frontend/
git commit -m "feat: scaffold vsport_frontend Next.js project with Tailwind + Jest"
```

---

## Task 2: Types + API Layer

**Files:**
- Create: `vsport_frontend/types/owner-landing.ts`
- Create: `vsport_frontend/lib/api/owner-landing.ts`
- Create: `vsport_frontend/__tests__/api/owner-landing.test.ts`

**Interfaces:**
- Produces: `OwnerStats`, `Testimonial` types; `getOwnerStats(): Promise<OwnerStats | null>`

- [ ] **Step 1: Write failing tests**

Create `__tests__/api/owner-landing.test.ts`:

```ts
import { getOwnerStats } from '@/lib/api/owner-landing'

describe('getOwnerStats', () => {
  afterEach(() => jest.restoreAllMocks())

  it('maps API response to OwnerStats', async () => {
    jest.spyOn(global, 'fetch').mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({
        totalFacilities: 120,
        totalCourts: 500,
        totalBookings: 50000,
        totalCustomers: 15000,
      }),
    } as Response)

    const result = await getOwnerStats()
    expect(result).toEqual({
      totalFacilities: 120,
      totalCourts: 500,
      totalBookings: 50000,
      totalCustomers: 15000,
    })
  })

  it('returns null when fetch throws', async () => {
    jest.spyOn(global, 'fetch').mockRejectedValue(new Error('Network error'))
    expect(await getOwnerStats()).toBeNull()
  })

  it('returns null when response is not ok', async () => {
    jest.spyOn(global, 'fetch').mockResolvedValue({ ok: false } as Response)
    expect(await getOwnerStats()).toBeNull()
  })

  it('falls back to 0 for missing fields', async () => {
    jest.spyOn(global, 'fetch').mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({}),
    } as Response)

    const result = await getOwnerStats()
    expect(result).toEqual({
      totalFacilities: 0,
      totalCourts: 0,
      totalBookings: 0,
      totalCustomers: 0,
    })
  })
})
```

- [ ] **Step 2: Run tests — expect failure**

```bash
npm test -- --testPathPattern="api/owner-landing"
```

Expected: FAIL — `Cannot find module '@/lib/api/owner-landing'`

- [ ] **Step 3: Create types**

Create `types/owner-landing.ts`:

```ts
export interface OwnerStats {
  totalFacilities: number
  totalCourts: number
  totalBookings: number
  totalCustomers: number
}

export interface Testimonial {
  id: number
  ownerName: string
  facilityName: string
  avatarUrl: string
  content: string
  rating: number
}
```

- [ ] **Step 4: Implement API function**

Create `lib/api/owner-landing.ts`:

```ts
import { OwnerStats } from '@/types/owner-landing'

const BACKEND = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'

export async function getOwnerStats(): Promise<OwnerStats | null> {
  try {
    const res = await fetch(`${BACKEND}/api/v1/home`, {
      next: { revalidate: 3600 },
    })
    if (!res.ok) return null
    const data = await res.json()
    return {
      totalFacilities: data.totalFacilities ?? 0,
      totalCourts:     data.totalCourts     ?? 0,
      totalBookings:   data.totalBookings   ?? 0,
      totalCustomers:  data.totalCustomers  ?? 0,
    }
  } catch {
    return null
  }
}
```

- [ ] **Step 5: Run tests — expect pass**

```bash
npm test -- --testPathPattern="api/owner-landing"
```

Expected: 4 tests PASS

- [ ] **Step 6: Commit**

```bash
git add vsport_frontend/types/ vsport_frontend/lib/ vsport_frontend/__tests__/api/
git commit -m "feat: add OwnerStats types and getOwnerStats API function"
```

---

## Task 3: Navbar

**Files:**
- Create: `vsport_frontend/components/owner-landing/Navbar.tsx`
- Create: `vsport_frontend/__tests__/components/Navbar.test.tsx`

**Interfaces:**
- Produces: `<Navbar />` — no props, Client Component

- [ ] **Step 1: Write failing test**

Create `__tests__/components/Navbar.test.tsx`:

```tsx
import { render, screen } from '@testing-library/react'
import Navbar from '@/components/owner-landing/Navbar'

describe('Navbar', () => {
  it('renders the V-Sport logo', () => {
    render(<Navbar />)
    expect(screen.getByText(/V-/i)).toBeInTheDocument()
    expect(screen.getByText(/SPORT/i)).toBeInTheDocument()
  })

  it('renders navigation links', () => {
    render(<Navbar />)
    expect(screen.getByText('Tính năng')).toBeInTheDocument()
    expect(screen.getByText('Thống kê')).toBeInTheDocument()
    expect(screen.getByText('Liên hệ')).toBeInTheDocument()
  })

  it('renders Đăng ký CTA button linking to /owner-register', () => {
    render(<Navbar />)
    const link = screen.getByRole('link', { name: /đăng ký/i })
    expect(link).toHaveAttribute('href', '/owner-register')
  })
})
```

- [ ] **Step 2: Run test — expect failure**

```bash
npm test -- --testPathPattern="Navbar"
```

Expected: FAIL — `Cannot find module`

- [ ] **Step 3: Implement Navbar**

Create `components/owner-landing/Navbar.tsx`:

```tsx
'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 10)
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  return (
    <header
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        scrolled
          ? 'bg-vs-navy/90 backdrop-blur-md border-b border-white/10 shadow-lg'
          : 'bg-transparent'
      }`}
    >
      <nav className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
        <Link href="/" className="text-white font-bold text-xl tracking-tight">
          V-<span className="text-vs-cyan">SPORT</span>
        </Link>

        <div className="hidden md:flex items-center gap-8">
          <a href="#tinh-nang" className="text-slate-300 hover:text-white text-sm transition-colors">
            Tính năng
          </a>
          <a href="#thong-ke" className="text-slate-300 hover:text-white text-sm transition-colors">
            Thống kê
          </a>
          <a href="#lien-he" className="text-slate-300 hover:text-white text-sm transition-colors">
            Liên hệ
          </a>
        </div>

        <div className="flex items-center gap-3">
          <Link
            href="/dang-nhap"
            className="text-slate-300 hover:text-white text-sm transition-colors px-3 py-1.5"
          >
            Đăng nhập
          </Link>
          <Link
            href="/owner-register"
            className="bg-vs-blue hover:bg-blue-700 text-white text-sm font-semibold px-4 py-2 rounded-lg transition-colors"
          >
            Đăng ký
          </Link>
        </div>
      </nav>
    </header>
  )
}
```

- [ ] **Step 4: Run test — expect pass**

```bash
npm test -- --testPathPattern="Navbar"
```

Expected: 3 tests PASS

- [ ] **Step 5: Commit**

```bash
git add vsport_frontend/components/owner-landing/Navbar.tsx vsport_frontend/__tests__/components/Navbar.test.tsx
git commit -m "feat: add Owner Landing Navbar with scroll-aware blur"
```

---

## Task 4: Hero Section

**Files:**
- Create: `vsport_frontend/components/owner-landing/HeroSection.tsx`

**Interfaces:**
- Consumes: `onOpenContact: () => void` prop (to open ContactModal)
- Produces: `<HeroSection onOpenContact={fn} />`

- [ ] **Step 1: Write failing test**

Create `__tests__/components/HeroSection.test.tsx`:

```tsx
import { render, screen, fireEvent } from '@testing-library/react'
import HeroSection from '@/components/owner-landing/HeroSection'

describe('HeroSection', () => {
  it('renders the main headline', () => {
    render(<HeroSection onOpenContact={() => {}} />)
    expect(screen.getByRole('heading', { level: 1 })).toBeInTheDocument()
  })

  it('renders primary CTA link to /owner-register', () => {
    render(<HeroSection onOpenContact={() => {}} />)
    const link = screen.getByRole('link', { name: /đăng ký ngay/i })
    expect(link).toHaveAttribute('href', '/owner-register')
  })

  it('calls onOpenContact when secondary CTA is clicked', () => {
    const mock = jest.fn()
    render(<HeroSection onOpenContact={mock} />)
    fireEvent.click(screen.getByRole('button', { name: /liên hệ tư vấn/i }))
    expect(mock).toHaveBeenCalledTimes(1)
  })
})
```

- [ ] **Step 2: Run test — expect failure**

```bash
npm test -- --testPathPattern="HeroSection"
```

Expected: FAIL

- [ ] **Step 3: Implement HeroSection**

Create `components/owner-landing/HeroSection.tsx`:

```tsx
import Link from 'next/link'
import { ArrowRight, ChevronDown } from 'lucide-react'

interface Props {
  onOpenContact: () => void
}

export default function HeroSection({ onOpenContact }: Props) {
  return (
    <section className="relative min-h-screen flex items-center bg-gradient-to-br from-vs-navy via-[#1e3a5f] to-vs-blue overflow-hidden">
      {/* Background decoration */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-1/4 right-1/4 w-96 h-96 bg-vs-cyan/10 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 left-1/4 w-64 h-64 bg-vs-blue/20 rounded-full blur-3xl" />
      </div>

      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-24 pb-16">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Left: Text */}
          <div>
            <span className="inline-flex items-center gap-2 bg-vs-cyan/10 border border-vs-cyan/30 text-vs-cyan text-sm font-medium px-3 py-1 rounded-full mb-6">
              Nền tảng quản lý sân thể thao #1 Việt Nam
            </span>

            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-white leading-tight mb-6">
              Đưa sân thể thao của bạn{' '}
              <span className="text-vs-cyan">lên tầm cao mới</span>
            </h1>

            <p className="text-lg text-slate-300 mb-8 max-w-lg">
              Quản lý lịch đặt, thu tiền tự động, phân tích doanh thu — tất cả trong một nền tảng.
              Tham gia cùng hàng trăm chủ sân đang phát triển với V-Sport.
            </p>

            <div className="flex flex-wrap gap-4">
              <Link
                href="/owner-register"
                className="inline-flex items-center gap-2 bg-vs-blue hover:bg-blue-700 text-white font-semibold px-6 py-3 rounded-xl transition-all duration-200 shadow-lg shadow-blue-500/25 hover:shadow-blue-500/40 hover:-translate-y-0.5"
              >
                Đăng ký ngay
                <ArrowRight className="w-4 h-4" />
              </Link>

              <button
                onClick={onOpenContact}
                className="inline-flex items-center gap-2 border border-white/30 hover:border-white/60 text-white font-semibold px-6 py-3 rounded-xl transition-all duration-200 hover:bg-white/5"
              >
                Liên hệ tư vấn
              </button>
            </div>
          </div>

          {/* Right: Dashboard mockup */}
          <div className="hidden lg:flex justify-center">
            <div className="relative w-full max-w-md">
              <div className="bg-white/10 backdrop-blur-sm border border-white/20 rounded-2xl p-6 shadow-2xl">
                <div className="flex items-center gap-2 mb-4">
                  <div className="w-3 h-3 rounded-full bg-red-400" />
                  <div className="w-3 h-3 rounded-full bg-yellow-400" />
                  <div className="w-3 h-3 rounded-full bg-green-400" />
                  <span className="ml-2 text-white/60 text-xs">V-Sport Dashboard</span>
                </div>
                <div className="space-y-3">
                  {[
                    { label: 'Lịch đặt hôm nay', value: '24 lượt', color: 'bg-vs-blue' },
                    { label: 'Doanh thu tháng', value: '18.5M ₫', color: 'bg-vs-cyan' },
                    { label: 'Sân đang hoạt động', value: '8/10 sân', color: 'bg-green-400' },
                  ].map((item) => (
                    <div key={item.label} className="bg-white/5 rounded-lg p-3 flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div className={`w-2 h-8 rounded-full ${item.color}`} />
                        <span className="text-white/80 text-sm">{item.label}</span>
                      </div>
                      <span className="text-white font-semibold text-sm">{item.value}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Scroll indicator */}
      <div className="absolute bottom-8 left-1/2 -translate-x-1/2 animate-bounce">
        <ChevronDown className="w-6 h-6 text-white/40" />
      </div>
    </section>
  )
}
```

- [ ] **Step 4: Run test — expect pass**

```bash
npm test -- --testPathPattern="HeroSection"
```

Expected: 3 tests PASS

- [ ] **Step 5: Commit**

```bash
git add vsport_frontend/components/owner-landing/HeroSection.tsx vsport_frontend/__tests__/components/HeroSection.test.tsx
git commit -m "feat: add HeroSection with dual CTA and dashboard mockup"
```

---

## Task 5: Pain Points Section

**Files:**
- Create: `vsport_frontend/components/owner-landing/PainPointsSection.tsx`

**Interfaces:**
- Produces: `<PainPointsSection />` — no props

- [ ] **Step 1: Write failing test**

Create `__tests__/components/PainPointsSection.test.tsx`:

```tsx
import { render, screen } from '@testing-library/react'
import PainPointsSection from '@/components/owner-landing/PainPointsSection'

describe('PainPointsSection', () => {
  it('renders section heading', () => {
    render(<PainPointsSection />)
    expect(screen.getByRole('heading', { level: 2 })).toBeInTheDocument()
  })

  it('renders exactly 3 pain point cards', () => {
    render(<PainPointsSection />)
    const cards = screen.getAllByRole('article')
    expect(cards).toHaveLength(3)
  })
})
```

- [ ] **Step 2: Run test — expect failure**

```bash
npm test -- --testPathPattern="PainPoints"
```

Expected: FAIL

- [ ] **Step 3: Implement PainPointsSection**

Create `components/owner-landing/PainPointsSection.tsx`:

```tsx
import { BookOpen, Banknote, BarChart2 } from 'lucide-react'

const PAIN_POINTS = [
  {
    icon: BookOpen,
    title: 'Quản lý lịch bằng sổ tay',
    description:
      'Ghi chép thủ công dễ nhầm lẫn, đặt trùng giờ, khó theo dõi lịch sử. Mỗi ngày mất hàng giờ chỉ để sắp xếp lịch.',
  },
  {
    icon: Banknote,
    title: 'Thu tiền thủ công, dễ thất thoát',
    description:
      'Nhận tiền mặt không có hóa đơn, khó đối soát, nhân viên dễ sai sót. Không biết doanh thu thực tế là bao nhiêu.',
  },
  {
    icon: BarChart2,
    title: 'Không nắm được hiệu suất sân',
    description:
      'Không biết giờ nào sân đông, giờ nào vắng. Không có dữ liệu để điều chỉnh giá hoặc chạy khuyến mãi hiệu quả.',
  },
]

export default function PainPointsSection() {
  return (
    <section className="py-24 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl sm:text-4xl font-bold text-vs-navy mb-4">
            Bạn đang gặp những vấn đề này?
          </h2>
          <p className="text-vs-slate text-lg max-w-2xl mx-auto">
            Hầu hết chủ sân thể thao đều gặp phải những khó khăn chung khi vận hành thủ công.
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {PAIN_POINTS.map((point) => {
            const Icon = point.icon
            return (
              <article
                key={point.title}
                className="group bg-slate-50 hover:bg-red-50 border border-slate-100 hover:border-red-100 rounded-2xl p-8 transition-all duration-300"
              >
                <div className="w-12 h-12 bg-red-100 group-hover:bg-red-200 rounded-xl flex items-center justify-center mb-5 transition-colors">
                  <Icon className="w-6 h-6 text-red-500" />
                </div>
                <h3 className="text-lg font-bold text-vs-navy mb-3">{point.title}</h3>
                <p className="text-vs-slate text-sm leading-relaxed">{point.description}</p>
              </article>
            )
          })}
        </div>
      </div>
    </section>
  )
}
```

- [ ] **Step 4: Run test — expect pass**

```bash
npm test -- --testPathPattern="PainPoints"
```

Expected: 2 tests PASS

- [ ] **Step 5: Commit**

```bash
git add vsport_frontend/components/owner-landing/PainPointsSection.tsx vsport_frontend/__tests__/components/PainPointsSection.test.tsx
git commit -m "feat: add PainPointsSection with 3 pain point cards"
```

---

## Task 6: Solution Section

**Files:**
- Create: `vsport_frontend/components/owner-landing/SolutionSection.tsx`

**Interfaces:**
- Produces: `<SolutionSection />` — no props

- [ ] **Step 1: Write failing test**

Create `__tests__/components/SolutionSection.test.tsx`:

```tsx
import { render, screen } from '@testing-library/react'
import SolutionSection from '@/components/owner-landing/SolutionSection'

describe('SolutionSection', () => {
  it('renders section heading', () => {
    render(<SolutionSection />)
    expect(screen.getByRole('heading', { level: 2 })).toBeInTheDocument()
  })

  it('renders all checklist items', () => {
    render(<SolutionSection />)
    const items = screen.getAllByRole('listitem')
    expect(items.length).toBeGreaterThanOrEqual(4)
  })
})
```

- [ ] **Step 2: Run test — expect failure**

```bash
npm test -- --testPathPattern="SolutionSection"
```

Expected: FAIL

- [ ] **Step 3: Implement SolutionSection**

Create `components/owner-landing/SolutionSection.tsx`:

```tsx
import { CheckCircle2 } from 'lucide-react'

const SOLUTIONS = [
  'Lịch đặt sân trực quan, real-time, không bao giờ trùng giờ',
  'Thanh toán QR tự động — tiền về tài khoản ngay lập tức',
  'Báo cáo doanh thu theo ngày, tuần, tháng ngay trên dashboard',
  'Khuyến mãi linh hoạt để giữ chân khách hàng thường xuyên',
  'App mobile giúp khách đặt sân 24/7 — tăng lượng booking',
]

export default function SolutionSection() {
  return (
    <section className="py-24 bg-slate-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid lg:grid-cols-2 gap-16 items-center">
          {/* Left: Visual */}
          <div className="order-2 lg:order-1">
            <div className="bg-gradient-to-br from-vs-navy to-vs-blue rounded-3xl p-8 shadow-2xl">
              <div className="text-center mb-6">
                <span className="text-vs-cyan font-semibold text-sm uppercase tracking-wider">
                  V-Sport Platform
                </span>
              </div>
              <div className="space-y-4">
                {[
                  { label: 'Quản lý lịch đặt', pct: 95 },
                  { label: 'Doanh thu tháng này', pct: 78 },
                  { label: 'Tỷ lệ lấp đầy sân', pct: 88 },
                ].map((bar) => (
                  <div key={bar.label}>
                    <div className="flex justify-between text-sm text-white/80 mb-1">
                      <span>{bar.label}</span>
                      <span>{bar.pct}%</span>
                    </div>
                    <div className="h-2 bg-white/10 rounded-full overflow-hidden">
                      <div
                        className="h-full bg-vs-cyan rounded-full"
                        style={{ width: `${bar.pct}%` }}
                      />
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Right: Text */}
          <div className="order-1 lg:order-2">
            <h2 className="text-3xl sm:text-4xl font-bold text-vs-navy mb-4">
              V-Sport giải quyết tất cả —{' '}
              <span className="text-vs-blue">trong một nền tảng</span>
            </h2>
            <p className="text-vs-slate text-lg mb-8">
              Không cần nhiều công cụ rời rạc. V-Sport tích hợp toàn bộ nghiệp vụ quản lý sân
              thể thao vào một hệ thống duy nhất, dễ dùng.
            </p>

            <ul className="space-y-4">
              {SOLUTIONS.map((item) => (
                <li key={item} className="flex items-start gap-3">
                  <CheckCircle2 className="w-5 h-5 text-vs-blue mt-0.5 shrink-0" />
                  <span className="text-vs-navy font-medium">{item}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </section>
  )
}
```

- [ ] **Step 4: Run test — expect pass**

```bash
npm test -- --testPathPattern="SolutionSection"
```

Expected: 2 tests PASS

- [ ] **Step 5: Commit**

```bash
git add vsport_frontend/components/owner-landing/SolutionSection.tsx vsport_frontend/__tests__/components/SolutionSection.test.tsx
git commit -m "feat: add SolutionSection with 2-column layout and checklist"
```

---

## Task 7: Features Section

**Files:**
- Create: `vsport_frontend/components/owner-landing/FeatureCard.tsx`
- Create: `vsport_frontend/components/owner-landing/FeaturesSection.tsx`

**Interfaces:**
- Consumes: `FeatureCard` props: `{ icon: LucideIcon, title: string, description: string }`
- Produces: `<FeaturesSection />` — no props

- [ ] **Step 1: Write failing test**

Create `__tests__/components/FeaturesSection.test.tsx`:

```tsx
import { render, screen } from '@testing-library/react'
import FeaturesSection from '@/components/owner-landing/FeaturesSection'

describe('FeaturesSection', () => {
  it('renders section heading', () => {
    render(<FeaturesSection />)
    expect(screen.getByRole('heading', { level: 2 })).toBeInTheDocument()
  })

  it('renders exactly 5 feature cards', () => {
    render(<FeaturesSection />)
    expect(screen.getAllByRole('article')).toHaveLength(5)
  })

  it('renders all feature titles', () => {
    render(<FeaturesSection />)
    expect(screen.getByText('Quản lý lịch đặt trực quan')).toBeInTheDocument()
    expect(screen.getByText('Thanh toán QR & PayOS')).toBeInTheDocument()
    expect(screen.getByText('Báo cáo doanh thu')).toBeInTheDocument()
    expect(screen.getByText('Khuyến mãi thông minh')).toBeInTheDocument()
    expect(screen.getByText('App mobile cho khách hàng')).toBeInTheDocument()
  })
})
```

- [ ] **Step 2: Run test — expect failure**

```bash
npm test -- --testPathPattern="FeaturesSection"
```

Expected: FAIL

- [ ] **Step 3: Implement FeatureCard**

Create `components/owner-landing/FeatureCard.tsx`:

```tsx
import { LucideIcon } from 'lucide-react'

interface Props {
  icon: LucideIcon
  title: string
  description: string
}

export default function FeatureCard({ icon: Icon, title, description }: Props) {
  return (
    <article className="group bg-white hover:bg-vs-blue border border-slate-100 hover:border-vs-blue rounded-2xl p-8 transition-all duration-300 shadow-sm hover:shadow-xl hover:-translate-y-1 cursor-default">
      <div className="w-12 h-12 bg-vs-blue/10 group-hover:bg-white/20 rounded-xl flex items-center justify-center mb-5 transition-colors">
        <Icon className="w-6 h-6 text-vs-blue group-hover:text-white transition-colors" />
      </div>
      <h3 className="text-lg font-bold text-vs-navy group-hover:text-white mb-3 transition-colors">
        {title}
      </h3>
      <p className="text-vs-slate group-hover:text-blue-100 text-sm leading-relaxed transition-colors">
        {description}
      </p>
    </article>
  )
}
```

- [ ] **Step 4: Implement FeaturesSection**

Create `components/owner-landing/FeaturesSection.tsx`:

```tsx
import { Calendar, QrCode, TrendingUp, Gift, Smartphone } from 'lucide-react'
import FeatureCard from './FeatureCard'

const FEATURES = [
  {
    icon: Calendar,
    title: 'Quản lý lịch đặt trực quan',
    description:
      'Xem toàn bộ lịch đặt sân theo ngày, tuần trên một màn hình. Cập nhật real-time, không bao giờ trùng giờ.',
  },
  {
    icon: QrCode,
    title: 'Thanh toán QR & PayOS',
    description:
      'Khách quét QR, tiền vào tài khoản ngay lập tức. Hỗ trợ tất cả ngân hàng Việt Nam, hoàn toàn tự động.',
  },
  {
    icon: TrendingUp,
    title: 'Báo cáo doanh thu',
    description:
      'Dashboard phân tích doanh thu theo giờ, ngày, tháng. Biết chính xác khung giờ nào đông để tối ưu giá.',
  },
  {
    icon: Gift,
    title: 'Khuyến mãi thông minh',
    description:
      'Tạo mã giảm giá, ưu đãi giờ thấp điểm, chương trình khách hàng thân thiết — chỉ vài bước đơn giản.',
  },
  {
    icon: Smartphone,
    title: 'App mobile cho khách hàng',
    description:
      'Khách hàng đặt sân qua app V-Sport 24/7. Tăng lượng booking mà không cần thêm nhân sự tiếp nhận.',
  },
]

export default function FeaturesSection() {
  return (
    <section id="tinh-nang" className="py-24 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl sm:text-4xl font-bold text-vs-navy mb-4">
            Mọi thứ bạn cần để vận hành sân chuyên nghiệp
          </h2>
          <p className="text-vs-slate text-lg max-w-2xl mx-auto">
            5 tính năng cốt lõi được thiết kế dành riêng cho chủ sân thể thao Việt Nam.
          </p>
        </div>

        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {FEATURES.map((feature) => (
            <FeatureCard key={feature.title} {...feature} />
          ))}
        </div>
      </div>
    </section>
  )
}
```

- [ ] **Step 5: Run test — expect pass**

```bash
npm test -- --testPathPattern="FeaturesSection"
```

Expected: 3 tests PASS

- [ ] **Step 6: Commit**

```bash
git add vsport_frontend/components/owner-landing/FeatureCard.tsx vsport_frontend/components/owner-landing/FeaturesSection.tsx vsport_frontend/__tests__/components/FeaturesSection.test.tsx
git commit -m "feat: add FeatureCard and FeaturesSection with 5 feature grid"
```

---

## Task 8: Stats Section (Animated Counter)

**Files:**
- Create: `vsport_frontend/components/owner-landing/AnimatedCounter.tsx`
- Create: `vsport_frontend/components/owner-landing/StatsSection.tsx`
- Create: `vsport_frontend/__tests__/components/AnimatedCounter.test.tsx`

**Interfaces:**
- Consumes: `AnimatedCounter` props: `{ target: number, suffix?: string, duration?: number }`
- Consumes: `StatsSection` props: `{ stats: OwnerStats | null }`
- Produces: `<StatsSection stats={stats} />`

- [ ] **Step 1: Write failing tests**

Create `__tests__/components/AnimatedCounter.test.tsx`:

```tsx
import { render, screen } from '@testing-library/react'
import AnimatedCounter from '@/components/owner-landing/AnimatedCounter'

// Mock IntersectionObserver (jsdom does not support it)
const mockObserve = jest.fn()
const mockDisconnect = jest.fn()
beforeEach(() => {
  global.IntersectionObserver = jest.fn().mockImplementation((cb) => {
    cb([{ isIntersecting: true }])
    return { observe: mockObserve, disconnect: mockDisconnect }
  }) as unknown as typeof IntersectionObserver
})

describe('AnimatedCounter', () => {
  it('renders without crashing', () => {
    render(<AnimatedCounter target={1000} />)
    expect(screen.getByRole('status')).toBeInTheDocument()
  })

  it('renders a suffix when provided', () => {
    render(<AnimatedCounter target={500} suffix="+" />)
    expect(screen.getByRole('status')).toHaveTextContent('+')
  })
})
```

- [ ] **Step 2: Run test — expect failure**

```bash
npm test -- --testPathPattern="AnimatedCounter"
```

Expected: FAIL

- [ ] **Step 3: Implement AnimatedCounter**

Create `components/owner-landing/AnimatedCounter.tsx`:

```tsx
'use client'

import { useEffect, useRef, useState } from 'react'

interface Props {
  target: number
  suffix?: string
  duration?: number
}

export default function AnimatedCounter({ target, suffix = '', duration = 2000 }: Props) {
  const [count, setCount] = useState(0)
  const ref = useRef<HTMLSpanElement>(null)
  const started = useRef(false)

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && !started.current) {
          started.current = true
          const startTime = performance.now()
          const tick = (now: number) => {
            const elapsed = now - startTime
            const progress = Math.min(elapsed / duration, 1)
            const eased = 1 - Math.pow(1 - progress, 3)
            setCount(Math.floor(eased * target))
            if (progress < 1) requestAnimationFrame(tick)
          }
          requestAnimationFrame(tick)
        }
      },
      { threshold: 0.3 }
    )
    if (ref.current) observer.observe(ref.current)
    return () => observer.disconnect()
  }, [target, duration])

  return (
    <span ref={ref} role="status">
      {count.toLocaleString('vi-VN')}
      {suffix}
    </span>
  )
}
```

- [ ] **Step 4: Implement StatsSection**

Create `components/owner-landing/StatsSection.tsx`:

```tsx
import AnimatedCounter from './AnimatedCounter'
import { OwnerStats } from '@/types/owner-landing'

interface Props {
  stats: OwnerStats | null
}

const STATS_CONFIG = [
  { key: 'totalFacilities' as const, label: 'Cơ sở đang hoạt động', suffix: '+' },
  { key: 'totalCourts'     as const, label: 'Sân thể thao', suffix: '+' },
  { key: 'totalBookings'   as const, label: 'Lượt đặt sân', suffix: '+' },
  { key: 'totalCustomers'  as const, label: 'Khách hàng tin dùng', suffix: '+' },
]

export default function StatsSection({ stats }: Props) {
  return (
    <section id="thong-ke" className="py-24 bg-vs-navy">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl sm:text-4xl font-bold text-white mb-4">
            Những con số nói lên tất cả
          </h2>
          <p className="text-slate-400 text-lg">
            V-Sport đang phục vụ hàng trăm cơ sở thể thao trên toàn quốc.
          </p>
        </div>

        <div className="grid grid-cols-2 lg:grid-cols-4 gap-8">
          {STATS_CONFIG.map(({ key, label, suffix }) => (
            <div key={key} className="text-center">
              <div className="text-4xl sm:text-5xl font-extrabold text-vs-cyan mb-2">
                {stats ? (
                  <AnimatedCounter target={stats[key]} suffix={suffix} />
                ) : (
                  <span>--</span>
                )}
              </div>
              <p className="text-slate-400 text-sm font-medium">{label}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
```

- [ ] **Step 5: Run tests — expect pass**

```bash
npm test -- --testPathPattern="AnimatedCounter"
```

Expected: 2 tests PASS

- [ ] **Step 6: Commit**

```bash
git add vsport_frontend/components/owner-landing/AnimatedCounter.tsx vsport_frontend/components/owner-landing/StatsSection.tsx vsport_frontend/__tests__/components/AnimatedCounter.test.tsx
git commit -m "feat: add AnimatedCounter (Intersection Observer) and StatsSection"
```

---

## Task 9: Testimonials Section

**Files:**
- Create: `vsport_frontend/components/owner-landing/TestimonialCard.tsx`
- Create: `vsport_frontend/components/owner-landing/TestimonialsSection.tsx`

**Interfaces:**
- Consumes: `TestimonialCard` props: `{ testimonial: Testimonial }`
- Produces: `<TestimonialsSection />` — no props (uses hardcoded data)

- [ ] **Step 1: Write failing test**

Create `__tests__/components/TestimonialsSection.test.tsx`:

```tsx
import { render, screen } from '@testing-library/react'
import TestimonialsSection from '@/components/owner-landing/TestimonialsSection'

describe('TestimonialsSection', () => {
  it('renders section heading', () => {
    render(<TestimonialsSection />)
    expect(screen.getByRole('heading', { level: 2 })).toBeInTheDocument()
  })

  it('renders at least one testimonial owner name', () => {
    render(<TestimonialsSection />)
    expect(screen.getByText('Nguyễn Văn Hùng')).toBeInTheDocument()
  })
})
```

- [ ] **Step 2: Run test — expect failure**

```bash
npm test -- --testPathPattern="Testimonials"
```

Expected: FAIL

- [ ] **Step 3: Implement TestimonialCard**

Create `components/owner-landing/TestimonialCard.tsx`:

```tsx
import { Star } from 'lucide-react'
import { Testimonial } from '@/types/owner-landing'

interface Props {
  testimonial: Testimonial
}

export default function TestimonialCard({ testimonial }: Props) {
  return (
    <div className="bg-white rounded-2xl p-8 shadow-sm border border-slate-100 h-full flex flex-col">
      <div className="flex gap-1 mb-4">
        {Array.from({ length: 5 }).map((_, i) => (
          <Star
            key={i}
            className={`w-4 h-4 ${i < testimonial.rating ? 'text-yellow-400 fill-yellow-400' : 'text-slate-200'}`}
          />
        ))}
      </div>

      <p className="text-vs-slate text-sm leading-relaxed flex-1 mb-6 italic">
        &ldquo;{testimonial.content}&rdquo;
      </p>

      <div className="flex items-center gap-3">
        <div className="w-10 h-10 rounded-full bg-vs-blue/10 flex items-center justify-center text-vs-blue font-bold text-sm shrink-0">
          {testimonial.ownerName.charAt(0)}
        </div>
        <div>
          <p className="text-vs-navy font-semibold text-sm">{testimonial.ownerName}</p>
          <p className="text-vs-slate text-xs">{testimonial.facilityName}</p>
        </div>
      </div>
    </div>
  )
}
```

- [ ] **Step 4: Implement TestimonialsSection**

Create `components/owner-landing/TestimonialsSection.tsx`:

```tsx
'use client'

import useEmblaCarousel from 'embla-carousel-react'
import { Testimonial } from '@/types/owner-landing'
import TestimonialCard from './TestimonialCard'
import { ChevronLeft, ChevronRight } from 'lucide-react'
import { useCallback } from 'react'

const TESTIMONIALS: Testimonial[] = [
  {
    id: 1,
    ownerName: 'Nguyễn Văn Hùng',
    facilityName: 'Sân cầu lông Hoàng Anh',
    avatarUrl: '',
    content:
      'Kể từ khi dùng V-Sport, lượng đặt sân tăng gấp đôi. Quản lý lịch rất dễ, thanh toán tự động, không cần thu tiền mặt nữa.',
    rating: 5,
  },
  {
    id: 2,
    ownerName: 'Trần Thị Mai',
    facilityName: 'Trung tâm thể thao Mai Linh',
    avatarUrl: '',
    content:
      'Báo cáo doanh thu rõ ràng theo từng ngày, giờ. Tôi biết chính xác khung giờ nào đông để tối ưu giá và chạy khuyến mãi.',
    rating: 5,
  },
  {
    id: 3,
    ownerName: 'Lê Minh Tuấn',
    facilityName: 'CLB Bóng đá Phú Nhuận',
    avatarUrl: '',
    content:
      'Tính năng QR code sân giúp khách tự đặt dịch vụ mà không cần nhân viên can thiệp. Tiết kiệm được 2 nhân sự xử lý đơn.',
    rating: 5,
  },
]

export default function TestimonialsSection() {
  const [emblaRef, emblaApi] = useEmblaCarousel({ loop: true, align: 'start' })

  const scrollPrev = useCallback(() => emblaApi?.scrollPrev(), [emblaApi])
  const scrollNext = useCallback(() => emblaApi?.scrollNext(), [emblaApi])

  return (
    <section className="py-24 bg-slate-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl sm:text-4xl font-bold text-vs-navy mb-4">
            Chủ sân nói gì về V-Sport?
          </h2>
          <p className="text-vs-slate text-lg">
            Hơn 200 chủ cơ sở đang tin tưởng dùng V-Sport mỗi ngày.
          </p>
        </div>

        <div className="relative">
          <div ref={emblaRef} className="overflow-hidden">
            <div className="flex gap-6">
              {TESTIMONIALS.map((t) => (
                <div key={t.id} className="flex-none w-full sm:w-[calc(50%-12px)] lg:w-[calc(33.333%-16px)]">
                  <TestimonialCard testimonial={t} />
                </div>
              ))}
            </div>
          </div>

          <div className="flex justify-center gap-3 mt-8">
            <button
              onClick={scrollPrev}
              className="w-10 h-10 rounded-full border border-slate-200 hover:border-vs-blue hover:text-vs-blue flex items-center justify-center transition-colors"
              aria-label="Testimonial trước"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <button
              onClick={scrollNext}
              className="w-10 h-10 rounded-full border border-slate-200 hover:border-vs-blue hover:text-vs-blue flex items-center justify-center transition-colors"
              aria-label="Testimonial tiếp"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>
    </section>
  )
}
```

- [ ] **Step 5: Run test — expect pass**

```bash
npm test -- --testPathPattern="Testimonials"
```

Expected: 2 tests PASS

- [ ] **Step 6: Commit**

```bash
git add vsport_frontend/components/owner-landing/TestimonialCard.tsx vsport_frontend/components/owner-landing/TestimonialsSection.tsx vsport_frontend/__tests__/components/TestimonialsSection.test.tsx
git commit -m "feat: add TestimonialsSection with Embla carousel"
```

---

## Task 10: Final CTA + Footer

**Files:**
- Create: `vsport_frontend/components/owner-landing/FinalCTASection.tsx`
- Create: `vsport_frontend/components/owner-landing/Footer.tsx`

**Interfaces:**
- Consumes: `FinalCTASection` props: `{ onOpenContact: () => void }`
- Produces: `<FinalCTASection onOpenContact={fn} />`, `<Footer />`

- [ ] **Step 1: Write failing test**

Create `__tests__/components/FinalCTASection.test.tsx`:

```tsx
import { render, screen, fireEvent } from '@testing-library/react'
import FinalCTASection from '@/components/owner-landing/FinalCTASection'

describe('FinalCTASection', () => {
  it('renders primary CTA linking to /owner-register', () => {
    render(<FinalCTASection onOpenContact={() => {}} />)
    const link = screen.getByRole('link', { name: /đăng ký ngay/i })
    expect(link).toHaveAttribute('href', '/owner-register')
  })

  it('calls onOpenContact when secondary CTA clicked', () => {
    const mock = jest.fn()
    render(<FinalCTASection onOpenContact={mock} />)
    fireEvent.click(screen.getByRole('button', { name: /liên hệ tư vấn/i }))
    expect(mock).toHaveBeenCalledTimes(1)
  })
})
```

- [ ] **Step 2: Run test — expect failure**

```bash
npm test -- --testPathPattern="FinalCTA"
```

Expected: FAIL

- [ ] **Step 3: Implement FinalCTASection**

Create `components/owner-landing/FinalCTASection.tsx`:

```tsx
import Link from 'next/link'
import { ArrowRight } from 'lucide-react'

interface Props {
  onOpenContact: () => void
}

export default function FinalCTASection({ onOpenContact }: Props) {
  return (
    <section className="py-24 bg-gradient-to-br from-vs-navy via-[#1e3a5f] to-vs-blue">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <h2 className="text-3xl sm:text-4xl font-extrabold text-white mb-4">
          Sẵn sàng đưa sân của bạn lên V-Sport?
        </h2>
        <p className="text-slate-300 text-lg mb-10 max-w-2xl mx-auto">
          Đăng ký miễn phí hôm nay. Cài đặt trong 15 phút, bắt đầu nhận booking ngay lập tức.
        </p>

        <div className="flex flex-wrap justify-center gap-4">
          <Link
            href="/owner-register"
            className="inline-flex items-center gap-2 bg-vs-cyan hover:bg-cyan-400 text-vs-navy font-bold px-8 py-4 rounded-xl transition-all duration-200 shadow-lg hover:-translate-y-0.5"
          >
            Đăng ký ngay
            <ArrowRight className="w-5 h-5" />
          </Link>

          <button
            onClick={onOpenContact}
            className="inline-flex items-center gap-2 border-2 border-white/40 hover:border-white text-white font-semibold px-8 py-4 rounded-xl transition-all duration-200 hover:bg-white/5"
          >
            Liên hệ tư vấn
          </button>
        </div>
      </div>
    </section>
  )
}
```

- [ ] **Step 4: Implement Footer**

Create `components/owner-landing/Footer.tsx`:

```tsx
import Link from 'next/link'

export default function Footer() {
  return (
    <footer id="lien-he" className="bg-vs-navy border-t border-white/10">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid md:grid-cols-3 gap-8 mb-8">
          <div>
            <p className="text-white font-bold text-xl mb-3">
              V-<span className="text-vs-cyan">SPORT</span>
            </p>
            <p className="text-slate-400 text-sm leading-relaxed">
              Nền tảng quản lý và đặt sân thể thao hàng đầu Việt Nam.
            </p>
          </div>

          <div>
            <p className="text-white font-semibold mb-4">Sản phẩm</p>
            <ul className="space-y-2 text-sm text-slate-400">
              <li><a href="#tinh-nang" className="hover:text-white transition-colors">Tính năng</a></li>
              <li><a href="#thong-ke" className="hover:text-white transition-colors">Thống kê</a></li>
              <li><Link href="/owner-register" className="hover:text-white transition-colors">Đăng ký đối tác</Link></li>
            </ul>
          </div>

          <div>
            <p className="text-white font-semibold mb-4">Liên hệ</p>
            <ul className="space-y-2 text-sm text-slate-400">
              <li>Email: support@vsport.vn</li>
              <li>Hotline: 1800 xxxx</li>
              <li>TP. Hồ Chí Minh, Việt Nam</li>
            </ul>
          </div>
        </div>

        <div className="border-t border-white/10 pt-6 text-center text-slate-500 text-xs">
          © {new Date().getFullYear()} V-Sport. All rights reserved.
        </div>
      </div>
    </footer>
  )
}
```

- [ ] **Step 5: Run test — expect pass**

```bash
npm test -- --testPathPattern="FinalCTA"
```

Expected: 2 tests PASS

- [ ] **Step 6: Commit**

```bash
git add vsport_frontend/components/owner-landing/FinalCTASection.tsx vsport_frontend/components/owner-landing/Footer.tsx vsport_frontend/__tests__/components/FinalCTASection.test.tsx
git commit -m "feat: add FinalCTASection and Footer"
```

---

## Task 11: Contact Modal

**Files:**
- Create: `vsport_frontend/components/owner-landing/ContactModal.tsx`
- Create: `vsport_frontend/__tests__/components/ContactModal.test.tsx`

**Interfaces:**
- Consumes: `{ isOpen: boolean, onClose: () => void }`
- Produces: `<ContactModal isOpen={bool} onClose={fn} />`

- [ ] **Step 1: Write failing test**

Create `__tests__/components/ContactModal.test.tsx`:

```tsx
import { render, screen, fireEvent } from '@testing-library/react'
import ContactModal from '@/components/owner-landing/ContactModal'

describe('ContactModal', () => {
  it('is not visible when isOpen is false', () => {
    render(<ContactModal isOpen={false} onClose={() => {}} />)
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
  })

  it('is visible when isOpen is true', () => {
    render(<ContactModal isOpen={true} onClose={() => {}} />)
    expect(screen.getByRole('dialog')).toBeInTheDocument()
  })

  it('shows contact information', () => {
    render(<ContactModal isOpen={true} onClose={() => {}} />)
    expect(screen.getByText(/support@vsport\.vn/i)).toBeInTheDocument()
  })

  it('calls onClose when backdrop is clicked', () => {
    const mock = jest.fn()
    render(<ContactModal isOpen={true} onClose={mock} />)
    fireEvent.click(screen.getByTestId('modal-backdrop'))
    expect(mock).toHaveBeenCalledTimes(1)
  })

  it('calls onClose when close button is clicked', () => {
    const mock = jest.fn()
    render(<ContactModal isOpen={true} onClose={mock} />)
    fireEvent.click(screen.getByRole('button', { name: /đóng/i }))
    expect(mock).toHaveBeenCalledTimes(1)
  })
})
```

- [ ] **Step 2: Run test — expect failure**

```bash
npm test -- --testPathPattern="ContactModal"
```

Expected: FAIL

- [ ] **Step 3: Implement ContactModal**

Create `components/owner-landing/ContactModal.tsx`:

```tsx
'use client'

import { X, Mail, Phone, MapPin } from 'lucide-react'
import { useEffect } from 'react'

interface Props {
  isOpen: boolean
  onClose: () => void
}

export default function ContactModal({ isOpen, onClose }: Props) {
  useEffect(() => {
    if (!isOpen) return
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose() }
    document.addEventListener('keydown', onKey)
    return () => document.removeEventListener('keydown', onKey)
  }, [isOpen, onClose])

  if (!isOpen) return null

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4"
      data-testid="modal-backdrop"
      onClick={onClose}
    >
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" />

      <div
        role="dialog"
        aria-modal="true"
        aria-label="Liên hệ tư vấn"
        className="relative bg-white rounded-2xl shadow-2xl max-w-md w-full p-8"
        onClick={(e) => e.stopPropagation()}
      >
        <button
          onClick={onClose}
          aria-label="Đóng"
          className="absolute top-4 right-4 w-8 h-8 rounded-full hover:bg-slate-100 flex items-center justify-center transition-colors"
        >
          <X className="w-4 h-4 text-slate-500" />
        </button>

        <h2 className="text-2xl font-bold text-vs-navy mb-2">Liên hệ tư vấn</h2>
        <p className="text-vs-slate text-sm mb-8">
          Đội ngũ V-Sport sẵn sàng hỗ trợ bạn đăng ký và cài đặt trong vòng 24 giờ.
        </p>

        <div className="space-y-5">
          <div className="flex items-center gap-4">
            <div className="w-10 h-10 bg-vs-blue/10 rounded-xl flex items-center justify-center shrink-0">
              <Mail className="w-5 h-5 text-vs-blue" />
            </div>
            <div>
              <p className="text-xs text-vs-slate font-medium mb-0.5">Email</p>
              <a href="mailto:support@vsport.vn" className="text-vs-navy font-semibold hover:text-vs-blue transition-colors">
                support@vsport.vn
              </a>
            </div>
          </div>

          <div className="flex items-center gap-4">
            <div className="w-10 h-10 bg-vs-blue/10 rounded-xl flex items-center justify-center shrink-0">
              <Phone className="w-5 h-5 text-vs-blue" />
            </div>
            <div>
              <p className="text-xs text-vs-slate font-medium mb-0.5">Hotline</p>
              <a href="tel:1800xxxx" className="text-vs-navy font-semibold hover:text-vs-blue transition-colors">
                1800 xxxx
              </a>
            </div>
          </div>

          <div className="flex items-center gap-4">
            <div className="w-10 h-10 bg-vs-blue/10 rounded-xl flex items-center justify-center shrink-0">
              <MapPin className="w-5 h-5 text-vs-blue" />
            </div>
            <div>
              <p className="text-xs text-vs-slate font-medium mb-0.5">Địa chỉ</p>
              <p className="text-vs-navy font-semibold">TP. Hồ Chí Minh, Việt Nam</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
```

- [ ] **Step 4: Run test — expect pass**

```bash
npm test -- --testPathPattern="ContactModal"
```

Expected: 5 tests PASS

- [ ] **Step 5: Commit**

```bash
git add vsport_frontend/components/owner-landing/ContactModal.tsx vsport_frontend/__tests__/components/ContactModal.test.tsx
git commit -m "feat: add ContactModal with keyboard/backdrop close"
```

---

## Task 12: Page Assembly

**Files:**
- Create: `vsport_frontend/app/owner/page.tsx`
- Delete: `vsport_frontend/app/page.tsx` default content (replace with redirect or keep as-is)

**Interfaces:**
- Consumes: `getOwnerStats()` from `@/lib/api/owner-landing`
- Consumes: All components from `@/components/owner-landing/*`
- Produces: fully assembled `/owner` route

- [ ] **Step 1: Write smoke test**

Create `__tests__/components/OwnerPage.test.tsx`:

```tsx
import { render, screen } from '@testing-library/react'
import OwnerPage from '@/app/owner/page'

jest.mock('@/lib/api/owner-landing', () => ({
  getOwnerStats: jest.fn().mockResolvedValue({
    totalFacilities: 120,
    totalCourts: 500,
    totalBookings: 50000,
    totalCustomers: 15000,
  }),
}))

describe('OwnerPage', () => {
  it('renders the page with all key sections', async () => {
    render(await OwnerPage())
    expect(screen.getByText(/đưa sân thể thao/i)).toBeInTheDocument()
    expect(screen.getByText(/bạn đang gặp/i)).toBeInTheDocument()
    expect(screen.getByText(/mọi thứ bạn cần/i)).toBeInTheDocument()
  })
})
```

- [ ] **Step 2: Run test — expect failure**

```bash
npm test -- --testPathPattern="OwnerPage"
```

Expected: FAIL — `Cannot find module '@/app/owner/page'`

- [ ] **Step 3: Create page**

Create `app/owner/page.tsx`:

```tsx
import { Suspense } from 'react'
import { getOwnerStats } from '@/lib/api/owner-landing'
import Navbar from '@/components/owner-landing/Navbar'
import HeroSection from '@/components/owner-landing/HeroSection'
import PainPointsSection from '@/components/owner-landing/PainPointsSection'
import SolutionSection from '@/components/owner-landing/SolutionSection'
import FeaturesSection from '@/components/owner-landing/FeaturesSection'
import StatsSection from '@/components/owner-landing/StatsSection'
import TestimonialsSection from '@/components/owner-landing/TestimonialsSection'
import FinalCTASection from '@/components/owner-landing/FinalCTASection'
import Footer from '@/components/owner-landing/Footer'
import ContactModalWrapper from '@/components/owner-landing/ContactModalWrapper'

export const revalidate = 3600

export default async function OwnerPage() {
  const stats = await getOwnerStats()

  return (
    <ContactModalWrapper>
      {({ openContact }) => (
        <main>
          <Navbar />
          <HeroSection onOpenContact={openContact} />
          <PainPointsSection />
          <SolutionSection />
          <FeaturesSection />
          <StatsSection stats={stats} />
          <TestimonialsSection />
          <FinalCTASection onOpenContact={openContact} />
          <Footer />
        </main>
      )}
    </ContactModalWrapper>
  )
}
```

- [ ] **Step 4: Create ContactModalWrapper**

Create `components/owner-landing/ContactModalWrapper.tsx`:

```tsx
'use client'

import { useState } from 'react'
import ContactModal from './ContactModal'

interface Props {
  children: (bag: { openContact: () => void }) => React.ReactNode
}

export default function ContactModalWrapper({ children }: Props) {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <>
      {children({ openContact: () => setIsOpen(true) })}
      <ContactModal isOpen={isOpen} onClose={() => setIsOpen(false)} />
    </>
  )
}
```

- [ ] **Step 5: Run all tests**

```bash
npm test
```

Expected: All tests PASS

- [ ] **Step 6: Start dev server and verify page**

```bash
npm run dev
```

Open `http://localhost:3000/owner` — verify all 9 sections render, scroll behavior works, ContactModal opens/closes.

- [ ] **Step 7: Final commit**

```bash
git add vsport_frontend/app/owner/ vsport_frontend/components/owner-landing/ContactModalWrapper.tsx vsport_frontend/__tests__/components/OwnerPage.test.tsx
git commit -m "feat: assemble /owner landing page — all sections wired"
```

---

## Self-Review Checklist

- [x] **Spec coverage**: Navbar ✓, Hero + dual CTA ✓, Pain Points ✓, Solution ✓, Features (A/B/D/E/F) ✓, Stats from API ✓, Testimonials ✓, Final CTA ✓, Footer ✓, ContactModal ✓
- [x] **No pricing section** — confirmed out of scope
- [x] **Placeholders**: contact details (email/phone/address) use placeholder values — these must be replaced with real V-Sport contact info before launch
- [x] **Type consistency**: `OwnerStats` defined in Task 2, consumed identically in Tasks 8 and 12; `Testimonial` defined in Task 2, consumed in Task 9
- [x] **ContactModalWrapper** added in Task 12 to bridge Server Component page with Client Component modal state — this was not in the original spec but is required by Next.js App Router's Server/Client boundary rules
