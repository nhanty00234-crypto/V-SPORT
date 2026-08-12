export type UserRole = 'CUSTOMER' | 'MANAGER' | 'STAFF' | 'ADMIN'

export interface User {
  id: number
  email: string
  phone: string
  fullName: string
  role: UserRole
  avatarUrl: string | null
}

export interface LoginResult {
  success: boolean
  loi?: string
  user?: User
}
