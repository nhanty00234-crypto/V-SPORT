# Phase 0: Shared Infrastructure

> **For agentic workers:** Use superpowers:executing-plans to implement task-by-task.

**Goal:** Tạo nền tảng cho toàn bộ migration — middleware auth, hook user, layout skeletons.

**Architecture:** Next.js middleware → gọi Java backend `GET /api/v1/auth/me` → route protect.

**Tech Stack:** Next.js 14 · TypeScript · Tailwind CSS · Java Servlet (backend thêm 1 endpoint)

## Global Constraints

- `NEXT_PUBLIC_BACKEND_URL` = `http://localhost:8080/Backend_java`
- Mọi fetch backend đều dùng `credentials: 'include'`
- Session attribute trong Java: `taiKhoan` (TaiKhoan object)
- Role values: `CUSTOMER` | `MANAGER` | `STAFF` | `ADMIN`
- Middleware chỉ chạy phía server (Edge Runtime)

---

### Task 1: Backend — thêm `GET /api/v1/auth/me`

**Files:**
- Create: `src/main/java/org/example/controller/api/v1/auth/WebSessionApiServlet.java`

**Interfaces:**
- Produces: `GET /api/v1/auth/me` → JSON `{id, email, phone, fullName, role, avatarUrl}` hoặc HTTP 401

- [ ] **Step 1: Viết WebSessionApiServlet**

```java
package org.example.controller.api.v1.auth;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;

import java.io.IOException;

@WebServlet("/api/v1/auth/me")
public class WebSessionApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        String origin = req.getHeader("Origin");
        if (origin != null) {
            String lower = origin.toLowerCase();
            if (lower.startsWith("http://localhost:") || lower.startsWith("http://127.0.0.1:")) {
                resp.setHeader("Access-Control-Allow-Origin", origin);
                resp.setHeader("Access-Control-Allow-Credentials", "true");
                resp.setHeader("Vary", "Origin");
            }
        }
        HttpSession session = req.getSession(false);
        TaiKhoan tk = session != null ? (TaiKhoan) session.getAttribute("taiKhoan") : null;
        if (tk == null) tk = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (tk == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
            return;
        }
        String json = String.format(
            "{\"id\":%d,\"email\":\"%s\",\"phone\":\"%s\",\"fullName\":\"%s\",\"role\":\"%s\",\"avatarUrl\":%s}",
            tk.getId(),
            escape(tk.getEmail()),
            escape(tk.getSoDienThoai() != null ? tk.getSoDienThoai() : ""),
            escape(tk.getHoTen() != null ? tk.getHoTen() : ""),
            escape(tk.getVaiTro() != null ? tk.getVaiTro() : ""),
            tk.getAvatarUrl() != null ? "\"" + escape(tk.getAvatarUrl()) + "\"" : "null"
        );
        resp.getWriter().write(json);
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String origin = req.getHeader("Origin");
        if (origin != null && (origin.toLowerCase().startsWith("http://localhost:") || origin.toLowerCase().startsWith("http://127.0.0.1:"))) {
            resp.setHeader("Access-Control-Allow-Origin", origin);
            resp.setHeader("Access-Control-Allow-Credentials", "true");
            resp.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
            resp.setHeader("Access-Control-Allow-Headers", "Content-Type, Accept");
            resp.setHeader("Vary", "Origin");
        }
        resp.setStatus(HttpServletResponse.SC_NO_CONTENT);
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
```

- [ ] **Step 2: Build + kiểm tra**

```bash
cd /home/nhan/Downloads/V-SPORT && mvn compile -q
```

Expected: BUILD SUCCESS

- [ ] **Step 3: Test thủ công (backend phải đang chạy)**

```bash
curl -s http://localhost:8080/Backend_java/api/v1/auth/me
```

Expected: `{"error":"Chưa đăng nhập"}` với status 401

---

### Task 2: Frontend — `lib/api/auth.ts` + Types

**Files:**
- Create: `vsport_frontend/types/auth.ts`
- Create: `vsport_frontend/lib/api/auth.ts`
- Test: `vsport_frontend/__tests__/lib/api/auth.test.ts`

**Interfaces:**
- Produces:
  ```ts
  getCurrentUser(): Promise<User | null>
  login(identifier, password, method): Promise<LoginResult>
  logout(): Promise<void>
  ```

- [ ] **Step 1: Viết types**

```ts
// vsport_frontend/types/auth.ts
export type UserRole = 'CUSTOMER' | 'MANAGER' | 'STAFF' | 'ADMIN'

export interface User {
  id: number
  email: string
  phone: string
  fullName: string
  role: UserRole
  avatarUrl: string | null
}

export interface LoginResult {
  success: boolean
  loi?: string
  user?: User
}
```

- [ ] **Step 2: Viết API functions**

```ts
// vsport_frontend/lib/api/auth.ts
import { User, LoginResult } from '@/types/auth'

const BASE = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'

export async function getCurrentUser(): Promise<User | null> {
  try {
    const res = await fetch(`${BASE}/api/v1/auth/me`, {
      credentials: 'include',
      cache: 'no-store',
    })
    if (!res.ok) return null
    return res.json()
  } catch {
    return null
  }
}

export async function login(
  identifier: string,
  password: string,
  method: 'account' | 'phone' = 'account'
): Promise<LoginResult> {
  const body = new URLSearchParams({
    [method === 'phone' ? 'phone' : 'username']: identifier,
    password,
    loginMethod: method,
  })
  const res = await fetch(`${BASE}/dangnhap`, {
    method: 'POST',
    credentials: 'include',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'X-Requested-With': 'XMLHttpRequest',
    },
    body: body.toString(),
  })
  return res.json()
}

export async function logout(): Promise<void> {
  await fetch(`${BASE}/dangxuat`, { credentials: 'include' })
}
```

- [ ] **Step 3: Viết tests**

```ts
// vsport_frontend/__tests__/lib/api/auth.test.ts
const mockFetch = jest.fn()
beforeAll(() => { global.fetch = mockFetch })
afterEach(() => mockFetch.mockReset())

import { getCurrentUser, login, logout } from '@/lib/api/auth'

describe('getCurrentUser', () => {
  it('returns user when authenticated', async () => {
    mockFetch.mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve({ id: 1, email: 'a@b.com', role: 'CUSTOMER', fullName: 'Test', phone: '0901234567', avatarUrl: null }),
    })
    const user = await getCurrentUser()
    expect(user?.email).toBe('a@b.com')
  })

  it('returns null on 401', async () => {
    mockFetch.mockResolvedValueOnce({ ok: false })
    expect(await getCurrentUser()).toBeNull()
  })

  it('returns null on network error', async () => {
    mockFetch.mockRejectedValueOnce(new Error('network'))
    expect(await getCurrentUser()).toBeNull()
  })
})

describe('login', () => {
  it('posts to /dangnhap with AJAX header', async () => {
    mockFetch.mockResolvedValueOnce({ json: () => Promise.resolve({ success: true }) })
    await login('user@example.com', 'password123')
    const [, opts] = mockFetch.mock.calls[0]
    expect(opts.headers['X-Requested-With']).toBe('XMLHttpRequest')
    expect(opts.method).toBe('POST')
  })

  it('returns login result', async () => {
    mockFetch.mockResolvedValueOnce({ json: () => Promise.resolve({ success: false, loi: 'Sai mật khẩu' }) })
    const result = await login('user@example.com', 'wrong')
    expect(result.success).toBe(false)
    expect(result.loi).toBe('Sai mật khẩu')
  })
})
```

- [ ] **Step 4: Chạy tests**

```bash
cd /home/nhan/Downloads/V-SPORT/vsport_frontend && npm test -- --testPathPatterns="lib/api/auth" --watchAll=false
```

Expected: 5 tests passed

---

### Task 3: Frontend — `middleware.ts`

**Files:**
- Create: `vsport_frontend/middleware.ts`
- Test: `vsport_frontend/__tests__/middleware.test.ts`

**Logic:**
- Protected prefixes: `/account`, `/dat-san`, `/gio-hang`, `/xac-nhan`, `/thanh-toan`, `/doi-nhom`, `/ghep-keo`, `/ban-do`, `/quet-qr`, `/hoan-tien`, `/manager`, `/staff`, `/admin`
- Call `GET /api/v1/auth/me` từ middleware (server-side với cookies forwarded)
- 401 → redirect `/dang-nhap?redirect=<current>`
- Role sai → redirect về home của role đúng

- [ ] **Step 1: Viết middleware**

```ts
// vsport_frontend/middleware.ts
import { NextRequest, NextResponse } from 'next/server'

const PROTECTED_PREFIXES = [
  '/account', '/dat-san', '/gio-hang', '/xac-nhan', '/thanh-toan',
  '/doi-nhom', '/ghep-keo', '/ban-do', '/quet-qr', '/hoan-tien',
  '/manager', '/staff', '/admin',
]

const ROLE_HOME: Record<string, string> = {
  CUSTOMER: '/tim-kiem',
  MANAGER: '/manager/dashboard',
  STAFF: '/staff/dashboard',
  ADMIN: '/admin/dashboard',
}

const ROLE_PREFIX: Record<string, string> = {
  MANAGER: '/manager',
  STAFF: '/staff',
  ADMIN: '/admin',
}

export async function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl
  const isProtected = PROTECTED_PREFIXES.some(p => pathname.startsWith(p))
  if (!isProtected) return NextResponse.next()

  const backendUrl = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'
  let user: { role: string } | null = null

  try {
    const res = await fetch(`${backendUrl}/api/v1/auth/me`, {
      headers: { Cookie: req.headers.get('cookie') ?? '' },
    })
    if (res.ok) user = await res.json()
  } catch {
    // network error — treat as unauthenticated
  }

  if (!user) {
    const loginUrl = new URL('/dang-nhap', req.url)
    loginUrl.searchParams.set('redirect', pathname)
    return NextResponse.redirect(loginUrl)
  }

  // Role-based access: /manager needs MANAGER, /staff needs STAFF, /admin needs ADMIN
  for (const [role, prefix] of Object.entries(ROLE_PREFIX)) {
    if (pathname.startsWith(prefix) && user.role !== role) {
      return NextResponse.redirect(new URL(ROLE_HOME[user.role] ?? '/', req.url))
    }
  }

  return NextResponse.next()
}

export const config = {
  matcher: [
    '/account/:path*', '/dat-san/:path*', '/gio-hang', '/xac-nhan',
    '/thanh-toan', '/doi-nhom/:path*', '/ghep-keo', '/ban-do',
    '/quet-qr', '/hoan-tien/:path*', '/manager/:path*',
    '/staff/:path*', '/admin/:path*',
  ],
}
```

- [ ] **Step 2: Commit Phase 0**

```bash
cd /home/nhan/Downloads/V-SPORT
git add vsport_frontend/types/auth.ts vsport_frontend/lib/api/auth.ts vsport_frontend/middleware.ts vsport_frontend/__tests__/lib/api/auth.test.ts src/main/java/org/example/controller/api/v1/auth/WebSessionApiServlet.java
git commit -m "feat(phase0): shared auth infra — /api/v1/auth/me + middleware + auth API layer"
```

---

### Task 4: Layout Skeletons cho mỗi Portal

**Files:**
- Create: `vsport_frontend/app/(customer)/layout.tsx`
- Create: `vsport_frontend/app/(manager)/layout.tsx`
- Create: `vsport_frontend/app/(staff)/layout.tsx`
- Create: `vsport_frontend/app/(admin)/layout.tsx`
- Create: `vsport_frontend/components/shared/PortalSidebar.tsx`

- [ ] **Step 1: Customer layout**

```tsx
// vsport_frontend/app/(customer)/layout.tsx
import { getCurrentUser } from '@/lib/api/auth'
import { redirect } from 'next/navigation'

export default async function CustomerLayout({ children }: { children: React.ReactNode }) {
  const user = await getCurrentUser()
  if (!user) redirect('/dang-nhap')
  return (
    <div className="min-h-screen bg-slate-50">
      {/* CustomerNavbar và BottomNav sẽ được thêm vào Phase 2 */}
      <main className="pb-20 md:pb-0">{children}</main>
    </div>
  )
}
```

- [ ] **Step 2: Manager layout skeleton**

```tsx
// vsport_frontend/app/(manager)/layout.tsx
import { getCurrentUser } from '@/lib/api/auth'
import { redirect } from 'next/navigation'

export default async function ManagerLayout({ children }: { children: React.ReactNode }) {
  const user = await getCurrentUser()
  if (!user || user.role !== 'MANAGER') redirect('/dang-nhap')
  return (
    <div className="flex min-h-screen bg-slate-100">
      {/* ManagerSidebar sẽ thêm vào Phase 3 */}
      <main className="flex-1 p-6">{children}</main>
    </div>
  )
}
```

- [ ] **Step 3: Staff layout skeleton**

```tsx
// vsport_frontend/app/(staff)/layout.tsx
import { getCurrentUser } from '@/lib/api/auth'
import { redirect } from 'next/navigation'

export default async function StaffLayout({ children }: { children: React.ReactNode }) {
  const user = await getCurrentUser()
  if (!user || user.role !== 'STAFF') redirect('/dang-nhap')
  return (
    <div className="flex min-h-screen bg-slate-100">
      <main className="flex-1 p-6">{children}</main>
    </div>
  )
}
```

- [ ] **Step 4: Admin layout skeleton**

```tsx
// vsport_frontend/app/(admin)/layout.tsx
import { getCurrentUser } from '@/lib/api/auth'
import { redirect } from 'next/navigation'

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const user = await getCurrentUser()
  if (!user || user.role !== 'ADMIN') redirect('/dang-nhap')
  return (
    <div className="flex min-h-screen bg-slate-100">
      <main className="flex-1 p-6">{children}</main>
    </div>
  )
}
```

- [ ] **Step 5: Commit layouts**

```bash
cd /home/nhan/Downloads/V-SPORT
git add vsport_frontend/app/\(customer\)/layout.tsx vsport_frontend/app/\(manager\)/layout.tsx vsport_frontend/app/\(staff\)/layout.tsx vsport_frontend/app/\(admin\)/layout.tsx
git commit -m "feat(phase0): portal layout skeletons with role-based auth guard"
```
