'use client'
import { useState } from 'react'
import type { Branch } from '@/types/admin-pages'

const STATUS_COLOR: Record<string, string> = {
  'Đang hoạt động': 'bg-green-100 text-green-700',
  'Chờ duyệt': 'bg-yellow-100 text-yellow-700',
  'Tạm đóng': 'bg-red-100 text-red-700',
  'Đã đóng': 'bg-slate-100 text-slate-500',
}

export default function BranchesClient({ branches }: { branches: Branch[] }) {
  const [search, setSearch] = useState('')
  const [filterStatus, setFilterStatus] = useState('all')

  const filtered = branches.filter(b => {
    const matchSearch = b.ten.toLowerCase().includes(search.toLowerCase()) || b.diaChi.toLowerCase().includes(search.toLowerCase())
    const matchStatus = filterStatus === 'all' || b.trangThai === filterStatus
    return matchSearch && matchStatus
  })

  const active = branches.filter(b => b.trangThai === 'Đang hoạt động').length
  const pending = branches.filter(b => b.trangThai === 'Chờ duyệt').length

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-3 gap-3">
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-blue-700">{branches.length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Tổng chi nhánh</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-green-700">{active}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Đang hoạt động</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-yellow-700">{pending}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Chờ duyệt</p>
        </div>
      </div>

      <div className="flex flex-wrap gap-3 items-center">
        <input className="border border-slate-200 rounded-lg px-3 py-2 text-sm w-64 focus:outline-none focus:ring-2 focus:ring-blue-300"
          placeholder="Tìm tên, địa chỉ..." value={search} onChange={e => setSearch(e.target.value)} />
        <select className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-300"
          value={filterStatus} onChange={e => setFilterStatus(e.target.value)}>
          <option value="all">Tất cả trạng thái</option>
          <option value="Đang hoạt động">Đang hoạt động</option>
          <option value="Chờ duyệt">Chờ duyệt</option>
          <option value="Tạm đóng">Tạm đóng</option>
        </select>
        <span className="ml-auto text-xs text-slate-400">{filtered.length} chi nhánh</span>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
        {filtered.length === 0 ? (
          <div className="col-span-3 text-center py-12 text-slate-400">Không có chi nhánh nào</div>
        ) : filtered.map(b => (
          <div key={b.id} className="bg-white border border-slate-200 rounded-2xl p-5 hover:shadow-md transition-shadow">
            <div className="flex items-start justify-between mb-3">
              <div>
                <p className="font-bold text-slate-800">{b.ten}</p>
                <p className="text-xs text-slate-400 mt-0.5">ID #{b.id}</p>
              </div>
              <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${STATUS_COLOR[b.trangThai] ?? 'bg-slate-100 text-slate-600'}`}>
                {b.trangThai}
              </span>
            </div>
            <div className="space-y-1.5 text-sm text-slate-500">
              <p className="flex items-center gap-2"><span>📍</span><span className="line-clamp-1">{b.diaChi || '—'}</span></p>
              <p className="flex items-center gap-2"><span>📞</span><span>{b.soDienThoai || '—'}</span></p>
              <p className="flex items-center gap-2"><span>🏸</span><span>{b.soLuongSan} sân · {b.loaiHinh || 'Chưa phân loại'}</span></p>
              {b.accountIdQuanLy > 0 && <p className="flex items-center gap-2"><span>👤</span><span>Quản lý #{b.accountIdQuanLy}</span></p>}
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
