# Owner Registration Page Design

**Date:** 2026-08-12  
**Route:** `/owner-register` + `/owner-register/success`  
**Stack:** Next.js 14 App Router · Tailwind CSS · Java Servlet backend

---

## Goal

Xây dựng trang đăng ký chủ sân V-Sport (`/owner-register`) với luồng 3 bước:
1. Xác thực email + SĐT qua OTP
2. Nhập mã OTP 6 chữ số
3. Điền thông tin cơ sở (tên, địa chỉ, giờ, môn thể thao, vị trí bản đồ)

Sau khi đăng ký thành công → redirect `/owner-register/success`.

---

## Backend API Contract

Endpoints trên Java backend (`/Backend_java`), dùng server-side session (cookie) để lưu OTP:

| Method | Path | Params | Response |
|---|---|---|---|
| `POST` | `/owner/send-otp` | `email`, `phone` | `{success, message?}` |
| `POST` | `/owner/verify-otp` | `email`, `otp` | `{success, message?}` |
| `POST` | `/owner/register` | form fields | `{success, message?}` |
| `GET` | `/owner/otp-status` | — | `{emailVerified, otpActive, secondsRemaining, otpEmail}` |

**Tất cả fetch phải kèm `credentials: 'include'`** để session cookie được gửi/nhận.

OTP hết hạn sau **5 phút**. Backend kiểm tra `ownerEmailVerified` trong session trước khi chấp nhận bước 3.

---

## Architecture

### Routes

```
app/owner-register/page.tsx           ← Server Component (thin wrapper)
app/owner-register/success/page.tsx   ← Server Component (thin wrapper)
```

### Client Components

```
components/owner-register/
  OwnerRegisterClient.tsx   ← Wizard state machine, bước 1|2|3
  Step1EmailPhone.tsx       ← Email + SĐT + "Gửi OTP"
  Step2OTP.tsx              ← 6 ô OTP + countdown + gửi lại
  Step3Details.tsx          ← Form chi tiết cơ sở
  SportsTable.tsx           ← Add-row table môn thể thao
  MapPicker.tsx             ← Google Maps click-to-pick lat/lng
  ProgressBar.tsx           ← Thanh tiến trình bước 1→2→3
  SuccessPageClient.tsx     ← Màn hình thành công
```

### API Layer

```
lib/api/owner-register.ts   ← sendOtp(), verifyOtp(), register()
types/owner-register.ts     ← RegistrationData, SportRow, OtpStatus
```

### Reused

- `components/owner-landing/Navbar.tsx` — dùng lại không thay đổi

---

## State Flow

`OwnerRegisterClient` (Client Component, `'use client'`) giữ toàn bộ wizard state:

```ts
const [step, setStep] = useState<1 | 2 | 3>(1)
const [email, setEmail] = useState('')
const [phone, setPhone] = useState('')
```

State flow: Step1 gọi `setEmail`/`setPhone`/`setStep(2)` → Step2 dùng `email` để gọi verify → Step3 nhận `email`+`phone` làm readonly.

---

## Component Details

### ProgressBar

Hiển thị dưới Navbar. 3 bước dạng `● ──── ○ ──── ○`.

Props: `{ currentStep: 1 | 2 | 3 }`

### Step1EmailPhone

Fields:
- **Email** — required, validate regex trước khi gọi API
- **Số điện thoại** — required, regex VN phone (`/^(0[3|5|7|8|9])+([0-9]{8})$/`)

Submit → `POST /owner/send-otp`. Hiển thị lỗi inline nếu `success: false`.

### Step2OTP

- 6 ô `<input>` riêng biệt (type="text", maxLength=1)
- Gõ ký tự → auto-focus ô tiếp theo
- Xóa → focus ô trước
- Paste 6 số → điền tất cả cùng lúc
- Khi đủ 6 số → tự động submit (không cần bấm nút)
- Countdown `MM:SS` real-time (5 phút)
- Nút "Gửi lại" — disabled khi countdown > 0
- Nút "← Quay lại" → `setStep(1)`

Submit → `POST /owner/verify-otp`. Thành công → `setStep(3)`.

### Step3Details

| Field | Required | Notes |
|---|---|---|
| Tên cơ sở / chủ sân | ✅ | `ownerName` |
| Email | readonly | pre-filled từ Step 1 |
| Số điện thoại | readonly | pre-filled từ Step 1 |
| Địa chỉ | ✅ | `address` |
| Mô tả | ❌ | `description`, textarea |
| Giờ mở cửa | ✅ | `openTime`, `<input type="time">` |
| Giờ đóng cửa | ✅ | `closeTime`, `<input type="time">` |
| Ngày hoạt động | ✅ | `operatingDays`, 7 checkbox T2→CN, value `"T2,T3,T4,T5,T6,T7,CN"` |
| Môn thể thao & sân | ✅ ≥1 row | `SportsTable` |
| Vị trí bản đồ | ❌ | `MapPicker` |

Submit → `POST /owner/register` với tất cả fields. Thành công → `router.push('/owner-register/success')`.

### SportsTable

Danh sách môn cố định: Cầu lông, Bóng đá, Bida, Pickleball, Tennis, Bóng rổ, Bóng chuyền, Bơi lội.

State: `rows: SportRow[]` (local). Mỗi row: dropdown sport + input quantity (min 1).

- Nút `+ Thêm môn` → thêm row với sport đầu tiên chưa được chọn
- Nút `✕` xóa row (tối thiểu 1 row)
- Validation: mỗi sport chỉ xuất hiện 1 lần

Serialize khi submit:
```ts
JSON.stringify(rows) // → sportsData param
```

### MapPicker

- Load Google Maps JS SDK qua `next/script` với `NEXT_PUBLIC_GOOGLE_MAPS_KEY`
- Default center: TP.HCM `{lat: 10.8231, lng: 106.6297}`
- Click trên map → đặt marker + update state `{viDo, kinhDo}`
- **Fallback**: nếu `NEXT_PUBLIC_GOOGLE_MAPS_KEY` không có → render 2 `<input type="number">` Vĩ độ / Kinh độ

Props: `{ viDo?: string; kinhDo?: string; onChange: (lat: string, lng: string) => void }`

### SuccessPageClient

- Icon checkmark lớn (green)  
- Heading: "Đăng ký thành công!"  
- Body: "Chúng tôi đã nhận được thông tin của bạn. Admin sẽ xem xét và duyệt trong vòng 1-3 ngày làm việc."  
- CTA: "Về trang chủ" → `/owner`

---

## Types

```ts
// types/owner-register.ts
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
  sportsData: string     // JSON.stringify(SportRow[])
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

---

## API Layer

```ts
// lib/api/owner-register.ts
const BASE = process.env.NEXT_PUBLIC_BACKEND_URL

export async function sendOtp(email: string, phone: string) {
  const body = new URLSearchParams({ email, phone })
  const res = await fetch(`${BASE}/owner/send-otp`, {
    method: 'POST', body, credentials: 'include',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
  })
  return res.json() as Promise<{ success: boolean; message?: string }>
}

export async function verifyOtp(email: string, otp: string) {
  const body = new URLSearchParams({ email, otp })
  const res = await fetch(`${BASE}/owner/verify-otp`, {
    method: 'POST', body, credentials: 'include',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
  })
  return res.json() as Promise<{ success: boolean; message?: string }>
}

export async function register(data: RegistrationData) {
  const body = new URLSearchParams(data as Record<string, string>)
  const res = await fetch(`${BASE}/owner/register`, {
    method: 'POST', body, credentials: 'include',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
  })
  return res.json() as Promise<{ success: boolean; message?: string }>
}
```

---

## Error Handling

- Lỗi API → hiển thị `message` inline dưới nút submit (dạng banner đỏ)
- Network error → "Lỗi kết nối. Vui lòng thử lại."
- OTP hết hạn → hiển thị lỗi + enable nút "Gửi lại"
- Form validation → inline error dưới field (trước khi gọi API)

---

## Environment

```
NEXT_PUBLIC_BACKEND_URL=http://localhost:8080/Backend_java
NEXT_PUBLIC_GOOGLE_MAPS_KEY=<optional, fallback về text input nếu không có>
```

---

## Out of Scope

- Capabilities selection (admin xử lý sau khi duyệt)
- File upload ảnh cơ sở (giai đoạn sau)
- Auth/session check (security chưa bật)
- Email thông báo cho owner (backend đã xử lý qua NotificationService)
