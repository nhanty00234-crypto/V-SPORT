import { getAdminTrash } from '@/lib/api/admin-pages'

export const metadata = { title: 'Thùng rác | V-SPORT Admin' }

const ROLE_LABELS: Record<number, string> = { 1: 'Admin', 2: 'Manager', 3: 'KH', 4: 'Lễ tân', 5: 'NV', 6: 'Owner' }

export default async function AdminThungRacPage() {
  const data = await getAdminTrash()
  const accounts = data?.accounts ?? []
  const branches = data?.branches ?? []

  return (
    <div className="space-y-5">
      <div className="bg-red-50 border border-red-200 rounded-2xl p-4 flex items-start gap-3">
        <span className="text-2xl">🗑️</span>
        <div>
          <p className="font-bold text-red-800">Thùng rác hệ thống</p>
          <p className="text-sm text-red-600">{accounts.length} tài khoản + {branches.length} chi nhánh đã bị xóa mềm</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
        <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
          <div className="px-5 py-4 border-b border-slate-100">
            <h3 className="font-bold text-slate-800">Tài khoản đã xóa ({accounts.length})</h3>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-slate-50 text-slate-500 text-xs">
                <tr>
                  <th className="px-4 py-3 text-left font-semibold">ID</th>
                  <th className="px-4 py-3 text-left font-semibold">Họ tên</th>
                  <th className="px-4 py-3 text-left font-semibold">Email</th>
                  <th className="px-4 py-3 text-left font-semibold">Vai trò</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {accounts.length === 0 ? (
                  <tr><td colSpan={4} className="px-4 py-6 text-center text-slate-400">Trống</td></tr>
                ) : accounts.map(a => (
                  <tr key={a.id} className="hover:bg-slate-50">
                    <td className="px-4 py-3 font-mono text-xs text-slate-500">#{a.id}</td>
                    <td className="px-4 py-3 text-slate-800">{a.fullName || '—'}</td>
                    <td className="px-4 py-3 text-slate-500 text-xs">{a.email || '—'}</td>
                    <td className="px-4 py-3 text-slate-400 text-xs">{ROLE_LABELS[a.roleId] ?? `${a.roleId}`}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
          <div className="px-5 py-4 border-b border-slate-100">
            <h3 className="font-bold text-slate-800">Chi nhánh đã xóa ({branches.length})</h3>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-slate-50 text-slate-500 text-xs">
                <tr>
                  <th className="px-4 py-3 text-left font-semibold">ID</th>
                  <th className="px-4 py-3 text-left font-semibold">Tên chi nhánh</th>
                  <th className="px-4 py-3 text-left font-semibold">Trạng thái</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {branches.length === 0 ? (
                  <tr><td colSpan={3} className="px-4 py-6 text-center text-slate-400">Trống</td></tr>
                ) : branches.map(b => (
                  <tr key={b.id} className="hover:bg-slate-50">
                    <td className="px-4 py-3 font-mono text-xs text-slate-500">#{b.id}</td>
                    <td className="px-4 py-3 text-slate-800">{b.ten}</td>
                    <td className="px-4 py-3 text-slate-400 text-xs">{b.trangThai}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  )
}
