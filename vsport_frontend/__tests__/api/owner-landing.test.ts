import { getOwnerStats } from '@/lib/api/owner-landing'

const mockFetch = jest.fn()

beforeAll(() => { global.fetch = mockFetch })
afterEach(() => mockFetch.mockReset())

describe('getOwnerStats', () => {
  it('maps API response to OwnerStats', async () => {
    mockFetch.mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({
        totalFacilities: 120,
        totalCourts: 500,
        totalBookings: 50000,
        totalCustomers: 15000,
      }),
    })

    const result = await getOwnerStats()
    expect(result).toEqual({
      totalFacilities: 120,
      totalCourts: 500,
      totalBookings: 50000,
      totalCustomers: 15000,
    })
  })

  it('returns null when fetch throws', async () => {
    mockFetch.mockRejectedValue(new Error('Network error'))
    expect(await getOwnerStats()).toBeNull()
  })

  it('returns null when response is not ok', async () => {
    mockFetch.mockResolvedValue({ ok: false })
    expect(await getOwnerStats()).toBeNull()
  })

  it('falls back to 0 for missing fields', async () => {
    mockFetch.mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({}),
    })

    const result = await getOwnerStats()
    expect(result).toEqual({
      totalFacilities: 0,
      totalCourts: 0,
      totalBookings: 0,
      totalCustomers: 0,
    })
  })
})
