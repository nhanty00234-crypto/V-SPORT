'use client'
import { useState } from 'react'
import type { Court } from '@/types/manager-pages'

const STATUS_COLOR: Record<string, string> = {
  'Sẵn sàng': 'bg-green-100 text-green-700',
  'Đang dùng': 'bg-blue-100 text-blue-700',
  'Bảo trì': 'bg-red-100 text-red-700',
  'Tạm đóng': 'bg-yellow-100 text-yellow-700',
}

function fmt(n: number) { return n.toLocaleString('vi-VN') + 'đ' }

export default function CourtsClient({ courts }: { courts: Court[] }) {
  const [search, setSearch] = useState('')
  const [filterStatus, setFilterStatus] = useState('all')

  const filtered = courts.filter(c => {
    const matchSearch = c.ten.toLowerCase().includes(search.toLowerCase()) || c.tenLoaiSan.toLowerCase().includes(search.toLowerCase())
    const matchStatus = filterStatus === 'all' || c.trangThai === filterStatus
    return matchSearch && matchStatus
  })

  const active = courts.filter(c => c.trangThai === 'Sẵn sàng' || c.trangThai === 'Đang dùng').length
  const statuses = Array.from(new Set(courts.map(c => c.trangThai)))

  return (
    <div className="space-y-5">
      {/* Header stats */}
      <div className="grid grid-cols-3 gap-3">
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-indigo-700">{courts.length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Tổng số sân</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-green-700">{active}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Đang hoạt động</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-red-700">{courts.length - active}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Không hoạt động</p>
        </div>
      </div>

      {/* Filters + add */}
      <div className="flex flex-wrap gap-3 items-center">
        <input
          className="border border-slate-200 rounded-lg px-3 py-2 text-sm w-64 focus:outline-none focus:ring-2 focus:ring-indigo-300"
          placeholder="Tìm tên sân, loại sân..."
          value={search} onChange={e => setSearch(e.target.value)}
        />
        <select
          className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300"
          value={filterStatus} onChange={e => setFilterStatus(e.target.value)}
        >
          <option value="all">Tất cả trạng thái</option>
          {statuses.map(s => <option key={s} value={s}>{s}</option>)}
        </select>
        <a
          href={`${process.env.NEXT_PUBLIC_BACKEND_URL?.replace('/Backend_java', '')}/Backend_java/manager/quan-ly-san`}
          target="_blank" rel="noopener noreferrer"
          className="ml-auto bg-indigo-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-indigo-700 transition-colors"
        >
          + Quản lý đầy đủ (JSP)
        </a>
      </div>

      {/* Table */}
      <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs">
              <tr>
                <th className="px-4 py-3 text-left font-semibold">ID</th>
                <th className="px-4 py-3 text-left font-semibold">Tên sân</th>
                <th className="px-4 py-3 text-left font-semibold">Loại sân</th>
                <th className="px-4 py-3 text-left font-semibold">Trạng thái</th>
                <th className="px-4 py-3 text-right font-semibold">Giá (không đèn)</th>
                <th className="px-4 py-3 text-right font-semibold">Giá (có đèn)</th>
                <th className="px-4 py-3 text-left font-semibold">Mô tả</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.length === 0 ? (
                <tr><td colSpan={7} className="px-4 py-8 text-center text-slate-400">Không có sân nào</td></tr>
              ) : filtered.map(c => (
                <tr key={c.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-4 py-3 font-mono text-xs text-slate-500">#{c.id}</td>
                  <td className="px-4 py-3 font-semibold text-slate-800">{c.ten}</td>
                  <td className="px-4 py-3 text-slate-500">{c.tenLoaiSan || '—'}</td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${STATUS_COLOR[c.trangThai] ?? 'bg-slate-100 text-slate-600'}`}>
                      {c.trangThai}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-right font-medium">{fmt(c.giaKhongDen)}</td>
                  <td className="px-4 py-3 text-right font-medium">{fmt(c.giaCoDen)}</td>
                  <td className="px-4 py-3 text-slate-500 text-xs max-w-[200px] truncate">{c.moTa || '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="px-4 py-3 border-t border-slate-100 text-xs text-slate-400">
          Hiển thị {filtered.length} / {courts.length} sân
        </div>
      </div>
    </div>
  )
}
