'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  Home,
  Trophy,
  Package,
  Activity,
  Settings,
  Menu,
  X,
  Sparkles,
} from 'lucide-react';
import { useState } from 'react';

const navigation = [
  { name: 'Dashboard', href: '/', icon: Home },
  { name: 'Milestones', href: '/milestones', icon: Trophy },
  { name: 'Products', href: '/products', icon: Package },
  { name: 'Metrics', href: '/metrics', icon: Activity },
  { name: 'Settings', href: '/settings', icon: Settings },
];

export function Navigation() {
  const pathname = usePathname();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <nav className="bg-brand-dark border-b border-brand-border backdrop-blur-lg sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-16">
          <div className="flex">
            <div className="flex-shrink-0 flex items-center">
              <Link href="/" className="flex items-center gap-2 group">
                <div className="w-8 h-8 bg-gradient-brand rounded-lg flex items-center justify-center group-hover:scale-110 transition-transform">
                  <Sparkles className="w-5 h-5 text-white" />
                </div>
                <span className="text-2xl font-bold text-gradient">
                  UnlockEngine
                </span>
                <span className="px-2 py-0.5 text-xs font-bold bg-primary-500/20 text-primary-300 rounded border border-primary-500/30">
                  Admin
                </span>
              </Link>
            </div>
            <div className="hidden sm:ml-10 sm:flex sm:space-x-2">
              {navigation.map((item) => {
                const isActive = pathname === item.href;
                const Icon = item.icon;
                return (
                  <Link
                    key={item.name}
                    href={item.href}
                    className={`inline-flex items-center px-4 py-2 rounded-lg text-sm font-semibold transition-all ${
                      isActive
                        ? 'bg-gradient-brand text-white shadow-lg shadow-primary-500/30'
                        : 'text-white/60 hover:text-white hover:bg-brand-surface'
                    }`}
                  >
                    <Icon className="w-4 h-4 mr-2" />
                    {item.name}
                  </Link>
                );
              })}
            </div>
          </div>
          <div className="flex items-center sm:hidden">
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="inline-flex items-center justify-center p-2 rounded-lg text-white/60 hover:text-white hover:bg-brand-surface transition-all"
            >
              {mobileMenuOpen ? (
                <X className="block h-6 w-6" />
              ) : (
                <Menu className="block h-6 w-6" />
              )}
            </button>
          </div>
        </div>
      </div>

      {mobileMenuOpen && (
        <div className="sm:hidden border-t border-brand-border bg-brand-surface">
          <div className="pt-2 pb-3 space-y-1 px-4">
            {navigation.map((item) => {
              const isActive = pathname === item.href;
              const Icon = item.icon;
              return (
                <Link
                  key={item.name}
                  href={item.href}
                  className={`flex items-center px-4 py-3 rounded-lg text-base font-semibold transition-all ${
                    isActive
                      ? 'bg-gradient-brand text-white shadow-lg'
                      : 'text-white/60 hover:text-white hover:bg-brand-dark'
                  }`}
                  onClick={() => setMobileMenuOpen(false)}
                >
                  <Icon className="w-5 h-5 mr-3" />
                  {item.name}
                </Link>
              );
            })}
          </div>
        </div>
      )}
    </nav>
  );
}
