const BASE = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'
export const metadata = { title: 'Kho dịch vụ | V-SPORT Admin' }
export default function Page() {
  return (
    <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
      <div className="px-6 py-5 border-b border-slate-100 flex items-center justify-between">
        <div>
          <h2 className="text-lg font-bold text-slate-800">Kho dịch vụ</h2>
          <p className="text-sm text-slate-500 mt-0.5">Quản lý danh mục dịch vụ và sản phẩm.</p>
        </div>
        <a href={`${BASE}/admin/kho-dich-vu`}
           className="px-4 py-2 bg-blue-600 text-white text-sm font-semibold rounded-xl hover:bg-blue-700 transition-colors">
          Mở giao diện đầy đủ →
        </a>
      </div>
      <div className="p-6 text-center text-slate-400 py-16">
        <div className="text-5xl mb-3">📦</div>
        <p className="font-medium">Giao diện Kho dịch vụ.</p>
        <a href={`${BASE}/admin/kho-dich-vu`} className="mt-4 inline-block text-blue-600 text-sm hover:underline">
          Nhấn vào đây nếu không tự chuyển →
        </a>
      </div>
    </div>
  )
}
