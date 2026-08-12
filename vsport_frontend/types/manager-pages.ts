export interface Court {
  id: number
  ten: string
  trangThai: string
  moTa: string
  giaKhongDen: number
  giaCoDen: number
  loaiSanId: number
  tenLoaiSan: string
}

export interface Booking {
  id: number
  accountId: number
  sanId: number
  ngayDat: string
  gioBatDau: string
  gioKetThuc: string
  tongTien: number
  trangThai: string
  tenKhach: string
  phone: string
  tenSan: string
  createdTime?: string
}

export interface Invoice {
  id: number
  datSanId: number
  accountId: number
  total: number
  status: string
  date: string
}

export interface InvoiceStats {
  revenueToday: number
  totalRevenue: number
  invoices: Invoice[]
}

export interface Product {
  id: number
  ten: string
  donGia: number
  soLuongTon: number
  trangThai: string
  skuCode: string
  danhMucId: number
  donViTinh: string
}

export interface InventoryStats {
  total: number
  lowStock: number
  outOfStock: number
  totalInventoryValue: number
  products: Product[]
}

export interface Promotion {
  id: number
  maCode: string
  moTa: string
  loaiGiam: string
  giaTriGiam: number
  ngayBatDau: string
  ngayKetThuc: string
  soLanToiDa: number
  soLanDaDung: number
  trangThai: string
  giaTriToiThieu: number
}

export interface PromotionStats {
  countActive: number
  countUpcoming: number
  countExpired: number
  totalUsage: number
  promotions: Promotion[]
}

export interface StaffMember {
  id: number
  username: string
  fullName: string
  email: string
  phone: string
  roleId: number
  roleName: string
  trangThai: string
  locked: boolean
  initial: string
}

export interface Shift {
  id: number
  accountId: number
  tenCa: string
  viTri: string
  ngayLam: string
  gioBatDau: string
  gioKetThuc: string
  trangThai: string
  ghiChu: string
}

export interface QRRequest {
  id: number
  sanId: number
  status: string
  createdAt: string
  note: string
  requestType: string
}

export interface Refund {
  id: number
  hoaDonId: number
  accountId: number
  soTienHoan: number
  lyDo: string
  trangThai: string
  thoiGianYeuCau: string
  ghiChuXuLy: string
  maGiaoDichHoan: string
}

export interface AuditLogEntry {
  id: number
  actorName: string
  actorRole: number
  action: string
  entityType: string
  entityName: string
  details: string
  ipAddress: string
  createdAt: string
  coSoId?: number
}

export interface TrashData {
  courts: { id: number; ten: string; deletedAt: string }[]
  bookings: { id: number; ngayDat: string; trangThai: string }[]
  products: { id: number; ten: string; deletedAt: string }[]
  staff: { id: number; fullName: string; email: string }[]
}
