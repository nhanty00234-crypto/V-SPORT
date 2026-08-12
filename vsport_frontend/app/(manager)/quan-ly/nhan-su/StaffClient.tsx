'use client'
import { useState } from 'react'
import type { StaffMember } from '@/types/manager-pages'

const ROLE_LABELS: Record<number, { label: string; color: string }> = {
  2: { label: 'Quản lý', color: 'bg-indigo-100 text-indigo-700' },
  4: { label: 'Lễ tân', color: 'bg-orange-100 text-orange-700' },
  5: { label: 'Nhân viên', color: 'bg-amber-100 text-amber-700' },
}

export default function StaffClient({ staff }: { staff: StaffMember[] }) {
  const [search, setSearch] = useState('')
  const [filterRole, setFilterRole] = useState('all')

  const filtered = staff.filter(s => {
    const matchSearch = s.fullName.toLowerCase().includes(search.toLowerCase()) ||
      s.email.toLowerCase().includes(search.toLowerCase()) || s.phone.includes(search)
    const matchRole = filterRole === 'all' || String(s.roleId) === filterRole
    return matchSearch && matchRole
  })

  const active = staff.filter(s => !s.locked).length

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-3 gap-3">
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-indigo-700">{staff.length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Tổng nhân sự</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-green-700">{active}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Đang hoạt động</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-red-700">{staff.length - active}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Bị khóa</p>
        </div>
      </div>

      <div className="flex flex-wrap gap-3 items-center">
        <input className="border border-slate-200 rounded-lg px-3 py-2 text-sm w-64 focus:outline-none focus:ring-2 focus:ring-indigo-300"
          placeholder="Tìm tên, email, số điện thoại..." value={search} onChange={e => setSearch(e.target.value)} />
        <select className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300"
          value={filterRole} onChange={e => setFilterRole(e.target.value)}>
          <option value="all">Tất cả vai trò</option>
          <option value="4">Lễ tân</option>
          <option value="5">Nhân viên</option>
        </select>
        <span className="ml-auto text-xs text-slate-400">{filtered.length} nhân sự</span>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
        {filtered.length === 0 ? (
          <div className="col-span-3 text-center py-12 text-slate-400">Không có nhân sự nào</div>
        ) : filtered.map(s => {
          const role = ROLE_LABELS[s.roleId] ?? { label: s.roleName, color: 'bg-slate-100 text-slate-600' }
          return (
            <div key={s.id} className="bg-white border border-slate-200 rounded-2xl p-5 flex gap-4">
              <div className={`w-12 h-12 rounded-full flex items-center justify-center text-white font-bold text-lg flex-shrink-0 ${s.locked ? 'bg-slate-400' : 'bg-indigo-500'}`}>
                {s.initial || s.fullName.charAt(0)}
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-1">
                  <p className="font-bold text-slate-800 truncate">{s.fullName}</p>
                  {s.locked && <span className="text-[10px] bg-red-100 text-red-600 px-1.5 py-0.5 rounded-full">Khóa</span>}
                </div>
                <p className="text-xs text-slate-400 truncate">{s.email}</p>
                <p className="text-xs text-slate-400">{s.phone}</p>
                <div className="mt-2">
                  <span className={`text-[11px] px-2 py-0.5 rounded-full font-semibold ${role.color}`}>{role.label}</span>
                </div>
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}
