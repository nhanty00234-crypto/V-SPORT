import { getShifts } from '@/lib/api/manager-pages'
import ShiftsClient from './ShiftsClient'

export const metadata = { title: 'Ca làm việc | V-SPORT Manager' }

export default async function CaLamViecPage() {
  const today = new Date()
  const from = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-01`
  const lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0).getDate()
  const to = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${lastDay}`
  const data = await getShifts(from, to)
  return <ShiftsClient shifts={data?.shifts ?? []} defaultFrom={from} defaultTo={to} />
}
