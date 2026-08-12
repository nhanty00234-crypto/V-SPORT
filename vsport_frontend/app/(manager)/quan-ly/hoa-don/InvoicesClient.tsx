'use client'
import { useState } from 'react'
import type { InvoiceStats, Invoice } from '@/types/manager-pages'

const STATUS_COLOR: Record<string, string> = {
  'Đã thanh toán': 'bg-green-100 text-green-700',
  'Chờ thanh toán': 'bg-yellow-100 text-yellow-700',
  'Đã hoàn tiền': 'bg-blue-100 text-blue-700',
  'Hủy': 'bg-red-100 text-red-700',
}

function fmt(n: number) { return n.toLocaleString('vi-VN') + 'đ' }

export default function InvoicesClient({ data }: { data: InvoiceStats | null }) {
  const [search, setSearch] = useState('')
  const [filterStatus, setFilterStatus] = useState('all')

  if (!data) return <div className="text-center py-12 text-slate-400">Không tải được dữ liệu hóa đơn.</div>

  const { invoices, revenueToday, totalRevenue } = data
  const filtered = invoices.filter(inv => {
    const matchSearch = String(inv.id).includes(search) || String(inv.datSanId).includes(search)
    const matchStatus = filterStatus === 'all' || inv.status === filterStatus
    return matchSearch && matchStatus
  })

  const statuses = Array.from(new Set(invoices.map(inv => inv.status)))

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-indigo-700">{invoices.length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Tổng hóa đơn</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-xl font-black text-green-700">{fmt(revenueToday)}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Doanh thu hôm nay</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-xl font-black text-emerald-700">{fmt(totalRevenue)}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Tổng doanh thu</p>
        </div>
      </div>

      <div className="flex flex-wrap gap-3 items-center">
        <input className="border border-slate-200 rounded-lg px-3 py-2 text-sm w-56 focus:outline-none focus:ring-2 focus:ring-indigo-300"
          placeholder="Tìm ID hóa đơn, đặt sân..." value={search} onChange={e => setSearch(e.target.value)} />
        <select className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300"
          value={filterStatus} onChange={e => setFilterStatus(e.target.value)}>
          <option value="all">Tất cả trạng thái</option>
          {statuses.map(s => <option key={s} value={s}>{s}</option>)}
        </select>
        <span className="ml-auto text-xs text-slate-400">{filtered.length} kết quả</span>
      </div>

      <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs">
              <tr>
                <th className="px-4 py-3 text-left font-semibold">ID HĐ</th>
                <th className="px-4 py-3 text-left font-semibold">ID ĐS</th>
                <th className="px-4 py-3 text-left font-semibold">Khách hàng</th>
                <th className="px-4 py-3 text-left font-semibold">Ngày lập</th>
                <th className="px-4 py-3 text-right font-semibold">Tổng tiền</th>
                <th className="px-4 py-3 text-left font-semibold">Trạng thái</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.length === 0 ? (
                <tr><td colSpan={6} className="px-4 py-8 text-center text-slate-400">Không có hóa đơn nào</td></tr>
              ) : filtered.slice(0, 100).map(inv => (
                <tr key={inv.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-4 py-3 font-mono text-xs text-slate-500">#{inv.id}</td>
                  <td className="px-4 py-3 font-mono text-xs text-slate-400">#{inv.datSanId}</td>
                  <td className="px-4 py-3 text-slate-500">KH #{inv.accountId}</td>
                  <td className="px-4 py-3 text-slate-600">{inv.date}</td>
                  <td className="px-4 py-3 text-right font-bold text-slate-800">{fmt(inv.total)}</td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${STATUS_COLOR[inv.status] ?? 'bg-slate-100 text-slate-600'}`}>
                      {inv.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="px-4 py-3 border-t border-slate-100 text-xs text-slate-400">
          Hiển thị {Math.min(filtered.length, 100)} / {invoices.length} hóa đơn
        </div>
      </div>
    </div>
  )
}
