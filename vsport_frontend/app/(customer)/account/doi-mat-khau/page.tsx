import AccountSidebar from '@/components/customer/layout/AccountSidebar'
import ChangePasswordForm from '@/components/customer/account/ChangePasswordForm'

export const metadata = { title: 'Đổi mật khẩu | V-SPORT' }

export default function DoiMatKhauPage() {
  return (
    <div className="max-w-5xl mx-auto px-4 py-6 flex gap-6">
      <AccountSidebar />
      <div className="flex-1">
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6">
          <h1 className="text-lg font-bold text-vs-navy mb-2">Đổi mật khẩu</h1>
          <p className="text-sm text-vs-slate mb-6">Mật khẩu mới phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt.</p>
          <ChangePasswordForm />
        </div>
      </div>
    </div>
  )
}
