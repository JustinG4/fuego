'use client';

import { Inter } from 'next/font/google';
import './globals.css';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Menu, X } from 'lucide-react';
import { useState } from 'react';

const inter = Inter({ subsets: ['latin'], weight: ['300', '400', '500', '600', '700'] });

const navigation = [
  { name: 'HOME', href: '/' },
  { name: 'MILESTONES', href: '/milestones' },
  { name: 'PRODUCTS', href: '/products' },
];

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <html lang="en">
      <body className={inter.className}>
        {/* Navigation - Fuego-inspired */}
        <nav className="fixed top-0 w-full z-50 bg-brand-black/90 backdrop-blur-sm border-b border-brand-border">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center h-16">
              {/* Left Navigation - Desktop */}
              <div className="hidden md:flex items-center space-x-8">
                {navigation.slice(0, 2).map((item) => (
                  <Link
                    key={item.name}
                    href={item.href}
                    className={`text-sm font-medium tracking-wide transition-colors duration-300 ${
                      pathname === item.href
                        ? 'text-primary-400'
                        : 'text-white hover:text-primary-400'
                    }`}
                  >
                    {item.name}
                  </Link>
                ))}
              </div>

              {/* Center Logo */}
              <Link
                href="/"
                className="absolute left-1/2 transform -translate-x-1/2 text-xl font-light tracking-tight text-white"
              >
                UnlockEngine
              </Link>

              {/* Right Navigation - Desktop */}
              <div className="hidden md:flex items-center space-x-8">
                {navigation.slice(2).map((item) => (
                  <Link
                    key={item.name}
                    href={item.href}
                    className={`text-sm font-medium tracking-wide transition-colors duration-300 ${
                      pathname === item.href
                        ? 'text-primary-400'
                        : 'text-white hover:text-primary-400'
                    }`}
                  >
                    {item.name}
                  </Link>
                ))}
              </div>

              {/* Mobile menu button */}
              <div className="md:hidden">
                <button
                  onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                  className="text-white p-2"
                >
                  {mobileMenuOpen ? (
                    <X className="h-6 w-6" />
                  ) : (
                    <Menu className="h-6 w-6" />
                  )}
                </button>
              </div>
            </div>
          </div>

          {/* Mobile menu */}
          {mobileMenuOpen && (
            <div className="md:hidden bg-brand-dark border-t border-brand-border">
              <div className="px-4 pt-2 pb-3 space-y-1">
                {navigation.map((item) => (
                  <Link
                    key={item.name}
                    href={item.href}
                    className={`block px-3 py-2 text-sm font-medium tracking-wide transition-colors ${
                      pathname === item.href
                        ? 'text-primary-400'
                        : 'text-white hover:text-primary-400'
                    }`}
                    onClick={() => setMobileMenuOpen(false)}
                  >
                    {item.name}
                  </Link>
                ))}
              </div>
            </div>
          )}
        </nav>

        {/* Main content with top padding to account for fixed nav */}
        <main className="pt-16">{children}</main>
      </body>
    </html>
  );
}
