export interface CustomerProfile {
  id: number
  fullName: string
  email: string
  phone: string
  avatarUrl: string | null
  role: string
  reputationScore: number
  totalBookings: number
  upcomingBookings: number
  unreadNotifications: number
}

export interface Booking {
  bookingId: number
  date: string
  startTime: string
  endTime: string
  status: string
  totalAmount: number
  courtName: string | null
  facilityId: number
  facilityName: string | null
  facilityAddress: string | null
  sportName: string | null
}

export interface BookingPage {
  total: number
  page: number
  pageSize: number
  items: Booking[]
}

export interface ReputationHistory {
  id: number
  change: number
  reason: string | null
  actionType: string | null
  createdAt: string | null
}

export interface ReputationData {
  score: number
  history: ReputationHistory[]
}

export interface Notification {
  id: number
  tieuDe: string
  noiDung: string
  loai: string | null
  daDoc: boolean
  thoiGian: string | null
  duongDan: string | null
}

export interface NotificationPage {
  unread: number
  items: Notification[]
}

export interface FacilitySummary {
  id: number
  name: string
  address: string
  phone: string | null
  image: string | null
  openTime: string | null
  closeTime: string | null
  openNow: boolean
  hasPromotion: boolean
  minPrice: number
  readyCourtCount: number
  sports: string[]
  latitude: number | null
  longitude: number | null
}

export interface Sport {
  id: number
  name: string
}

export interface SearchResult {
  sports: Sport[]
  facilities: FacilitySummary[]
  total: number
}
