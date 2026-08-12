import { render, screen, fireEvent } from '@testing-library/react'
import SportsTable from '@/components/owner-register/SportsTable'
import type { SportRow } from '@/types/owner-register'

const defaultRows: SportRow[] = [{ sport: 'Cầu lông', quantity: 2 }]

describe('SportsTable', () => {
  it('renders existing rows', () => {
    render(<SportsTable value={defaultRows} onChange={jest.fn()} />)
    expect(screen.getByDisplayValue('Cầu lông')).toBeInTheDocument()
    expect(screen.getByDisplayValue('2')).toBeInTheDocument()
  })

  it('calls onChange with new row when "Thêm môn" is clicked', () => {
    const onChange = jest.fn()
    render(<SportsTable value={defaultRows} onChange={onChange} />)
    fireEvent.click(screen.getByRole('button', { name: /thêm môn/i }))
    expect(onChange).toHaveBeenCalledWith(
      expect.arrayContaining([
        { sport: 'Cầu lông', quantity: 2 },
        expect.objectContaining({ quantity: 1 }),
      ])
    )
  })

  it('calls onChange without removed row when delete is clicked', () => {
    const rows: SportRow[] = [
      { sport: 'Cầu lông', quantity: 2 },
      { sport: 'Bóng đá', quantity: 1 },
    ]
    const onChange = jest.fn()
    render(<SportsTable value={rows} onChange={onChange} />)
    const deleteButtons = screen.getAllByRole('button', { name: /xóa/i })
    fireEvent.click(deleteButtons[0])
    expect(onChange).toHaveBeenCalledWith([{ sport: 'Bóng đá', quantity: 1 }])
  })

  it('does not show delete button when only 1 row', () => {
    render(<SportsTable value={defaultRows} onChange={jest.fn()} />)
    expect(screen.queryByRole('button', { name: /xóa/i })).not.toBeInTheDocument()
  })

  it('does not show "Thêm môn" when all sports are selected', () => {
    const allSports: SportRow[] = [
      'Cầu lông', 'Bóng đá', 'Bida', 'Pickleball',
      'Tennis', 'Bóng rổ', 'Bóng chuyền', 'Bơi lội',
    ].map(sport => ({ sport, quantity: 1 }))
    render(<SportsTable value={allSports} onChange={jest.fn()} />)
    expect(screen.queryByRole('button', { name: /thêm môn/i })).not.toBeInTheDocument()
  })

  it('updates quantity when input changes', () => {
    const onChange = jest.fn()
    render(<SportsTable value={defaultRows} onChange={onChange} />)
    fireEvent.change(screen.getByDisplayValue('2'), { target: { value: '5' } })
    expect(onChange).toHaveBeenCalledWith([{ sport: 'Cầu lông', quantity: 5 }])
  })
})
