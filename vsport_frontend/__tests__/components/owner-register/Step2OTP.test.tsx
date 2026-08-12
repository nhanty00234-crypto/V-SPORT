import { render, screen, fireEvent, waitFor, act } from '@testing-library/react'
import Step2OTP from '@/components/owner-register/Step2OTP'

jest.mock('@/lib/api/owner-register', () => ({
  sendOtp: jest.fn(),
  verifyOtp: jest.fn(),
}))

import { verifyOtp, sendOtp } from '@/lib/api/owner-register'
const mockVerifyOtp = verifyOtp as jest.Mock
const mockSendOtp = sendOtp as jest.Mock

beforeEach(() => {
  mockVerifyOtp.mockReset()
  mockSendOtp.mockReset()
  jest.useFakeTimers()
})
afterEach(() => jest.useRealTimers())

const defaultProps = {
  email: 'owner@example.com',
  phone: '0901234567',
  onSuccess: jest.fn(),
  onBack: jest.fn(),
}

describe('Step2OTP', () => {
  it('renders 6 OTP input boxes', () => {
    render(<Step2OTP {...defaultProps} />)
    const inputs = screen.getAllByRole('textbox')
    expect(inputs).toHaveLength(6)
  })

  it('shows the email address in instructions', () => {
    render(<Step2OTP {...defaultProps} />)
    expect(screen.getByText(/owner@example\.com/)).toBeInTheDocument()
  })

  it('calls verifyOtp and onSuccess when 6 digits are entered', async () => {
    mockVerifyOtp.mockResolvedValueOnce({ success: true })
    const onSuccess = jest.fn()
    render(<Step2OTP {...defaultProps} onSuccess={onSuccess} />)
    const inputs = screen.getAllByRole('textbox')

    await act(async () => {
      inputs.forEach((input, i) => {
        fireEvent.change(input, { target: { value: String(i + 1) } })
      })
    })

    await waitFor(() => expect(mockVerifyOtp).toHaveBeenCalledWith('owner@example.com', '123456'))
    await waitFor(() => expect(onSuccess).toHaveBeenCalled())
  })

  it('shows error when OTP is wrong', async () => {
    mockVerifyOtp.mockResolvedValueOnce({ success: false, message: 'Mã OTP không đúng.' })
    render(<Step2OTP {...defaultProps} />)
    const inputs = screen.getAllByRole('textbox')
    await act(async () => {
      inputs.forEach((input, i) => {
        fireEvent.change(input, { target: { value: String(i + 1) } })
      })
    })
    expect(await screen.findByText(/mã otp không đúng/i)).toBeInTheDocument()
  })

  it('calls onBack when back button is clicked', () => {
    const onBack = jest.fn()
    render(<Step2OTP {...defaultProps} onBack={onBack} />)
    fireEvent.click(screen.getByRole('button', { name: /quay lại/i }))
    expect(onBack).toHaveBeenCalled()
  })

  it('shows resend button disabled while countdown is active', () => {
    render(<Step2OTP {...defaultProps} />)
    const resend = screen.getByRole('button', { name: /gửi lại/i })
    expect(resend).toBeDisabled()
  })

  it('enables resend button when countdown reaches 0', async () => {
    render(<Step2OTP {...defaultProps} />)
    for (let i = 0; i <= 300; i++) {
      await act(async () => { jest.advanceTimersByTime(1000) })
    }
    expect(screen.getByRole('button', { name: /gửi lại/i })).not.toBeDisabled()
  })
})
