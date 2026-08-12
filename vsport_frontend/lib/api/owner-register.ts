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
