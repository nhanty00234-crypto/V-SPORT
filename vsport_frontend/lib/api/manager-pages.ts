import type {
  Court, Booking, InvoiceStats, InventoryStats, PromotionStats,
  StaffMember, Shift, QRRequest, Refund, AuditLogEntry, TrashData
} from '@/types/manager-pages'

const BASE = process.env.NEXT_PUBLIC_BACKEND_URL
const OPT = { credentials: 'include' as const, headers: { 'X-Requested-With': 'XMLHttpRequest' } }

async function get<T>(path: string): Promise<T | null> {
  try {
    const res = await fetch(`${BASE}/api/v1/web/manager${path}`, { ...OPT, cache: 'no-store' })
    if (!res.ok) return null
    return res.json()
  } catch { return null }
}

export async function getCourts(): Promise<{ courts: Court[] } | null> {
  return get('/san')
}
export async function getBookings(): Promise<{ bookings: Booking[] } | null> {
  return get('/dat-san')
}
export async function getInvoices(): Promise<InvoiceStats | null> {
  return get('/hoa-don')
}
export async function getInventory(): Promise<InventoryStats | null> {
  return get('/kho-dich-vu')
}
export async function getPromotions(): Promise<PromotionStats | null> {
  return get('/khuyen-mai')
}
export async function getStaff(): Promise<{ staff: StaffMember[] } | null> {
  return get('/nhan-su')
}
export async function getShifts(from?: string, to?: string): Promise<{ shifts: Shift[] } | null> {
  const q = from ? `?from=${from}&to=${to ?? ''}` : ''
  return get(`/ca-lam-viec${q}`)
}
export async function getQrCourts(): Promise<{ courts: Court[]; qrRequests: QRRequest[] } | null> {
  return get('/ma-qr-san')
}
export async function getRefunds(page = 1): Promise<{ refunds: Refund[] } | null> {
  return get(`/hoan-tien?page=${page}`)
}
export async function getTrash(): Promise<TrashData | null> {
  return get('/thung-rac')
}
export async function getAuditLog(page = 1): Promise<{ logs: AuditLogEntry[] } | null> {
  return get(`/audit-log?page=${page}`)
}
