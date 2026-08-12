import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import RegisterCard from '@/components/auth/RegisterCard'

const mockPush = jest.fn()
jest.mock('next/navigation', () => ({
  useRouter: () => ({ push: mockPush }),
}))

const mockFetch = jest.fn()
global.fetch = mockFetch

function fillForm(overrides: Partial<Record<string, string>> = {}) {
  const defaults = {
    fullname: 'Nguyễn Văn A',
    username: 'nguyenvana',
    email: 'a@example.com',
    phone: '0912345678',
    password: 'Password1!',
    confirmPassword: 'Password1!',
  }
  const vals = { ...defaults, ...overrides }
  fireEvent.change(screen.getByPlaceholderText('Nguyễn Văn A'), { target: { value: vals.fullname } })
  fireEvent.change(screen.getByPlaceholderText('nguyenvana123'), { target: { value: vals.username } })
  fireEvent.change(screen.getByPlaceholderText('email@example.com'), { target: { value: vals.email } })
  fireEvent.change(screen.getByPlaceholderText('0912 345 678'), { target: { value: vals.phone } })
  const [passInput, confirmInput] = screen.getAllByPlaceholderText('••••••••')
  fireEvent.change(passInput, { target: { value: vals.password } })
  fireEvent.change(confirmInput, { target: { value: vals.confirmPassword } })
}

describe('RegisterCard', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('renders all form fields', () => {
    render(<RegisterCard />)
    expect(screen.getByPlaceholderText('Nguyễn Văn A')).toBeInTheDocument()
    expect(screen.getByPlaceholderText('nguyenvana123')).toBeInTheDocument()
    expect(screen.getByPlaceholderText('email@example.com')).toBeInTheDocument()
    expect(screen.getByPlaceholderText('0912 345 678')).toBeInTheDocument()
  })

  it('shows error when passwords do not match', async () => {
    render(<RegisterCard />)
    fillForm({ confirmPassword: 'Different1!' })
    fireEvent.click(screen.getByRole('checkbox'))
    fireEvent.click(screen.getByRole('button', { name: /tạo tài khoản/i }))
    await waitFor(() => expect(screen.getByText(/Mật khẩu xác nhận không khớp/i)).toBeInTheDocument())
  })

  it('shows error when password is too weak', async () => {
    render(<RegisterCard />)
    fillForm({ password: 'weak', confirmPassword: 'weak' })
    fireEvent.click(screen.getByRole('checkbox'))
    fireEvent.click(screen.getByRole('button', { name: /tạo tài khoản/i }))
    await waitFor(() => expect(screen.getByText(/chưa đáp ứng yêu cầu/i)).toBeInTheDocument())
  })

  it('requires agree checkbox', async () => {
    render(<RegisterCard />)
    fillForm()
    // do NOT check the checkbox
    fireEvent.click(screen.getByRole('button', { name: /tạo tài khoản/i }))
    await waitFor(() => expect(screen.getByText(/đồng ý với điều khoản/i)).toBeInTheDocument())
  })

  it('redirects to OTP page on successful registration', async () => {
    mockFetch.mockResolvedValue({
      json: () => Promise.resolve({ success: true, email: 'a@example.com' }),
    })
    render(<RegisterCard />)
    fillForm()
    fireEvent.click(screen.getByRole('checkbox'))
    fireEvent.click(screen.getByRole('button', { name: /tạo tài khoản/i }))
    await waitFor(() =>
      expect(mockPush).toHaveBeenCalledWith(expect.stringContaining('/xac-thuc-otp'))
    )
  })

  it('shows server error on failed registration', async () => {
    mockFetch.mockResolvedValue({
      json: () => Promise.resolve({ success: false, loi: 'Email đã tồn tại!' }),
    })
    render(<RegisterCard />)
    fillForm()
    fireEvent.click(screen.getByRole('checkbox'))
    fireEvent.click(screen.getByRole('button', { name: /tạo tài khoản/i }))
    await waitFor(() => expect(screen.getByText('Email đã tồn tại!')).toBeInTheDocument())
  })
})
