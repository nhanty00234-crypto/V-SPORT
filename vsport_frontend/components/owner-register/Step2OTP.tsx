'use client'

import { useState, useRef, useEffect, useCallback } from 'react'
import { ArrowLeft } from 'lucide-react'
import { verifyOtp, sendOtp } from '@/lib/api/owner-register'

interface Props {
  email: string
  phone: string
  onSuccess: () => void
  onBack: () => void
}

export default function Step2OTP({ email, phone, onSuccess, onBack }: Props) {
  const [digits, setDigits] = useState<string[]>(['', '', '', '', '', ''])
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [secondsLeft, setSecondsLeft] = useState(300)
  const inputRefs = useRef<Array<HTMLInputElement | null>>([])

  useEffect(() => {
    if (secondsLeft <= 0) return
    const id = setTimeout(() => setSecondsLeft(s => s - 1), 1000)
    return () => clearTimeout(id)
  }, [secondsLeft])

  const mm = String(Math.floor(secondsLeft / 60)).padStart(2, '0')
  const ss = String(secondsLeft % 60).padStart(2, '0')

  const submit = useCallback(
    async (otp: string) => {
      setLoading(true)
      setError('')
      try {
        const res = await verifyOtp(email, otp)
        if (res.success) {
          onSuccess()
        } else {
          setError(res.message ?? 'Mã OTP không đúng. Vui lòng thử lại.')
          setDigits(['', '', '', '', '', ''])
          inputRefs.current[0]?.focus()
        }
      } catch {
        setError('Lỗi kết nối. Vui lòng thử lại.')
      } finally {
        setLoading(false)
      }
    },
    [email, onSuccess]
  )

  const handleChange = (index: number, value: string) => {
    if (!/^\d?$/.test(value)) return
    const next = [...digits]
    next[index] = value
    setDigits(next)
    if (value && index < 5) {
      inputRefs.current[index + 1]?.focus()
    }
    if (next.every(d => d !== '')) {
      submit(next.join(''))
    }
  }

  const handleKeyDown = (index: number, e: React.KeyboardEvent) => {
    if (e.key === 'Backspace' && !digits[index] && index > 0) {
      inputRefs.current[index - 1]?.focus()
    }
  }

  const handlePaste = (e: React.ClipboardEvent) => {
    const pasted = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6)
    if (pasted.length === 6) {
      e.preventDefault()
      const next = pasted.split('')
      setDigits(next)
      inputRefs.current[5]?.focus()
      submit(pasted)
    }
  }

  const handleResend = async () => {
    setError('')
    setDigits(['', '', '', '', '', ''])
    try {
      await sendOtp(email, phone)
      setSecondsLeft(300)
    } catch {
      setError('Lỗi gửi lại OTP. Vui lòng thử lại.')
    }
  }

  return (
    <section className="max-w-lg mx-auto px-4 py-12">
      <button
        type="button"
        onClick={onBack}
        aria-label="Quay lại"
        className="flex items-center gap-1.5 text-vs-slate text-sm mb-8 hover:text-vs-navy transition-colors"
      >
        <ArrowLeft className="w-4 h-4" /> Quay lại
      </button>

      <h2 className="text-2xl font-bold text-vs-navy mb-2">Nhập mã xác nhận</h2>
      <p className="text-vs-slate text-sm mb-8">
        Chúng tôi đã gửi mã OTP 6 chữ số đến <strong>{email}</strong>.
      </p>

      <div className="flex gap-3 justify-center mb-6" onPaste={handlePaste}>
        {digits.map((d, i) => (
          <input
            key={i}
            ref={el => { inputRefs.current[i] = el }}
            type="text"
            inputMode="numeric"
            maxLength={1}
            value={d}
            onChange={e => handleChange(i, e.target.value)}
            onKeyDown={e => handleKeyDown(i, e)}
            aria-label={`Số ${i + 1}`}
            className="w-12 h-14 text-center text-xl font-bold border-2 rounded-xl border-slate-200 focus:border-vs-blue focus:ring-2 focus:ring-vs-blue/20 outline-none text-vs-navy"
          />
        ))}
      </div>

      {error && (
        <p role="alert" className="text-sm text-red-600 bg-red-50 rounded-lg px-4 py-3 mb-4 text-center">
          {error}
        </p>
      )}

      <div className="flex items-center justify-between text-sm">
        <span className="text-vs-slate">
          {secondsLeft > 0 ? `Mã hết hạn sau ${mm}:${ss}` : 'Mã đã hết hạn'}
        </span>
        <button
          type="button"
          onClick={handleResend}
          disabled={secondsLeft > 0}
          className="font-medium text-vs-blue hover:text-vs-navy disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
        >
          Gửi lại
        </button>
      </div>

      {loading && (
        <p className="text-center text-vs-slate text-sm mt-4">Đang xác nhận...</p>
      )}
    </section>
  )
}
