import { getAdminAuditLog } from '@/lib/api/admin-pages'

export const metadata = { title: 'Audit Log | V-SPORT Admin' }

const ROLE_LABELS: Record<number, string> = { 1: 'Admin', 2: 'Manager', 3: 'KH', 4: 'Lễ tân', 5: 'NV', 6: 'Owner' }

const ACTION_COLOR: Record<string, string> = {
  'CREATE': 'bg-green-100 text-green-700',
  'UPDATE': 'bg-blue-100 text-blue-700',
  'DELETE': 'bg-red-100 text-red-700',
  'LOGIN': 'bg-indigo-100 text-indigo-700',
  'RESTORE': 'bg-emerald-100 text-emerald-700',
}

export default async function AdminAuditLogPage() {
  const data = await getAdminAuditLog()
  const logs = data?.logs ?? []

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-3 gap-3">
        {[
          { label: 'Tổng log', value: logs.length, color: 'text-blue-700' },
          { label: 'Tạo mới', value: logs.filter(l => l.action === 'CREATE').length, color: 'text-green-700' },
          { label: 'Xóa', value: logs.filter(l => l.action === 'DELETE').length, color: 'text-red-700' },
        ].map(s => (
          <div key={s.label} className="bg-white border border-slate-200 rounded-xl p-4">
            <p className={`text-2xl font-black ${s.color}`}>{s.value}</p>
            <p className="text-xs font-semibold text-slate-500 mt-0.5">{s.label}</p>
          </div>
        ))}
      </div>

      <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
        <div className="px-5 py-4 border-b border-slate-100">
          <h3 className="font-bold text-slate-800">Nhật ký thao tác toàn hệ thống (50 gần nhất)</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs">
              <tr>
                <th className="px-4 py-3 text-left font-semibold">Thời gian</th>
                <th className="px-4 py-3 text-left font-semibold">Người thực hiện</th>
                <th className="px-4 py-3 text-left font-semibold">Hành động</th>
                <th className="px-4 py-3 text-left font-semibold">Đối tượng</th>
                <th className="px-4 py-3 text-left font-semibold">Chi nhánh</th>
                <th className="px-4 py-3 text-left font-semibold">IP</th>
                <th className="px-4 py-3 text-left font-semibold">Chi tiết</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {logs.length === 0 ? (
                <tr><td colSpan={7} className="px-4 py-8 text-center text-slate-400">Không có log nào</td></tr>
              ) : logs.map(l => (
                <tr key={l.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-4 py-3 text-slate-400 text-xs whitespace-nowrap">{l.createdAt}</td>
                  <td className="px-4 py-3">
                    <p className="font-medium text-slate-800">{l.actorName || '—'}</p>
                    <p className="text-[11px] text-slate-400">{ROLE_LABELS[l.actorRole] ?? `Role ${l.actorRole}`}</p>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${ACTION_COLOR[l.action] ?? 'bg-slate-100 text-slate-600'}`}>
                      {l.action}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-slate-500 text-xs">
                    <p>{l.entityType}</p>
                    <p className="text-slate-400">{l.entityName || '—'}</p>
                  </td>
                  <td className="px-4 py-3 text-slate-400">{l.coSoId > 0 ? `#${l.coSoId}` : '—'}</td>
                  <td className="px-4 py-3 text-slate-400 text-xs font-mono">{l.ipAddress || '—'}</td>
                  <td className="px-4 py-3 text-slate-400 text-xs max-w-[200px] truncate">{l.details || '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
