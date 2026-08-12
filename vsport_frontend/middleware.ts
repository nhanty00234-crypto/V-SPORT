import { NextRequest, NextResponse } from 'next/server'

const PROTECTED_PREFIXES = [
  '/account',
  '/dat-san',
  '/gio-hang',
  '/xac-nhan',
  '/thanh-toan',
  '/doi-nhom',
  '/ghep-keo',
  '/ban-do',
  '/quet-qr',
  '/hoan-tien',
  '/manager',
  '/staff',
  '/admin',
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

  // Role-based access: /manager requires MANAGER, /staff requires STAFF, /admin requires ADMIN
  for (const [role, prefix] of Object.entries(ROLE_PREFIX)) {
    if (pathname.startsWith(prefix) && user.role !== role) {
      const home = ROLE_HOME[user.role] ?? '/'
      return NextResponse.redirect(new URL(home, req.url))
    }
  }

  return NextResponse.next()
}

export const config = {
  matcher: [
    '/account/:path*',
    '/dat-san/:path*',
    '/gio-hang',
    '/xac-nhan',
    '/thanh-toan',
    '/doi-nhom/:path*',
    '/ghep-keo',
    '/ban-do',
    '/quet-qr',
    '/hoan-tien/:path*',
    '/manager/:path*',
    '/staff/:path*',
    '/admin/:path*',
  ],
}
