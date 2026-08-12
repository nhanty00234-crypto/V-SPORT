import { StaffDashboardStats } from '@/types/staff'

const BASE = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'
const WEB = `${BASE}/api/v1/web/staff`

function apiFetch(path: string, init?: RequestInit) {
  return fetch(`${WEB}${path}`, {
    credentials: 'include',
    headers: { 'X-Requested-With': 'XMLHttpRequest' },
    ...init,
  })
}

export async function getStaffDashboard(): Promise<StaffDashboardStats | null> {
  try {
    const res = await apiFetch('/dashboard', { cache: 'no-store' })
    if (!res.ok) return null
    return res.json()
  } catch {
    return null
  }
}
