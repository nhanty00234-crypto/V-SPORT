import type { Branch, Account, AdminInvoice, AdminBooking, AdminAuditLog, AdminTrash } from '@/types/admin-pages'

const BASE = process.env.NEXT_PUBLIC_BACKEND_URL
const OPT = { credentials: 'include' as const, headers: { 'X-Requested-With': 'XMLHttpRequest' } }

async function get<T>(path: string): Promise<T | null> {
  try {
    const res = await fetch(`${BASE}/api/v1/web/admin${path}`, { ...OPT, cache: 'no-store' })
    if (!res.ok) return null
    return res.json()
  } catch { return null }
}

export async function getBranches(): Promise<{ branches: Branch[] } | null> { return get('/chi-nhanh') }
export async function getOwners(): Promise<{ accounts: Account[] } | null> { return get('/owner') }
export async function getAllUsers(): Promise<{ accounts: Account[] } | null> { return get('/nhan-su') }
export async function getAdminInvoices(): Promise<{ totalRevenue: number; invoices: AdminInvoice[] } | null> { return get('/hoa-don') }
export async function getAdminBookings(): Promise<{ bookings: AdminBooking[] } | null> { return get('/lich-dat-san') }
export async function getAdminAuditLog(page = 1): Promise<{ logs: AdminAuditLog[] } | null> { return get(`/audit-log?page=${page}`) }
export async function getAdminTrash(): Promise<AdminTrash | null> { return get('/thung-rac') }
