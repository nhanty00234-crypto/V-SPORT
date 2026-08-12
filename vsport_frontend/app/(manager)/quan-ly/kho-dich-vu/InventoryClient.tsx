'use client'
import { useState } from 'react'
import type { InventoryStats, Product } from '@/types/manager-pages'

function fmt(n: number) { return n.toLocaleString('vi-VN') + 'đ' }

function stockBadge(qty: number) {
  if (qty === 0) return 'bg-red-100 text-red-700'
  if (qty <= 5) return 'bg-yellow-100 text-yellow-700'
  return 'bg-green-100 text-green-700'
}

export default function InventoryClient({ data }: { data: InventoryStats | null }) {
  const [search, setSearch] = useState('')
  const [filterStatus, setFilterStatus] = useState('all')

  if (!data) return <div className="text-center py-12 text-slate-400">Không tải được dữ liệu kho.</div>

  const { products, total, lowStock, outOfStock, totalInventoryValue } = data
  const filtered = products.filter(p => {
    const matchSearch = p.ten.toLowerCase().includes(search.toLowerCase()) || p.skuCode.toLowerCase().includes(search.toLowerCase())
    const matchStatus = filterStatus === 'all' || p.trangThai === filterStatus
    return matchSearch && matchStatus
  })

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-indigo-700">{total}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Tổng sản phẩm</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-yellow-700">{lowStock}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Sắp hết hàng (≤5)</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-red-700">{outOfStock}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Hết hàng</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-lg font-black text-emerald-700">{fmt(totalInventoryValue)}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Giá trị tồn kho</p>
        </div>
      </div>

      <div className="flex flex-wrap gap-3 items-center">
        <input className="border border-slate-200 rounded-lg px-3 py-2 text-sm w-64 focus:outline-none focus:ring-2 focus:ring-indigo-300"
          placeholder="Tìm tên sản phẩm, SKU..." value={search} onChange={e => setSearch(e.target.value)} />
        <select className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300"
          value={filterStatus} onChange={e => setFilterStatus(e.target.value)}>
          <option value="all">Tất cả trạng thái</option>
          <option value="Đang bán">Đang bán</option>
          <option value="Ngừng bán">Ngừng bán</option>
        </select>
        <span className="ml-auto text-xs text-slate-400">{filtered.length} sản phẩm</span>
      </div>

      <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs">
              <tr>
                <th className="px-4 py-3 text-left font-semibold">ID</th>
                <th className="px-4 py-3 text-left font-semibold">Tên sản phẩm</th>
                <th className="px-4 py-3 text-left font-semibold">SKU</th>
                <th className="px-4 py-3 text-left font-semibold">Đơn vị</th>
                <th className="px-4 py-3 text-right font-semibold">Đơn giá</th>
                <th className="px-4 py-3 text-right font-semibold">Tồn kho</th>
                <th className="px-4 py-3 text-left font-semibold">Trạng thái</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.length === 0 ? (
                <tr><td colSpan={7} className="px-4 py-8 text-center text-slate-400">Không có sản phẩm nào</td></tr>
              ) : filtered.map(p => (
                <tr key={p.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-4 py-3 font-mono text-xs text-slate-500">#{p.id}</td>
                  <td className="px-4 py-3 font-semibold text-slate-800">{p.ten}</td>
                  <td className="px-4 py-3 font-mono text-xs text-slate-400">{p.skuCode || '—'}</td>
                  <td className="px-4 py-3 text-slate-500">{p.donViTinh}</td>
                  <td className="px-4 py-3 text-right font-medium">{fmt(p.donGia)}</td>
                  <td className="px-4 py-3 text-right">
                    <span className={`px-2 py-0.5 rounded-full text-[11px] font-bold ${stockBadge(p.soLuongTon)}`}>
                      {p.soLuongTon}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${p.trangThai === 'Đang bán' ? 'bg-green-100 text-green-700' : 'bg-slate-100 text-slate-500'}`}>
                      {p.trangThai}
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
