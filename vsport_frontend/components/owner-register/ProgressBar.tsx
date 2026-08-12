interface Props {
  currentStep: 1 | 2 | 3
}

const STEPS = [
  { num: 1, label: 'Xác thực email' },
  { num: 2, label: 'Mã xác nhận' },
  { num: 3, label: 'Thông tin cơ sở' },
]

export default function ProgressBar({ currentStep }: Props) {
  return (
    <nav aria-label="Các bước đăng ký" className="bg-white">
      <ol className="max-w-2xl mx-auto px-4 py-4 flex items-center">
        {STEPS.map((step, i) => {
          const isActive = step.num === currentStep
          const isDone = step.num < currentStep
          return (
            <li
              key={step.num}
              aria-current={isActive ? 'step' : undefined}
              className="flex items-center flex-1"
            >
              <div className="flex flex-col items-center gap-1 flex-1">
                <span
                  className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold transition-colors ${
                    isDone
                      ? 'bg-vs-blue text-white'
                      : isActive
                      ? 'bg-vs-navy text-white ring-4 ring-vs-navy/20'
                      : 'bg-slate-100 text-vs-slate'
                  }`}
                >
                  {isDone ? '✓' : step.num}
                </span>
                <span
                  className={`text-xs font-medium ${
                    isActive ? 'text-vs-navy' : isDone ? 'text-vs-blue' : 'text-vs-slate'
                  }`}
                >
                  {step.label}
                </span>
              </div>
              {i < STEPS.length - 1 && (
                <div
                  className={`h-0.5 flex-1 mx-2 -mt-4 transition-colors ${
                    step.num < currentStep ? 'bg-vs-blue' : 'bg-slate-200'
                  }`}
                />
              )}
            </li>
          )
        })}
      </ol>
    </nav>
  )
}
