'use client'
import { useEffect, useRef, useState } from 'react'

const BASE = typeof window !== 'undefined' ? (process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java') : ''

type Mode = 'idle' | 'scanning' | 'result' | 'error'

export default function QuetQRPage() {
  const videoRef = useRef<HTMLVideoElement>(null)
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const streamRef = useRef<MediaStream | null>(null)
  const [mode, setMode] = useState<Mode>('idle')
  const [result, setResult] = useState('')
  const [error, setError] = useState('')
  const [codeInput, setCodeInput] = useState('')
  const [lookupResult, setLookupResult] = useState<{ message: string; success: boolean } | null>(null)
  const [looking, setLooking] = useState(false)
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null)

  function stopCamera() {
    if (streamRef.current) { streamRef.current.getTracks().forEach(t => t.stop()); streamRef.current = null }
    if (intervalRef.current) { clearInterval(intervalRef.current); intervalRef.current = null }
  }

  async function startCamera() {
    setError('')
    setResult('')
    setLookupResult(null)
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } })
      streamRef.current = stream
      if (videoRef.current) { videoRef.current.srcObject = stream; videoRef.current.play() }
      setMode('scanning')
      // Poll canvas for QR — basic detection via BarcodeDetector if available
      if ('BarcodeDetector' in window) {
        const detector = new (window as any).BarcodeDetector({ formats: ['qr_code'] })
        intervalRef.current = setInterval(async () => {
          if (!videoRef.current || videoRef.current.readyState < 2) return
          try {
            const barcodes = await detector.detect(videoRef.current)
            if (barcodes.length > 0) {
              const value = barcodes[0].rawValue
              stopCamera()
              setResult(value)
              setMode('result')
            }
          } catch {}
        }, 500)
      }
    } catch (e: any) {
      setError(e.name === 'NotAllowedError' ? 'Bạn chưa cấp quyền camera.' : 'Không thể mở camera.')
      setMode('error')
    }
  }

  useEffect(() => { return () => stopCamera() }, [])

  async function handleLookup() {
    const code = result || codeInput.trim()
    if (!code) return
    setLooking(true)
    setLookupResult(null)
    try {
      const res = await fetch(`${BASE}/customer/quet-qr/lookup`, {
        method: 'POST', credentials: 'include',
        headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
        body: JSON.stringify({ code }),
      })
      const data = res.ok ? await res.json() : null
      setLookupResult(data ?? { message: 'Không tìm thấy thông tin.', success: false })
    } catch {
      setLookupResult({ message: 'Lỗi kết nối.', success: false })
    } finally {
      setLooking(false)
    }
  }

  function reset() {
    stopCamera()
    setMode('idle')
    setResult('')
    setError('')
    setLookupResult(null)
  }

  return (
    <div className="max-w-md mx-auto space-y-5">
      <div className="bg-gradient-to-br from-vs-navy to-blue-800 rounded-2xl p-6 text-white">
        <h1 className="text-2xl font-black mb-1">Quét mã QR</h1>
        <p className="text-blue-200 text-sm">Quét mã QR để check-in sân hoặc xác nhận dịch vụ.</p>
      </div>

      {/* Action buttons */}
      {mode === 'idle' && (
        <div className="grid grid-cols-2 gap-3">
          <button onClick={startCamera}
            className="bg-vs-blue text-white rounded-2xl p-5 flex flex-col items-center gap-2 hover:bg-blue-700">
            <span className="text-3xl">📷</span>
            <span className="font-semibold text-sm">Quét bằng camera</span>
          </button>
          <div className="bg-white border border-slate-200 rounded-2xl p-5 flex flex-col items-center gap-2">
            <span className="text-3xl">⌨️</span>
            <span className="font-semibold text-sm text-slate-700">Nhập mã thủ công</span>
          </div>
        </div>
      )}

      {/* Camera scanner */}
      {mode === 'scanning' && (
        <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
          <div className="relative">
            <video ref={videoRef} className="w-full" playsInline muted />
            <canvas ref={canvasRef} className="hidden" />
            <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
              <div className="w-48 h-48 border-2 border-white rounded-2xl opacity-70"></div>
            </div>
          </div>
          <div className="p-4 text-center">
            <p className="text-sm text-slate-500 mb-3">Đưa mã QR vào khung để quét</p>
            {'BarcodeDetector' in window ? (
              <p className="text-xs text-green-600">Đang quét tự động...</p>
            ) : (
              <p className="text-xs text-amber-600">Trình duyệt không hỗ trợ quét tự động. Nhập mã thủ công bên dưới.</p>
            )}
            <button onClick={reset} className="mt-3 border border-slate-200 text-slate-600 px-4 py-2 rounded-xl text-sm font-semibold">Hủy</button>
          </div>
        </div>
      )}

      {/* Error */}
      {mode === 'error' && (
        <div className="bg-red-50 border border-red-200 rounded-2xl p-5 text-center">
          <p className="text-red-600 font-semibold mb-3">{error}</p>
          <button onClick={reset} className="bg-vs-blue text-white px-5 py-2 rounded-xl text-sm font-semibold">Thử lại</button>
        </div>
      )}

      {/* Result */}
      {mode === 'result' && result && (
        <div className="bg-white border border-slate-200 rounded-2xl p-5">
          <p className="text-sm font-semibold text-slate-700 mb-2">Mã đã quét:</p>
          <p className="bg-slate-50 rounded-xl px-4 py-3 font-mono text-sm break-all">{result}</p>
          {lookupResult && (
            <div className={`mt-3 rounded-xl px-4 py-3 text-sm font-semibold ${lookupResult.success ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-600'}`}>
              {lookupResult.message}
            </div>
          )}
          <div className="flex gap-2 mt-3">
            <button onClick={handleLookup} disabled={looking}
              className="flex-1 bg-vs-blue text-white py-2.5 rounded-xl font-semibold text-sm disabled:opacity-50">
              {looking ? 'Đang xử lý...' : 'Xác nhận check-in'}
            </button>
            <button onClick={reset} className="border border-slate-200 text-slate-600 px-4 py-2.5 rounded-xl text-sm font-semibold">Quét lại</button>
          </div>
        </div>
      )}

      {/* Manual code input */}
      <div className="bg-white border border-slate-200 rounded-2xl p-5 space-y-3">
        <p className="font-semibold text-slate-700 text-sm">Hoặc nhập mã thủ công</p>
        <div className="flex gap-2">
          <input value={codeInput} onChange={e => setCodeInput(e.target.value)}
            placeholder="Nhập mã QR hoặc mã đặt sân..."
            className="flex-1 border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-300" />
          <button onClick={async () => { setResult(codeInput.trim()); setMode('result'); await handleLookup() }}
            disabled={!codeInput.trim() || looking}
            className="bg-vs-blue text-white px-4 py-2.5 rounded-xl text-sm font-semibold disabled:opacity-50">
            Tìm
          </button>
        </div>
      </div>

      {/* Guide */}
      <div className="bg-blue-50 border border-blue-200 rounded-xl p-4">
        <p className="font-semibold text-blue-800 text-sm mb-2">Hướng dẫn:</p>
        <ul className="text-xs text-blue-700 space-y-1 list-disc list-inside">
          <li>Quét mã QR trên vé đặt sân để check-in</li>
          <li>Quét mã QR trên bảng hiệu cơ sở để xem thông tin</li>
          <li>Nhập mã đặt sân thủ công nếu camera không hoạt động</li>
        </ul>
      </div>

      <div className="text-center">
        <a href={`${BASE}/customer/quet-qr`} target="_blank" rel="noopener noreferrer"
          className="text-vs-blue text-sm font-semibold hover:underline">
          Mở trang quét QR đầy đủ →
        </a>
      </div>
    </div>
  )
}
