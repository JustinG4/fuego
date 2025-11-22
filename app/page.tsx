import Navigation from '@/components/Navigation'
import HeroSection from '@/components/HeroSection'
import ExtraSection from '@/components/ExtraSection'
import CategoryGrid from '@/components/CategoryGrid'

export default function Home() {
  return (
    <main className="min-h-screen bg-brand-black">
      <Navigation />
      <HeroSection />
      <ExtraSection />
      <CategoryGrid />
    </main>
  )
}