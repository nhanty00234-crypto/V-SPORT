'use client'

import { useState, useRef, useEffect } from 'react'
import Link from 'next/link'
import { useSearchParams, useRouter } from 'next/navigation'

const BASE = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'
const OTP_LENGTH = 6

export default function OtpCard() {
  const params = useSearchParams()
  const router = useRouter()
  const email = params.get('email') ?? ''

  const [digits, setDigits] = useState(Array(OTP_LENGTH).fill(''))
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [lockedOut, setLockedOut] = useState(false)
  const refs = useRef<(HTMLInputElement | null)[]>([])

  useEffect(() => {
    refs.current[0]?.focus()
  }, [])

  function handleChange(index: number, value: string) {
    if (!/^\d*$/.test(value)) return
    const next = [...digits]
    next[index] = value.slice(-1)
    setDigits(next)
    if (value && index < OTP_LENGTH - 1) refs.current[index + 1]?.focus()
  }

  function handleKeyDown(index: number, e: React.KeyboardEvent) {
    if (e.key === 'Backspace' && !digits[index] && index > 0) {
      refs.current[index - 1]?.focus()
    }
  }

  function handlePaste(e: React.ClipboardEvent) {
    e.preventDefault()
    const pasted = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, OTP_LENGTH)
    const next = Array(OTP_LENGTH).fill('')
    pasted.split('').forEach((c, i) => { next[i] = c })
    setDigits(next)
    const focusIndex = Math.min(pasted.length, OTP_LENGTH - 1)
    refs.current[focusIndex]?.focus()
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    const otp = digits.join('')
    if (otp.length < OTP_LENGTH) { setError('Vui lòng nhập đủ 6 chữ số.'); return }
    setError('')
    setLoading(true)
    try {
      const body = new URLSearchParams({ otp, email })
      const res = await fetch(`${BASE}/nhapma`, {
        method: 'POST',
        credentials: 'include',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: body.toString(),
      })
      const data = await res.json()
      if (data.success) {
        router.push('/dang-nhap?verified=1')
      } else if (data.lockedOut) {
        setLockedOut(true)
      } else {
        setError(data.loi ?? 'Mã OTP không đúng. Vui lòng thử lại.')
        setDigits(Array(OTP_LENGTH).fill(''))
        refs.current[0]?.focus()
      }
    } catch {
      setError('Không thể kết nối tới máy chủ. Vui lòng thử lại.')
    } finally {
      setLoading(false)
    }
  }

  if (lockedOut) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-slate-50 px-4">
        <div className="w-full max-w-md text-center">
          <div className="text-5xl mb-4">🔒</div>
          <h2 className="text-xl font-bold text-vs-navy mb-2">Tài khoản tạm khóa</h2>
          <p className="text-sm text-vs-slate mb-6">
            Bạn đã nhập sai quá nhiều lần. Vui lòng thử lại sau ít phút.
          </p>
          <Link href="/dang-nhap" className="text-vs-blue text-sm hover:underline">
            Quay lại đăng nhập
          </Link>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-slate-50 px-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <Link href="/" className="inline-block text-2xl font-bold tracking-tight">
            <span className="text-vs-navy">V-</span>
            <span className="text-vs-cyan">SPORT</span>
          </Link>
          <p className="mt-2 text-sm text-vs-slate">Xác thực email của bạn</p>
        </div>

        <div className="bg-white rounded-2xl shadow-sm border border-slate-100 p-8">
          <div className="text-center mb-6">
            <div className="text-4xl mb-3">📧</div>
            <p className="text-sm text-vs-slate">
              Mã OTP đã được gửi tới{' '}
              <span className="font-medium text-vs-navy">{email}</span>
            </p>
          </div>

          <form onSubmit={handleSubmit}>
            <div className="flex justify-center gap-2 mb-6" onPaste={handlePaste}>
              {digits.map((d, i) => (
                <input
                  key={i}
                  ref={el => { refs.current[i] = el }}
                  type="text"
                  inputMode="numeric"
                  maxLength={1}
                  value={d}
                  onChange={e => handleChange(i, e.target.value)}
                  onKeyDown={e => handleKeyDown(i, e)}
                  className="w-11 h-12 text-center text-lg font-semibold rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-vs-blue focus:border-transparent"
                />
              ))}
            </div>

            {error && (
              <p className="text-sm text-red-600 bg-red-50 rounded-lg px-3 py-2 mb-4 text-center">{error}</p>
            )}

            <button
              type="submit"
              disabled={loading || digits.join('').length < OTP_LENGTH}
              className="w-full py-2.5 rounded-lg bg-vs-blue text-white font-semibold text-sm hover:bg-blue-700 disabled:opacity-60 transition-colors"
            >
              {loading ? 'Đang xác thực...' : 'Xác nhận'}
            </button>
          </form>

          <p className="mt-6 text-center text-xs text-vs-slate">
            Không nhận được mã?{' '}
            <Link href="/dang-ky" className="text-vs-blue hover:underline">
              Đăng ký lại
            </Link>
          </p>
        </div>
      </div>
    </div>
  )
}
