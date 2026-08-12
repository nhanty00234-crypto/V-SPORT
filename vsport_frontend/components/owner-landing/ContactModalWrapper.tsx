'use client'

import { useState } from 'react'
import ContactModal from './ContactModal'

interface Props {
  children: (bag: { openContact: () => void }) => React.ReactNode
}

export default function ContactModalWrapper({ children }: Props) {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <>
      {children({ openContact: () => setIsOpen(true) })}
      <ContactModal isOpen={isOpen} onClose={() => setIsOpen(false)} />
    </>
  )
}
