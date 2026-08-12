import { getStaffHoaDon } from '@/lib/api/staff-pages'

export const metadata = { title: 'Hóa đơn | V-SPORT Staff' }

const STATUS_COLOR: Record<string, string> = {
  'Đã thanh toán': 'bg-green-100 text-green-700',
  'Chờ thanh toán': 'bg-yellow-100 text-yellow-700',
  'Đã hoàn tiền': 'bg-blue-100 text-blue-700',
  'Hủy': 'bg-red-100 text-red-700',
}

export default async function StaffHoaDonPage() {
  const data = await getStaffHoaDon()
  const invoices = data?.invoices ?? []
  const revenueToday = data?.revenueToday ?? 0

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-slate-800">{invoices.length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Tổng hóa đơn</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-xl font-black text-orange-700">{revenueToday.toLocaleString('vi-VN')}đ</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Doanh thu hôm nay</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-green-700">{invoices.filter(i => i.status === 'Đã thanh toán').length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Đã thanh toán</p>
        </div>
      </div>

      <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
        <div className="px-5 py-4 border-b border-slate-100">
          <h3 className="font-bold text-slate-800">Hóa đơn gần đây</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs">
              <tr>
                <th className="px-4 py-3 text-left font-semibold">ID</th>
                <th className="px-4 py-3 text-left font-semibold">Đặt sân #</th>
                <th className="px-4 py-3 text-left font-semibold">Ngày lập</th>
                <th className="px-4 py-3 text-right font-semibold">Tổng tiền</th>
                <th className="px-4 py-3 text-left font-semibold">Trạng thái</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {invoices.length === 0 ? (
                <tr><td colSpan={5} className="px-4 py-8 text-center text-slate-400">Không có hóa đơn</td></tr>
              ) : invoices.slice(0, 100).map(inv => (
                <tr key={inv.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-4 py-3 font-mono text-xs text-slate-500">#{inv.id}</td>
                  <td className="px-4 py-3 font-mono text-xs text-slate-400">#{inv.datSanId}</td>
                  <td className="px-4 py-3 text-slate-600">{inv.date}</td>
                  <td className="px-4 py-3 text-right font-bold text-slate-800">{inv.total.toLocaleString('vi-VN')}đ</td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${STATUS_COLOR[inv.status] ?? 'bg-slate-100 text-slate-600'}`}>
                      {inv.status}
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
