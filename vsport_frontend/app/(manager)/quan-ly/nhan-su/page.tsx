import { getStaff } from '@/lib/api/manager-pages'
import StaffClient from './StaffClient'

export const metadata = { title: 'Nhân sự | V-SPORT Manager' }

export default async function NhanSuPage() {
  const data = await getStaff()
  return <StaffClient staff={data?.staff ?? []} />
}
