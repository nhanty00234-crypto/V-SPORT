'use client'
import { useState } from 'react'
import type { Account } from '@/types/admin-pages'

const ROLE_LABELS: Record<number, { label: string; color: string }> = {
  1: { label: 'Admin', color: 'bg-red-100 text-red-700' },
  2: { label: 'Manager', color: 'bg-indigo-100 text-indigo-700' },
  3: { label: 'Khách hàng', color: 'bg-sky-100 text-sky-700' },
  4: { label: 'Lễ tân', color: 'bg-orange-100 text-orange-700' },
  5: { label: 'Nhân viên', color: 'bg-amber-100 text-amber-700' },
  6: { label: 'Owner', color: 'bg-violet-100 text-violet-700' },
}

interface Props {
  accounts: Account[]
  title?: string
  roleFilter?: number
}

export default function AccountsClient({ accounts, title = 'Nhân sự hệ thống', roleFilter }: Props) {
  const [search, setSearch] = useState('')
  const [filterRole, setFilterRole] = useState(roleFilter ? String(roleFilter) : 'all')

  const filtered = accounts.filter(a => {
    const matchSearch = a.fullName.toLowerCase().includes(search.toLowerCase()) ||
      a.email.toLowerCase().includes(search.toLowerCase()) || a.username.toLowerCase().includes(search.toLowerCase())
    const matchRole = filterRole === 'all' || String(a.roleId) === filterRole
    return matchSearch && matchRole
  })

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
        {Object.entries(ROLE_LABELS).map(([roleId, { label, color }]) => {
          const count = accounts.filter(a => a.roleId === Number(roleId)).length
          if (count === 0) return null
          return (
            <div key={roleId} className="bg-white border border-slate-200 rounded-xl p-4">
              <p className="text-2xl font-black text-slate-800">{count}</p>
              <p className="text-xs font-semibold text-slate-500 mt-0.5">
                <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${color} mr-1`}>{label}</span>
              </p>
            </div>
          )
        }).filter(Boolean)}
      </div>

      <div className="flex flex-wrap gap-3 items-center">
        <input className="border border-slate-200 rounded-lg px-3 py-2 text-sm w-64 focus:outline-none focus:ring-2 focus:ring-blue-300"
          placeholder="Tìm tên, email, username..." value={search} onChange={e => setSearch(e.target.value)} />
        {!roleFilter && (
          <select className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-300"
            value={filterRole} onChange={e => setFilterRole(e.target.value)}>
            <option value="all">Tất cả vai trò</option>
            {Object.entries(ROLE_LABELS).map(([id, { label }]) => <option key={id} value={id}>{label}</option>)}
          </select>
        )}
        <span className="ml-auto text-xs text-slate-400">{filtered.length} tài khoản</span>
      </div>

      <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
        <div className="px-5 py-4 border-b border-slate-100">
          <h3 className="font-bold text-slate-800">{title}</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs">
              <tr>
                <th className="px-4 py-3 text-left font-semibold">ID</th>
                <th className="px-4 py-3 text-left font-semibold">Tên đăng nhập</th>
                <th className="px-4 py-3 text-left font-semibold">Họ tên</th>
                <th className="px-4 py-3 text-left font-semibold">Email</th>
                <th className="px-4 py-3 text-left font-semibold">SĐT</th>
                <th className="px-4 py-3 text-left font-semibold">Vai trò</th>
                <th className="px-4 py-3 text-left font-semibold">Chi nhánh</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.length === 0 ? (
                <tr><td colSpan={7} className="px-4 py-8 text-center text-slate-400">Không có tài khoản nào</td></tr>
              ) : filtered.slice(0, 100).map(a => {
                const role = ROLE_LABELS[a.roleId] ?? { label: `Role ${a.roleId}`, color: 'bg-slate-100 text-slate-600' }
                return (
                  <tr key={a.id} className="hover:bg-slate-50 transition-colors">
                    <td className="px-4 py-3 font-mono text-xs text-slate-500">#{a.id}</td>
                    <td className="px-4 py-3 font-medium text-slate-700">{a.username}</td>
                    <td className="px-4 py-3 font-semibold text-slate-800">{a.fullName || '—'}</td>
                    <td className="px-4 py-3 text-slate-500 text-xs">{a.email || '—'}</td>
                    <td className="px-4 py-3 text-slate-500">{a.phone || '—'}</td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${role.color}`}>{role.label}</span>
                    </td>
                    <td className="px-4 py-3 text-slate-400">{a.coSoId > 0 ? `#${a.coSoId}` : '—'}</td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
        <div className="px-4 py-3 border-t border-slate-100 text-xs text-slate-400">
          Hiển thị {Math.min(filtered.length, 100)} / {accounts.length} tài khoản
        </div>
      </div>
    </div>
  )
}
