import { getOwners } from '@/lib/api/admin-pages'
import AccountsClient from '../nhan-su/AccountsClient'

export const metadata = { title: 'Quản lý Owner | V-SPORT Admin' }

export default async function OwnerPage() {
  const data = await getOwners()
  return <AccountsClient accounts={data?.accounts ?? []} title="Danh sách Owner" roleFilter={6} />
}
