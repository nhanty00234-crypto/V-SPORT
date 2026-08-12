export interface Branch {
  id: number
  ten: string
  diaChi: string
  soDienThoai: string
  trangThai: string
  soLuongSan: number
  loaiHinh: string
  accountIdQuanLy: number
}

export interface Account {
  id: number
  username: string
  fullName: string
  email: string
  phone: string
  roleId: number
  coSoId: number
}

export interface AdminInvoice {
  id: number
  datSanId: number
  accountId: number
  total: number
  status: string
  date: string
}

export interface AdminBooking {
  id: number
  accountId: number
  sanId: number
  ngayDat: string
  gioBatDau: string
  gioKetThuc: string
  tongTien: number
  trangThai: string
  tenKhach: string
  tenSan: string
}

export interface AdminAuditLog {
  id: number
  actorName: string
  actorRole: number
  action: string
  entityType: string
  entityName: string
  details: string
  ipAddress: string
  coSoId: number
  createdAt: string
}

export interface AdminTrash {
  accounts: { id: number; fullName: string; email: string; roleId: number }[]
  branches: { id: number; ten: string; trangThai: string }[]
}
