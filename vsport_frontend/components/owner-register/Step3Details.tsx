'use client'

import { useState } from 'react'
import { MapPin, Clock, CalendarDays, AlignLeft } from 'lucide-react'
import SportsTable from './SportsTable'
import MapPicker from './MapPicker'
import { register } from '@/lib/api/owner-register'
import type { SportRow, RegistrationData } from '@/types/owner-register'

interface Props {
  email: string
  phone: string
  onSuccess: () => void
}

const DAYS = [
  { key: 'T2', label: 'T2' },
  { key: 'T3', label: 'T3' },
  { key: 'T4', label: 'T4' },
  { key: 'T5', label: 'T5' },
  { key: 'T6', label: 'T6' },
  { key: 'T7', label: 'T7' },
  { key: 'CN', label: 'CN' },
]

export default function Step3Details({ email, phone, onSuccess }: Props) {
  const [ownerName, setOwnerName] = useState('')
  const [address, setAddress] = useState('')
  const [description, setDescription] = useState('')
  const [openTime, setOpenTime] = useState('')
  const [closeTime, setCloseTime] = useState('')
  const [operatingDays, setOperatingDays] = useState<string[]>([])
  const [sports, setSports] = useState<SportRow[]>([{ sport: 'Cầu lông', quantity: 1 }])
  const [viDo, setViDo] = useState('')
  const [kinhDo, setKinhDo] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const toggleDay = (day: string) => {
    setOperatingDays(prev =>
      prev.includes(day) ? prev.filter(d => d !== day) : [...prev, day]
    )
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')

    if (!ownerName.trim()) { setError('Vui lòng nhập tên cơ sở.'); return }
    if (!address.trim()) { setError('Vui lòng nhập địa chỉ.'); return }
    if (!openTime) { setError('Vui lòng nhập giờ mở cửa.'); return }
    if (!closeTime) { setError('Vui lòng nhập giờ đóng cửa.'); return }
    if (operatingDays.length === 0) { setError('Vui lòng chọn ít nhất một ngày hoạt động.'); return }
    if (sports.length === 0) { setError('Vui lòng thêm ít nhất một môn thể thao.'); return }

    const data: RegistrationData = {
      ownerName: ownerName.trim(),
      email,
      phone,
      address: address.trim(),
      description: description.trim(),
      openTime,
      closeTime,
      operatingDays: operatingDays.join(','),
      sportsData: JSON.stringify(sports),
      ...(viDo && kinhDo ? { viDo, kinhDo } : {}),
    }

    setLoading(true)
    try {
      const res = await register(data)
      if (res.success) {
        onSuccess()
      } else {
        setError(res.message ?? 'Đăng ký thất bại. Vui lòng thử lại.')
      }
    } catch {
      setError('Lỗi kết nối. Vui lòng thử lại.')
    } finally {
      setLoading(false)
    }
  }

  const fieldClass =
    'w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm text-vs-navy focus:border-vs-blue focus:ring-2 focus:ring-vs-blue/20 outline-none'

  return (
    <section className="max-w-2xl mx-auto px-4 py-10">
      <h2 className="text-2xl font-bold text-vs-navy mb-2">Thông tin cơ sở</h2>
      <p className="text-vs-slate text-sm mb-8">Điền thông tin cơ sở thể thao của bạn.</p>

      <form onSubmit={handleSubmit} noValidate className="space-y-6">
        <div className="grid grid-cols-1 gap-5 sm:grid-cols-2">
          <div className="sm:col-span-2">
            <label htmlFor="ownerName" className="block text-sm font-medium text-vs-navy mb-1.5">
              Tên cơ sở / chủ sân <span className="text-red-500">*</span>
            </label>
            <input
              id="ownerName"
              type="text"
              value={ownerName}
              onChange={e => setOwnerName(e.target.value)}
              placeholder="Sân Cầu Lông ABC"
              className={fieldClass}
            />
          </div>

          <div>
            <label htmlFor="emailReadonly" className="block text-sm font-medium text-vs-navy mb-1.5">
              Email
            </label>
            <input
              id="emailReadonly"
              type="email"
              value={email}
              readOnly
              className={`${fieldClass} bg-slate-50`}
            />
          </div>
          <div>
            <label htmlFor="phoneReadonly" className="block text-sm font-medium text-vs-navy mb-1.5">
              Số điện thoại
            </label>
            <input
              id="phoneReadonly"
              type="tel"
              value={phone}
              readOnly
              className={`${fieldClass} bg-slate-50`}
            />
          </div>

          <div className="sm:col-span-2">
            <label htmlFor="address" className="block text-sm font-medium text-vs-navy mb-1.5">
              <MapPin className="inline w-4 h-4 mr-1" />Địa chỉ <span className="text-red-500">*</span>
            </label>
            <input
              id="address"
              type="text"
              value={address}
              onChange={e => setAddress(e.target.value)}
              placeholder="123 Lê Lợi, Q.1, TP.HCM"
              className={fieldClass}
            />
          </div>

          <div className="sm:col-span-2">
            <label htmlFor="description" className="block text-sm font-medium text-vs-navy mb-1.5">
              <AlignLeft className="inline w-4 h-4 mr-1" />Mô tả (tùy chọn)
            </label>
            <textarea
              id="description"
              rows={3}
              value={description}
              onChange={e => setDescription(e.target.value)}
              placeholder="Giới thiệu ngắn về cơ sở của bạn..."
              className={`${fieldClass} resize-none`}
            />
          </div>
        </div>

        <div>
          <p className="text-sm font-medium text-vs-navy mb-3">
            <Clock className="inline w-4 h-4 mr-1" />Giờ hoạt động <span className="text-red-500">*</span>
          </p>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label htmlFor="openTime" className="block text-xs text-vs-slate mb-1">
                Giờ mở cửa
              </label>
              <input
                id="openTime"
                type="time"
                value={openTime}
                onChange={e => setOpenTime(e.target.value)}
                className={fieldClass}
              />
            </div>
            <div>
              <label htmlFor="closeTime" className="block text-xs text-vs-slate mb-1">
                Giờ đóng cửa
              </label>
              <input
                id="closeTime"
                type="time"
                value={closeTime}
                onChange={e => setCloseTime(e.target.value)}
                className={fieldClass}
              />
            </div>
          </div>
        </div>

        <div>
          <p className="text-sm font-medium text-vs-navy mb-3">
            <CalendarDays className="inline w-4 h-4 mr-1" />Ngày hoạt động <span className="text-red-500">*</span>
          </p>
          <div className="flex gap-4 flex-wrap">
            {DAYS.map(d => (
              <label key={d.key} className="flex items-center gap-1.5 cursor-pointer">
                <input
                  type="checkbox"
                  checked={operatingDays.includes(d.key)}
                  onChange={() => toggleDay(d.key)}
                  className="w-4 h-4 rounded text-vs-blue focus:ring-vs-blue/30"
                />
                <span className="text-sm text-vs-navy">{d.label}</span>
              </label>
            ))}
          </div>
        </div>

        <div>
          <p className="text-sm font-medium text-vs-navy mb-3">
            Môn thể thao &amp; số sân <span className="text-red-500">*</span>
          </p>
          <SportsTable value={sports} onChange={setSports} />
        </div>

        <div>
          <p className="text-sm font-medium text-vs-navy mb-3">Vị trí bản đồ (tùy chọn)</p>
          <MapPicker
            viDo={viDo}
            kinhDo={kinhDo}
            onChange={(lat, lng) => {
              setViDo(lat)
              setKinhDo(lng)
            }}
          />
        </div>

        {error && (
          <p role="alert" className="text-sm text-red-600 bg-red-50 rounded-lg px-4 py-3">
            {error}
          </p>
        )}

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-vs-blue hover:bg-vs-navy text-white font-semibold py-3.5 px-6 rounded-xl transition-colors disabled:opacity-60"
        >
          {loading ? 'Đang gửi...' : 'Hoàn tất đăng ký'}
        </button>
      </form>
    </section>
  )
}
