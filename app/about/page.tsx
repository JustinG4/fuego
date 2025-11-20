import Navigation from '@/components/Navigation'
import AboutHero from '@/components/AboutHero'

export const metadata = {
  title: 'About - Milestone Verified Commerce | The Future of Fashion',
  description: 'Discover the revolutionary concept behind earned commerce - where physical effort unlocks exclusive access to premium fashion collections.',
}

export default function AboutPage() {
  return (
    <main className="min-h-screen bg-brand-black">
      <Navigation />
      <AboutHero />
    </main>
  )
}