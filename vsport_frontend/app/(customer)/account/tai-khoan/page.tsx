import { getCustomerProfile } from '@/lib/api/customer'
import { getCurrentUser } from '@/lib/api/auth'
import AccountSidebar from '@/components/customer/layout/AccountSidebar'
import Link from 'next/link'

export const metadata = { title: 'Tài khoản | V-SPORT' }

const BOOKING_STATUS_LABEL: Record<string, string> = {
  'Chờ xác nhận': 'Chờ xác nhận',
  'Đã xác nhận': 'Đã xác nhận',
  'Chờ thanh toán': 'Chờ thanh toán',
  'Hoàn thành': 'Hoàn thành',
  'Đã hủy': 'Đã hủy',
}

export default async function TaiKhoanPage() {
  const [auth, profile] = await Promise.all([getCurrentUser(), getCustomerProfile()])

  const quickLinks = [
    { href: '/account/ho-so', label: 'Cập nhật hồ sơ', desc: 'Tên, email, số điện thoại' },
    { href: '/account/lich-su', label: 'Lịch sử đặt sân', desc: `${profile?.totalBookings ?? 0} lần đặt sân` },
    { href: '/account/thong-bao', label: 'Thông báo', desc: profile?.unreadNotifications ? `${profile.unreadNotifications} chưa đọc` : 'Xem tất cả' },
    { href: '/account/uu-dai', label: 'Ưu đãi của tôi', desc: 'Voucher & khuyến mãi' },
    { href: '/account/diem-uy-tin', label: 'Điểm uy tín', desc: `${profile?.reputationScore ?? 100} điểm` },
    { href: '/account/doi-mat-khau', label: 'Đổi mật khẩu', desc: 'Bảo mật tài khoản' },
  ]

  return (
    <div className="max-w-5xl mx-auto px-4 py-6 flex gap-6">
      <AccountSidebar />

      <div className="flex-1 space-y-6">
        {/* Hero */}
        <div className="bg-gradient-to-r from-vs-navy to-blue-800 rounded-2xl p-6 text-white">
          <div className="flex items-center gap-4">
            {profile?.avatarUrl ? (
              <img src={profile.avatarUrl} alt="" className="w-16 h-16 rounded-full object-cover border-2 border-cyan-400" />
            ) : (
              <div className="w-16 h-16 rounded-full bg-vs-cyan text-vs-navy flex items-center justify-center text-2xl font-bold">
                {profile?.fullName?.split(' ').slice(-1)[0]?.[0]?.toUpperCase() ?? 'U'}
              </div>
            )}
            <div>
              <h1 className="text-xl font-bold">{profile?.fullName ?? auth?.fullName}</h1>
              <p className="text-sm text-blue-200">{profile?.email ?? auth?.email}</p>
              <p className="text-sm text-cyan-300 font-medium mt-1">
                {profile?.reputationScore ?? 100} điểm uy tín
              </p>
            </div>
          </div>

          <div className="grid grid-cols-3 gap-4 mt-6">
            <div className="bg-white/10 rounded-xl p-3 text-center">
              <p className="text-2xl font-bold">{profile?.totalBookings ?? 0}</p>
              <p className="text-xs text-blue-200 mt-1">Lần đặt sân</p>
            </div>
            <div className="bg-white/10 rounded-xl p-3 text-center">
              <p className="text-2xl font-bold">{profile?.upcomingBookings ?? 0}</p>
              <p className="text-xs text-blue-200 mt-1">Sắp tới</p>
            </div>
            <div className="bg-white/10 rounded-xl p-3 text-center">
              <p className="text-2xl font-bold">{profile?.unreadNotifications ?? 0}</p>
              <p className="text-xs text-blue-200 mt-1">Thông báo mới</p>
            </div>
          </div>
        </div>

        {/* Quick links */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          {quickLinks.map(link => (
            <Link
              key={link.href}
              href={link.href}
              className="bg-white rounded-xl border border-slate-100 p-4 hover:shadow-md hover:border-vs-blue transition-all group"
            >
              <p className="font-semibold text-vs-navy group-hover:text-vs-blue transition-colors">{link.label}</p>
              <p className="text-sm text-vs-slate mt-1">{link.desc}</p>
            </Link>
          ))}
        </div>
      </div>
    </div>
  )
}
