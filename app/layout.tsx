import './globals.css'
import type { Metadata } from 'next'
import { CartProvider } from '../hooks/useCart'

export const metadata: Metadata = {
  title: 'FUEGO - Earned Commerce Fashion',
  description: 'The world\'s first milestone-verified commerce engine. Work for what you wear.',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>
        <CartProvider>
          {children}
        </CartProvider>
      </body>
    </html>
  )
}