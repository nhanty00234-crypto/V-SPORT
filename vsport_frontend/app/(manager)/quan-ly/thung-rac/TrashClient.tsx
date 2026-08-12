'use client'
import { useState } from 'react'
import type { TrashData } from '@/types/manager-pages'

type Tab = 'courts' | 'bookings' | 'products' | 'staff'

export default function TrashClient({ data }: { data: TrashData | null }) {
  const [tab, setTab] = useState<Tab>('courts')

  if (!data) return <div className="text-center py-12 text-slate-400">Không tải được dữ liệu thùng rác.</div>

  const tabs: { key: Tab; label: string; count: number }[] = [
    { key: 'courts', label: 'Sân', count: data.courts.length },
    { key: 'bookings', label: 'Lịch đặt', count: data.bookings.length },
    { key: 'products', label: 'Sản phẩm', count: data.products.length },
    { key: 'staff', label: 'Nhân sự', count: data.staff.length },
  ]
  const total = data.courts.length + data.bookings.length + data.products.length + data.staff.length

  return (
    <div className="space-y-5">
      <div className="bg-red-50 border border-red-200 rounded-2xl p-4 flex items-start gap-3">
        <span className="text-2xl">🗑️</span>
        <div>
          <p className="font-bold text-red-800">Thùng rác</p>
          <p className="text-sm text-red-600">{total} mục đã bị xóa mềm. Có thể khôi phục qua giao diện JSP đầy đủ.</p>
        </div>
      </div>

      <div className="flex gap-1 border-b border-slate-200">
        {tabs.map(t => (
          <button key={t.key} onClick={() => setTab(t.key)}
            className={`px-4 py-2.5 text-sm font-semibold border-b-2 transition-colors ${tab === t.key ? 'border-indigo-600 text-indigo-700' : 'border-transparent text-slate-500 hover:text-slate-700'}`}>
            {t.label} ({t.count})
          </button>
        ))}
      </div>

      <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
        {tab === 'courts' && (
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs"><tr>
              <th className="px-4 py-3 text-left font-semibold">ID</th>
              <th className="px-4 py-3 text-left font-semibold">Tên sân</th>
              <th className="px-4 py-3 text-left font-semibold">Ngày xóa</th>
            </tr></thead>
            <tbody className="divide-y divide-slate-100">
              {data.courts.length === 0 ? <tr><td colSpan={3} className="px-4 py-8 text-center text-slate-400">Trống</td></tr>
                : data.courts.map(c => <tr key={c.id} className="hover:bg-slate-50"><td className="px-4 py-3 font-mono text-xs text-slate-500">#{c.id}</td><td className="px-4 py-3 text-slate-800">{c.ten}</td><td className="px-4 py-3 text-slate-400 text-xs">{c.deletedAt}</td></tr>)}
            </tbody>
          </table>
        )}
        {tab === 'bookings' && (
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs"><tr>
              <th className="px-4 py-3 text-left font-semibold">ID</th>
              <th className="px-4 py-3 text-left font-semibold">Ngày đặt</th>
              <th className="px-4 py-3 text-left font-semibold">Trạng thái</th>
            </tr></thead>
            <tbody className="divide-y divide-slate-100">
              {data.bookings.length === 0 ? <tr><td colSpan={3} className="px-4 py-8 text-center text-slate-400">Trống</td></tr>
                : data.bookings.map(b => <tr key={b.id} className="hover:bg-slate-50"><td className="px-4 py-3 font-mono text-xs text-slate-500">#{b.id}</td><td className="px-4 py-3 text-slate-600">{b.ngayDat}</td><td className="px-4 py-3 text-slate-400 text-xs">{b.trangThai}</td></tr>)}
            </tbody>
          </table>
        )}
        {tab === 'products' && (
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs"><tr>
              <th className="px-4 py-3 text-left font-semibold">ID</th>
              <th className="px-4 py-3 text-left font-semibold">Tên sản phẩm</th>
              <th className="px-4 py-3 text-left font-semibold">Ngày xóa</th>
            </tr></thead>
            <tbody className="divide-y divide-slate-100">
              {data.products.length === 0 ? <tr><td colSpan={3} className="px-4 py-8 text-center text-slate-400">Trống</td></tr>
                : data.products.map(p => <tr key={p.id} className="hover:bg-slate-50"><td className="px-4 py-3 font-mono text-xs text-slate-500">#{p.id}</td><td className="px-4 py-3 text-slate-800">{p.ten}</td><td className="px-4 py-3 text-slate-400 text-xs">{p.deletedAt}</td></tr>)}
            </tbody>
          </table>
        )}
        {tab === 'staff' && (
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs"><tr>
              <th className="px-4 py-3 text-left font-semibold">ID</th>
              <th className="px-4 py-3 text-left font-semibold">Họ tên</th>
              <th className="px-4 py-3 text-left font-semibold">Email</th>
            </tr></thead>
            <tbody className="divide-y divide-slate-100">
              {data.staff.length === 0 ? <tr><td colSpan={3} className="px-4 py-8 text-center text-slate-400">Trống</td></tr>
                : data.staff.map(s => <tr key={s.id} className="hover:bg-slate-50"><td className="px-4 py-3 font-mono text-xs text-slate-500">#{s.id}</td><td className="px-4 py-3 text-slate-800">{s.fullName}</td><td className="px-4 py-3 text-slate-400">{s.email}</td></tr>)}
            </tbody>
          </table>
        )}
      </div>
    </div>
  )
}
