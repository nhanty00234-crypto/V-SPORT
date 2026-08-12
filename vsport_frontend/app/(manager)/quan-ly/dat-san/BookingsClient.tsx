'use client'
import { useState } from 'react'
import type { Booking } from '@/types/manager-pages'

const STATUS_COLOR: Record<string, string> = {
  'Chờ xác nhận': 'bg-yellow-100 text-yellow-700',
  'Đã xác nhận': 'bg-green-100 text-green-700',
  'Đã check-in': 'bg-blue-100 text-blue-700',
  'Đã hoàn thành': 'bg-emerald-100 text-emerald-700',
  'Đã hủy': 'bg-red-100 text-red-700',
  'Chờ thanh toán': 'bg-orange-100 text-orange-700',
}

function fmt(n: number) { return n.toLocaleString('vi-VN') + 'đ' }

export default function BookingsClient({ bookings }: { bookings: Booking[] }) {
  const [search, setSearch] = useState('')
  const [filterStatus, setFilterStatus] = useState('all')
  const [filterDate, setFilterDate] = useState('')

  const filtered = bookings.filter(b => {
    const matchSearch = b.tenKhach.toLowerCase().includes(search.toLowerCase()) ||
      b.phone.includes(search) || b.tenSan.toLowerCase().includes(search.toLowerCase())
    const matchStatus = filterStatus === 'all' || b.trangThai === filterStatus
    const matchDate = !filterDate || b.ngayDat === filterDate
    return matchSearch && matchStatus && matchDate
  })

  const statuses = Array.from(new Set(bookings.map(b => b.trangThai)))
  const totalRevenue = bookings.filter(b => b.trangThai === 'Đã hoàn thành' || b.trangThai === 'Đã check-in')
    .reduce((sum, b) => sum + b.tongTien, 0)

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        {[
          { label: 'Tổng lịch đặt', value: bookings.length, color: 'text-indigo-700' },
          { label: 'Chờ xác nhận', value: bookings.filter(b => b.trangThai === 'Chờ xác nhận').length, color: 'text-yellow-700' },
          { label: 'Đã hoàn thành', value: bookings.filter(b => b.trangThai === 'Đã hoàn thành').length, color: 'text-emerald-700' },
          { label: 'Doanh thu', value: fmt(totalRevenue), color: 'text-green-700' },
        ].map(s => (
          <div key={s.label} className="bg-white border border-slate-200 rounded-xl p-4">
            <p className={`text-2xl font-black ${s.color}`}>{s.value}</p>
            <p className="text-xs font-semibold text-slate-500 mt-0.5">{s.label}</p>
          </div>
        ))}
      </div>

      <div className="flex flex-wrap gap-3 items-center">
        <input className="border border-slate-200 rounded-lg px-3 py-2 text-sm w-56 focus:outline-none focus:ring-2 focus:ring-indigo-300"
          placeholder="Tìm khách hàng, sân..." value={search} onChange={e => setSearch(e.target.value)} />
        <select className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300"
          value={filterStatus} onChange={e => setFilterStatus(e.target.value)}>
          <option value="all">Tất cả trạng thái</option>
          {statuses.map(s => <option key={s} value={s}>{s}</option>)}
        </select>
        <input type="date" className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300"
          value={filterDate} onChange={e => setFilterDate(e.target.value)} />
        <span className="ml-auto text-xs text-slate-400">{filtered.length} kết quả</span>
      </div>

      <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs">
              <tr>
                <th className="px-4 py-3 text-left font-semibold">ID</th>
                <th className="px-4 py-3 text-left font-semibold">Khách hàng</th>
                <th className="px-4 py-3 text-left font-semibold">Sân</th>
                <th className="px-4 py-3 text-left font-semibold">Ngày đặt</th>
                <th className="px-4 py-3 text-left font-semibold">Giờ</th>
                <th className="px-4 py-3 text-right font-semibold">Tổng tiền</th>
                <th className="px-4 py-3 text-left font-semibold">Trạng thái</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.length === 0 ? (
                <tr><td colSpan={7} className="px-4 py-8 text-center text-slate-400">Không có lịch đặt nào</td></tr>
              ) : filtered.slice(0, 100).map(b => (
                <tr key={b.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-4 py-3 font-mono text-xs text-slate-500">#{b.id}</td>
                  <td className="px-4 py-3">
                    <p className="font-semibold text-slate-800">{b.tenKhach || `KH #${b.accountId}`}</p>
                    <p className="text-xs text-slate-400">{b.phone}</p>
                  </td>
                  <td className="px-4 py-3 text-slate-600">{b.tenSan || `Sân #${b.sanId}`}</td>
                  <td className="px-4 py-3 text-slate-600">{b.ngayDat}</td>
                  <td className="px-4 py-3 text-slate-600 text-xs">{b.gioBatDau} – {b.gioKetThuc}</td>
                  <td className="px-4 py-3 text-right font-medium text-slate-800">{fmt(b.tongTien)}</td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${STATUS_COLOR[b.trangThai] ?? 'bg-slate-100 text-slate-600'}`}>
                      {b.trangThai}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="px-4 py-3 border-t border-slate-100 text-xs text-slate-400">
          Hiển thị {Math.min(filtered.length, 100)} / {bookings.length} lịch đặt
        </div>
      </div>
    </div>
  )
}
