'use client'
import { useState } from 'react'
import type { Shift } from '@/types/manager-pages'

const STATUS_COLOR: Record<string, string> = {
  'Đã xác nhận': 'bg-green-100 text-green-700',
  'Chờ duyệt': 'bg-yellow-100 text-yellow-700',
  'Đã hoàn thành': 'bg-emerald-100 text-emerald-700',
  'Vắng mặt': 'bg-red-100 text-red-700',
  'Đã hủy': 'bg-slate-100 text-slate-500',
}

export default function ShiftsClient({ shifts, defaultFrom, defaultTo }: { shifts: Shift[]; defaultFrom: string; defaultTo: string }) {
  const [filterDate, setFilterDate] = useState('')
  const [filterStatus, setFilterStatus] = useState('all')

  const filtered = shifts.filter(s => {
    const matchDate = !filterDate || s.ngayLam === filterDate
    const matchStatus = filterStatus === 'all' || s.trangThai === filterStatus
    return matchDate && matchStatus
  })

  const today = new Date().toISOString().split('T')[0]
  const todayShifts = shifts.filter(s => s.ngayLam === today)
  const statuses = Array.from(new Set(shifts.map(s => s.trangThai)))

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-3 gap-3">
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-indigo-700">{shifts.length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Tháng này</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-blue-700">{todayShifts.length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Hôm nay</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-green-700">{shifts.filter(s => s.trangThai === 'Đã xác nhận').length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Đã xác nhận</p>
        </div>
      </div>

      <div className="flex flex-wrap gap-3 items-center">
        <input type="date" className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300"
          value={filterDate} onChange={e => setFilterDate(e.target.value)} />
        <select className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300"
          value={filterStatus} onChange={e => setFilterStatus(e.target.value)}>
          <option value="all">Tất cả trạng thái</option>
          {statuses.map(s => <option key={s} value={s}>{s}</option>)}
        </select>
        <span className="ml-auto text-xs text-slate-400">{filtered.length} ca</span>
      </div>

      <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs">
              <tr>
                <th className="px-4 py-3 text-left font-semibold">ID</th>
                <th className="px-4 py-3 text-left font-semibold">Tên ca</th>
                <th className="px-4 py-3 text-left font-semibold">Vị trí</th>
                <th className="px-4 py-3 text-left font-semibold">Ngày làm</th>
                <th className="px-4 py-3 text-left font-semibold">Giờ</th>
                <th className="px-4 py-3 text-left font-semibold">Trạng thái</th>
                <th className="px-4 py-3 text-left font-semibold">Ghi chú</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.length === 0 ? (
                <tr><td colSpan={7} className="px-4 py-8 text-center text-slate-400">Không có ca làm việc nào</td></tr>
              ) : filtered.slice(0, 100).map(s => (
                <tr key={s.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-4 py-3 font-mono text-xs text-slate-500">#{s.id}</td>
                  <td className="px-4 py-3 font-semibold text-slate-800">{s.tenCa}</td>
                  <td className="px-4 py-3 text-slate-500">{s.viTri || '—'}</td>
                  <td className="px-4 py-3 text-slate-600">{s.ngayLam}</td>
                  <td className="px-4 py-3 text-slate-600 text-xs">{s.gioBatDau} – {s.gioKetThuc}</td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${STATUS_COLOR[s.trangThai] ?? 'bg-slate-100 text-slate-600'}`}>
                      {s.trangThai}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-slate-400 text-xs">{s.ghiChu || '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
