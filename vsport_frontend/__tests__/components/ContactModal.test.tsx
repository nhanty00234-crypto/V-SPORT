import { render, screen, fireEvent } from '@testing-library/react'
import ContactModal from '@/components/owner-landing/ContactModal'

describe('ContactModal', () => {
  it('is not visible when isOpen is false', () => {
    render(<ContactModal isOpen={false} onClose={() => {}} />)
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
  })

  it('is visible when isOpen is true', () => {
    render(<ContactModal isOpen={true} onClose={() => {}} />)
    expect(screen.getByRole('dialog')).toBeInTheDocument()
  })

  it('shows contact email', () => {
    render(<ContactModal isOpen={true} onClose={() => {}} />)
    expect(screen.getByText(/support@vsport\.vn/i)).toBeInTheDocument()
  })

  it('calls onClose when backdrop is clicked', () => {
    const mock = jest.fn()
    render(<ContactModal isOpen={true} onClose={mock} />)
    fireEvent.click(screen.getByTestId('modal-backdrop'))
    expect(mock).toHaveBeenCalledTimes(1)
  })

  it('calls onClose when close button is clicked', () => {
    const mock = jest.fn()
    render(<ContactModal isOpen={true} onClose={mock} />)
    fireEvent.click(screen.getByRole('button', { name: /đóng/i }))
    expect(mock).toHaveBeenCalledTimes(1)
  })
})
