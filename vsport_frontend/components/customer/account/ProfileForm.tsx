'use client'

import { useState } from 'react'
import type { CustomerProfile } from '@/types/customer'
import { updateProfile } from '@/lib/api/customer'
import { useRouter } from 'next/navigation'

interface Props { profile: CustomerProfile }

export default function ProfileForm({ profile }: Props) {
  const router = useRouter()
  const [form, setForm] = useState({
    fullName: profile.fullName ?? '',
    email: profile.email ?? '',
    phoneNumber: profile.phone ?? '',
    birthday: '',
    gender: '',
  })
  const [loading, setLoading] = useState(false)
  const [msg, setMsg] = useState<{ ok: boolean; text: string } | null>(null)

  function set(field: keyof typeof form) {
    return (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) =>
      setForm(prev => ({ ...prev, [field]: e.target.value }))
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setMsg(null)
    setLoading(true)
    try {
      const result = await updateProfile({
        fullName: form.fullName,
        email: form.email,
        phoneNumber: form.phoneNumber,
        birthday: form.birthday || undefined,
        gender: form.gender || undefined,
      })
      if (result.success) {
        setMsg({ ok: true, text: 'Cập nhật thành công!' })
        router.refresh()
      } else {
        setMsg({ ok: false, text: result.message ?? 'Cập nhật thất bại. Vui lòng thử lại.' })
      }
    } catch {
      setMsg({ ok: false, text: 'Không thể kết nối tới máy chủ.' })
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-vs-navy mb-1">Họ và tên</label>
          <input
            type="text"
            value={form.fullName}
            onChange={set('fullName')}
            className="w-full px-4 py-2.5 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-vs-blue"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-vs-navy mb-1">Email</label>
          <input
            type="email"
            value={form.email}
            onChange={set('email')}
            className="w-full px-4 py-2.5 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-vs-blue"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-vs-navy mb-1">Số điện thoại</label>
          <input
            type="tel"
            value={form.phoneNumber}
            onChange={set('phoneNumber')}
            className="w-full px-4 py-2.5 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-vs-blue"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-vs-navy mb-1">Giới tính</label>
          <select
            value={form.gender}
            onChange={set('gender')}
            className="w-full px-4 py-2.5 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-vs-blue"
          >
            <option value="">Chọn giới tính</option>
            <option value="Nam">Nam</option>
            <option value="Nữ">Nữ</option>
            <option value="Khác">Khác</option>
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-vs-navy mb-1">Ngày sinh</label>
          <input
            type="date"
            value={form.birthday}
            onChange={set('birthday')}
            max={new Date().toISOString().split('T')[0]}
            className="w-full px-4 py-2.5 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-vs-blue"
          />
        </div>
      </div>

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
        {loading ? 'Đang lưu...' : 'Lưu thay đổi'}
      </button>
    </form>
  )
}
