'use client'
import { useSearchParams } from 'next/navigation'
import { useEffect, useState, Suspense } from 'react'

interface BookingDetail {
  datSanId: number
  tenSan: string
  tenCoSo: string
  ngayDat: string
  gioBatDau: string
  gioKetThuc: string
  tongTienDuKien: number
  trangThai: string
  services?: { tenSanPham: string; soLuong: number; thanhTien: number }[]
}

function XacNhanInner() {
  const params = useSearchParams()
  const datSanId = params.get('id') || params.get('datSanId')
  const [booking, setBooking] = useState<BookingDetail | null>(null)
  const [loading, setLoading] = useState(true)
  const [promoCode, setPromoCode] = useState('')
  const [promoMsg, setPromoMsg] = useState('')
  const [discount, setDiscount] = useState(0)

  const BASE = process.env.NEXT_PUBLIC_BACKEND_URL

  useEffect(() => {
    if (!datSanId) { setLoading(false); return }
    fetch(`${BASE}/customer/api/booking-detail?datSanId=${datSanId}`, {
      credentials: 'include',
      headers: { 'X-Requested-With': 'XMLHttpRequest' },
    })
      .then(r => r.ok ? r.json() : null)
      .then(data => { if (data) setBooking(data) })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [datSanId])

  async function applyPromo() {
    if (!datSanId || !promoCode) return
    try {
      const res = await fetch(`${BASE}/api/promotion/apply`, {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
        body: JSON.stringify({ maCode: promoCode, datSanId: Number(datSanId) }),
      })
      const data = await res.json()
      if (data.success) {
        setDiscount(data.discount ?? 0)
        setPromoMsg(`Áp dụng thành công! Giảm ${(data.discount ?? 0).toLocaleString('vi-VN')}đ`)
      } else {
        setPromoMsg(data.error ?? 'Mã không hợp lệ')
      }
    } catch {
      setPromoMsg('Lỗi kết nối')
    }
  }

  if (loading) return <div className="text-center py-12 text-slate-400">Đang tải thông tin đặt sân...</div>

  if (!booking) {
    const jspUrl = `${BASE?.replace('/Backend_java', '')}/Backend_java/customer/xac-nhan${datSanId ? `?id=${datSanId}` : ''}`
    return (
      <div className="max-w-md mx-auto text-center py-12">
        <p className="text-4xl mb-4">📋</p>
        <p className="text-slate-600 mb-4">Không tìm thấy thông tin đặt sân.</p>
        <a href={jspUrl} target="_blank" rel="noopener noreferrer"
          className="inline-block bg-vs-blue text-white px-6 py-3 rounded-xl font-semibold">
          Xem xác nhận
        </a>
      </div>
    )
  }

  const finalAmount = Math.max(0, (booking.tongTienDuKien || 0) - discount)

  return (
    <div className="max-w-lg mx-auto space-y-5">
      <h1 className="text-2xl font-black text-vs-navy">Xác nhận đặt sân</h1>

      <div className="bg-white border border-slate-200 rounded-2xl p-5 space-y-4">
        <div>
          <p className="text-xs font-semibold text-slate-400 uppercase mb-2">Thông tin đặt sân</p>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between"><span className="text-slate-500">Sân:</span><span className="font-semibold text-slate-800">{booking.tenSan}</span></div>
            <div className="flex justify-between"><span className="text-slate-500">Cơ sở:</span><span className="font-semibold text-slate-800">{booking.tenCoSo}</span></div>
            <div className="flex justify-between"><span className="text-slate-500">Ngày:</span><span className="font-semibold text-slate-800">{booking.ngayDat}</span></div>
            <div className="flex justify-between"><span className="text-slate-500">Giờ:</span><span className="font-semibold text-slate-800">{booking.gioBatDau} – {booking.gioKetThuc}</span></div>
          </div>
        </div>

        {booking.services && booking.services.length > 0 && (
          <div className="border-t border-slate-100 pt-4">
            <p className="text-xs font-semibold text-slate-400 uppercase mb-2">Dịch vụ đi kèm</p>
            {booking.services.map((s, i) => (
              <div key={i} className="flex justify-between text-sm">
                <span className="text-slate-600">{s.tenSanPham} x{s.soLuong}</span>
                <span className="font-medium">{s.thanhTien.toLocaleString('vi-VN')}đ</span>
              </div>
            ))}
          </div>
        )}

        <div className="border-t border-slate-100 pt-4">
          <p className="text-xs font-semibold text-slate-400 uppercase mb-2">Mã khuyến mãi</p>
          <div className="flex gap-2">
            <input className="flex-1 border border-slate-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-300"
              placeholder="Nhập mã..." value={promoCode} onChange={e => setPromoCode(e.target.value.toUpperCase())} />
            <button onClick={applyPromo} className="bg-vs-blue text-white px-4 py-2 rounded-xl text-sm font-semibold hover:bg-blue-700">
              Áp dụng
            </button>
          </div>
          {promoMsg && <p className={`text-xs mt-1.5 ${discount > 0 ? 'text-green-600' : 'text-red-500'}`}>{promoMsg}</p>}
        </div>

        <div className="border-t border-slate-100 pt-4">
          <div className="flex justify-between text-sm mb-1">
            <span className="text-slate-500">Tạm tính:</span>
            <span>{(booking.tongTienDuKien || 0).toLocaleString('vi-VN')}đ</span>
          </div>
          {discount > 0 && (
            <div className="flex justify-between text-sm mb-1">
              <span className="text-green-600">Giảm giá:</span>
              <span className="text-green-600">-{discount.toLocaleString('vi-VN')}đ</span>
            </div>
          )}
          <div className="flex justify-between font-bold text-lg mt-2">
            <span>Tổng cộng:</span>
            <span className="text-vs-blue">{finalAmount.toLocaleString('vi-VN')}đ</span>
          </div>
        </div>
      </div>

      <div className="flex gap-3">
        <button onClick={() => window.history.back()}
          className="flex-1 border border-slate-200 text-slate-600 py-3 rounded-xl font-semibold hover:bg-slate-50 transition-colors">
          Quay lại
        </button>
        <a href={`${BASE?.replace('/Backend_java', '')}/Backend_java/customer/payos-checkout?datSanId=${datSanId}`}
          target="_blank" rel="noopener noreferrer"
          className="flex-1 bg-vs-blue text-white py-3 rounded-xl font-semibold text-center hover:bg-blue-700 transition-colors">
          Thanh toán →
        </a>
      </div>
    </div>
  )
}

export default function XacNhanClient() {
  return (
    <Suspense fallback={<div className="text-center py-12 text-slate-400">Đang tải...</div>}>
      <XacNhanInner />
    </Suspense>
  )
}
