export interface AdminRecentAccount {
  id: number
  fullName: string
  email: string
  roleId: number
}

export interface AdminDashboardStats {
  totalAccounts: number
  totalOwners: number
  totalManagers: number
  totalStaff: number
  totalCustomers: number
  totalBranches: number
  activeBranches: number
  recentAccounts: AdminRecentAccount[]
}
