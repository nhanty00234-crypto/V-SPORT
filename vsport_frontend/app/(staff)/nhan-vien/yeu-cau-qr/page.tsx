import { getStaffYeuCauQr } from '@/lib/api/staff-pages'

export const metadata = { title: 'Yêu cầu QR | V-SPORT Staff' }

const STATUS_COLOR: Record<string, string> = {
  'Chờ xử lý': 'bg-yellow-100 text-yellow-700',
  'Đã xử lý': 'bg-green-100 text-green-700',
  'Từ chối': 'bg-red-100 text-red-700',
}

export default async function YeuCauQrPage() {
  const data = await getStaffYeuCauQr()
  const requests = data?.requests ?? []
  const pending = requests.filter(r => r.status === 'Chờ xử lý').length

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-3 gap-3">
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-yellow-700">{pending}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Chờ xử lý</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-slate-800">{requests.length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Tổng yêu cầu</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-green-700">{requests.filter(r => r.status === 'Đã xử lý').length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Đã xử lý</p>
        </div>
      </div>

      <div className="space-y-3">
        {requests.length === 0 ? (
          <div className="bg-white border border-slate-200 rounded-2xl p-8 text-center text-slate-400">Không có yêu cầu QR nào</div>
        ) : requests.map(r => (
          <div key={r.id} className="bg-white border border-slate-200 rounded-2xl p-4 flex items-center gap-4">
            <div className="w-10 h-10 bg-orange-100 rounded-xl flex items-center justify-center text-lg flex-shrink-0">📷</div>
            <div className="flex-1 min-w-0">
              <p className="font-semibold text-slate-800">Yêu cầu QR - Sân #{r.sanId}</p>
              <p className="text-xs text-slate-400">Loại: {r.requestType || 'Chưa xác định'} · Tạo: {r.createdAt}</p>
              {r.note && <p className="text-xs text-slate-500 mt-1">{r.note}</p>}
            </div>
            <span className={`px-2 py-1 rounded-full text-[11px] font-semibold flex-shrink-0 ${STATUS_COLOR[r.status] ?? 'bg-slate-100 text-slate-600'}`}>
              {r.status}
            </span>
            {r.status === 'Chờ xử lý' && (
              <a href={`${process.env.NEXT_PUBLIC_BACKEND_URL?.replace('/Backend_java', '')}/Backend_java/staff/yeu-cau-qr?id=${r.id}`}
                target="_blank" rel="noopener noreferrer"
                className="bg-orange-600 text-white px-3 py-1.5 rounded-lg text-xs font-semibold hover:bg-orange-700 flex-shrink-0">
                Xử lý
              </a>
            )}
          </div>
        ))}
      </div>
    </div>
  )
}
