import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import Step1EmailPhone from '@/components/owner-register/Step1EmailPhone'

jest.mock('@/lib/api/owner-register', () => ({
  sendOtp: jest.fn(),
}))

import { sendOtp } from '@/lib/api/owner-register'
const mockSendOtp = sendOtp as jest.Mock

beforeEach(() => mockSendOtp.mockReset())

describe('Step1EmailPhone', () => {
  it('renders email and phone fields', () => {
    render(<Step1EmailPhone onSuccess={jest.fn()} />)
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/số điện thoại/i)).toBeInTheDocument()
  })

  it('shows error when email is invalid', async () => {
    render(<Step1EmailPhone onSuccess={jest.fn()} />)
    fireEvent.change(screen.getByLabelText(/email/i), { target: { value: 'notanemail' } })
    fireEvent.change(screen.getByLabelText(/số điện thoại/i), { target: { value: '0901234567' } })
    fireEvent.click(screen.getByRole('button', { name: /gửi mã otp/i }))
    expect(await screen.findByText(/email không hợp lệ/i)).toBeInTheDocument()
    expect(mockSendOtp).not.toHaveBeenCalled()
  })

  it('shows error when phone is invalid', async () => {
    render(<Step1EmailPhone onSuccess={jest.fn()} />)
    fireEvent.change(screen.getByLabelText(/email/i), { target: { value: 'owner@example.com' } })
    fireEvent.change(screen.getByLabelText(/số điện thoại/i), { target: { value: '12345' } })
    fireEvent.click(screen.getByRole('button', { name: /gửi mã otp/i }))
    expect(await screen.findByText(/số điện thoại không hợp lệ/i)).toBeInTheDocument()
    expect(mockSendOtp).not.toHaveBeenCalled()
  })

  it('calls sendOtp and onSuccess with valid inputs', async () => {
    mockSendOtp.mockResolvedValueOnce({ success: true })
    const onSuccess = jest.fn()
    render(<Step1EmailPhone onSuccess={onSuccess} />)
    fireEvent.change(screen.getByLabelText(/email/i), { target: { value: 'owner@example.com' } })
    fireEvent.change(screen.getByLabelText(/số điện thoại/i), { target: { value: '0901234567' } })
    fireEvent.click(screen.getByRole('button', { name: /gửi mã otp/i }))
    await waitFor(() => expect(onSuccess).toHaveBeenCalledWith('owner@example.com', '0901234567'))
  })

  it('shows API error message on failure', async () => {
    mockSendOtp.mockResolvedValueOnce({ success: false, message: 'Email đã tồn tại trong hệ thống.' })
    render(<Step1EmailPhone onSuccess={jest.fn()} />)
    fireEvent.change(screen.getByLabelText(/email/i), { target: { value: 'used@example.com' } })
    fireEvent.change(screen.getByLabelText(/số điện thoại/i), { target: { value: '0901234567' } })
    fireEvent.click(screen.getByRole('button', { name: /gửi mã otp/i }))
    expect(await screen.findByText(/email đã tồn tại/i)).toBeInTheDocument()
  })
})
