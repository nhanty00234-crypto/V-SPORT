import { render, screen, fireEvent, waitFor } from '@testing-library/react'

jest.mock('@/lib/api/owner-register', () => ({
  register: jest.fn(),
}))
jest.mock('@/components/owner-register/SportsTable', () => ({
  __esModule: true,
  default: ({ onChange }: { onChange: (r: unknown[]) => void }) => (
    <button onClick={() => onChange([{ sport: 'Cầu lông', quantity: 2 }])}>MockSports</button>
  ),
}))
jest.mock('@/components/owner-register/MapPicker', () => ({
  __esModule: true,
  default: () => <div>MockMap</div>,
}))

import Step3Details from '@/components/owner-register/Step3Details'
import { register } from '@/lib/api/owner-register'
const mockRegister = register as jest.Mock

beforeEach(() => mockRegister.mockReset())

const defaultProps = {
  email: 'owner@example.com',
  phone: '0901234567',
  onSuccess: jest.fn(),
}

describe('Step3Details', () => {
  it('renders required form fields', () => {
    render(<Step3Details {...defaultProps} />)
    expect(screen.getByLabelText(/tên cơ sở/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/địa chỉ/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/giờ mở cửa/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/giờ đóng cửa/i)).toBeInTheDocument()
  })

  it('shows pre-filled readonly email and phone', () => {
    render(<Step3Details {...defaultProps} />)
    const emailInput = screen.getByDisplayValue('owner@example.com')
    expect(emailInput).toHaveAttribute('readonly')
    const phoneInput = screen.getByDisplayValue('0901234567')
    expect(phoneInput).toHaveAttribute('readonly')
  })

  it('shows validation error when required fields are empty', async () => {
    render(<Step3Details {...defaultProps} />)
    fireEvent.click(screen.getByRole('button', { name: /hoàn tất/i }))
    expect(await screen.findByRole('alert')).toBeInTheDocument()
    expect(mockRegister).not.toHaveBeenCalled()
  })

  it('calls register and onSuccess when form is valid', async () => {
    mockRegister.mockResolvedValueOnce({ success: true })
    const onSuccess = jest.fn()
    render(<Step3Details {...defaultProps} onSuccess={onSuccess} />)

    fireEvent.change(screen.getByLabelText(/tên cơ sở/i), { target: { value: 'Sân ABC' } })
    fireEvent.change(screen.getByLabelText(/địa chỉ/i), { target: { value: '123 Lê Lợi' } })
    fireEvent.change(screen.getByLabelText(/giờ mở cửa/i), { target: { value: '06:00' } })
    fireEvent.change(screen.getByLabelText(/giờ đóng cửa/i), { target: { value: '22:00' } })
    fireEvent.click(screen.getAllByRole('checkbox')[0])

    fireEvent.click(screen.getByRole('button', { name: /hoàn tất/i }))
    await waitFor(() => expect(onSuccess).toHaveBeenCalled())
  })
})
