import { getAllUsers } from '@/lib/api/admin-pages'
import AccountsClient from './AccountsClient'

export const metadata = { title: 'Nhân sự | V-SPORT Admin' }

export default async function NhanSuPage() {
  const data = await getAllUsers()
  return <AccountsClient accounts={data?.accounts ?? []} title="Toàn bộ tài khoản hệ thống" />
}
