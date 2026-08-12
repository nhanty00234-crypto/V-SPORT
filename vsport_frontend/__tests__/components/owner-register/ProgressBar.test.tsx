import { render, screen } from '@testing-library/react'
import ProgressBar from '@/components/owner-register/ProgressBar'

describe('ProgressBar', () => {
  it('marks step 1 as active when currentStep is 1', () => {
    render(<ProgressBar currentStep={1} />)
    const step1 = screen.getByText('Xác thực email').closest('[aria-current]')
    expect(step1).toHaveAttribute('aria-current', 'step')
  })

  it('marks step 2 as active when currentStep is 2', () => {
    render(<ProgressBar currentStep={2} />)
    const step2 = screen.getByText('Mã xác nhận').closest('[aria-current]')
    expect(step2).toHaveAttribute('aria-current', 'step')
  })

  it('marks step 3 as active when currentStep is 3', () => {
    render(<ProgressBar currentStep={3} />)
    const step3 = screen.getByText('Thông tin cơ sở').closest('[aria-current]')
    expect(step3).toHaveAttribute('aria-current', 'step')
  })

  it('renders all 3 step labels', () => {
    render(<ProgressBar currentStep={1} />)
    expect(screen.getByText('Xác thực email')).toBeInTheDocument()
    expect(screen.getByText('Mã xác nhận')).toBeInTheDocument()
    expect(screen.getByText('Thông tin cơ sở')).toBeInTheDocument()
  })
})
