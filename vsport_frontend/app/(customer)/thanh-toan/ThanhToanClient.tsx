'use client'
import { useSearchParams, useRouter } from 'next/navigation'
import { useEffect, useState, useCallback, Suspense } from 'react'

type Status = 'pending' | 'paid' | 'failed' | 'cancelled' | 'loading'

function ThanhToanInner() {
  const params = useSearchParams()
  const router = useRouter()
  const datSanId = params.get('datSanId') || params.get('id')
  const [status, setStatus] = useState<Status>('loading')
  const [amount, setAmount] = useState<number | null>(null)
  const [qrUrl, setQrUrl] = useState<string | null>(null)
  const [polling, setPolling] = useState(true)

  const BASE = process.env.NEXT_PUBLIC_BACKEND_URL

  const checkStatus = useCallback(async () => {
    if (!datSanId) { setStatus('failed'); return }
    try {
      const res = await fetch(`${BASE}/customer/payos-status?datSanId=${datSanId}`, {
        credentials: 'include',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
      })
      if (!res.ok) { setStatus('pending'); return }
      const data = await res.json()
      if (data.trangThai === 'PAID' || data.trangThai === 'Đã thanh toán') {
        setStatus('paid')
        setPolling(false)
      } else if (data.trangThai === 'CANCELLED') {
        setStatus('cancelled')
        setPolling(false)
      } else {
        setStatus('pending')
        if (data.qrUrl) setQrUrl(data.qrUrl)
        if (data.amount) setAmount(data.amount)
      }
    } catch {
      setStatus('pending')
    }
  }, [datSanId, BASE])

  useEffect(() => {
    checkStatus()
    if (!polling) return
    const interval = setInterval(checkStatus, 5000)
    return () => clearInterval(interval)
  }, [checkStatus, polling])

  async function handleCancel() {
    if (!datSanId || !confirm('Bạn có chắc muốn hủy thanh toán?')) return
    await fetch(`${BASE}/customer/payos-cancel`, {
      method: 'POST', credentials: 'include',
      headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
      body: JSON.stringify({ datSanId: Number(datSanId) }),
    }).catch(() => {})
    setStatus('cancelled')
    setPolling(false)
  }

  async function handleRetry() {
    if (!datSanId) return
    const res = await fetch(`${BASE}/customer/payos-retry`, {
      method: 'POST', credentials: 'include',
      headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
      body: JSON.stringify({ datSanId: Number(datSanId) }),
    }).catch(() => null)
    if (res?.ok) {
      const data = await res.json()
      if (data.qrUrl) setQrUrl(data.qrUrl)
      setStatus('pending')
      setPolling(true)
    }
  }

  if (status === 'paid') return (
    <div className="max-w-md mx-auto text-center py-12 space-y-4">
      <div className="text-6xl">✅</div>
      <h2 className="text-2xl font-black text-green-700">Thanh toán thành công!</h2>
      <p className="text-slate-500">Lịch đặt sân của bạn đã được xác nhận.</p>
      <button onClick={() => router.push('/gio-hang')}
        className="bg-vs-blue text-white px-8 py-3 rounded-xl font-semibold">
        Xem lịch đặt sân
      </button>
    </div>
  )

  if (status === 'cancelled') return (
    <div className="max-w-md mx-auto text-center py-12 space-y-4">
      <div className="text-6xl">❌</div>
      <h2 className="text-2xl font-black text-red-700">Đã hủy thanh toán</h2>
      <p className="text-slate-500">Lịch đặt sân đã bị hủy.</p>
      <button onClick={() => router.push('/tim-kiem')}
        className="bg-vs-blue text-white px-8 py-3 rounded-xl font-semibold">
        Đặt sân mới
      </button>
    </div>
  )

  return (
    <div className="max-w-md mx-auto space-y-5">
      <h1 className="text-2xl font-black text-vs-navy">Thanh toán</h1>

      <div className="bg-white border border-slate-200 rounded-2xl p-6 text-center space-y-4">
        {status === 'loading' ? (
          <div className="text-slate-400">Đang tải mã QR...</div>
        ) : qrUrl ? (
          <img src={qrUrl} alt="QR Code thanh toán" className="w-48 h-48 mx-auto rounded-xl border border-slate-200" />
        ) : (
          <div className="w-48 h-48 mx-auto bg-slate-100 rounded-xl flex items-center justify-center">
            <div className="text-4xl">📱</div>
          </div>
        )}

        <div>
          <p className="text-sm text-slate-500 mb-1">Quét mã QR để thanh toán</p>
          {amount !== null && (
            <p className="text-2xl font-black text-vs-blue">{amount.toLocaleString('vi-VN')}đ</p>
          )}
        </div>

        <div className="flex items-center justify-center gap-2 text-sm text-slate-500">
          <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse"></div>
          Đang kiểm tra thanh toán...
        </div>

        <div className="flex gap-2 pt-2">
          <button onClick={handleCancel}
            className="flex-1 border border-slate-200 text-slate-600 py-2.5 rounded-xl text-sm font-semibold hover:bg-slate-50">
            Hủy
          </button>
          <button onClick={handleRetry}
            className="flex-1 border border-blue-200 text-vs-blue py-2.5 rounded-xl text-sm font-semibold hover:bg-blue-50">
            Tạo lại QR
          </button>
        </div>
      </div>

      <p className="text-xs text-slate-400 text-center">
        Mã đặt sân: #{datSanId} · Tự động xác nhận sau khi thanh toán
      </p>

      <div className="bg-blue-50 border border-blue-200 rounded-xl p-4 text-sm text-blue-700">
        <p className="font-semibold mb-1">Hướng dẫn:</p>
        <ol className="space-y-1 list-decimal list-inside text-xs">
          <li>Mở ứng dụng ngân hàng hoặc ví điện tử</li>
          <li>Chọn "Quét mã QR" hoặc "Thanh toán QR"</li>
          <li>Quét mã QR và xác nhận thanh toán</li>
          <li>Đợi hệ thống xác nhận (tự động, 5-10 giây)</li>
        </ol>
      </div>
    </div>
  )
}

export default function ThanhToanClient() {
  return (
    <Suspense fallback={<div className="text-center py-12 text-slate-400">Đang tải...</div>}>
      <ThanhToanInner />
    </Suspense>
  )
}
