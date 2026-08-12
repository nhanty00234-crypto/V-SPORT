import { getStaffCaLamViec } from '@/lib/api/staff-pages'

export const metadata = { title: 'Ca làm việc | V-SPORT Staff' }

const STATUS_COLOR: Record<string, string> = {
  'Đã xác nhận': 'bg-green-100 text-green-700',
  'Chờ duyệt': 'bg-yellow-100 text-yellow-700',
  'Đã hoàn thành': 'bg-emerald-100 text-emerald-700',
  'Vắng mặt': 'bg-red-100 text-red-700',
  'Đã hủy': 'bg-slate-100 text-slate-500',
}

export default async function StaffCaLamViecPage() {
  const today = new Date()
  const from = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-01`
  const lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0).getDate()
  const to = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${lastDay}`
  const data = await getStaffCaLamViec(from, to)
  const shifts = data?.shifts ?? []

  const todayStr = today.toISOString().split('T')[0]
  const todayShifts = shifts.filter(s => s.ngayLam === todayStr)

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-3 gap-3">
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-slate-800">{shifts.length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Ca tháng này</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-orange-700">{todayShifts.length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Ca hôm nay</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-green-700">{shifts.filter(s => s.trangThai === 'Đã xác nhận').length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Đã xác nhận</p>
        </div>
      </div>

      {todayShifts.length > 0 && (
        <div className="bg-orange-50 border border-orange-200 rounded-2xl p-4">
          <p className="font-bold text-orange-800 mb-2">Ca làm việc hôm nay</p>
          {todayShifts.map(s => (
            <div key={s.id} className="flex items-center gap-3 bg-white rounded-xl p-3 mb-2 last:mb-0">
              <span className="text-xl">⏰</span>
              <div>
                <p className="font-semibold text-slate-800">{s.tenCa}</p>
                <p className="text-xs text-slate-500">{s.gioBatDau} – {s.gioKetThuc} · {s.viTri || 'Chưa xác định vị trí'}</p>
              </div>
              <span className={`ml-auto px-2 py-0.5 rounded-full text-[11px] font-semibold ${STATUS_COLOR[s.trangThai] ?? 'bg-slate-100 text-slate-600'}`}>
                {s.trangThai}
              </span>
            </div>
          ))}
        </div>
      )}

      <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
        <div className="px-5 py-4 border-b border-slate-100">
          <h3 className="font-bold text-slate-800">Lịch làm việc tháng này</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs">
              <tr>
                <th className="px-4 py-3 text-left font-semibold">Tên ca</th>
                <th className="px-4 py-3 text-left font-semibold">Vị trí</th>
                <th className="px-4 py-3 text-left font-semibold">Ngày làm</th>
                <th className="px-4 py-3 text-left font-semibold">Giờ</th>
                <th className="px-4 py-3 text-left font-semibold">Trạng thái</th>
                <th className="px-4 py-3 text-left font-semibold">Ghi chú</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {shifts.length === 0 ? (
                <tr><td colSpan={6} className="px-4 py-8 text-center text-slate-400">Không có ca làm việc</td></tr>
              ) : shifts.map(s => (
                <tr key={s.id} className={`hover:bg-slate-50 transition-colors ${s.ngayLam === todayStr ? 'bg-orange-50' : ''}`}>
                  <td className="px-4 py-3 font-semibold text-slate-800">{s.tenCa}</td>
                  <td className="px-4 py-3 text-slate-500">{s.viTri || '—'}</td>
                  <td className="px-4 py-3 text-slate-600 font-medium">{s.ngayLam}</td>
                  <td className="px-4 py-3 text-xs text-slate-500">{s.gioBatDau}–{s.gioKetThuc}</td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${STATUS_COLOR[s.trangThai] ?? 'bg-slate-100 text-slate-600'}`}>
                      {s.trangThai}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-slate-400 text-xs">{s.ghiChu || '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
