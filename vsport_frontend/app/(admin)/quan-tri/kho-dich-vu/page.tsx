export const metadata = { title: 'Kho dịch vụ | V-SPORT Admin' }

export default function AdminKhoDichVuPage() {
  const jspUrl = `${process.env.NEXT_PUBLIC_BACKEND_URL?.replace('/Backend_java', '') ?? 'http://localhost:8080'}/Backend_java/admin/kho-dich-vu`
  return (
    <div className="space-y-5">
      <div className="bg-gradient-to-r from-blue-600 to-blue-800 rounded-2xl p-6 text-white">
        <h2 className="text-xl font-black mb-1">Kho dịch vụ toàn hệ thống</h2>
        <p className="text-blue-200 text-sm">Tổng quan sản phẩm và dịch vụ trên tất cả chi nhánh</p>
      </div>
      <div className="bg-blue-50 border border-blue-200 rounded-2xl p-5 flex items-start gap-4">
        <span className="text-2xl">📦</span>
        <div>
          <p className="font-bold text-blue-800 mb-1">Quản lý kho hàng</p>
          <p className="text-sm text-blue-700 mb-3">Manager của từng chi nhánh quản lý kho hàng của chi nhánh đó. Truy cập giao diện đầy đủ để xem chi tiết.</p>
          <a href={jspUrl} target="_blank" rel="noopener noreferrer"
            className="inline-flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-blue-700 transition-colors">
            Mở giao diện kho dịch vụ
          </a>
        </div>
      </div>
    </div>
  )
}
