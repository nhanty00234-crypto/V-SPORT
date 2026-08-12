import { getRefunds } from '@/lib/api/manager-pages'
import RefundsClient from './RefundsClient'

export const metadata = { title: 'Hoàn tiền | V-SPORT Manager' }

export default async function HoanTienPage() {
  const data = await getRefunds()
  return <RefundsClient refunds={data?.refunds ?? []} />
}
