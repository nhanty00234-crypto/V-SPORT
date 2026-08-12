export interface RecentInvoice {
  id: number
  total: number
  status: string
  date: string
}

export interface DashboardStats {
  coSoId: number
  managerName: string
  totalFields: number
  activeFields: number
  todayBookings: number
  revenueToday: number
  totalRevenue: number
  totalStaff: number
  recentInvoices: RecentInvoice[]
}
