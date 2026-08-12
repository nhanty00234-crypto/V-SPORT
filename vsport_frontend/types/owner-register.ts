export interface SportRow {
  sport: string
  quantity: number
}

export interface RegistrationData {
  ownerName: string
  email: string
  phone: string
  address: string
  description: string
  openTime: string
  closeTime: string
  operatingDays: string
  sportsData: string
  viDo?: string
  kinhDo?: string
}

export interface OtpStatus {
  emailVerified: boolean
  otpActive: boolean
  secondsRemaining: number
  otpEmail: string | null
}
