'use client'

import { useState } from 'react'
import { changePassword } from '@/lib/api/customer'

export default function ChangePasswordForm() {
  const [form, setForm] = useState({ currentPassword: '', newPassword: '', confirmPassword: '' })
  const [loading, setLoading] = useState(false)
  const [msg, setMsg] = useState<{ ok: boolean; text: string } | null>(null)

  function set(field: keyof typeof form) {
    return (e: React.ChangeEvent<HTMLInputElement>) =>
      setForm(prev => ({ ...prev, [field]: e.target.value }))
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    if (form.newPassword !== form.confirmPassword) {
      setMsg({ ok: false, text: 'Mật khẩu mới không khớp.' })
      return
    }
    setMsg(null)
    setLoading(true)
    try {
      const result = await changePassword(form.currentPassword, form.newPassword, form.confirmPassword)
      if (result.success) {
        setMsg({ ok: true, text: 'Đổi mật khẩu thành công!' })
        setForm({ currentPassword: '', newPassword: '', confirmPassword: '' })
      } else {
        setMsg({ ok: false, text: result.message ?? 'Đổi mật khẩu thất bại.' })
      }
    } catch {
      setMsg({ ok: false, text: 'Không thể kết nối tới máy chủ.' })
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4 max-w-sm">
      {[
        { field: 'currentPassword', label: 'Mật khẩu hiện tại' },
        { field: 'newPassword', label: 'Mật khẩu mới' },
        { field: 'confirmPassword', label: 'Xác nhận mật khẩu mới' },
      ].map(({ field, label }) => (
        <div key={field}>
          <label className="block text-sm font-medium text-vs-navy mb-1">{label}</label>
          <input
            type="password"
            value={form[field as keyof typeof form]}
            onChange={set(field as keyof typeof form)}
            required
            className="w-full px-4 py-2.5 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-vs-blue"
          />
        </div>
      ))}

      {msg && (
        <p className={`text-sm rounded-lg px-4 py-3 ${msg.ok ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-600'}`}>
          {msg.text}
        </p>
      )}

      <button
        type="submit"
        disabled={loading}
        className="px-6 py-2.5 bg-vs-blue text-white font-semibold text-sm rounded-lg hover:bg-blue-700 disabled:opacity-60 transition-colors"
      >
        {loading ? 'Đang đổi...' : 'Đổi mật khẩu'}
      </button>
    </form>
  )
}
