import { getStaffDatSan } from '@/lib/api/staff-pages'

export const metadata = { title: 'Đặt sân | V-SPORT Staff' }

const STATUS_COLOR: Record<string, string> = {
  'Chờ xác nhận': 'bg-yellow-100 text-yellow-700',
  'Đã xác nhận': 'bg-green-100 text-green-700',
  'Đã check-in': 'bg-blue-100 text-blue-700',
  'Đã hoàn thành': 'bg-emerald-100 text-emerald-700',
  'Đã hủy': 'bg-red-100 text-red-700',
}

export default async function StaffDatSanPage() {
  const data = await getStaffDatSan()
  const bookings = data?.bookings ?? []

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        {[
          { label: 'Tổng lịch', value: bookings.length, color: 'text-slate-800' },
          { label: 'Chờ xác nhận', value: bookings.filter(b => b.trangThai === 'Chờ xác nhận').length, color: 'text-yellow-700' },
          { label: 'Đang diễn ra', value: bookings.filter(b => b.trangThai === 'Đã check-in').length, color: 'text-blue-700' },
          { label: 'Đã hủy', value: bookings.filter(b => b.trangThai === 'Đã hủy').length, color: 'text-red-700' },
        ].map(s => (
          <div key={s.label} className="bg-white border border-slate-200 rounded-xl p-4">
            <p className={`text-2xl font-black ${s.color}`}>{s.value}</p>
            <p className="text-xs font-semibold text-slate-500 mt-0.5">{s.label}</p>
          </div>
        ))}
      </div>

      <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
        <div className="px-5 py-4 border-b border-slate-100">
          <h3 className="font-bold text-slate-800">Tất cả lịch đặt sân</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs">
              <tr>
                <th className="px-4 py-3 text-left font-semibold">ID</th>
                <th className="px-4 py-3 text-left font-semibold">Khách hàng</th>
                <th className="px-4 py-3 text-left font-semibold">Sân</th>
                <th className="px-4 py-3 text-left font-semibold">Ngày</th>
                <th className="px-4 py-3 text-left font-semibold">Giờ</th>
                <th className="px-4 py-3 text-right font-semibold">Tổng tiền</th>
                <th className="px-4 py-3 text-left font-semibold">Trạng thái</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {bookings.length === 0 ? (
                <tr><td colSpan={7} className="px-4 py-8 text-center text-slate-400">Không có lịch đặt sân nào</td></tr>
              ) : bookings.slice(0, 100).map(b => (
                <tr key={b.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-4 py-3 font-mono text-xs text-slate-500">#{b.id}</td>
                  <td className="px-4 py-3">
                    <p className="font-medium text-slate-800">{b.tenKhach || `KH #${b.accountId}`}</p>
                    <p className="text-xs text-slate-400">{b.phone}</p>
                  </td>
                  <td className="px-4 py-3 text-slate-600">{b.tenSan || `Sân #${b.sanId}`}</td>
                  <td className="px-4 py-3 text-slate-600">{b.ngayDat}</td>
                  <td className="px-4 py-3 text-xs text-slate-500">{b.gioBatDau}–{b.gioKetThuc}</td>
                  <td className="px-4 py-3 text-right font-bold">{b.tongTien.toLocaleString('vi-VN')}đ</td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${STATUS_COLOR[b.trangThai] ?? 'bg-slate-100 text-slate-600'}`}>
                      {b.trangThai}
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
