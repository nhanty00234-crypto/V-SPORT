# Owner Registration Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Xây dựng trang đăng ký chủ sân V-Sport (`/owner-register`) dạng 3-bước wizard: Email+Phone → OTP → Chi tiết cơ sở, kèm trang thành công `/owner-register/success`.

**Architecture:** `OwnerRegisterClient` (`'use client'`) giữ wizard state (`step: 1|2|3`, `email`, `phone`); mỗi bước là component riêng nhận callback `onSuccess`/`onBack`. Tất cả fetch kèm `credentials: 'include'` để Java session cookie được truyền giữa các bước.

**Tech Stack:** Next.js 14 App Router · Tailwind CSS · Java Servlet (session-based OTP) · Google Maps JS API (optional, fallback text input)

## Global Constraints

- Working directory frontend: `vsport_frontend/` — chạy lệnh npm từ thư mục này
- Working directory backend: repo root (`/home/nhan/Downloads/V-SPORT`) — chạy `mvn package -q`
- Brand colors Tailwind: `vs-navy` (#0f172a), `vs-blue` (#2563eb), `vs-cyan` (#06b6d4), `vs-slate` (#64748b)
- Font: `font-sans` (Be Vietnam Pro, khai báo trong `app/layout.tsx`)
- Test command: `cd vsport_frontend && npm test -- --testPathPatterns="<pattern>" --watchAll=false`
- Jest 30: dùng `--testPathPatterns` (không phải `--testPathPattern`)
- Mock fetch: `const mockFetch = jest.fn(); beforeAll(() => { global.fetch = mockFetch }); afterEach(() => mockFetch.mockReset())`
- Backend URL: `process.env.NEXT_PUBLIC_BACKEND_URL` = `http://localhost:8080/Backend_java`
- Tất cả API call dùng `credentials: 'include'` và `Content-Type: application/x-www-form-urlencoded`
- Không có capabilities field trong form (spec: bỏ qua)

---

## File Map

| File | Trách nhiệm |
|---|---|
| `src/main/java/org/example/controller/OwnerRegisterServlet.java` | Thêm CORS header cho `/owner/*` |
| `vsport_frontend/types/owner-register.ts` | SportRow, RegistrationData, OtpStatus |
| `vsport_frontend/lib/api/owner-register.ts` | sendOtp(), verifyOtp(), register() |
| `vsport_frontend/components/owner-register/ProgressBar.tsx` | Thanh tiến trình bước 1→2→3 |
| `vsport_frontend/components/owner-register/Step1EmailPhone.tsx` | Form email + SĐT, gửi OTP |
| `vsport_frontend/components/owner-register/Step2OTP.tsx` | 6 ô OTP, countdown, gửi lại |
| `vsport_frontend/components/owner-register/SportsTable.tsx` | Add-row table chọn môn thể thao |
| `vsport_frontend/components/owner-register/MapPicker.tsx` | Google Maps click-to-pick; fallback text |
| `vsport_frontend/components/owner-register/Step3Details.tsx` | Form chi tiết cơ sở |
| `vsport_frontend/components/owner-register/OwnerRegisterClient.tsx` | Wizard state machine |
| `vsport_frontend/app/owner-register/page.tsx` | Server Component wrapper |
| `vsport_frontend/components/owner-register/SuccessPageClient.tsx` | Màn hình thành công |
| `vsport_frontend/app/owner-register/success/page.tsx` | Server Component wrapper |

---

## Task 1: Backend — CORS cho /owner/* endpoints

**Files:**
- Modify: `src/main/java/org/example/controller/OwnerRegisterServlet.java`

**Interfaces:**
- Produces: CORS headers `Access-Control-Allow-Origin` + `Access-Control-Allow-Credentials: true` trên response từ `/owner/send-otp`, `/owner/verify-otp`, `/owner/register`, `/owner/otp-status` khi Origin là `localhost:*` hoặc `127.0.0.1:*`

- [ ] **Step 1: Thêm helper `addCorsHeaders` và override `doOptions` vào `OwnerRegisterServlet`**

Mở `src/main/java/org/example/controller/OwnerRegisterServlet.java`. Thêm method sau ngay trước `doGet`:

```java
// Dev-only CORS: cho phép Next.js frontend (localhost:3000) gọi sang backend (localhost:8080)
private void addCorsHeaders(HttpServletRequest req, HttpServletResponse resp) {
    String origin = req.getHeader("Origin");
    if (origin == null) return;
    String lower = origin.toLowerCase();
    if (lower.startsWith("http://localhost:") || lower.startsWith("http://127.0.0.1:")) {
        resp.setHeader("Access-Control-Allow-Origin", origin);
        resp.setHeader("Access-Control-Allow-Credentials", "true");
        resp.setHeader("Vary", "Origin");
        resp.setHeader("Access-Control-Allow-Headers", "Content-Type, Accept");
        resp.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
    }
}

@Override
protected void doOptions(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException {
    addCorsHeaders(req, resp);
    resp.setStatus(HttpServletResponse.SC_NO_CONTENT);
}
```

- [ ] **Step 2: Gọi `addCorsHeaders` ở đầu `doGet` và `doPost`**

Dòng đầu tiên của `doGet` (trước `if ("/owner/otp-status"...)`):
```java
addCorsHeaders(req, resp);
```

Dòng đầu tiên của `doPost` (trước `req.setCharacterEncoding`):
```java
addCorsHeaders(req, resp);
```

- [ ] **Step 3: Build backend để kiểm tra không lỗi compile**

```bash
mvn package -q -DskipTests
```

Expected: BUILD SUCCESS, không có lỗi.

- [ ] **Step 4: Commit**

```bash
git add src/main/java/org/example/controller/OwnerRegisterServlet.java
git commit -m "feat: add dev CORS headers to OwnerRegisterServlet for Next.js frontend"
```

---

## Task 2: Types + API layer

**Files:**
- Create: `vsport_frontend/types/owner-register.ts`
- Create: `vsport_frontend/lib/api/owner-register.ts`
- Create: `vsport_frontend/__tests__/api/owner-register.test.ts`

**Interfaces:**
- Produces:
  - `SportRow { sport: string; quantity: number }`
  - `RegistrationData { ownerName, email, phone, address, description, openTime, closeTime, operatingDays, sportsData, viDo?, kinhDo? }`
  - `OtpStatus { emailVerified, otpActive, secondsRemaining, otpEmail }`
  - `sendOtp(email: string, phone: string): Promise<{success: boolean; message?: string}>`
  - `verifyOtp(email: string, otp: string): Promise<{success: boolean; message?: string}>`
  - `register(data: RegistrationData): Promise<{success: boolean; message?: string}>`

- [ ] **Step 1: Viết test trước**

Tạo `vsport_frontend/__tests__/api/owner-register.test.ts`:

```typescript
import { sendOtp, verifyOtp, register } from '@/lib/api/owner-register'
import type { RegistrationData } from '@/types/owner-register'

const mockFetch = jest.fn()
beforeAll(() => { global.fetch = mockFetch })
afterEach(() => mockFetch.mockReset())

const BASE = 'http://localhost:8080/Backend_java'

describe('sendOtp', () => {
  it('POSTs email and phone to /owner/send-otp with credentials', async () => {
    mockFetch.mockResolvedValueOnce({ json: () => Promise.resolve({ success: true }) })

    const result = await sendOtp('owner@example.com', '0901234567')

    expect(mockFetch).toHaveBeenCalledWith(
      `${BASE}/owner/send-otp`,
      expect.objectContaining({
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      })
    )
    expect(result).toEqual({ success: true })
  })

  it('returns success: false with message on API error', async () => {
    mockFetch.mockResolvedValueOnce({
      json: () => Promise.resolve({ success: false, message: 'Email đã tồn tại.' }),
    })
    const result = await sendOtp('used@example.com', '0901234567')
    expect(result).toEqual({ success: false, message: 'Email đã tồn tại.' })
  })
})

describe('verifyOtp', () => {
  it('POSTs email and otp to /owner/verify-otp', async () => {
    mockFetch.mockResolvedValueOnce({ json: () => Promise.resolve({ success: true }) })

    await verifyOtp('owner@example.com', '123456')

    expect(mockFetch).toHaveBeenCalledWith(
      `${BASE}/owner/verify-otp`,
      expect.objectContaining({ method: 'POST', credentials: 'include' })
    )
  })
})

describe('register', () => {
  it('POSTs registration data to /owner/register', async () => {
    mockFetch.mockResolvedValueOnce({ json: () => Promise.resolve({ success: true }) })

    const data: RegistrationData = {
      ownerName: 'Sân Cầu Lông ABC',
      email: 'abc@example.com',
      phone: '0901234567',
      address: '123 Lê Lợi, Q1, TP.HCM',
      description: 'Cơ sở chất lượng',
      openTime: '06:00',
      closeTime: '22:00',
      operatingDays: 'T2,T3,T4,T5,T6',
      sportsData: '[{"sport":"Cầu lông","quantity":4}]',
    }

    const result = await register(data)

    expect(mockFetch).toHaveBeenCalledWith(
      `${BASE}/owner/register`,
      expect.objectContaining({ method: 'POST', credentials: 'include' })
    )
    expect(result).toEqual({ success: true })
  })
})
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

```bash
cd vsport_frontend && npm test -- --testPathPatterns="owner-register.test.ts" --watchAll=false
```

Expected: FAIL — "Cannot find module '@/lib/api/owner-register'"

- [ ] **Step 3: Tạo types**

Tạo `vsport_frontend/types/owner-register.ts`:

```typescript
export interface SportRow {
  sport: string
  quantity: number
}

export interface RegistrationData {
  ownerName: string
  email: string
  phone: string
  address: string
  description: string
  openTime: string
  closeTime: string
  operatingDays: string
  sportsData: string
  viDo?: string
  kinhDo?: string
}

export interface OtpStatus {
  emailVerified: boolean
  otpActive: boolean
  secondsRemaining: number
  otpEmail: string | null
}
```

- [ ] **Step 4: Tạo API layer**

Tạo `vsport_frontend/lib/api/owner-register.ts`:

```typescript
import type { RegistrationData } from '@/types/owner-register'

const BASE = process.env.NEXT_PUBLIC_BACKEND_URL

export async function sendOtp(
  email: string,
  phone: string
): Promise<{ success: boolean; message?: string }> {
  const res = await fetch(`${BASE}/owner/send-otp`, {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ email, phone }).toString(),
  })
  return res.json()
}

export async function verifyOtp(
  email: string,
  otp: string
): Promise<{ success: boolean; message?: string }> {
  const res = await fetch(`${BASE}/owner/verify-otp`, {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ email, otp }).toString(),
  })
  return res.json()
}

export async function register(
  data: RegistrationData
): Promise<{ success: boolean; message?: string }> {
  const res = await fetch(`${BASE}/owner/register`, {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams(data as Record<string, string>).toString(),
  })
  return res.json()
}
```

- [ ] **Step 5: Chạy test, xác nhận PASS**

```bash
cd vsport_frontend && npm test -- --testPathPatterns="owner-register.test.ts" --watchAll=false
```

Expected: PASS (3 test suites)

- [ ] **Step 6: Commit**

```bash
git add vsport_frontend/types/owner-register.ts vsport_frontend/lib/api/owner-register.ts vsport_frontend/__tests__/api/owner-register.test.ts
git commit -m "feat: add owner-register types and API layer"
```

---

## Task 3: ProgressBar

**Files:**
- Create: `vsport_frontend/components/owner-register/ProgressBar.tsx`
- Create: `vsport_frontend/__tests__/components/owner-register/ProgressBar.test.tsx`

**Interfaces:**
- Consumes: nothing
- Produces: `<ProgressBar currentStep={1 | 2 | 3} />`

- [ ] **Step 1: Viết test**

Tạo `vsport_frontend/__tests__/components/owner-register/ProgressBar.test.tsx`:

```tsx
import { render, screen } from '@testing-library/react'
import ProgressBar from '@/components/owner-register/ProgressBar'

describe('ProgressBar', () => {
  it('marks step 1 as active when currentStep is 1', () => {
    render(<ProgressBar currentStep={1} />)
    const step1 = screen.getByText('Xác thực email').closest('[aria-current]')
    expect(step1).toHaveAttribute('aria-current', 'step')
  })

  it('marks step 2 as active when currentStep is 2', () => {
    render(<ProgressBar currentStep={2} />)
    const step2 = screen.getByText('Mã xác nhận').closest('[aria-current]')
    expect(step2).toHaveAttribute('aria-current', 'step')
  })

  it('marks step 3 as active when currentStep is 3', () => {
    render(<ProgressBar currentStep={3} />)
    const step3 = screen.getByText('Thông tin cơ sở').closest('[aria-current]')
    expect(step3).toHaveAttribute('aria-current', 'step')
  })

  it('renders all 3 step labels', () => {
    render(<ProgressBar currentStep={1} />)
    expect(screen.getByText('Xác thực email')).toBeInTheDocument()
    expect(screen.getByText('Mã xác nhận')).toBeInTheDocument()
    expect(screen.getByText('Thông tin cơ sở')).toBeInTheDocument()
  })
})
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

```bash
cd vsport_frontend && npm test -- --testPathPatterns="ProgressBar" --watchAll=false
```

Expected: FAIL — "Cannot find module '@/components/owner-register/ProgressBar'"

- [ ] **Step 3: Tạo ProgressBar component**

Tạo `vsport_frontend/components/owner-register/ProgressBar.tsx`:

```tsx
interface Props {
  currentStep: 1 | 2 | 3
}

const STEPS = [
  { num: 1, label: 'Xác thực email' },
  { num: 2, label: 'Mã xác nhận' },
  { num: 3, label: 'Thông tin cơ sở' },
]

export default function ProgressBar({ currentStep }: Props) {
  return (
    <nav aria-label="Các bước đăng ký" className="bg-white border-b border-slate-100">
      <ol className="max-w-2xl mx-auto px-4 py-4 flex items-center gap-0">
        {STEPS.map((step, i) => {
          const isActive = step.num === currentStep
          const isDone = step.num < currentStep
          return (
            <li
              key={step.num}
              aria-current={isActive ? 'step' : undefined}
              className="flex items-center flex-1"
            >
              <div className="flex flex-col items-center gap-1 flex-1">
                <span
                  className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold transition-colors ${
                    isDone
                      ? 'bg-vs-blue text-white'
                      : isActive
                      ? 'bg-vs-navy text-white ring-4 ring-vs-navy/20'
                      : 'bg-slate-100 text-vs-slate'
                  }`}
                >
                  {isDone ? '✓' : step.num}
                </span>
                <span
                  className={`text-xs font-medium ${
                    isActive ? 'text-vs-navy' : isDone ? 'text-vs-blue' : 'text-vs-slate'
                  }`}
                >
                  {step.label}
                </span>
              </div>
              {i < STEPS.length - 1 && (
                <div
                  className={`h-0.5 flex-1 mx-2 -mt-4 transition-colors ${
                    step.num < currentStep ? 'bg-vs-blue' : 'bg-slate-200'
                  }`}
                />
              )}
            </li>
          )
        })}
      </ol>
    </nav>
  )
}
```

- [ ] **Step 4: Chạy test, xác nhận PASS**

```bash
cd vsport_frontend && npm test -- --testPathPatterns="ProgressBar" --watchAll=false
```

Expected: PASS (4 tests)

- [ ] **Step 5: Commit**

```bash
git add vsport_frontend/components/owner-register/ProgressBar.tsx vsport_frontend/__tests__/components/owner-register/ProgressBar.test.tsx
git commit -m "feat: add ProgressBar step indicator for owner registration"
```

---

## Task 4: Step1EmailPhone

**Files:**
- Create: `vsport_frontend/components/owner-register/Step1EmailPhone.tsx`
- Create: `vsport_frontend/__tests__/components/owner-register/Step1EmailPhone.test.tsx`

**Interfaces:**
- Consumes: `sendOtp` từ `@/lib/api/owner-register`
- Produces: `<Step1EmailPhone onSuccess={(email: string, phone: string) => void} />`

- [ ] **Step 1: Viết test**

Tạo `vsport_frontend/__tests__/components/owner-register/Step1EmailPhone.test.tsx`:

```tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import Step1EmailPhone from '@/components/owner-register/Step1EmailPhone'

jest.mock('@/lib/api/owner-register', () => ({
  sendOtp: jest.fn(),
}))

import { sendOtp } from '@/lib/api/owner-register'
const mockSendOtp = sendOtp as jest.Mock

beforeEach(() => mockSendOtp.mockReset())

describe('Step1EmailPhone', () => {
  it('renders email and phone fields', () => {
    render(<Step1EmailPhone onSuccess={jest.fn()} />)
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/số điện thoại/i)).toBeInTheDocument()
  })

  it('shows error when email is invalid', async () => {
    render(<Step1EmailPhone onSuccess={jest.fn()} />)
    fireEvent.change(screen.getByLabelText(/email/i), { target: { value: 'notanemail' } })
    fireEvent.change(screen.getByLabelText(/số điện thoại/i), { target: { value: '0901234567' } })
    fireEvent.click(screen.getByRole('button', { name: /gửi mã otp/i }))
    expect(await screen.findByText(/email không hợp lệ/i)).toBeInTheDocument()
    expect(mockSendOtp).not.toHaveBeenCalled()
  })

  it('shows error when phone is invalid', async () => {
    render(<Step1EmailPhone onSuccess={jest.fn()} />)
    fireEvent.change(screen.getByLabelText(/email/i), { target: { value: 'owner@example.com' } })
    fireEvent.change(screen.getByLabelText(/số điện thoại/i), { target: { value: '12345' } })
    fireEvent.click(screen.getByRole('button', { name: /gửi mã otp/i }))
    expect(await screen.findByText(/số điện thoại không hợp lệ/i)).toBeInTheDocument()
    expect(mockSendOtp).not.toHaveBeenCalled()
  })

  it('calls sendOtp and onSuccess with valid inputs', async () => {
    mockSendOtp.mockResolvedValueOnce({ success: true })
    const onSuccess = jest.fn()
    render(<Step1EmailPhone onSuccess={onSuccess} />)
    fireEvent.change(screen.getByLabelText(/email/i), { target: { value: 'owner@example.com' } })
    fireEvent.change(screen.getByLabelText(/số điện thoại/i), { target: { value: '0901234567' } })
    fireEvent.click(screen.getByRole('button', { name: /gửi mã otp/i }))
    await waitFor(() => expect(onSuccess).toHaveBeenCalledWith('owner@example.com', '0901234567'))
  })

  it('shows API error message on failure', async () => {
    mockSendOtp.mockResolvedValueOnce({ success: false, message: 'Email đã tồn tại trong hệ thống.' })
    render(<Step1EmailPhone onSuccess={jest.fn()} />)
    fireEvent.change(screen.getByLabelText(/email/i), { target: { value: 'used@example.com' } })
    fireEvent.change(screen.getByLabelText(/số điện thoại/i), { target: { value: '0901234567' } })
    fireEvent.click(screen.getByRole('button', { name: /gửi mã otp/i }))
    expect(await screen.findByText(/email đã tồn tại/i)).toBeInTheDocument()
  })
})
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

```bash
cd vsport_frontend && npm test -- --testPathPatterns="Step1EmailPhone" --watchAll=false
```

Expected: FAIL — "Cannot find module '@/components/owner-register/Step1EmailPhone'"

- [ ] **Step 3: Tạo component**

Tạo `vsport_frontend/components/owner-register/Step1EmailPhone.tsx`:

```tsx
'use client'

import { useState } from 'react'
import { sendOtp } from '@/lib/api/owner-register'
import { Mail, Phone, ArrowRight } from 'lucide-react'

interface Props {
  onSuccess: (email: string, phone: string) => void
}

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const VN_PHONE_RE = /^(0[35789])\d{8}$/

export default function Step1EmailPhone({ onSuccess }: Props) {
  const [email, setEmail] = useState('')
  const [phone, setPhone] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')

    if (!EMAIL_RE.test(email.trim())) {
      setError('Email không hợp lệ. Vui lòng kiểm tra lại.')
      return
    }
    if (!VN_PHONE_RE.test(phone.trim())) {
      setError('Số điện thoại không hợp lệ. Nhập đúng định dạng 0xxx xxxxxxx.')
      return
    }

    setLoading(true)
    try {
      const res = await sendOtp(email.trim(), phone.trim())
      if (res.success) {
        onSuccess(email.trim(), phone.trim())
      } else {
        setError(res.message ?? 'Gửi OTP thất bại. Vui lòng thử lại.')
      }
    } catch {
      setError('Lỗi kết nối. Vui lòng thử lại.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <section className="max-w-lg mx-auto px-4 py-12">
      <h1 className="text-2xl font-bold text-vs-navy mb-2">Đăng ký đối tác</h1>
      <p className="text-vs-slate text-sm mb-8">
        Nhập email và số điện thoại để nhận mã xác thực. OTP gửi đến hộp thư của bạn.
      </p>

      <form onSubmit={handleSubmit} noValidate className="space-y-5">
        <div>
          <label htmlFor="email" className="block text-sm font-medium text-vs-navy mb-1.5">
            Email <span className="text-red-500">*</span>
          </label>
          <div className="relative">
            <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-vs-slate" />
            <input
              id="email"
              type="email"
              value={email}
              onChange={e => setEmail(e.target.value)}
              placeholder="owner@example.com"
              className="w-full pl-10 pr-4 py-3 rounded-xl border border-slate-200 focus:border-vs-blue focus:ring-2 focus:ring-vs-blue/20 outline-none text-vs-navy text-sm"
              required
            />
          </div>
        </div>

        <div>
          <label htmlFor="phone" className="block text-sm font-medium text-vs-navy mb-1.5">
            Số điện thoại <span className="text-red-500">*</span>
          </label>
          <div className="relative">
            <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-vs-slate" />
            <input
              id="phone"
              type="tel"
              value={phone}
              onChange={e => setPhone(e.target.value)}
              placeholder="0901 234 567"
              className="w-full pl-10 pr-4 py-3 rounded-xl border border-slate-200 focus:border-vs-blue focus:ring-2 focus:ring-vs-blue/20 outline-none text-vs-navy text-sm"
              required
            />
          </div>
        </div>

        {error && (
          <p role="alert" className="text-sm text-red-600 bg-red-50 rounded-lg px-4 py-3">
            {error}
          </p>
        )}

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-vs-blue hover:bg-vs-navy text-white font-semibold py-3 px-6 rounded-xl transition-colors flex items-center justify-center gap-2 disabled:opacity-60"
        >
          {loading ? 'Đang gửi...' : 'Gửi mã OTP'}
          {!loading && <ArrowRight className="w-4 h-4" />}
        </button>
      </form>
    </section>
  )
}
```

- [ ] **Step 4: Chạy test, xác nhận PASS**

```bash
cd vsport_frontend && npm test -- --testPathPatterns="Step1EmailPhone" --watchAll=false
```

Expected: PASS (5 tests)

- [ ] **Step 5: Commit**

```bash
git add vsport_frontend/components/owner-register/Step1EmailPhone.tsx vsport_frontend/__tests__/components/owner-register/Step1EmailPhone.test.tsx
git commit -m "feat: add Step1EmailPhone for owner registration wizard"
```

---

## Task 5: Step2OTP

**Files:**
- Create: `vsport_frontend/components/owner-register/Step2OTP.tsx`
- Create: `vsport_frontend/__tests__/components/owner-register/Step2OTP.test.tsx`

**Interfaces:**
- Consumes: `verifyOtp` từ `@/lib/api/owner-register`
- Produces: `<Step2OTP email={string} onSuccess={() => void} onBack={() => void} />`

- [ ] **Step 1: Viết test**

Tạo `vsport_frontend/__tests__/components/owner-register/Step2OTP.test.tsx`:

```tsx
import { render, screen, fireEvent, waitFor, act } from '@testing-library/react'
import Step2OTP from '@/components/owner-register/Step2OTP'

jest.mock('@/lib/api/owner-register', () => ({
  sendOtp: jest.fn(),
  verifyOtp: jest.fn(),
}))

import { verifyOtp, sendOtp } from '@/lib/api/owner-register'
const mockVerifyOtp = verifyOtp as jest.Mock
const mockSendOtp = sendOtp as jest.Mock

beforeEach(() => {
  mockVerifyOtp.mockReset()
  mockSendOtp.mockReset()
  jest.useFakeTimers()
})
afterEach(() => jest.useRealTimers())

const defaultProps = {
  email: 'owner@example.com',
  phone: '0901234567',
  onSuccess: jest.fn(),
  onBack: jest.fn(),
}

describe('Step2OTP', () => {
  it('renders 6 OTP input boxes', () => {
    render(<Step2OTP {...defaultProps} />)
    const inputs = screen.getAllByRole('textbox')
    expect(inputs).toHaveLength(6)
  })

  it('shows the email address in instructions', () => {
    render(<Step2OTP {...defaultProps} />)
    expect(screen.getByText(/owner@example\.com/)).toBeInTheDocument()
  })

  it('calls verifyOtp and onSuccess when 6 digits are entered', async () => {
    mockVerifyOtp.mockResolvedValueOnce({ success: true })
    render(<Step2OTP {...defaultProps} />)
    const inputs = screen.getAllByRole('textbox')

    act(() => {
      inputs.forEach((input, i) => {
        fireEvent.change(input, { target: { value: String(i + 1) } })
      })
    })

    await waitFor(() => expect(mockVerifyOtp).toHaveBeenCalledWith('owner@example.com', '123456'))
    await waitFor(() => expect(defaultProps.onSuccess).toHaveBeenCalled())
  })

  it('shows error when OTP is wrong', async () => {
    mockVerifyOtp.mockResolvedValueOnce({ success: false, message: 'Mã OTP không đúng.' })
    render(<Step2OTP {...defaultProps} />)
    const inputs = screen.getAllByRole('textbox')
    act(() => {
      inputs.forEach((input, i) => {
        fireEvent.change(input, { target: { value: String(i + 1) } })
      })
    })
    expect(await screen.findByText(/mã otp không đúng/i)).toBeInTheDocument()
  })

  it('calls onBack when back button is clicked', () => {
    const onBack = jest.fn()
    render(<Step2OTP {...defaultProps} onBack={onBack} />)
    fireEvent.click(screen.getByRole('button', { name: /quay lại/i }))
    expect(onBack).toHaveBeenCalled()
  })

  it('shows resend button disabled while countdown is active', () => {
    render(<Step2OTP {...defaultProps} />)
    const resend = screen.getByRole('button', { name: /gửi lại/i })
    expect(resend).toBeDisabled()
  })

  it('enables resend button when countdown reaches 0', async () => {
    render(<Step2OTP {...defaultProps} />)
    // Tick 301× because each act() flushes one React re-render + new setTimeout
    for (let i = 0; i <= 300; i++) {
      await act(async () => { jest.advanceTimersByTime(1000) })
    }
    expect(screen.getByRole('button', { name: /gửi lại/i })).not.toBeDisabled()
  })
})
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

```bash
cd vsport_frontend && npm test -- --testPathPatterns="Step2OTP" --watchAll=false
```

Expected: FAIL — "Cannot find module '@/components/owner-register/Step2OTP'"

- [ ] **Step 3: Tạo component**

Tạo `vsport_frontend/components/owner-register/Step2OTP.tsx`:

```tsx
'use client'

import { useState, useRef, useEffect, useCallback } from 'react'
import { ArrowLeft } from 'lucide-react'
import { verifyOtp, sendOtp } from '@/lib/api/owner-register'

interface Props {
  email: string
  phone: string
  onSuccess: () => void
  onBack: () => void
}

export default function Step2OTP({ email, phone, onSuccess, onBack }: Props) {
  const [digits, setDigits] = useState<string[]>(['', '', '', '', '', ''])
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [secondsLeft, setSecondsLeft] = useState(300)
  const inputRefs = useRef<Array<HTMLInputElement | null>>([])

  // Countdown
  useEffect(() => {
    if (secondsLeft <= 0) return
    const id = setTimeout(() => setSecondsLeft(s => s - 1), 1000)
    return () => clearTimeout(id)
  }, [secondsLeft])

  const mm = String(Math.floor(secondsLeft / 60)).padStart(2, '0')
  const ss = String(secondsLeft % 60).padStart(2, '0')

  const submit = useCallback(
    async (otp: string) => {
      if (loading) return
      setLoading(true)
      setError('')
      try {
        const res = await verifyOtp(email, otp)
        if (res.success) {
          onSuccess()
        } else {
          setError(res.message ?? 'Mã OTP không đúng. Vui lòng thử lại.')
          setDigits(['', '', '', '', '', ''])
          inputRefs.current[0]?.focus()
        }
      } catch {
        setError('Lỗi kết nối. Vui lòng thử lại.')
      } finally {
        setLoading(false)
      }
    },
    [email, loading, onSuccess]
  )

  const handleChange = (index: number, value: string) => {
    if (!/^\d?$/.test(value)) return
    const next = [...digits]
    next[index] = value
    setDigits(next)
    if (value && index < 5) {
      inputRefs.current[index + 1]?.focus()
    }
    if (next.every(d => d !== '')) {
      submit(next.join(''))
    }
  }

  const handleKeyDown = (index: number, e: React.KeyboardEvent) => {
    if (e.key === 'Backspace' && !digits[index] && index > 0) {
      inputRefs.current[index - 1]?.focus()
    }
  }

  const handlePaste = (e: React.ClipboardEvent) => {
    const pasted = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6)
    if (pasted.length === 6) {
      e.preventDefault()
      const next = pasted.split('')
      setDigits(next)
      inputRefs.current[5]?.focus()
      submit(pasted)
    }
  }

  const handleResend = async () => {
    setError('')
    setDigits(['', '', '', '', '', ''])
    try {
      await sendOtp(email, phone)
      setSecondsLeft(300)
    } catch {
      setError('Lỗi gửi lại OTP. Vui lòng thử lại.')
    }
  }

  return (
    <section className="max-w-lg mx-auto px-4 py-12">
      <button
        type="button"
        onClick={onBack}
        aria-label="Quay lại"
        className="flex items-center gap-1.5 text-vs-slate text-sm mb-8 hover:text-vs-navy transition-colors"
      >
        <ArrowLeft className="w-4 h-4" /> Quay lại
      </button>

      <h2 className="text-2xl font-bold text-vs-navy mb-2">Nhập mã xác nhận</h2>
      <p className="text-vs-slate text-sm mb-8">
        Chúng tôi đã gửi mã OTP 6 chữ số đến <strong>{email}</strong>.
      </p>

      <div className="flex gap-3 justify-center mb-6" onPaste={handlePaste}>
        {digits.map((d, i) => (
          <input
            key={i}
            ref={el => { inputRefs.current[i] = el }}
            type="text"
            inputMode="numeric"
            maxLength={1}
            value={d}
            onChange={e => handleChange(i, e.target.value)}
            onKeyDown={e => handleKeyDown(i, e)}
            aria-label={`Số ${i + 1}`}
            className="w-12 h-14 text-center text-xl font-bold border-2 rounded-xl border-slate-200 focus:border-vs-blue focus:ring-2 focus:ring-vs-blue/20 outline-none text-vs-navy"
          />
        ))}
      </div>

      {error && (
        <p role="alert" className="text-sm text-red-600 bg-red-50 rounded-lg px-4 py-3 mb-4 text-center">
          {error}
        </p>
      )}

      <div className="flex items-center justify-between text-sm">
        <span className="text-vs-slate">
          {secondsLeft > 0 ? `Mã hết hạn sau ${mm}:${ss}` : 'Mã đã hết hạn'}
        </span>
        <button
          type="button"
          onClick={handleResend}
          disabled={secondsLeft > 0}
          className="font-medium text-vs-blue hover:text-vs-navy disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
        >
          Gửi lại
        </button>
      </div>

      {loading && (
        <p className="text-center text-vs-slate text-sm mt-4">Đang xác nhận...</p>
      )}
    </section>
  )
}
```

- [ ] **Step 4: Chạy test, xác nhận PASS**

```bash
cd vsport_frontend && npm test -- --testPathPatterns="Step2OTP" --watchAll=false
```

Expected: PASS (7 tests)

- [ ] **Step 5: Commit**

```bash
git add vsport_frontend/components/owner-register/Step2OTP.tsx vsport_frontend/__tests__/components/owner-register/Step2OTP.test.tsx
git commit -m "feat: add Step2OTP with 6-digit auto-submit and countdown"
```

---

## Task 6: SportsTable

**Files:**
- Create: `vsport_frontend/components/owner-register/SportsTable.tsx`
- Create: `vsport_frontend/__tests__/components/owner-register/SportsTable.test.tsx`

**Interfaces:**
- Consumes: `SportRow` từ `@/types/owner-register`
- Produces: `<SportsTable value={SportRow[]} onChange={(rows: SportRow[]) => void} />`

- [ ] **Step 1: Viết test**

Tạo `vsport_frontend/__tests__/components/owner-register/SportsTable.test.tsx`:

```tsx
import { render, screen, fireEvent } from '@testing-library/react'
import SportsTable from '@/components/owner-register/SportsTable'
import type { SportRow } from '@/types/owner-register'

const defaultRows: SportRow[] = [{ sport: 'Cầu lông', quantity: 2 }]

describe('SportsTable', () => {
  it('renders existing rows', () => {
    render(<SportsTable value={defaultRows} onChange={jest.fn()} />)
    expect(screen.getByDisplayValue('Cầu lông')).toBeInTheDocument()
    expect(screen.getByDisplayValue('2')).toBeInTheDocument()
  })

  it('calls onChange with new row when "Thêm môn" is clicked', () => {
    const onChange = jest.fn()
    render(<SportsTable value={defaultRows} onChange={onChange} />)
    fireEvent.click(screen.getByRole('button', { name: /thêm môn/i }))
    expect(onChange).toHaveBeenCalledWith(
      expect.arrayContaining([
        { sport: 'Cầu lông', quantity: 2 },
        expect.objectContaining({ quantity: 1 }),
      ])
    )
  })

  it('calls onChange without removed row when delete is clicked', () => {
    const rows: SportRow[] = [
      { sport: 'Cầu lông', quantity: 2 },
      { sport: 'Bóng đá', quantity: 1 },
    ]
    const onChange = jest.fn()
    render(<SportsTable value={rows} onChange={onChange} />)
    const deleteButtons = screen.getAllByRole('button', { name: /xóa/i })
    fireEvent.click(deleteButtons[0])
    expect(onChange).toHaveBeenCalledWith([{ sport: 'Bóng đá', quantity: 1 }])
  })

  it('does not show delete button when only 1 row', () => {
    render(<SportsTable value={defaultRows} onChange={jest.fn()} />)
    expect(screen.queryByRole('button', { name: /xóa/i })).not.toBeInTheDocument()
  })

  it('does not show "Thêm môn" when all sports are selected', () => {
    const allSports: SportRow[] = [
      'Cầu lông', 'Bóng đá', 'Bida', 'Pickleball',
      'Tennis', 'Bóng rổ', 'Bóng chuyền', 'Bơi lội',
    ].map(sport => ({ sport, quantity: 1 }))
    render(<SportsTable value={allSports} onChange={jest.fn()} />)
    expect(screen.queryByRole('button', { name: /thêm môn/i })).not.toBeInTheDocument()
  })

  it('updates quantity when input changes', () => {
    const onChange = jest.fn()
    render(<SportsTable value={defaultRows} onChange={onChange} />)
    fireEvent.change(screen.getByDisplayValue('2'), { target: { value: '5' } })
    expect(onChange).toHaveBeenCalledWith([{ sport: 'Cầu lông', quantity: 5 }])
  })
})
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

```bash
cd vsport_frontend && npm test -- --testPathPatterns="SportsTable" --watchAll=false
```

Expected: FAIL — "Cannot find module '@/components/owner-register/SportsTable'"

- [ ] **Step 3: Tạo component**

Tạo `vsport_frontend/components/owner-register/SportsTable.tsx`:

```tsx
'use client'

import { Plus, X } from 'lucide-react'
import type { SportRow } from '@/types/owner-register'

const SPORTS = [
  'Cầu lông', 'Bóng đá', 'Bida', 'Pickleball',
  'Tennis', 'Bóng rổ', 'Bóng chuyền', 'Bơi lội',
]

interface Props {
  value: SportRow[]
  onChange: (rows: SportRow[]) => void
}

export default function SportsTable({ value, onChange }: Props) {
  const usedSports = value.map(r => r.sport)
  const available = SPORTS.filter(s => !usedSports.includes(s))

  const addRow = () => {
    if (available.length === 0) return
    onChange([...value, { sport: available[0], quantity: 1 }])
  }

  const removeRow = (i: number) => {
    onChange(value.filter((_, idx) => idx !== i))
  }

  const updateSport = (i: number, sport: string) => {
    onChange(value.map((r, idx) => (idx === i ? { ...r, sport } : r)))
  }

  const updateQuantity = (i: number, qty: number) => {
    onChange(value.map((r, idx) => (idx === i ? { ...r, quantity: qty } : r)))
  }

  return (
    <div className="space-y-3">
      {value.map((row, i) => (
        <div key={i} className="flex items-center gap-3">
          <select
            value={row.sport}
            onChange={e => updateSport(i, e.target.value)}
            className="flex-1 rounded-xl border border-slate-200 px-3 py-2.5 text-sm text-vs-navy focus:border-vs-blue focus:ring-2 focus:ring-vs-blue/20 outline-none"
          >
            {SPORTS.filter(s => s === row.sport || !usedSports.includes(s)).map(s => (
              <option key={s} value={s}>{s}</option>
            ))}
          </select>

          <input
            type="number"
            min={1}
            max={99}
            value={row.quantity}
            onChange={e => updateQuantity(i, parseInt(e.target.value) || 1)}
            className="w-20 rounded-xl border border-slate-200 px-3 py-2.5 text-sm text-vs-navy text-center focus:border-vs-blue focus:ring-2 focus:ring-vs-blue/20 outline-none"
          />
          <span className="text-vs-slate text-sm shrink-0">sân</span>

          {value.length > 1 && (
            <button
              type="button"
              onClick={() => removeRow(i)}
              aria-label="Xóa"
              className="text-slate-400 hover:text-red-500 transition-colors"
            >
              <X className="w-4 h-4" />
            </button>
          )}
        </div>
      ))}

      {available.length > 0 && (
        <button
          type="button"
          onClick={addRow}
          className="flex items-center gap-2 text-vs-blue text-sm font-medium hover:text-vs-navy transition-colors mt-1"
        >
          <Plus className="w-4 h-4" /> Thêm môn
        </button>
      )}
    </div>
  )
}
```

- [ ] **Step 4: Chạy test, xác nhận PASS**

```bash
cd vsport_frontend && npm test -- --testPathPatterns="SportsTable" --watchAll=false
```

Expected: PASS (6 tests)

- [ ] **Step 5: Commit**

```bash
git add vsport_frontend/components/owner-register/SportsTable.tsx vsport_frontend/__tests__/components/owner-register/SportsTable.test.tsx
git commit -m "feat: add SportsTable component for sport/court selection"
```

---

## Task 7: MapPicker

**Files:**
- Create: `vsport_frontend/components/owner-register/MapPicker.tsx`
- Create: `vsport_frontend/__tests__/components/owner-register/MapPicker.test.tsx`

**Interfaces:**
- Produces: `<MapPicker viDo?: string kinhDo?: string onChange: (lat: string, lng: string) => void />`
- Fallback (khi `NEXT_PUBLIC_GOOGLE_MAPS_KEY` không có): 2 text input Vĩ độ / Kinh độ

- [ ] **Step 1: Viết test**

Tạo `vsport_frontend/__tests__/components/owner-register/MapPicker.test.tsx`:

```tsx
import { render, screen, fireEvent } from '@testing-library/react'

jest.mock('next/script', () => ({
  __esModule: true,
  default: () => null,
}))

import MapPicker from '@/components/owner-register/MapPicker'

// In test env, NEXT_PUBLIC_GOOGLE_MAPS_KEY is undefined → fallback renders
describe('MapPicker (fallback — no API key)', () => {
  it('renders Vĩ độ and Kinh độ text inputs as fallback', () => {
    render(<MapPicker onChange={jest.fn()} />)
    expect(screen.getByPlaceholderText(/vĩ độ/i)).toBeInTheDocument()
    expect(screen.getByPlaceholderText(/kinh độ/i)).toBeInTheDocument()
  })

  it('pre-fills inputs from viDo and kinhDo props', () => {
    render(<MapPicker viDo="10.82" kinhDo="106.63" onChange={jest.fn()} />)
    expect(screen.getByDisplayValue('10.82')).toBeInTheDocument()
    expect(screen.getByDisplayValue('106.63')).toBeInTheDocument()
  })

  it('calls onChange when Vĩ độ changes', () => {
    const onChange = jest.fn()
    render(<MapPicker kinhDo="106.63" onChange={onChange} />)
    fireEvent.change(screen.getByPlaceholderText(/vĩ độ/i), { target: { value: '10.99' } })
    expect(onChange).toHaveBeenCalledWith('10.99', '106.63')
  })

  it('calls onChange when Kinh độ changes', () => {
    const onChange = jest.fn()
    render(<MapPicker viDo="10.82" onChange={onChange} />)
    fireEvent.change(screen.getByPlaceholderText(/kinh độ/i), { target: { value: '107.00' } })
    expect(onChange).toHaveBeenCalledWith('10.82', '107.00')
  })
})
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

```bash
cd vsport_frontend && npm test -- --testPathPatterns="MapPicker" --watchAll=false
```

Expected: FAIL — "Cannot find module '@/components/owner-register/MapPicker'"

- [ ] **Step 3: Tạo component**

Tạo `vsport_frontend/components/owner-register/MapPicker.tsx`:

```tsx
'use client'

import { useRef, useEffect, useState } from 'react'
import Script from 'next/script'

interface Props {
  viDo?: string
  kinhDo?: string
  onChange: (lat: string, lng: string) => void
}

const API_KEY = process.env.NEXT_PUBLIC_GOOGLE_MAPS_KEY

declare global {
  interface Window {
    google?: {
      maps: {
        Map: new (
          el: HTMLElement,
          opts: { center: { lat: number; lng: number }; zoom: number }
        ) => {
          addListener: (
            event: string,
            fn: (e: { latLng: { lat: () => number; lng: () => number } }) => void
          ) => void
        }
        Marker: new (opts: {
          map: unknown
          position: { lat: number; lng: number }
        }) => { setPosition: (p: { lat: number; lng: number }) => void }
      }
    }
  }
}

export default function MapPicker({ viDo, kinhDo, onChange }: Props) {
  const mapRef = useRef<HTMLDivElement>(null)
  const [mapsLoaded, setMapsLoaded] = useState(false)
  const [localLat, setLocalLat] = useState(viDo ?? '')
  const [localLng, setLocalLng] = useState(kinhDo ?? '')

  useEffect(() => {
    if (!mapsLoaded || !mapRef.current || !window.google) return
    const center = viDo && kinhDo
      ? { lat: parseFloat(viDo), lng: parseFloat(kinhDo) }
      : { lat: 10.8231, lng: 106.6297 }

    const map = new window.google.maps.Map(mapRef.current, { center, zoom: 13 })
    const marker = new window.google.maps.Marker({ map, position: center })

    map.addListener('click', (e: { latLng: { lat: () => number; lng: () => number } }) => {
      const lat = e.latLng.lat().toFixed(6)
      const lng = e.latLng.lng().toFixed(6)
      marker.setPosition({ lat: parseFloat(lat), lng: parseFloat(lng) })
      onChange(lat, lng)
    })
  }, [mapsLoaded]) // eslint-disable-line react-hooks/exhaustive-deps

  if (!API_KEY) {
    return (
      <div className="grid grid-cols-2 gap-3">
        <div>
          <label htmlFor="viDo" className="block text-xs text-vs-slate mb-1">Vĩ độ</label>
          <input
            id="viDo"
            type="number"
            step="any"
            placeholder="Vĩ độ (10.82...)"
            value={localLat}
            onChange={e => {
              setLocalLat(e.target.value)
              onChange(e.target.value, localLng)
            }}
            className="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm text-vs-navy focus:border-vs-blue focus:ring-2 focus:ring-vs-blue/20 outline-none"
          />
        </div>
        <div>
          <label htmlFor="kinhDo" className="block text-xs text-vs-slate mb-1">Kinh độ</label>
          <input
            id="kinhDo"
            type="number"
            step="any"
            placeholder="Kinh độ (106.62...)"
            value={localLng}
            onChange={e => {
              setLocalLng(e.target.value)
              onChange(localLat, e.target.value)
            }}
            className="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm text-vs-navy focus:border-vs-blue focus:ring-2 focus:ring-vs-blue/20 outline-none"
          />
        </div>
      </div>
    )
  }

  return (
    <>
      <Script
        src={`https://maps.googleapis.com/maps/api/js?key=${API_KEY}`}
        onLoad={() => setMapsLoaded(true)}
      />
      <div
        ref={mapRef}
        className="w-full h-64 rounded-xl border border-slate-200 bg-slate-50"
      />
      {!mapsLoaded && (
        <p className="text-center text-vs-slate text-sm mt-2">Đang tải bản đồ...</p>
      )}
    </>
  )
}
```

- [ ] **Step 4: Chạy test, xác nhận PASS**

```bash
cd vsport_frontend && npm test -- --testPathPatterns="MapPicker" --watchAll=false
```

Expected: PASS (4 tests)

- [ ] **Step 5: Commit**

```bash
git add vsport_frontend/components/owner-register/MapPicker.tsx vsport_frontend/__tests__/components/owner-register/MapPicker.test.tsx
git commit -m "feat: add MapPicker with Google Maps and text-input fallback"
```

---

## Task 8: Step3Details

**Files:**
- Create: `vsport_frontend/components/owner-register/Step3Details.tsx`
- Create: `vsport_frontend/__tests__/components/owner-register/Step3Details.test.tsx`

**Interfaces:**
- Consumes: `SportsTable`, `MapPicker`, `register` từ `@/lib/api/owner-register`, types từ `@/types/owner-register`
- Produces: `<Step3Details email={string} phone={string} onSuccess={() => void} />`

- [ ] **Step 1: Viết test**

Tạo `vsport_frontend/__tests__/components/owner-register/Step3Details.test.tsx`:

```tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react'

jest.mock('@/lib/api/owner-register', () => ({
  register: jest.fn(),
}))
jest.mock('@/components/owner-register/SportsTable', () => ({
  __esModule: true,
  default: ({ onChange }: { onChange: (r: unknown[]) => void }) => (
    <button onClick={() => onChange([{ sport: 'Cầu lông', quantity: 2 }])}>MockSports</button>
  ),
}))
jest.mock('@/components/owner-register/MapPicker', () => ({
  __esModule: true,
  default: () => <div>MockMap</div>,
}))

import Step3Details from '@/components/owner-register/Step3Details'
import { register } from '@/lib/api/owner-register'
const mockRegister = register as jest.Mock

beforeEach(() => mockRegister.mockReset())

const defaultProps = {
  email: 'owner@example.com',
  phone: '0901234567',
  onSuccess: jest.fn(),
}

describe('Step3Details', () => {
  it('renders required form fields', () => {
    render(<Step3Details {...defaultProps} />)
    expect(screen.getByLabelText(/tên cơ sở/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/địa chỉ/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/giờ mở cửa/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/giờ đóng cửa/i)).toBeInTheDocument()
  })

  it('shows pre-filled readonly email and phone', () => {
    render(<Step3Details {...defaultProps} />)
    const emailInput = screen.getByDisplayValue('owner@example.com')
    expect(emailInput).toHaveAttribute('readonly')
    const phoneInput = screen.getByDisplayValue('0901234567')
    expect(phoneInput).toHaveAttribute('readonly')
  })

  it('shows validation error when required fields are empty', async () => {
    render(<Step3Details {...defaultProps} />)
    fireEvent.click(screen.getByRole('button', { name: /hoàn tất/i }))
    expect(await screen.findByRole('alert')).toBeInTheDocument()
    expect(mockRegister).not.toHaveBeenCalled()
  })

  it('calls register and onSuccess when form is valid', async () => {
    mockRegister.mockResolvedValueOnce({ success: true })
    render(<Step3Details {...defaultProps} />)

    fireEvent.change(screen.getByLabelText(/tên cơ sở/i), { target: { value: 'Sân ABC' } })
    fireEvent.change(screen.getByLabelText(/địa chỉ/i), { target: { value: '123 Lê Lợi' } })
    fireEvent.change(screen.getByLabelText(/giờ mở cửa/i), { target: { value: '06:00' } })
    fireEvent.change(screen.getByLabelText(/giờ đóng cửa/i), { target: { value: '22:00' } })
    // Check at least one day
    fireEvent.click(screen.getAllByRole('checkbox')[0])

    fireEvent.click(screen.getByRole('button', { name: /hoàn tất/i }))
    await waitFor(() => expect(defaultProps.onSuccess).toHaveBeenCalled())
  })
})
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

```bash
cd vsport_frontend && npm test -- --testPathPatterns="Step3Details" --watchAll=false
```

Expected: FAIL — "Cannot find module '@/components/owner-register/Step3Details'"

- [ ] **Step 3: Tạo component**

Tạo `vsport_frontend/components/owner-register/Step3Details.tsx`:

```tsx
'use client'

import { useState } from 'react'
import { MapPin, Clock, CalendarDays, AlignLeft } from 'lucide-react'
import SportsTable from './SportsTable'
import MapPicker from './MapPicker'
import { register } from '@/lib/api/owner-register'
import type { SportRow, RegistrationData } from '@/types/owner-register'

interface Props {
  email: string
  phone: string
  onSuccess: () => void
}

const DAYS = [
  { key: 'T2', label: 'T2' },
  { key: 'T3', label: 'T3' },
  { key: 'T4', label: 'T4' },
  { key: 'T5', label: 'T5' },
  { key: 'T6', label: 'T6' },
  { key: 'T7', label: 'T7' },
  { key: 'CN', label: 'CN' },
]

export default function Step3Details({ email, phone, onSuccess }: Props) {
  const [ownerName, setOwnerName] = useState('')
  const [address, setAddress] = useState('')
  const [description, setDescription] = useState('')
  const [openTime, setOpenTime] = useState('')
  const [closeTime, setCloseTime] = useState('')
  const [operatingDays, setOperatingDays] = useState<string[]>([])
  const [sports, setSports] = useState<SportRow[]>([{ sport: 'Cầu lông', quantity: 1 }])
  const [viDo, setViDo] = useState('')
  const [kinhDo, setKinhDo] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const toggleDay = (day: string) => {
    setOperatingDays(prev =>
      prev.includes(day) ? prev.filter(d => d !== day) : [...prev, day]
    )
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')

    if (!ownerName.trim()) { setError('Vui lòng nhập tên cơ sở.'); return }
    if (!address.trim()) { setError('Vui lòng nhập địa chỉ.'); return }
    if (!openTime) { setError('Vui lòng nhập giờ mở cửa.'); return }
    if (!closeTime) { setError('Vui lòng nhập giờ đóng cửa.'); return }
    if (operatingDays.length === 0) { setError('Vui lòng chọn ít nhất một ngày hoạt động.'); return }
    if (sports.length === 0) { setError('Vui lòng thêm ít nhất một môn thể thao.'); return }

    const data: RegistrationData = {
      ownerName: ownerName.trim(),
      email,
      phone,
      address: address.trim(),
      description: description.trim(),
      openTime,
      closeTime,
      operatingDays: operatingDays.join(','),
      sportsData: JSON.stringify(sports),
      ...(viDo && kinhDo ? { viDo, kinhDo } : {}),
    }

    setLoading(true)
    try {
      const res = await register(data)
      if (res.success) {
        onSuccess()
      } else {
        setError(res.message ?? 'Đăng ký thất bại. Vui lòng thử lại.')
      }
    } catch {
      setError('Lỗi kết nối. Vui lòng thử lại.')
    } finally {
      setLoading(false)
    }
  }

  const fieldClass =
    'w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm text-vs-navy focus:border-vs-blue focus:ring-2 focus:ring-vs-blue/20 outline-none'

  return (
    <section className="max-w-2xl mx-auto px-4 py-10">
      <h2 className="text-2xl font-bold text-vs-navy mb-2">Thông tin cơ sở</h2>
      <p className="text-vs-slate text-sm mb-8">Điền thông tin cơ sở thể thao của bạn.</p>

      <form onSubmit={handleSubmit} noValidate className="space-y-6">
        {/* Thông tin cơ bản */}
        <div className="grid grid-cols-1 gap-5 sm:grid-cols-2">
          <div className="sm:col-span-2">
            <label htmlFor="ownerName" className="block text-sm font-medium text-vs-navy mb-1.5">
              Tên cơ sở / chủ sân <span className="text-red-500">*</span>
            </label>
            <input
              id="ownerName"
              type="text"
              value={ownerName}
              onChange={e => setOwnerName(e.target.value)}
              placeholder="Sân Cầu Lông ABC"
              className={fieldClass}
            />
          </div>

          <div>
            <label htmlFor="emailReadonly" className="block text-sm font-medium text-vs-navy mb-1.5">Email</label>
            <input id="emailReadonly" type="email" value={email} readOnly className={`${fieldClass} bg-slate-50`} />
          </div>
          <div>
            <label htmlFor="phoneReadonly" className="block text-sm font-medium text-vs-navy mb-1.5">Số điện thoại</label>
            <input id="phoneReadonly" type="tel" value={phone} readOnly className={`${fieldClass} bg-slate-50`} />
          </div>

          <div className="sm:col-span-2">
            <label htmlFor="address" className="block text-sm font-medium text-vs-navy mb-1.5">
              <MapPin className="inline w-4 h-4 mr-1" />Địa chỉ <span className="text-red-500">*</span>
            </label>
            <input
              id="address"
              type="text"
              value={address}
              onChange={e => setAddress(e.target.value)}
              placeholder="123 Lê Lợi, Q.1, TP.HCM"
              className={fieldClass}
            />
          </div>

          <div className="sm:col-span-2">
            <label htmlFor="description" className="block text-sm font-medium text-vs-navy mb-1.5">
              <AlignLeft className="inline w-4 h-4 mr-1" />Mô tả (tùy chọn)
            </label>
            <textarea
              id="description"
              rows={3}
              value={description}
              onChange={e => setDescription(e.target.value)}
              placeholder="Giới thiệu ngắn về cơ sở của bạn..."
              className={`${fieldClass} resize-none`}
            />
          </div>
        </div>

        {/* Giờ và ngày hoạt động */}
        <div>
          <p className="text-sm font-medium text-vs-navy mb-3">
            <Clock className="inline w-4 h-4 mr-1" />Giờ hoạt động <span className="text-red-500">*</span>
          </p>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label htmlFor="openTime" className="block text-xs text-vs-slate mb-1">Giờ mở cửa</label>
              <input id="openTime" type="time" value={openTime} onChange={e => setOpenTime(e.target.value)} className={fieldClass} />
            </div>
            <div>
              <label htmlFor="closeTime" className="block text-xs text-vs-slate mb-1">Giờ đóng cửa</label>
              <input id="closeTime" type="time" value={closeTime} onChange={e => setCloseTime(e.target.value)} className={fieldClass} />
            </div>
          </div>
        </div>

        <div>
          <p className="text-sm font-medium text-vs-navy mb-3">
            <CalendarDays className="inline w-4 h-4 mr-1" />Ngày hoạt động <span className="text-red-500">*</span>
          </p>
          <div className="flex gap-2 flex-wrap">
            {DAYS.map(d => (
              <label key={d.key} className="flex items-center gap-1.5 cursor-pointer">
                <input
                  type="checkbox"
                  checked={operatingDays.includes(d.key)}
                  onChange={() => toggleDay(d.key)}
                  className="w-4 h-4 rounded text-vs-blue focus:ring-vs-blue/30"
                />
                <span className="text-sm text-vs-navy">{d.label}</span>
              </label>
            ))}
          </div>
        </div>

        {/* Môn thể thao */}
        <div>
          <p className="text-sm font-medium text-vs-navy mb-3">
            Môn thể thao & số sân <span className="text-red-500">*</span>
          </p>
          <SportsTable value={sports} onChange={setSports} />
        </div>

        {/* Vị trí bản đồ */}
        <div>
          <p className="text-sm font-medium text-vs-navy mb-3">Vị trí bản đồ (tùy chọn)</p>
          <MapPicker
            viDo={viDo}
            kinhDo={kinhDo}
            onChange={(lat, lng) => { setViDo(lat); setKinhDo(lng) }}
          />
        </div>

        {error && (
          <p role="alert" className="text-sm text-red-600 bg-red-50 rounded-lg px-4 py-3">
            {error}
          </p>
        )}

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-vs-blue hover:bg-vs-navy text-white font-semibold py-3.5 px-6 rounded-xl transition-colors disabled:opacity-60"
        >
          {loading ? 'Đang gửi...' : 'Hoàn tất đăng ký'}
        </button>
      </form>
    </section>
  )
}
```

- [ ] **Step 4: Chạy test, xác nhận PASS**

```bash
cd vsport_frontend && npm test -- --testPathPatterns="Step3Details" --watchAll=false
```

Expected: PASS (5 tests)

- [ ] **Step 5: Commit**

```bash
git add vsport_frontend/components/owner-register/Step3Details.tsx vsport_frontend/__tests__/components/owner-register/Step3Details.test.tsx
git commit -m "feat: add Step3Details with full facility registration form"
```

---

## Task 9: OwnerRegisterClient + routes

**Files:**
- Create: `vsport_frontend/components/owner-register/OwnerRegisterClient.tsx`
- Create: `vsport_frontend/app/owner-register/page.tsx`
- Create: `vsport_frontend/__tests__/components/owner-register/OwnerRegisterClient.test.tsx`

**Interfaces:**
- Consumes: Navbar, ProgressBar, Step1EmailPhone, Step2OTP, Step3Details
- Produces: `<OwnerRegisterClient />` (no props), mounted tại `/owner-register`

- [ ] **Step 1: Viết test**

Tạo `vsport_frontend/__tests__/components/owner-register/OwnerRegisterClient.test.tsx`:

```tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react'

const mockPush = jest.fn()
jest.mock('next/navigation', () => ({
  useRouter: () => ({ push: mockPush }),
}))
jest.mock('@/components/owner-landing/Navbar', () => ({
  __esModule: true,
  default: () => <nav>Navbar</nav>,
}))
jest.mock('@/components/owner-register/ProgressBar', () => ({
  __esModule: true,
  default: ({ currentStep }: { currentStep: number }) => <div data-testid="progress">{currentStep}</div>,
}))
jest.mock('@/components/owner-register/Step1EmailPhone', () => ({
  __esModule: true,
  default: ({ onSuccess }: { onSuccess: (e: string, p: string) => void }) => (
    <button onClick={() => onSuccess('test@example.com', '0901234567')}>Step1</button>
  ),
}))
jest.mock('@/components/owner-register/Step2OTP', () => ({
  __esModule: true,
  default: ({ onSuccess, onBack }: { onSuccess: () => void; onBack: () => void }) => (
    <div>
      <button onClick={onSuccess}>Step2Success</button>
      <button onClick={onBack}>Step2Back</button>
    </div>
  ),
}))
jest.mock('@/components/owner-register/Step3Details', () => ({
  __esModule: true,
  default: ({ onSuccess }: { onSuccess: () => void }) => (
    <button onClick={onSuccess}>Step3Success</button>
  ),
}))

import OwnerRegisterClient from '@/components/owner-register/OwnerRegisterClient'

describe('OwnerRegisterClient', () => {
  it('shows step 1 initially', () => {
    render(<OwnerRegisterClient />)
    expect(screen.getByText('Step1')).toBeInTheDocument()
    expect(screen.queryByText('Step2Success')).not.toBeInTheDocument()
  })

  it('shows progress bar at step 1', () => {
    render(<OwnerRegisterClient />)
    expect(screen.getByTestId('progress')).toHaveTextContent('1')
  })

  it('advances to step 2 when step 1 succeeds', async () => {
    render(<OwnerRegisterClient />)
    fireEvent.click(screen.getByText('Step1'))
    await waitFor(() => expect(screen.getByText('Step2Success')).toBeInTheDocument())
    expect(screen.queryByText('Step1')).not.toBeInTheDocument()
  })

  it('goes back to step 1 from step 2', async () => {
    render(<OwnerRegisterClient />)
    fireEvent.click(screen.getByText('Step1'))
    await waitFor(() => screen.getByText('Step2Back'))
    fireEvent.click(screen.getByText('Step2Back'))
    await waitFor(() => expect(screen.getByText('Step1')).toBeInTheDocument())
  })

  it('advances to step 3 when step 2 succeeds', async () => {
    render(<OwnerRegisterClient />)
    fireEvent.click(screen.getByText('Step1'))
    await waitFor(() => screen.getByText('Step2Success'))
    fireEvent.click(screen.getByText('Step2Success'))
    await waitFor(() => expect(screen.getByText('Step3Success')).toBeInTheDocument())
  })

  it('calls router.push to success page when step 3 completes', async () => {
    render(<OwnerRegisterClient />)
    fireEvent.click(screen.getByText('Step1'))
    await waitFor(() => screen.getByText('Step2Success'))
    fireEvent.click(screen.getByText('Step2Success'))
    await waitFor(() => screen.getByText('Step3Success'))
    fireEvent.click(screen.getByText('Step3Success'))
    await waitFor(() => expect(mockPush).toHaveBeenCalledWith('/owner-register/success'))
  })
})
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

```bash
cd vsport_frontend && npm test -- --testPathPatterns="OwnerRegisterClient" --watchAll=false
```

Expected: FAIL — "Cannot find module '@/components/owner-register/OwnerRegisterClient'"

- [ ] **Step 3: Tạo OwnerRegisterClient**

Tạo `vsport_frontend/components/owner-register/OwnerRegisterClient.tsx`:

```tsx
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Navbar from '@/components/owner-landing/Navbar'
import ProgressBar from './ProgressBar'
import Step1EmailPhone from './Step1EmailPhone'
import Step2OTP from './Step2OTP'
import Step3Details from './Step3Details'

export default function OwnerRegisterClient() {
  const router = useRouter()
  const [step, setStep] = useState<1 | 2 | 3>(1)
  const [email, setEmail] = useState('')
  const [phone, setPhone] = useState('')

  const handleStep1Success = (em: string, ph: string) => {
    setEmail(em)
    setPhone(ph)
    setStep(2)
  }

  return (
    <>
      <Navbar />
      <ProgressBar currentStep={step} />
      {step === 1 && <Step1EmailPhone onSuccess={handleStep1Success} />}
      {step === 2 && (
        <Step2OTP
          email={email}
          phone={phone}
          onSuccess={() => setStep(3)}
          onBack={() => setStep(1)}
        />
      )}
      {step === 3 && (
        <Step3Details
          email={email}
          phone={phone}
          onSuccess={() => router.push('/owner-register/success')}
        />
      )}
    </>
  )
}
```

- [ ] **Step 4: Tạo page route**

Tạo `vsport_frontend/app/owner-register/page.tsx`:

```tsx
import OwnerRegisterClient from '@/components/owner-register/OwnerRegisterClient'

export const metadata = {
  title: 'Đăng ký đối tác | V-Sport',
  description: 'Đăng ký trở thành đối tác chủ sân của V-Sport',
}

export default function OwnerRegisterPage() {
  return <OwnerRegisterClient />
}
```

- [ ] **Step 5: Chạy test, xác nhận PASS**

```bash
cd vsport_frontend && npm test -- --testPathPatterns="OwnerRegisterClient" --watchAll=false
```

Expected: PASS (6 tests)

- [ ] **Step 6: Commit**

```bash
git add vsport_frontend/components/owner-register/OwnerRegisterClient.tsx vsport_frontend/app/owner-register/page.tsx vsport_frontend/__tests__/components/owner-register/OwnerRegisterClient.test.tsx
git commit -m "feat: add OwnerRegisterClient wizard and /owner-register route"
```

---

## Task 10: Success Page

**Files:**
- Create: `vsport_frontend/components/owner-register/SuccessPageClient.tsx`
- Create: `vsport_frontend/app/owner-register/success/page.tsx`
- Create: `vsport_frontend/__tests__/components/owner-register/SuccessPageClient.test.tsx`

**Interfaces:**
- Produces: `<SuccessPageClient />` (no props), route `/owner-register/success`

- [ ] **Step 1: Viết test**

Tạo `vsport_frontend/__tests__/components/owner-register/SuccessPageClient.test.tsx`:

```tsx
import { render, screen } from '@testing-library/react'
import SuccessPageClient from '@/components/owner-register/SuccessPageClient'

describe('SuccessPageClient', () => {
  it('shows success heading', () => {
    render(<SuccessPageClient />)
    expect(screen.getByRole('heading', { name: /đăng ký thành công/i })).toBeInTheDocument()
  })

  it('mentions admin review process', () => {
    render(<SuccessPageClient />)
    expect(screen.getByText(/1-3 ngày/i)).toBeInTheDocument()
  })

  it('has a link back to /owner', () => {
    render(<SuccessPageClient />)
    const link = screen.getByRole('link', { name: /về trang chủ/i })
    expect(link).toHaveAttribute('href', '/owner')
  })
})
```

- [ ] **Step 2: Chạy test, xác nhận FAIL**

```bash
cd vsport_frontend && npm test -- --testPathPatterns="SuccessPageClient" --watchAll=false
```

Expected: FAIL — "Cannot find module '@/components/owner-register/SuccessPageClient'"

- [ ] **Step 3: Tạo SuccessPageClient**

Tạo `vsport_frontend/components/owner-register/SuccessPageClient.tsx`:

```tsx
import Link from 'next/link'
import { CheckCircle, ArrowLeft } from 'lucide-react'
import Navbar from '@/components/owner-landing/Navbar'

export default function SuccessPageClient() {
  return (
    <>
      <Navbar />
      <main className="min-h-[80vh] flex flex-col items-center justify-center px-4 py-16 text-center">
        <div className="w-20 h-20 rounded-full bg-green-100 flex items-center justify-center mb-6">
          <CheckCircle className="w-10 h-10 text-green-600" />
        </div>

        <h1 className="text-3xl font-bold text-vs-navy mb-3">Đăng ký thành công!</h1>

        <p className="text-vs-slate text-base max-w-md mb-2">
          Chúng tôi đã nhận được thông tin của bạn. Admin V-Sport sẽ xem xét và
          duyệt hồ sơ trong vòng <strong>1-3 ngày làm việc</strong>.
        </p>
        <p className="text-vs-slate text-sm max-w-md mb-10">
          Sau khi được duyệt, bạn sẽ nhận thông báo qua email và có thể đăng nhập
          để quản lý cơ sở.
        </p>

        <Link
          href="/owner"
          className="inline-flex items-center gap-2 bg-vs-blue hover:bg-vs-navy text-white font-semibold px-8 py-3.5 rounded-xl transition-colors"
        >
          <ArrowLeft className="w-4 h-4" /> Về trang chủ
        </Link>
      </main>
    </>
  )
}
```

- [ ] **Step 4: Tạo success route**

Tạo `vsport_frontend/app/owner-register/success/page.tsx`:

```tsx
import SuccessPageClient from '@/components/owner-register/SuccessPageClient'

export const metadata = {
  title: 'Đăng ký thành công | V-Sport',
  description: 'Hồ sơ đăng ký đối tác của bạn đã được gửi thành công',
}

export default function OwnerRegisterSuccessPage() {
  return <SuccessPageClient />
}
```

- [ ] **Step 5: Chạy test, xác nhận PASS**

```bash
cd vsport_frontend && npm test -- --testPathPatterns="SuccessPageClient" --watchAll=false
```

Expected: PASS (3 tests)

- [ ] **Step 6: Chạy toàn bộ test suite để đảm bảo không có regression**

```bash
cd vsport_frontend && npm test -- --watchAll=false
```

Expected: PASS toàn bộ — bao gồm các test cũ của owner landing page.

- [ ] **Step 7: Commit**

```bash
git add vsport_frontend/components/owner-register/SuccessPageClient.tsx vsport_frontend/app/owner-register/success/page.tsx vsport_frontend/__tests__/components/owner-register/SuccessPageClient.test.tsx
git commit -m "feat: add /owner-register/success page"
```

---

## Kiểm tra cuối cùng

Sau khi hoàn thành tất cả tasks:

1. Build backend: `mvn package -q -DskipTests` → BUILD SUCCESS
2. Chạy backend trong IntelliJ (port 8080)
3. Chạy frontend: `cd vsport_frontend && npm run dev` → mở `http://localhost:3000/owner-register`
4. Kiểm tra thủ công luồng:
   - Bước 1: nhập email + SĐT → bấm "Gửi mã OTP" → xem console Java backend log OTP
   - Bước 2: nhập OTP từ email (hoặc console) → xác nhận
   - Bước 3: điền thông tin cơ sở → bấm "Hoàn tất đăng ký"
   - Redirect sang `/owner-register/success`
