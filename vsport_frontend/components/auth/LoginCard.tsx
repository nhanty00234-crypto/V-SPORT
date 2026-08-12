'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { useSearchParams, useRouter } from 'next/navigation'
import { login } from '@/lib/api/auth'

export default function LoginCard() {
  const params = useSearchParams()
  const router = useRouter()
  const redirect = params.get('redirect') ?? '/tim-kiem'

  const [tab, setTab] = useState<'account' | 'phone'>('account')
  const [identifier, setIdentifier] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    setIdentifier('')
    setError('')
  }, [tab])

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const result = await login(identifier, password, tab)
      if (result.success) {
        router.push(redirect)
      } else {
        setError(result.loi ?? 'Đăng nhập thất bại. Vui lòng thử lại.')
      }
    } catch {
      setError('Không thể kết nối tới máy chủ. Vui lòng thử lại.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-slate-50 px-4">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-8">
          <Link href="/" className="inline-block text-2xl font-bold tracking-tight">
            <span className="text-vs-navy">V-</span>
            <span className="text-vs-cyan">SPORT</span>
          </Link>
          <p className="mt-2 text-sm text-vs-slate">Đăng nhập vào tài khoản của bạn</p>
        </div>

        <div className="bg-white rounded-2xl shadow-sm border border-slate-100 p-8">
          {/* Tabs */}
          <div className="flex rounded-lg bg-slate-100 p-1 mb-6">
            <button
              type="button"
              onClick={() => setTab('account')}
              className={`flex-1 py-2 text-sm font-medium rounded-md transition-all ${
                tab === 'account'
                  ? 'bg-white text-vs-navy shadow-sm'
                  : 'text-vs-slate hover:text-vs-navy'
              }`}
            >
              Tài khoản
            </button>
            <button
              type="button"
              onClick={() => setTab('phone')}
              className={`flex-1 py-2 text-sm font-medium rounded-md transition-all ${
                tab === 'phone'
                  ? 'bg-white text-vs-navy shadow-sm'
                  : 'text-vs-slate hover:text-vs-navy'
              }`}
            >
              Số điện thoại
            </button>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-vs-navy mb-1">
                {tab === 'account' ? 'Tên đăng nhập hoặc email' : 'Số điện thoại'}
              </label>
              <input
                type={tab === 'phone' ? 'tel' : 'text'}
                value={identifier}
                onChange={e => setIdentifier(e.target.value)}
                placeholder={tab === 'account' ? 'username hoặc email@example.com' : '0912 345 678'}
                required
                className="w-full px-4 py-2.5 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-vs-blue focus:border-transparent"
              />
            </div>

            <div>
              <div className="flex justify-between items-center mb-1">
                <label className="block text-sm font-medium text-vs-navy">Mật khẩu</label>
                <Link
                  href="/quen-mat-khau"
                  className="text-xs text-vs-blue hover:underline"
                >
                  Quên mật khẩu?
                </Link>
              </div>
              <input
                type="password"
                value={password}
                onChange={e => setPassword(e.target.value)}
                placeholder="••••••••"
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
              {loading ? 'Đang đăng nhập...' : 'Đăng nhập'}
            </button>
          </form>

          <p className="mt-6 text-center text-sm text-vs-slate">
            Chưa có tài khoản?{' '}
            <Link href="/dang-ky" className="text-vs-blue font-medium hover:underline">
              Đăng ký ngay
            </Link>
          </p>
        </div>

        <p className="mt-4 text-center text-sm text-vs-slate">
          Bạn là chủ sân?{' '}
          <Link href="/owner" className="text-vs-cyan font-medium hover:underline">
            Đăng ký làm đối tác
          </Link>
        </p>
      </div>
    </div>
  )
}
