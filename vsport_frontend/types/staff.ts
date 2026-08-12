export interface StaffRecentInvoice {
  id: number
  total: number
  status: string
  date: string
}

export interface StaffDashboardStats {
  coSoId: number
  staffName: string
  totalFields: number
  activeFields: number
  todayBookings: number
  revenueToday: number
  recentInvoices: StaffRecentInvoice[]
}
