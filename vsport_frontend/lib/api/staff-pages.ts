import type { Booking, Invoice, Refund, Shift } from '@/types/manager-pages'
import type { AdminAuditLog } from '@/types/admin-pages'

const BASE = process.env.NEXT_PUBLIC_BACKEND_URL
const OPT = { credentials: 'include' as const, headers: { 'X-Requested-With': 'XMLHttpRequest' } }

async function get<T>(path: string): Promise<T | null> {
  try {
    const res = await fetch(`${BASE}/api/v1/web/staff${path}`, { ...OPT, cache: 'no-store' })
    if (!res.ok) return null
    return res.json()
  } catch { return null }
}

export type StaffBookingList = { bookings: Booking[] }
export type StaffInvoiceList = { revenueToday: number; invoices: Invoice[] }
export type StaffRefundList = { refunds: Refund[] }
export type StaffShiftList = { shifts: Shift[] }
export type StaffQRList = { requests: { id: number; sanId: number; status: string; createdAt: string; note: string; requestType: string; handledByStaffId: number }[] }

export async function getCheckInBookings(): Promise<StaffBookingList | null> { return get('/bookings') }
export async function getStaffDatSan(): Promise<StaffBookingList | null> { return get('/dat-san') }
export async function getStaffHoaDon(): Promise<StaffInvoiceList | null> { return get('/hoa-don') }
export async function getStaffHoanTien(page = 1): Promise<StaffRefundList | null> { return get(`/hoan-tien?page=${page}`) }
export async function getStaffCaLamViec(from?: string, to?: string): Promise<StaffShiftList | null> {
  const q = from ? `?from=${from}&to=${to ?? ''}` : ''
  return get(`/ca-lam-viec${q}`)
}
export async function getStaffYeuCauQr(): Promise<StaffQRList | null> { return get('/yeu-cau-qr') }
