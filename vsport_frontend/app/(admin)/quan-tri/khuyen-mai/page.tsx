export const metadata = { title: 'Khuyến mãi | V-SPORT Admin' }

export default function AdminKhuyenMaiPage() {
  const jspUrl = `${process.env.NEXT_PUBLIC_BACKEND_URL?.replace('/Backend_java', '') ?? 'http://localhost:8080'}/Backend_java/admin/khuyen-mai`
  return (
    <div className="space-y-5">
      <div className="bg-gradient-to-r from-blue-600 to-blue-800 rounded-2xl p-6 text-white">
        <h2 className="text-xl font-black mb-1">Quản lý khuyến mãi toàn hệ thống</h2>
        <p className="text-blue-200 text-sm">Xem và quản lý tất cả chương trình khuyến mãi trên các chi nhánh</p>
      </div>
      <div className="bg-blue-50 border border-blue-200 rounded-2xl p-5 flex items-start gap-4">
        <span className="text-2xl">💡</span>
        <div>
          <p className="font-bold text-blue-800 mb-1">Quản lý khuyến mãi</p>
          <p className="text-sm text-blue-700 mb-3">Manager của từng chi nhánh quản lý khuyến mãi của chi nhánh đó. Admin xem tổng quan qua giao diện JSP.</p>
          <a href={jspUrl} target="_blank" rel="noopener noreferrer"
            className="inline-flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-blue-700 transition-colors">
            Mở giao diện quản lý khuyến mãi
          </a>
        </div>
      </div>
    </div>
  )
}
