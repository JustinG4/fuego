'use client'

import { useState } from 'react'
import Link from 'next/link'
import Image from 'next/image'
import { MagnifyingGlassIcon, ShoppingBagIcon, Bars3Icon, XMarkIcon } from '@heroicons/react/24/outline'
import { useCart } from '../hooks/useCart'
import CartSidebar from './CartSidebar'

const Navigation = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false)
  const { getCartCount, toggleCart } = useCart()

  const navigationItems = [
    { name: 'SHOP', href: '/shop' },
    { name: 'ABOUT', href: '/about' },
    { name: 'BURN', href: '/burn' },
  ]

  return (
    <nav className="fixed top-0 w-full z-50 bg-transparent">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-20">
          {/* Left Navigation */}
          <div className="hidden md:flex items-center space-x-8">
            {navigationItems.map((item) => (
              <Link
                key={item.name}
                href={item.href}
                className="text-white text-sm font-medium tracking-wide hover:text-brand-accent transition-colors duration-300 cursor-pointer"
              >
                {item.name}
              </Link>
            ))}
          </div>

          {/* Logo - Positioned to span 50/50 across background split */}
          <div className="absolute left-1/2 top-1/2 transform -translate-x-1/2 -translate-y-1/2 z-50">
            <Link href="/">
              <Image
                src="/center_logo.png"
                alt="Brand Logo"
                width={64}
                height={64}
                className="object-contain drop-shadow-lg"
                priority
              />
            </Link>
          </div>

          {/* Right Navigation */}
          <div className="hidden md:flex items-center space-x-6">
            <Link href="/account" className="text-white text-sm font-medium tracking-wide hover:text-brand-accent transition-colors duration-300">
              ACCOUNT
            </Link>
            <button className="text-white hover:text-brand-accent transition-colors duration-300">
              <MagnifyingGlassIcon className="h-5 w-5" />
            </button>
            <button 
              onClick={toggleCart}
              className="text-white hover:text-brand-accent transition-colors duration-300 relative"
            >
              <ShoppingBagIcon className="h-5 w-5" />
              {getCartCount() > 0 && (
                <span className="absolute -top-2 -right-2 bg-brand-accent text-black text-xs rounded-full h-4 w-4 flex items-center justify-center font-medium">
                  {getCartCount()}
                </span>
              )}
            </button>
          </div>

          {/* Mobile menu button */}
          <div className="md:hidden">
            <button
              onClick={() => setIsMenuOpen(!isMenuOpen)}
              className="text-white hover:text-brand-accent transition-colors duration-300"
            >
              {isMenuOpen ? (
                <XMarkIcon className="h-6 w-6" />
              ) : (
                <Bars3Icon className="h-6 w-6" />
              )}
            </button>
          </div>
        </div>

        {/* Mobile menu */}
        {isMenuOpen && (
          <div className="md:hidden">
            <div className="px-2 pt-2 pb-3 space-y-1 bg-brand-gray">
              {navigationItems.map((item) => (
                <Link
                  key={item.name}
                  href={item.href}
                  className="block px-3 py-2 text-white text-sm font-medium tracking-wide hover:text-brand-accent transition-colors duration-300"
                  onClick={() => setIsMenuOpen(false)}
                >
                  {item.name}
                </Link>
              ))}
              <div className="border-t border-brand-light-gray pt-3">
                <Link
                  href="/account"
                  className="block px-3 py-2 text-white text-sm font-medium tracking-wide hover:text-brand-accent transition-colors duration-300"
                  onClick={() => setIsMenuOpen(false)}
                >
                  ACCOUNT
                </Link>
                <button
                  onClick={() => {
                    toggleCart()
                    setIsMenuOpen(false)
                  }}
                  className="block px-3 py-2 text-white text-sm font-medium tracking-wide hover:text-brand-accent transition-colors duration-300 text-left w-full"
                >
                  CART
                </button>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Cart Sidebar */}
      <CartSidebar />
    </nav>
  )
}

export default Navigation