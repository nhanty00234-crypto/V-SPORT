'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { getBookings } from '@/lib/api/customer'
import type { BookingPage, Booking } from '@/types/customer'

const STATUSES = [
  { value: '', label: 'Tất cả' },
  { value: 'Chờ xác nhận', label: 'Chờ xác nhận' },
  { value: 'Đã xác nhận', label: 'Đã xác nhận' },
  { value: 'Hoàn thành', label: 'Hoàn thành' },
  { value: 'Đã hủy', label: 'Đã hủy' },
]

const STATUS_COLORS: Record<string, string> = {
  'Chờ xác nhận': 'bg-yellow-100 text-yellow-700',
  'Đã xác nhận': 'bg-blue-100 text-blue-700',
  'Chờ thanh toán': 'bg-orange-100 text-orange-700',
  'Hoàn thành': 'bg-green-100 text-green-700',
  'Đã hủy': 'bg-slate-100 text-slate-500',
}

function fmt(dateStr: string | null) {
  if (!dateStr) return '—'
  return new Date(dateStr).toLocaleDateString('vi-VN')
}

function fmtCurrency(amount: number) {
  return new Intl.NumberFormat('vi-VN').format(amount) + ' ₫'
}

export default function BookingHistoryClient() {
  const [status, setStatus] = useState('')
  const [page, setPage] = useState(1)
  const [data, setData] = useState<BookingPage | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    setLoading(true)
    getBookings(page, status).then(d => { setData(d); setLoading(false) })
  }, [page, status])

  function onStatusChange(s: string) {
    setStatus(s)
    setPage(1)
  }

  const totalPages = data ? Math.ceil(data.total / data.pageSize) : 0

  return (
    <div>
      {/* Filter tabs */}
      <div className="flex gap-2 flex-wrap mb-4">
        {STATUSES.map(s => (
          <button
            key={s.value}
            onClick={() => onStatusChange(s.value)}
            className={`px-3 py-1.5 text-sm rounded-full border font-medium transition-all ${
              status === s.value
                ? 'bg-vs-navy text-white border-vs-navy'
                : 'border-slate-200 text-vs-slate hover:border-vs-navy hover:text-vs-navy'
            }`}
          >
            {s.label}
          </button>
        ))}
      </div>

      {loading && <div className="text-vs-slate text-sm py-8 text-center">Đang tải...</div>}

      {!loading && data?.items.length === 0 && (
        <div className="text-center py-12">
          <p className="text-vs-slate text-sm mb-4">Không có lịch đặt sân nào.</p>
          <Link href="/tim-kiem" className="text-vs-blue text-sm font-medium hover:underline">
            Tìm sân ngay →
          </Link>
        </div>
      )}

      {!loading && data && data.items.length > 0 && (
        <div className="space-y-3">
          {data.items.map((b: Booking) => (
            <div key={b.bookingId} className="bg-white rounded-xl border border-slate-100 p-4 shadow-sm">
              <div className="flex items-start justify-between gap-2">
                <div>
                  <p className="font-semibold text-vs-navy text-sm">{b.facilityName ?? 'Cơ sở'}</p>
                  <p className="text-xs text-vs-slate mt-0.5">{b.facilityAddress}</p>
                  <p className="text-xs text-vs-slate mt-1">
                    {b.courtName} · {b.sportName} · {fmt(b.date)} · {b.startTime?.slice(0, 5)}–{b.endTime?.slice(0, 5)}
                  </p>
                </div>
                <div className="text-right flex-shrink-0">
                  <span className={`inline-block px-2 py-1 rounded-full text-xs font-medium ${STATUS_COLORS[b.status] ?? 'bg-slate-100 text-slate-500'}`}>
                    {b.status}
                  </span>
                  <p className="text-sm font-bold text-vs-navy mt-1">{fmtCurrency(b.totalAmount)}</p>
                </div>
              </div>
            </div>
          ))}

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="flex justify-center gap-2 pt-2">
              <button
                onClick={() => setPage(p => Math.max(1, p - 1))}
                disabled={page === 1}
                className="px-3 py-1.5 text-sm rounded-lg border border-slate-200 text-vs-slate disabled:opacity-40 hover:border-vs-blue hover:text-vs-blue"
              >
                ←
              </button>
              <span className="px-3 py-1.5 text-sm text-vs-slate">
                {page} / {totalPages}
              </span>
              <button
                onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                disabled={page === totalPages}
                className="px-3 py-1.5 text-sm rounded-lg border border-slate-200 text-vs-slate disabled:opacity-40 hover:border-vs-blue hover:text-vs-blue"
              >
                →
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  )
}
