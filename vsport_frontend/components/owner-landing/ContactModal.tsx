'use client'

import { useEffect } from 'react'
import { X, Mail, Phone, MapPin } from 'lucide-react'

interface Props {
  isOpen: boolean
  onClose: () => void
}

export default function ContactModal({ isOpen, onClose }: Props) {
  useEffect(() => {
    if (!isOpen) return
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose() }
    document.addEventListener('keydown', onKey)
    return () => document.removeEventListener('keydown', onKey)
  }, [isOpen, onClose])

  if (!isOpen) return null

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4"
      data-testid="modal-backdrop"
      onClick={onClose}
    >
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" />

      <div
        role="dialog"
        aria-modal="true"
        aria-label="Liên hệ tư vấn"
        className="relative bg-white rounded-2xl shadow-2xl max-w-md w-full p-8"
        onClick={(e) => e.stopPropagation()}
      >
        <button
          onClick={onClose}
          aria-label="Đóng"
          className="absolute top-4 right-4 w-8 h-8 rounded-full hover:bg-slate-100 flex items-center justify-center transition-colors"
        >
          <X className="w-4 h-4 text-slate-500" />
        </button>

        <h2 className="text-2xl font-bold text-vs-navy mb-2">Liên hệ tư vấn</h2>
        <p className="text-vs-slate text-sm mb-8">
          Đội ngũ V-Sport sẵn sàng hỗ trợ bạn đăng ký và cài đặt trong vòng 24 giờ.
        </p>

        <div className="space-y-5">
          {[
            { Icon: Mail,   label: 'Email',   value: 'support@vsport.vn', href: 'mailto:support@vsport.vn' },
            { Icon: Phone,  label: 'Hotline', value: '1800 xxxx',          href: 'tel:1800xxxx' },
            { Icon: MapPin, label: 'Địa chỉ', value: 'TP. Hồ Chí Minh, Việt Nam', href: undefined },
          ].map(({ Icon, label, value, href }) => (
            <div key={label} className="flex items-center gap-4">
              <div className="w-10 h-10 bg-vs-blue/10 rounded-xl flex items-center justify-center shrink-0">
                <Icon className="w-5 h-5 text-vs-blue" />
              </div>
              <div>
                <p className="text-xs text-vs-slate font-medium mb-0.5">{label}</p>
                {href ? (
                  <a href={href} className="text-vs-navy font-semibold hover:text-vs-blue transition-colors">
                    {value}
                  </a>
                ) : (
                  <p className="text-vs-navy font-semibold">{value}</p>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
