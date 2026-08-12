'use client'

import { useState } from 'react'
import Link from 'next/link'

const BASE = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'

export default function ForgotPasswordCard() {
  const [email, setEmail] = useState('')
  const [error, setError] = useState('')
  const [sent, setSent] = useState(false)
  const [loading, setLoading] = useState(false)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const body = new URLSearchParams({ email })
      const res = await fetch(`${BASE}/quenmatkhau`, {
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
        setSent(true)
      } else {
        setError(data.loi ?? 'Không tìm thấy email. Vui lòng kiểm tra lại.')
      }
    } catch {
      setError('Không thể kết nối tới máy chủ. Vui lòng thử lại.')
    } finally {
      setLoading(false)
    }
  }

  if (sent) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-slate-50 px-4">
        <div className="w-full max-w-md">
          <div className="text-center mb-8">
            <Link href="/" className="inline-block text-2xl font-bold tracking-tight">
              <span className="text-vs-navy">V-</span>
              <span className="text-vs-cyan">SPORT</span>
            </Link>
          </div>
          <div className="bg-white rounded-2xl shadow-sm border border-slate-100 p-8 text-center">
            <div className="text-5xl mb-4">✉️</div>
            <h2 className="text-lg font-bold text-vs-navy mb-2">Kiểm tra hộp thư của bạn</h2>
            <p className="text-sm text-vs-slate mb-6">
              Mật khẩu mới đã được gửi tới{' '}
              <span className="font-medium text-vs-navy">{email}</span>.
              Hãy đăng nhập và đổi mật khẩu ngay.
            </p>
            <Link
              href="/dang-nhap"
              className="inline-block w-full py-2.5 rounded-lg bg-vs-blue text-white font-semibold text-sm hover:bg-blue-700 transition-colors"
            >
              Đi đến đăng nhập
            </Link>
          </div>
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
          <p className="mt-2 text-sm text-vs-slate">Lấy lại mật khẩu</p>
        </div>

        <div className="bg-white rounded-2xl shadow-sm border border-slate-100 p-8">
          <p className="text-sm text-vs-slate mb-6">
            Nhập email đăng ký. Chúng tôi sẽ gửi mật khẩu mới vào hộp thư của bạn.
          </p>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-vs-navy mb-1">Email</label>
              <input
                type="email"
                value={email}
                onChange={e => setEmail(e.target.value)}
                placeholder="email@example.com"
                required
                className="w-full px-4 py-2.5 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-vs-blue focus:border-transparent"
              />
            </div>

            {error && (
              <p className="text-sm text-red-600 bg-red-50 rounded-lg px-3 py-2">{error}</p>
            )}

            <button
              type="submit"
              disabled={loading}
              className="w-full py-2.5 rounded-lg bg-vs-blue text-white font-semibold text-sm hover:bg-blue-700 disabled:opacity-60 transition-colors"
            >
              {loading ? 'Đang gửi...' : 'Gửi mật khẩu mới'}
            </button>
          </form>

          <p className="mt-6 text-center text-sm text-vs-slate">
            <Link href="/dang-nhap" className="text-vs-blue hover:underline">
              ← Quay lại đăng nhập
            </Link>
          </p>
        </div>
      </div>
    </div>
  )
}
