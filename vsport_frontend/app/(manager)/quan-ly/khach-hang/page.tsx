export const metadata = { title: 'Khách hàng | V-SPORT Manager' }

export default function KhachHangPage() {
  const jspUrl = `${process.env.NEXT_PUBLIC_BACKEND_URL?.replace('/Backend_java', '') ?? 'http://localhost:8080'}/Backend_java/manager/khach-hang`

  return (
    <div className="space-y-5">
      <div className="bg-gradient-to-r from-indigo-600 to-indigo-800 rounded-2xl p-6 text-white">
        <h2 className="text-xl font-black mb-1">Quản lý khách hàng</h2>
        <p className="text-indigo-200 text-sm">Xem khách hàng thân thiết, đánh giá, và hành vi đặt sân</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {[
          { icon: '⭐', title: 'Khách VIP', desc: 'Khách hàng đặt sân thường xuyên nhất', color: 'from-yellow-50 to-orange-50 border-yellow-200' },
          { icon: '🔄', title: 'Khách trung thành', desc: 'Khách hàng quay lại nhiều lần', color: 'from-green-50 to-emerald-50 border-green-200' },
          { icon: '⚠️', title: 'Nguy cơ hủy', desc: 'Khách hàng có tỷ lệ hủy cao', color: 'from-red-50 to-rose-50 border-red-200' },
        ].map(c => (
          <div key={c.title} className={`bg-gradient-to-br ${c.color} border rounded-2xl p-5`}>
            <div className="text-3xl mb-3">{c.icon}</div>
            <h3 className="font-bold text-slate-800 mb-1">{c.title}</h3>
            <p className="text-sm text-slate-500">{c.desc}</p>
          </div>
        ))}
      </div>

      <div className="bg-amber-50 border border-amber-200 rounded-2xl p-5 flex items-start gap-4">
        <span className="text-2xl">💡</span>
        <div>
          <p className="font-bold text-amber-800 mb-1">Thông tin khách hàng chi tiết</p>
          <p className="text-sm text-amber-700 mb-3">Dữ liệu phân tích khách hàng đầy đủ (đánh giá, hành vi hủy, điểm thưởng) được hiển thị trong giao diện JSP quản lý.</p>
          <a href={jspUrl} target="_blank" rel="noopener noreferrer"
            className="inline-flex items-center gap-2 bg-amber-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-amber-700 transition-colors">
            Mở giao diện quản lý khách hàng
          </a>
        </div>
      </div>
    </div>
  )
}
