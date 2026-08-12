'use client'

import { useState } from 'react'
import { sendOtp } from '@/lib/api/owner-register'
import { Mail, Phone, ArrowRight } from 'lucide-react'

interface Props {
  onSuccess: (email: string, phone: string) => void
}

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const VN_PHONE_RE = /^(0[35789])\d{8}$/

export default function Step1EmailPhone({ onSuccess }: Props) {
  const [email, setEmail] = useState('')
  const [phone, setPhone] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')

    if (!EMAIL_RE.test(email.trim())) {
      setError('Email không hợp lệ. Vui lòng kiểm tra lại.')
      return
    }
    if (!VN_PHONE_RE.test(phone.trim())) {
      setError('Số điện thoại không hợp lệ. Nhập đúng định dạng 0xxx xxxxxxx.')
      return
    }

    setLoading(true)
    try {
      const res = await sendOtp(email.trim(), phone.trim())
      if (res.success) {
        onSuccess(email.trim(), phone.trim())
      } else {
        setError(res.message ?? 'Gửi OTP thất bại. Vui lòng thử lại.')
      }
    } catch {
      setError('Lỗi kết nối. Vui lòng thử lại.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <section className="max-w-lg mx-auto px-4 py-12">
      <h1 className="text-2xl font-bold text-vs-navy mb-2">Đăng ký đối tác</h1>
      <p className="text-vs-slate text-sm mb-8">
        Nhập email và số điện thoại để nhận mã xác thực. OTP gửi đến hộp thư của bạn.
      </p>

      <form onSubmit={handleSubmit} noValidate className="space-y-5">
        <div>
          <label htmlFor="email" className="block text-sm font-medium text-vs-navy mb-1.5">
            Email <span className="text-red-500">*</span>
          </label>
          <div className="relative">
            <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-vs-slate" />
            <input
              id="email"
              type="email"
              value={email}
              onChange={e => setEmail(e.target.value)}
              placeholder="owner@example.com"
              className="w-full pl-10 pr-4 py-3 rounded-xl border border-slate-200 focus:border-vs-blue focus:ring-2 focus:ring-vs-blue/20 outline-none text-vs-navy text-sm"
              required
            />
          </div>
        </div>

        <div>
          <label htmlFor="phone" className="block text-sm font-medium text-vs-navy mb-1.5">
            Số điện thoại <span className="text-red-500">*</span>
          </label>
          <div className="relative">
            <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-vs-slate" />
            <input
              id="phone"
              type="tel"
              value={phone}
              onChange={e => setPhone(e.target.value)}
              placeholder="0901 234 567"
              className="w-full pl-10 pr-4 py-3 rounded-xl border border-slate-200 focus:border-vs-blue focus:ring-2 focus:ring-vs-blue/20 outline-none text-vs-navy text-sm"
              required
            />
          </div>
        </div>

        {error && (
          <p role="alert" className="text-sm text-red-600 bg-red-50 rounded-lg px-4 py-3">
            {error}
          </p>
        )}

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-vs-blue hover:bg-vs-navy text-white font-semibold py-3 px-6 rounded-xl transition-colors flex items-center justify-center gap-2 disabled:opacity-60"
        >
          {loading ? 'Đang gửi...' : 'Gửi mã OTP'}
          {!loading && <ArrowRight className="w-4 h-4" />}
        </button>
      </form>
    </section>
  )
}
