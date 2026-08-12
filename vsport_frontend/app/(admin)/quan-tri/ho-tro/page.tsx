export const metadata = { title: 'Hỗ trợ | V-SPORT Admin' }

export default function HoTroPage() {
  return (
    <div className="space-y-5">
      <div className="bg-gradient-to-r from-blue-600 to-blue-800 rounded-2xl p-6 text-white">
        <h2 className="text-xl font-black mb-1">Trung tâm hỗ trợ</h2>
        <p className="text-blue-200 text-sm">Quản lý ticket hỗ trợ và phản hồi khách hàng</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {[
          { icon: '🎫', title: 'Ticket hỗ trợ', desc: 'Xem và xử lý yêu cầu hỗ trợ từ người dùng', color: 'bg-blue-50 border-blue-200' },
          { icon: '⭐', title: 'Đánh giá & Phản hồi', desc: 'Xem đánh giá của khách hàng về hệ thống', color: 'bg-yellow-50 border-yellow-200' },
          { icon: '📢', title: 'Thông báo hệ thống', desc: 'Gửi thông báo đến người dùng theo nhóm', color: 'bg-green-50 border-green-200' },
        ].map(c => (
          <div key={c.title} className={`${c.color} border rounded-2xl p-5`}>
            <div className="text-3xl mb-3">{c.icon}</div>
            <h3 className="font-bold text-slate-800 mb-1">{c.title}</h3>
            <p className="text-sm text-slate-500">{c.desc}</p>
          </div>
        ))}
      </div>

      <div className="bg-blue-50 border border-blue-200 rounded-2xl p-5 flex items-start gap-4">
        <span className="text-2xl">🚧</span>
        <div>
          <p className="font-bold text-blue-800 mb-1">Tính năng đang phát triển</p>
          <p className="text-sm text-blue-700">
            Module hỗ trợ sẽ được tích hợp đầy đủ trong phiên bản tới bao gồm: ticket tracking, live chat, và hệ thống thông báo đẩy.
          </p>
        </div>
      </div>

      <div className="bg-white border border-slate-200 rounded-2xl p-5">
        <h3 className="font-bold text-slate-800 mb-3">Liên hệ hỗ trợ kỹ thuật</h3>
        <div className="space-y-2 text-sm text-slate-600">
          <p>📧 Email: support@vsport.vn</p>
          <p>📞 Hotline: 1900 xxxx</p>
          <p>💬 Zalo OA: V-SPORT Official</p>
        </div>
      </div>
    </div>
  )
}
