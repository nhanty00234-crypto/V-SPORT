import { render, screen } from '@testing-library/react'

jest.mock('@/components/owner-register/RegisterHeader', () => ({
  __esModule: true,
  default: () => <div />,
}))

import SuccessPageClient from '@/components/owner-register/SuccessPageClient'

describe('SuccessPageClient', () => {
  it('shows success heading', () => {
    render(<SuccessPageClient />)
    expect(screen.getByRole('heading', { name: /đăng ký thành công/i })).toBeInTheDocument()
  })

  it('mentions admin review process', () => {
    render(<SuccessPageClient />)
    expect(screen.getByText(/1-3 ngày/i)).toBeInTheDocument()
  })

  it('has a link back to /owner', () => {
    render(<SuccessPageClient />)
    const link = screen.getByRole('link', { name: /về trang chủ/i })
    expect(link).toHaveAttribute('href', '/owner')
  })
})
