import type { CustomerProfile, BookingPage, ReputationData, NotificationPage, SearchResult } from '@/types/customer'

const BASE = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'
const WEB = `${BASE}/api/v1/web`

async function get<T>(path: string, params?: Record<string, string>): Promise<T> {
  const url = new URL(`${WEB}${path}`)
  if (params) Object.entries(params).forEach(([k, v]) => url.searchParams.set(k, v))
  const res = await fetch(url.toString(), { credentials: 'include', cache: 'no-store' })
  if (!res.ok) throw new Error(`HTTP ${res.status}`)
  return res.json()
}

export async function getCustomerProfile(): Promise<CustomerProfile | null> {
  try { return await get<CustomerProfile>('/customer/me') } catch { return null }
}

export async function getBookings(page = 1, status = ''): Promise<BookingPage | null> {
  try {
    const p: Record<string, string> = { page: String(page) }
    if (status) p.status = status
    return await get<BookingPage>('/customer/bookings', p)
  } catch { return null }
}

export async function getReputation(): Promise<ReputationData | null> {
  try { return await get<ReputationData>('/customer/reputation') } catch { return null }
}

export async function getNotifications(page = 1): Promise<NotificationPage | null> {
  try { return await get<NotificationPage>('/customer/notifications', { page: String(page) }) } catch { return null }
}

export async function markAllNotificationsRead(): Promise<boolean> {
  try {
    const res = await fetch(`${WEB}/customer/notifications/read-all`, {
      method: 'POST',
      credentials: 'include',
    })
    return res.ok
  } catch { return false }
}

export async function searchFacilities(q = '', sportId?: number, openNow?: boolean): Promise<SearchResult | null> {
  try {
    const p: Record<string, string> = {}
    if (q) p.q = q
    if (sportId) p.sportId = String(sportId)
    if (openNow) p.openNow = '1'
    return await get<SearchResult>('/search', p)
  } catch { return null }
}

export async function changePassword(currentPassword: string, newPassword: string, confirmPassword: string) {
  const body = new URLSearchParams({ action: 'changePassword', currentPassword, newPassword, confirmPassword })
  const res = await fetch(`${BASE}/account/update-profile`, {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
    body: body.toString(),
  })
  return res.json() as Promise<{ success: boolean; message?: string }>
}

export async function updateProfile(data: { fullName?: string; email?: string; phoneNumber?: string; birthday?: string; gender?: string }) {
  const body = new URLSearchParams({ action: 'updateBasicInfo', ...Object.fromEntries(Object.entries(data).filter(([, v]) => v != null)) } as Record<string, string>)
  const res = await fetch(`${BASE}/account/update-profile`, {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
    body: body.toString(),
  })
  return res.json() as Promise<{ success: boolean; message?: string }>
}
