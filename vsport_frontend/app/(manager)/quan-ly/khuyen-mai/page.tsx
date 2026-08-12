import { getPromotions } from '@/lib/api/manager-pages'
import PromotionsClient from './PromotionsClient'

export const metadata = { title: 'Khuyến mãi | V-SPORT Manager' }

export default async function KhuyenMaiPage() {
  const data = await getPromotions()
  return <PromotionsClient data={data} />
}
