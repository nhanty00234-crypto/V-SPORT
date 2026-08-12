import { OwnerStats } from '@/types/owner-landing'

const BACKEND = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'

export async function getOwnerStats(): Promise<OwnerStats | null> {
  try {
    const res = await fetch(`${BACKEND}/api/v1/home`, {
      next: { revalidate: 3600 },
    })
    if (!res.ok) return null
    const data = await res.json()
    return {
      totalFacilities: data.totalFacilities ?? 0,
      totalCourts:     data.totalCourts     ?? 0,
      totalBookings:   data.totalBookings   ?? 0,
      totalCustomers:  data.totalCustomers  ?? 0,
    }
  } catch {
    return null
  }
}
