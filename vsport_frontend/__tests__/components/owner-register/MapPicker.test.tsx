import { render, screen, fireEvent } from '@testing-library/react'

jest.mock('next/script', () => ({
  __esModule: true,
  default: () => null,
}))

import MapPicker from '@/components/owner-register/MapPicker'

// In test env, NEXT_PUBLIC_GOOGLE_MAPS_KEY is undefined → fallback renders
describe('MapPicker (fallback — no API key)', () => {
  it('renders Vĩ độ and Kinh độ text inputs as fallback', () => {
    render(<MapPicker onChange={jest.fn()} />)
    expect(screen.getByPlaceholderText(/vĩ độ/i)).toBeInTheDocument()
    expect(screen.getByPlaceholderText(/kinh độ/i)).toBeInTheDocument()
  })

  it('pre-fills inputs from viDo and kinhDo props', () => {
    render(<MapPicker viDo="10.82" kinhDo="106.63" onChange={jest.fn()} />)
    expect(screen.getByDisplayValue('10.82')).toBeInTheDocument()
    expect(screen.getByDisplayValue('106.63')).toBeInTheDocument()
  })

  it('calls onChange when Vĩ độ changes', () => {
    const onChange = jest.fn()
    render(<MapPicker kinhDo="106.63" onChange={onChange} />)
    fireEvent.change(screen.getByPlaceholderText(/vĩ độ/i), { target: { value: '10.99' } })
    expect(onChange).toHaveBeenCalledWith('10.99', '106.63')
  })

  it('calls onChange when Kinh độ changes', () => {
    const onChange = jest.fn()
    render(<MapPicker viDo="10.82" onChange={onChange} />)
    fireEvent.change(screen.getByPlaceholderText(/kinh độ/i), { target: { value: '107.00' } })
    expect(onChange).toHaveBeenCalledWith('10.82', '107.00')
  })
})
