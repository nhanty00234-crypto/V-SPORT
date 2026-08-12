import { getCourts } from '@/lib/api/manager-pages'
import CourtsClient from './CourtsClient'

export const metadata = { title: 'Quản lý sân | V-SPORT Manager' }

export default async function SanPage() {
  const data = await getCourts()
  return <CourtsClient courts={data?.courts ?? []} />
}
