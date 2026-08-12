export interface OwnerStats {
  totalFacilities: number
  totalCourts: number
  totalBookings: number
  totalCustomers: number
}

export interface Testimonial {
  id: number
  ownerName: string
  facilityName: string
  avatarUrl: string
  content: string
  rating: number
}
