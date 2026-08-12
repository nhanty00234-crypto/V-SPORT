'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import RegisterHeader from './RegisterHeader'
import Step1EmailPhone from './Step1EmailPhone'
import Step2OTP from './Step2OTP'
import Step3Details from './Step3Details'

export default function OwnerRegisterClient() {
  const router = useRouter()
  const [step, setStep] = useState<1 | 2 | 3>(1)
  const [email, setEmail] = useState('')
  const [phone, setPhone] = useState('')

  const handleStep1Success = (em: string, ph: string) => {
    setEmail(em)
    setPhone(ph)
    setStep(2)
  }

  return (
    <>
      <RegisterHeader currentStep={step} />
      {step === 1 && <Step1EmailPhone onSuccess={handleStep1Success} />}
      {step === 2 && (
        <Step2OTP
          email={email}
          phone={phone}
          onSuccess={() => setStep(3)}
          onBack={() => setStep(1)}
        />
      )}
      {step === 3 && (
        <Step3Details
          email={email}
          phone={phone}
          onSuccess={() => router.push('/owner-register/success')}
        />
      )}
    </>
  )
}
