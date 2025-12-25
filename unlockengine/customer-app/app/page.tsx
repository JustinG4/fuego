'use client';

import Link from 'next/link';
import { motion } from 'framer-motion';
import { Trophy, Package, Target, Flame, ArrowRight } from 'lucide-react';

export default function HomePage() {
  return (
    <div className="min-h-screen">
      {/* Hero Section - Fuego-inspired split screen */}
      <section className="h-screen flex flex-col md:flex-row">
        {/* Left Side */}
        <div className="w-full md:w-1/2 relative bg-gradient-to-br from-primary-600 to-primary-700 flex items-center justify-center">
          <div className="absolute inset-0 bg-black/20"></div>
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8 }}
            className="relative z-10 text-center px-8"
          >
            <h1 className="text-5xl md:text-7xl font-light text-white mb-6 tracking-tight leading-tight">
              Earn Your <em className="font-normal">Rewards</em>
            </h1>
            <p className="text-lg md:text-xl text-white/90 mb-8 font-light max-w-md mx-auto">
              Complete milestones. Unlock products. Achieve greatness.
            </p>
            <Link href="/milestones">
              <button className="btn-primary">
                View Milestones
              </button>
            </Link>
          </motion.div>
        </div>

        {/* Right Side */}
        <div className="w-full md:w-1/2 relative bg-gradient-to-br from-secondary-600 to-secondary-700 flex items-center justify-center">
          <div className="absolute inset-0 bg-gradient-to-l from-black/20 to-transparent"></div>
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8, delay: 0.3 }}
            className="relative z-10 text-center px-8"
          >
            <h2 className="text-4xl md:text-6xl font-light text-white mb-6 tracking-tight">
              Milestone-Driven <em className="font-normal">Commerce</em>
            </h2>
            <Link href="/products">
              <button className="btn-secondary">
                Browse Products
              </button>
            </Link>
          </motion.div>
        </div>
      </section>

      {/* How It Works */}
      <section className="section bg-brand-dark">
        <div className="container-custom">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8 }}
            className="text-center mb-16"
          >
            <h2 className="text-4xl md:text-5xl font-light text-white mb-4 tracking-tight">
              How It Works
            </h2>
            <p className="text-xl text-gray-400 font-light max-w-2xl mx-auto">
              Three simple steps to unlock exclusive products
            </p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {[
              {
                icon: <Target className="w-12 h-12" />,
                title: "Choose Your Goal",
                description: "Browse milestones and pick challenges that inspire you."
              },
              {
                icon: <Flame className="w-12 h-12" />,
                title: "Track Progress",
                description: "Your fitness data syncs automatically."
              },
              {
                icon: <Package className="w-12 h-12" />,
                title: "Unlock & Shop",
                description: "Complete milestones to unlock exclusive products."
              }
            ].map((step, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: index * 0.1 }}
                className="text-center"
              >
                <div className="inline-flex p-4 mb-6 text-primary-400">
                  {step.icon}
                </div>
                <h3 className="text-xl font-medium text-white mb-3 tracking-wide uppercase text-sm">
                  {step.title}
                </h3>
                <p className="text-gray-400 font-light">
                  {step.description}
                </p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Achievement Tiers */}
      <section className="section bg-brand-black">
        <div className="container-custom">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8 }}
            className="text-center mb-16"
          >
            <h2 className="text-4xl md:text-5xl font-light text-white mb-4 tracking-tight">
              Achievement Tiers
            </h2>
            <p className="text-xl text-gray-400 font-light max-w-2xl mx-auto">
              Progress through tiers and unlock premium products
            </p>
          </motion.div>

          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
            {[
              { name: "SPARK", gradient: "tier-spark", count: 3 },
              { name: "FLAME", gradient: "tier-flame", count: 4 },
              { name: "INFERNO", gradient: "tier-inferno", count: 3 },
              { name: "LEGEND", gradient: "tier-legend", count: 2 }
            ].map((tier, index) => (
              <motion.div
                key={tier.name}
                initial={{ opacity: 0, scale: 0.9 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: index * 0.1 }}
                className="group"
              >
                <div className="relative aspect-[3/4] overflow-hidden bg-brand-dark rounded-lg">
                  <div className={`absolute inset-0 bg-gradient-to-br ${tier.gradient} opacity-90 group-hover:opacity-100 transition-opacity duration-300`}></div>
                  <div className="absolute inset-0 bg-black/20 group-hover:bg-black/40 transition-all duration-300"></div>
                  <div className="absolute bottom-6 left-6 right-6">
                    <h3 className="text-2xl font-light text-white mb-2 tracking-wide">
                      {tier.name}
                    </h3>
                    <p className="text-sm text-white/80 font-medium uppercase tracking-wide">
                      {tier.count} Milestones
                    </p>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="section bg-primary-600">
        <div className="container-custom">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8 }}
            className="text-center"
          >
            <h2 className="text-4xl md:text-5xl font-light text-white mb-6 tracking-tight">
              Ready to Start Your Journey?
            </h2>
            <p className="text-xl text-white/90 mb-8 font-light max-w-2xl mx-auto">
              Join thousands of athletes earning their rewards through achievement
            </p>
            <Link href="/milestones">
              <button className="px-8 py-3 bg-white text-primary-600 font-medium uppercase tracking-wide text-sm hover:bg-gray-100 transition-all duration-300 inline-flex items-center gap-2">
                View All Milestones
                <ArrowRight className="w-4 h-4" />
              </button>
            </Link>
          </motion.div>
        </div>
      </section>
    </div>
  );
}
