import { getOwnerStats } from '@/lib/api/owner-landing'
import OwnerPageClient from '@/components/owner-landing/OwnerPageClient'

export const revalidate = 3600

export default async function OwnerPage() {
  const stats = await getOwnerStats()
  return <OwnerPageClient stats={stats} />
}
