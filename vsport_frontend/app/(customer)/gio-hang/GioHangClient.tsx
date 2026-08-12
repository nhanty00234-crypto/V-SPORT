'use client'
import { useEffect, useState } from 'react'
import Link from 'next/link'

interface Booking {
  id: number
  sanId: number
  ngayDat: string
  gioBatDau: string
  gioKetThuc: string
  tongTienDuKien: number
  trangThai: string
  tenSan?: string
  tenCoSo?: string
  coSoId?: number
}

const STATUS_COLOR: Record<string, string> = {
  'Chờ xác nhận': 'bg-yellow-100 text-yellow-700',
  'Đã xác nhận': 'bg-green-100 text-green-700',
  'Đã check-in': 'bg-blue-100 text-blue-700',
  'Đã hoàn thành': 'bg-emerald-100 text-emerald-700',
  'Đã hủy': 'bg-red-100 text-red-700',
  'Chờ thanh toán': 'bg-orange-100 text-orange-700',
}

export default function GioHangClient() {
  const [bookings, setBookings] = useState<Booking[]>([])
  const [loading, setLoading] = useState(true)
  const [filterStatus, setFilterStatus] = useState('all')

  useEffect(() => {
    const BASE = process.env.NEXT_PUBLIC_BACKEND_URL
    fetch(`${BASE}/api/v1/web/customer/bookings`, {
      credentials: 'include',
      headers: { 'X-Requested-With': 'XMLHttpRequest' },
    })
      .then(r => r.ok ? r.json() : null)
      .then(data => {
        if (data?.bookings) setBookings(data.bookings)
      })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  const filtered = bookings.filter(b =>
    filterStatus === 'all' || b.trangThai === filterStatus
  )

  const pending = bookings.filter(b => b.trangThai === 'Chờ xác nhận' || b.trangThai === 'Chờ thanh toán').length
  const totalSpent = bookings.filter(b => b.trangThai === 'Đã hoàn thành').reduce((s, b) => s + (b.tongTienDuKien || 0), 0)

  const BASE = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'

  return (
    <div className="max-w-3xl mx-auto space-y-5">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-black text-vs-navy">Lịch sử đặt sân</h1>
        <Link href="/tim-kiem" className="bg-vs-blue text-white px-4 py-2 rounded-xl text-sm font-semibold hover:bg-blue-700 transition-colors">
          + Đặt sân mới
        </Link>
      </div>

      <div className="grid grid-cols-3 gap-3">
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-vs-navy">{bookings.length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Tổng lịch đặt</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-orange-600">{pending}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Đang chờ</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-lg font-black text-green-700">{totalSpent.toLocaleString('vi-VN')}đ</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Đã thanh toán</p>
        </div>
      </div>

      <div className="flex gap-2 overflow-x-auto pb-1">
        {['all', 'Chờ xác nhận', 'Đã xác nhận', 'Đã check-in', 'Đã hoàn thành', 'Đã hủy'].map(s => (
          <button key={s} onClick={() => setFilterStatus(s)}
            className={`whitespace-nowrap px-3 py-1.5 rounded-full text-xs font-semibold transition-colors ${filterStatus === s ? 'bg-vs-blue text-white' : 'bg-white border border-slate-200 text-slate-600 hover:bg-slate-50'}`}>
            {s === 'all' ? 'Tất cả' : s}
          </button>
        ))}
      </div>

      {loading ? (
        <div className="bg-white border border-slate-200 rounded-2xl p-8 text-center text-slate-400">Đang tải...</div>
      ) : filtered.length === 0 ? (
        <div className="bg-white border border-slate-200 rounded-2xl p-8 text-center">
          <p className="text-4xl mb-3">📅</p>
          <p className="font-medium text-slate-600">Không có lịch đặt sân nào</p>
          <Link href="/tim-kiem" className="inline-block mt-4 bg-vs-blue text-white px-6 py-2.5 rounded-xl text-sm font-semibold">
            Đặt sân ngay
          </Link>
        </div>
      ) : (
        <div className="space-y-3">
          {filtered.map(b => (
            <div key={b.id} className="bg-white border border-slate-200 rounded-2xl p-4 hover:shadow-sm transition-shadow">
              <div className="flex items-start justify-between gap-3">
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    <p className="font-bold text-slate-800">{b.tenSan || `Sân #${b.sanId}`}</p>
                    <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${STATUS_COLOR[b.trangThai] ?? 'bg-slate-100 text-slate-600'}`}>
                      {b.trangThai}
                    </span>
                  </div>
                  <p className="text-sm text-slate-500">{b.tenCoSo || ''}</p>
                  <p className="text-xs text-slate-400 mt-1">
                    {b.ngayDat} · {b.gioBatDau} – {b.gioKetThuc}
                  </p>
                </div>
                <div className="text-right flex-shrink-0">
                  <p className="font-bold text-vs-navy">{(b.tongTienDuKien || 0).toLocaleString('vi-VN')}đ</p>
                  <p className="font-mono text-xs text-slate-400">#{b.id}</p>
                </div>
              </div>
              {(b.trangThai === 'Chờ thanh toán') && (
                <div className="mt-3 pt-3 border-t border-slate-100 flex gap-2">
                  <a href={`${BASE}/customer/payos-checkout?datSanId=${b.id}`} target="_blank" rel="noopener noreferrer"
                    className="bg-vs-blue text-white px-3 py-1.5 rounded-lg text-xs font-semibold">
                    Thanh toán ngay
                  </a>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
