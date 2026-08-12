'use client'
import { useState } from 'react'
import type { AuditLogEntry } from '@/types/manager-pages'

const ACTION_COLOR: Record<string, string> = {
  'CREATE': 'bg-green-100 text-green-700',
  'UPDATE': 'bg-blue-100 text-blue-700',
  'DELETE': 'bg-red-100 text-red-700',
  'LOGIN': 'bg-indigo-100 text-indigo-700',
  'RESTORE': 'bg-emerald-100 text-emerald-700',
}

export default function AuditLogClient({ logs }: { logs: AuditLogEntry[] }) {
  const [search, setSearch] = useState('')
  const [filterAction, setFilterAction] = useState('all')

  const filtered = logs.filter(l => {
    const matchSearch = l.actorName.toLowerCase().includes(search.toLowerCase()) ||
      l.entityType.toLowerCase().includes(search.toLowerCase()) ||
      l.entityName.toLowerCase().includes(search.toLowerCase())
    const matchAction = filterAction === 'all' || l.action === filterAction
    return matchSearch && matchAction
  })

  const actions = Array.from(new Set(logs.map(l => l.action)))

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-3 gap-3">
        {[
          { label: 'Tổng log', value: logs.length, color: 'text-indigo-700' },
          { label: 'Tạo mới', value: logs.filter(l => l.action === 'CREATE').length, color: 'text-green-700' },
          { label: 'Xóa', value: logs.filter(l => l.action === 'DELETE').length, color: 'text-red-700' },
        ].map(s => (
          <div key={s.label} className="bg-white border border-slate-200 rounded-xl p-4">
            <p className={`text-2xl font-black ${s.color}`}>{s.value}</p>
            <p className="text-xs font-semibold text-slate-500 mt-0.5">{s.label}</p>
          </div>
        ))}
      </div>

      <div className="flex flex-wrap gap-3 items-center">
        <input className="border border-slate-200 rounded-lg px-3 py-2 text-sm w-64 focus:outline-none focus:ring-2 focus:ring-indigo-300"
          placeholder="Tìm tên, loại đối tượng..." value={search} onChange={e => setSearch(e.target.value)} />
        <select className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300"
          value={filterAction} onChange={e => setFilterAction(e.target.value)}>
          <option value="all">Tất cả hành động</option>
          {actions.map(a => <option key={a} value={a}>{a}</option>)}
        </select>
        <span className="ml-auto text-xs text-slate-400">{filtered.length} log</span>
      </div>

      <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs">
              <tr>
                <th className="px-4 py-3 text-left font-semibold">Thời gian</th>
                <th className="px-4 py-3 text-left font-semibold">Người thực hiện</th>
                <th className="px-4 py-3 text-left font-semibold">Hành động</th>
                <th className="px-4 py-3 text-left font-semibold">Loại đối tượng</th>
                <th className="px-4 py-3 text-left font-semibold">Đối tượng</th>
                <th className="px-4 py-3 text-left font-semibold">IP</th>
                <th className="px-4 py-3 text-left font-semibold">Chi tiết</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.length === 0 ? (
                <tr><td colSpan={7} className="px-4 py-8 text-center text-slate-400">Không có log nào</td></tr>
              ) : filtered.slice(0, 100).map(l => (
                <tr key={l.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-4 py-3 text-slate-400 text-xs whitespace-nowrap">{l.createdAt}</td>
                  <td className="px-4 py-3 font-medium text-slate-800">{l.actorName || '—'}</td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${ACTION_COLOR[l.action] ?? 'bg-slate-100 text-slate-600'}`}>
                      {l.action}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-slate-500 text-xs">{l.entityType}</td>
                  <td className="px-4 py-3 text-slate-600 text-xs">{l.entityName || '—'}</td>
                  <td className="px-4 py-3 text-slate-400 text-xs font-mono">{l.ipAddress || '—'}</td>
                  <td className="px-4 py-3 text-slate-400 text-xs max-w-[200px] truncate">{l.details || '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="px-4 py-3 border-t border-slate-100 text-xs text-slate-400">
          Hiển thị {Math.min(filtered.length, 100)} / {logs.length} log (trang hiện tại)
        </div>
      </div>
    </div>
  )
}
