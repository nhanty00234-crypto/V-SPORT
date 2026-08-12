'use client'
import { useState } from 'react'
import type { Booking } from '@/types/manager-pages'

const STATUS_COLOR: Record<string, string> = {
  'Chờ xác nhận': 'bg-yellow-100 text-yellow-700',
  'Đã xác nhận': 'bg-green-100 text-green-700',
  'Đã check-in': 'bg-blue-100 text-blue-700',
  'Đã hoàn thành': 'bg-emerald-100 text-emerald-700',
  'Đã hủy': 'bg-red-100 text-red-700',
}

export default function CheckInClient({ bookings }: { bookings: Booking[] }) {
  const [search, setSearch] = useState('')
  const [filterStatus, setFilterStatus] = useState('all')

  const filtered = bookings.filter(b => {
    const matchSearch = b.tenKhach.toLowerCase().includes(search.toLowerCase()) ||
      b.phone.includes(search) || b.tenSan.toLowerCase().includes(search.toLowerCase()) ||
      String(b.id).includes(search)
    const matchStatus = filterStatus === 'all' || b.trangThai === filterStatus
    return matchSearch && matchStatus
  })

  const readyForCheckIn = bookings.filter(b => b.trangThai === 'Đã xác nhận').length
  const checkedIn = bookings.filter(b => b.trangThai === 'Đã check-in').length

  return (
    <div className="space-y-5">
      <div className="bg-gradient-to-r from-orange-700 to-orange-900 rounded-2xl p-6 text-white">
        <h2 className="text-xl font-black mb-1">Check-in sân hôm nay</h2>
        <p className="text-orange-200 text-sm">{bookings.length} lịch đặt · {readyForCheckIn} chờ check-in · {checkedIn} đã check-in</p>
      </div>

      <div className="grid grid-cols-3 gap-3">
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-slate-800">{bookings.length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Tổng lịch hôm nay</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-orange-700">{readyForCheckIn}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Chờ check-in</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-blue-700">{checkedIn}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Đã check-in</p>
        </div>
      </div>

      <div className="flex flex-wrap gap-3 items-center">
        <input className="border border-slate-200 rounded-lg px-3 py-2 text-sm w-64 focus:outline-none focus:ring-2 focus:ring-orange-300"
          placeholder="Tìm tên, SĐT, ID đặt sân..." value={search} onChange={e => setSearch(e.target.value)} />
        <select className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-orange-300"
          value={filterStatus} onChange={e => setFilterStatus(e.target.value)}>
          <option value="all">Tất cả trạng thái</option>
          <option value="Đã xác nhận">Chờ check-in</option>
          <option value="Đã check-in">Đã check-in</option>
          <option value="Đã hoàn thành">Đã hoàn thành</option>
        </select>
        <span className="ml-auto text-xs text-slate-400">{filtered.length} kết quả</span>
      </div>

      <div className="space-y-3">
        {filtered.length === 0 ? (
          <div className="bg-white border border-slate-200 rounded-2xl p-8 text-center text-slate-400">
            Không có lịch đặt nào phù hợp
          </div>
        ) : filtered.map(b => (
          <div key={b.id} className="bg-white border border-slate-200 rounded-2xl p-4 flex items-center gap-4 hover:shadow-sm transition-shadow">
            <div className="w-12 h-12 bg-orange-100 rounded-xl flex items-center justify-center text-xl flex-shrink-0">🏸</div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 mb-1">
                <p className="font-bold text-slate-800">{b.tenKhach || `Khách #${b.accountId}`}</p>
                <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${STATUS_COLOR[b.trangThai] ?? 'bg-slate-100 text-slate-600'}`}>
                  {b.trangThai}
                </span>
              </div>
              <p className="text-xs text-slate-400">{b.phone} · {b.tenSan} · {b.gioBatDau}–{b.gioKetThuc}</p>
            </div>
            <div className="text-right flex-shrink-0">
              <p className="font-mono text-xs text-slate-400">#{b.id}</p>
              <p className="font-bold text-slate-800">{b.tongTien.toLocaleString('vi-VN')}đ</p>
            </div>
            {b.trangThai === 'Đã xác nhận' && (
              <a href={`${process.env.NEXT_PUBLIC_BACKEND_URL?.replace('/Backend_java', '')}/Backend_java/staff/checkin?id=${b.id}`}
                target="_blank" rel="noopener noreferrer"
                className="bg-orange-600 text-white px-3 py-2 rounded-lg text-xs font-bold hover:bg-orange-700 flex-shrink-0">
                Check-in
              </a>
            )}
          </div>
        ))}
      </div>
    </div>
  )
}
