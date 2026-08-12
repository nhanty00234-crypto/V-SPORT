'use client'
import { useState } from 'react'
import type { PromotionStats, Promotion } from '@/types/manager-pages'

const STATUS_COLOR: Record<string, string> = {
  'Đang diễn ra': 'bg-green-100 text-green-700',
  'Sắp diễn ra': 'bg-blue-100 text-blue-700',
  'Đã kết thúc': 'bg-slate-100 text-slate-500',
  'Tạm dừng': 'bg-yellow-100 text-yellow-700',
}

function fmtDiscount(p: Promotion) {
  if (p.loaiGiam === 'PERCENT') return `${p.giaTriGiam}%`
  return p.giaTriGiam.toLocaleString('vi-VN') + 'đ'
}

export default function PromotionsClient({ data }: { data: PromotionStats | null }) {
  const [search, setSearch] = useState('')
  const [filterStatus, setFilterStatus] = useState('all')

  if (!data) return <div className="text-center py-12 text-slate-400">Không tải được dữ liệu khuyến mãi.</div>

  const { promotions, countActive, countUpcoming, countExpired, totalUsage } = data
  const filtered = promotions.filter(p => {
    const matchSearch = p.maCode.toLowerCase().includes(search.toLowerCase()) || p.moTa.toLowerCase().includes(search.toLowerCase())
    const matchStatus = filterStatus === 'all' || p.trangThai === filterStatus
    return matchSearch && matchStatus
  })

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-green-700">{countActive}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Đang diễn ra</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-blue-700">{countUpcoming}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Sắp diễn ra</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-slate-500">{countExpired}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Đã kết thúc</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-indigo-700">{totalUsage}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Lượt sử dụng</p>
        </div>
      </div>

      <div className="flex flex-wrap gap-3 items-center">
        <input className="border border-slate-200 rounded-lg px-3 py-2 text-sm w-64 focus:outline-none focus:ring-2 focus:ring-indigo-300"
          placeholder="Tìm mã code, mô tả..." value={search} onChange={e => setSearch(e.target.value)} />
        <select className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300"
          value={filterStatus} onChange={e => setFilterStatus(e.target.value)}>
          <option value="all">Tất cả trạng thái</option>
          <option value="Đang diễn ra">Đang diễn ra</option>
          <option value="Sắp diễn ra">Sắp diễn ra</option>
          <option value="Đã kết thúc">Đã kết thúc</option>
        </select>
        <span className="ml-auto text-xs text-slate-400">{filtered.length} khuyến mãi</span>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
        {filtered.length === 0 ? (
          <div className="col-span-3 text-center py-12 text-slate-400">Không có khuyến mãi nào</div>
        ) : filtered.map(p => (
          <div key={p.id} className="bg-white border border-slate-200 rounded-2xl p-5 hover:shadow-md transition-shadow">
            <div className="flex items-start justify-between mb-3">
              <span className="font-mono font-bold text-lg text-indigo-700 bg-indigo-50 px-2 py-0.5 rounded-lg">{p.maCode}</span>
              <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${STATUS_COLOR[p.trangThai] ?? 'bg-slate-100 text-slate-600'}`}>
                {p.trangThai}
              </span>
            </div>
            <p className="text-sm text-slate-600 mb-3 line-clamp-2">{p.moTa}</p>
            <div className="flex items-center justify-between text-sm">
              <span className="font-bold text-emerald-700 text-lg">{fmtDiscount(p)}</span>
              <span className="text-slate-400 text-xs">{p.soLanDaDung}/{p.soLanToiDa || '∞'} lượt</span>
            </div>
            {p.giaTriToiThieu > 0 && (
              <p className="text-xs text-slate-400 mt-1">Đơn tối thiểu: {p.giaTriToiThieu.toLocaleString('vi-VN')}đ</p>
            )}
            <div className="mt-3 pt-3 border-t border-slate-100 text-xs text-slate-400 flex justify-between">
              <span>Từ: {p.ngayBatDau}</span>
              <span>Đến: {p.ngayKetThuc}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
