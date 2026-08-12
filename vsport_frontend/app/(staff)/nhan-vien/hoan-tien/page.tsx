import { getStaffHoanTien } from '@/lib/api/staff-pages'

export const metadata = { title: 'Hoàn tiền | V-SPORT Staff' }

const STATUS_COLOR: Record<string, string> = {
  'Chờ xử lý': 'bg-yellow-100 text-yellow-700',
  'Đã hoàn tiền': 'bg-green-100 text-green-700',
  'Từ chối': 'bg-red-100 text-red-700',
}

export default async function StaffHoanTienPage() {
  const data = await getStaffHoanTien()
  const refunds = data?.refunds ?? []
  const pending = refunds.filter(r => r.trangThai === 'Chờ xử lý').length

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-3 gap-3">
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-yellow-700">{pending}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Chờ xử lý</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-slate-800">{refunds.length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Tổng yêu cầu</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-green-700">{refunds.filter(r => r.trangThai === 'Đã hoàn tiền').length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Đã hoàn tiền</p>
        </div>
      </div>

      <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
        <div className="px-5 py-4 border-b border-slate-100">
          <h3 className="font-bold text-slate-800">Yêu cầu hoàn tiền</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs">
              <tr>
                <th className="px-4 py-3 text-left font-semibold">ID</th>
                <th className="px-4 py-3 text-left font-semibold">HĐ #</th>
                <th className="px-4 py-3 text-right font-semibold">Số tiền</th>
                <th className="px-4 py-3 text-left font-semibold">Lý do</th>
                <th className="px-4 py-3 text-left font-semibold">Thời gian</th>
                <th className="px-4 py-3 text-left font-semibold">Trạng thái</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {refunds.length === 0 ? (
                <tr><td colSpan={6} className="px-4 py-8 text-center text-slate-400">Không có yêu cầu hoàn tiền</td></tr>
              ) : refunds.map(r => (
                <tr key={r.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-4 py-3 font-mono text-xs text-slate-500">#{r.id}</td>
                  <td className="px-4 py-3 font-mono text-xs text-slate-400">#{r.hoaDonId}</td>
                  <td className="px-4 py-3 text-right font-bold text-red-700">{r.soTienHoan.toLocaleString('vi-VN')}đ</td>
                  <td className="px-4 py-3 text-slate-600 max-w-[200px] truncate">{r.lyDo}</td>
                  <td className="px-4 py-3 text-slate-400 text-xs">{r.thoiGianYeuCau}</td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${STATUS_COLOR[r.trangThai] ?? 'bg-slate-100 text-slate-600'}`}>
                      {r.trangThai}
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
