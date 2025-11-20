import Navigation from '@/components/Navigation'
import BurnTimeline from '@/components/BurnTimeline'

export const metadata = {
  title: 'BURN - Milestone Verified Commerce | Earn Your Access',
  description: 'Transform physical effort into unlockable access. The world\'s first milestone-verified commerce engine where you work for what you wear.',
}

export default function BurnPage() {
  return (
    <main className="min-h-screen bg-brand-black">
      <Navigation />
      <BurnTimeline />
    </main>
  )
}