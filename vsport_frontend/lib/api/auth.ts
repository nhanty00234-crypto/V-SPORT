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
