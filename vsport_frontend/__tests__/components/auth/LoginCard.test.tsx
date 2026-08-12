import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import LoginCard from '@/components/auth/LoginCard'
import * as authApi from '@/lib/api/auth'

jest.mock('@/lib/api/auth', () => ({
  login: jest.fn(),
}))

const mockPush = jest.fn()
jest.mock('next/navigation', () => ({
  useSearchParams: () => ({ get: () => null }),
  useRouter: () => ({ push: mockPush }),
}))

describe('LoginCard', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('renders login form with both tabs', () => {
    render(<LoginCard />)
    expect(screen.getByText('Tài khoản')).toBeInTheDocument()
    expect(screen.getByText('Số điện thoại')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Đăng nhập' })).toBeInTheDocument()
  })

  it('redirects to /tim-kiem on successful login', async () => {
    jest.mocked(authApi.login).mockResolvedValue({ success: true })
    render(<LoginCard />)
    fireEvent.change(screen.getByPlaceholderText(/username hoặc email/i), { target: { value: 'user1' } })
    fireEvent.change(screen.getByPlaceholderText('••••••••'), { target: { value: 'pass123' } })
    fireEvent.click(screen.getByRole('button', { name: 'Đăng nhập' }))
    await waitFor(() => expect(mockPush).toHaveBeenCalledWith('/tim-kiem'))
  })

  it('shows error message on failed login', async () => {
    jest.mocked(authApi.login).mockResolvedValue({ success: false, loi: 'Sai mật khẩu' })
    render(<LoginCard />)
    fireEvent.change(screen.getByPlaceholderText(/username hoặc email/i), { target: { value: 'user1' } })
    fireEvent.change(screen.getByPlaceholderText('••••••••'), { target: { value: 'wrong' } })
    fireEvent.click(screen.getByRole('button', { name: 'Đăng nhập' }))
    await waitFor(() => expect(screen.getByText('Sai mật khẩu')).toBeInTheDocument())
  })

  it('switches to phone tab and calls login with phone method', async () => {
    jest.mocked(authApi.login).mockResolvedValue({ success: true })
    render(<LoginCard />)
    fireEvent.click(screen.getByText('Số điện thoại'))
    fireEvent.change(screen.getByPlaceholderText('0912 345 678'), { target: { value: '0912345678' } })
    fireEvent.change(screen.getByPlaceholderText('••••••••'), { target: { value: 'pass123' } })
    fireEvent.click(screen.getByRole('button', { name: 'Đăng nhập' }))
    await waitFor(() => expect(authApi.login).toHaveBeenCalledWith('0912345678', 'pass123', 'phone'))
  })

  it('shows network error when fetch throws', async () => {
    jest.mocked(authApi.login).mockRejectedValue(new Error('Network error'))
    render(<LoginCard />)
    fireEvent.change(screen.getByPlaceholderText(/username hoặc email/i), { target: { value: 'user1' } })
    fireEvent.change(screen.getByPlaceholderText('••••••••'), { target: { value: 'pass123' } })
    fireEvent.click(screen.getByRole('button', { name: 'Đăng nhập' }))
    await waitFor(() => expect(screen.getByText(/Không thể kết nối/i)).toBeInTheDocument())
  })
})
