'use client'

import { useState } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'

const BASE = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'

const PASSWORD_RULES = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^a-zA-Z\d]).{8,}$/

function PasswordStrength({ value }: { value: string }) {
  const checks = [
    { label: 'Ít nhất 8 ký tự', ok: value.length >= 8 },
    { label: 'Chữ hoa', ok: /[A-Z]/.test(value) },
    { label: 'Chữ thường', ok: /[a-z]/.test(value) },
    { label: 'Số', ok: /\d/.test(value) },
    { label: 'Ký tự đặc biệt', ok: /[^a-zA-Z\d]/.test(value) },
  ]
  const passed = checks.filter(c => c.ok).length
  const color = passed <= 2 ? 'bg-red-400' : passed <= 3 ? 'bg-yellow-400' : 'bg-green-500'
  if (!value) return null
  return (
    <div className="mt-2 space-y-1">
      <div className="flex gap-1">
        {checks.map((_, i) => (
          <div key={i} className={`h-1 flex-1 rounded-full ${i < passed ? color : 'bg-slate-200'}`} />
        ))}
      </div>
      <div className="flex flex-wrap gap-x-3 gap-y-1">
        {checks.map(c => (
          <span key={c.label} className={`text-xs ${c.ok ? 'text-green-600' : 'text-vs-slate'}`}>
            {c.ok ? '✓' : '○'} {c.label}
          </span>
        ))}
      </div>
    </div>
  )
}

export default function RegisterCard() {
  const router = useRouter()

  const [form, setForm] = useState({
    fullname: '',
    username: '',
    email: '',
    phone: '',
    password: '',
    confirmPassword: '',
    agree: false,
  })
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  function set(field: keyof typeof form) {
    return (e: React.ChangeEvent<HTMLInputElement>) =>
      setForm(prev => ({ ...prev, [field]: e.target.type === 'checkbox' ? e.target.checked : e.target.value }))
  }

  function validate(): string | null {
    if (!form.fullname.trim()) return 'Vui lòng nhập họ và tên.'
    if (!form.username.trim()) return 'Vui lòng nhập tên đăng nhập.'
    if (!/^[^\s]{3,50}$/.test(form.username)) return 'Tên đăng nhập 3-50 ký tự, không chứa khoảng trắng.'
    if (!form.email.trim()) return 'Vui lòng nhập email.'
    if (!form.phone.trim()) return 'Vui lòng nhập số điện thoại.'
    if (!PASSWORD_RULES.test(form.password)) return 'Mật khẩu chưa đáp ứng yêu cầu.'
    if (form.password !== form.confirmPassword) return 'Mật khẩu xác nhận không khớp.'
    if (!form.agree) return 'Bạn cần đồng ý với điều khoản dịch vụ.'
    return null
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    const err = validate()
    if (err) { setError(err); return }
    setError('')
    setLoading(true)
    try {
      const body = new URLSearchParams({
        fullname: form.fullname,
        username: form.username,
        email: form.email,
        phone: form.phone,
        password: form.password,
        confirm_password: form.confirmPassword,
        'agree[]': 'on',
      })
      const res = await fetch(`${BASE}/dangky`, {
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
        const email = encodeURIComponent(data.email ?? form.email)
        router.push(`/xac-thuc-otp?email=${email}`)
      } else {
        setError(data.loi ?? 'Đăng ký thất bại. Vui lòng thử lại.')
      }
    } catch {
      setError('Không thể kết nối tới máy chủ. Vui lòng thử lại.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-slate-50 px-4 py-12">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-8">
          <Link href="/" className="inline-block text-2xl font-bold tracking-tight">
            <span className="text-vs-navy">V-</span>
            <span className="text-vs-cyan">SPORT</span>
          </Link>
          <p className="mt-2 text-sm text-vs-slate">Tạo tài khoản mới</p>
        </div>

        <div className="bg-white rounded-2xl shadow-sm border border-slate-100 p-8">
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="col-span-2">
                <label className="block text-sm font-medium text-vs-navy mb-1">Họ và tên</label>
                <input
                  type="text"
                  value={form.fullname}
                  onChange={set('fullname')}
                  placeholder="Nguyễn Văn A"
                  required
                  className="w-full px-4 py-2.5 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-vs-blue focus:border-transparent"
                />
              </div>
              <div className="col-span-2">
                <label className="block text-sm font-medium text-vs-navy mb-1">Tên đăng nhập</label>
                <input
                  type="text"
                  value={form.username}
                  onChange={set('username')}
                  placeholder="nguyenvana123"
                  required
                  className="w-full px-4 py-2.5 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-vs-blue focus:border-transparent"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-vs-navy mb-1">Email</label>
                <input
                  type="email"
                  value={form.email}
                  onChange={set('email')}
                  placeholder="email@example.com"
                  required
                  className="w-full px-4 py-2.5 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-vs-blue focus:border-transparent"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-vs-navy mb-1">Số điện thoại</label>
                <input
                  type="tel"
                  value={form.phone}
                  onChange={set('phone')}
                  placeholder="0912 345 678"
                  required
                  className="w-full px-4 py-2.5 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-vs-blue focus:border-transparent"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-vs-navy mb-1">Mật khẩu</label>
              <input
                type="password"
                value={form.password}
                onChange={set('password')}
                placeholder="••••••••"
                required
                className="w-full px-4 py-2.5 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-vs-blue focus:border-transparent"
              />
              <PasswordStrength value={form.password} />
            </div>

            <div>
              <label className="block text-sm font-medium text-vs-navy mb-1">Xác nhận mật khẩu</label>
              <input
                type="password"
                value={form.confirmPassword}
                onChange={set('confirmPassword')}
                placeholder="••••••••"
                required
                className="w-full px-4 py-2.5 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-vs-blue focus:border-transparent"
              />
              {form.confirmPassword && form.password !== form.confirmPassword && (
                <p className="mt-1 text-xs text-red-500">Mật khẩu không khớp</p>
              )}
            </div>

            <label className="flex items-start gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={form.agree}
                onChange={set('agree')}
                className="mt-0.5 rounded border-slate-300 text-vs-blue focus:ring-vs-blue"
              />
              <span className="text-sm text-vs-slate">
                Tôi đồng ý với{' '}
                <a href="#" className="text-vs-blue hover:underline">điều khoản dịch vụ</a>
                {' '}và{' '}
                <a href="#" className="text-vs-blue hover:underline">chính sách bảo mật</a>
              </span>
            </label>

            {error && (
              <p className="text-sm text-red-600 bg-red-50 rounded-lg px-3 py-2">{error}</p>
            )}

            <button
              type="submit"
              disabled={loading}
              className="w-full py-2.5 rounded-lg bg-vs-blue text-white font-semibold text-sm hover:bg-blue-700 disabled:opacity-60 transition-colors"
            >
              {loading ? 'Đang tạo tài khoản...' : 'Tạo tài khoản'}
            </button>
          </form>

          <p className="mt-6 text-center text-sm text-vs-slate">
            Đã có tài khoản?{' '}
            <Link href="/dang-nhap" className="text-vs-blue font-medium hover:underline">
              Đăng nhập
            </Link>
          </p>
        </div>
      </div>
    </div>
  )
}
