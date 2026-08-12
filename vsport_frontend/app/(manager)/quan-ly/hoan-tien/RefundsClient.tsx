'use client'
import { useState } from 'react'
import type { Refund } from '@/types/manager-pages'

const STATUS_COLOR: Record<string, string> = {
  'Chờ xử lý': 'bg-yellow-100 text-yellow-700',
  'Đã hoàn tiền': 'bg-green-100 text-green-700',
  'Từ chối': 'bg-red-100 text-red-700',
  'Đang xử lý': 'bg-blue-100 text-blue-700',
}

function fmt(n: number) { return n.toLocaleString('vi-VN') + 'đ' }

export default function RefundsClient({ refunds }: { refunds: Refund[] }) {
  const [search, setSearch] = useState('')
  const [filterStatus, setFilterStatus] = useState('all')

  const filtered = refunds.filter(r => {
    const matchSearch = r.lyDo.toLowerCase().includes(search.toLowerCase()) ||
      String(r.hoaDonId).includes(search) || (r.maGiaoDichHoan && r.maGiaoDichHoan.includes(search))
    const matchStatus = filterStatus === 'all' || r.trangThai === filterStatus
    return matchSearch && matchStatus
  })

  const pending = refunds.filter(r => r.trangThai === 'Chờ xử lý').length
  const totalRefunded = refunds.filter(r => r.trangThai === 'Đã hoàn tiền').reduce((sum, r) => sum + r.soTienHoan, 0)

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-3 gap-3">
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-yellow-700">{pending}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Chờ xử lý</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-indigo-700">{refunds.length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Tổng yêu cầu</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-lg font-black text-red-700">{fmt(totalRefunded)}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Đã hoàn tiền</p>
        </div>
      </div>

      <div className="flex flex-wrap gap-3 items-center">
        <input className="border border-slate-200 rounded-lg px-3 py-2 text-sm w-64 focus:outline-none focus:ring-2 focus:ring-indigo-300"
          placeholder="Tìm lý do, ID hóa đơn..." value={search} onChange={e => setSearch(e.target.value)} />
        <select className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300"
          value={filterStatus} onChange={e => setFilterStatus(e.target.value)}>
          <option value="all">Tất cả trạng thái</option>
          <option value="Chờ xử lý">Chờ xử lý</option>
          <option value="Đã hoàn tiền">Đã hoàn tiền</option>
          <option value="Từ chối">Từ chối</option>
        </select>
        <span className="ml-auto text-xs text-slate-400">{filtered.length} yêu cầu</span>
      </div>

      <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs">
              <tr>
                <th className="px-4 py-3 text-left font-semibold">ID</th>
                <th className="px-4 py-3 text-left font-semibold">HĐ #</th>
                <th className="px-4 py-3 text-left font-semibold">Khách hàng</th>
                <th className="px-4 py-3 text-right font-semibold">Số tiền hoàn</th>
                <th className="px-4 py-3 text-left font-semibold">Lý do</th>
                <th className="px-4 py-3 text-left font-semibold">Thời gian YC</th>
                <th className="px-4 py-3 text-left font-semibold">Trạng thái</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.length === 0 ? (
                <tr><td colSpan={7} className="px-4 py-8 text-center text-slate-400">Không có yêu cầu hoàn tiền</td></tr>
              ) : filtered.slice(0, 100).map(r => (
                <tr key={r.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-4 py-3 font-mono text-xs text-slate-500">#{r.id}</td>
                  <td className="px-4 py-3 font-mono text-xs text-slate-400">#{r.hoaDonId}</td>
                  <td className="px-4 py-3 text-slate-500">KH #{r.accountId}</td>
                  <td className="px-4 py-3 text-right font-bold text-red-700">{fmt(r.soTienHoan)}</td>
                  <td className="px-4 py-3 text-slate-600 max-w-[200px] truncate">{r.lyDo}</td>
                  <td className="px-4 py-3 text-slate-400 text-xs">{r.thoiGianYeuCau}</td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${STATUS_COLOR[r.trangThai] ?? 'bg-slate-100 text-slate-600'}`}>
                      {r.trangThai}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
