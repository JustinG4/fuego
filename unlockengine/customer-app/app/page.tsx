'use client';

import Link from 'next/link';
import { Trophy, Package, Zap, ArrowRight, Target, Flame } from 'lucide-react';

export default function HomePage() {
  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="relative overflow-hidden bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-600 text-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
          <div className="text-center max-w-3xl mx-auto">
            <div className="inline-flex items-center gap-2 px-4 py-2 bg-white/10 backdrop-blur-sm rounded-full mb-6">
              <Zap className="w-4 h-4" />
              <span className="text-sm font-semibold">Milestone-Driven Commerce</span>
            </div>
            <h1 className="text-6xl font-bold mb-6 leading-tight">
              Earn Your Rewards
            </h1>
            <p className="text-xl text-white/90 mb-8">
              Complete fitness milestones, unlock exclusive products, and achieve greatness.
              Your achievements deserve to be rewarded.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link
                href="/milestones"
                className="inline-flex items-center justify-center px-8 py-4 bg-white text-indigo-600 rounded-lg font-semibold hover:bg-gray-100 transition-all shadow-lg hover:shadow-xl"
              >
                View Milestones
                <ArrowRight className="w-5 h-5 ml-2" />
              </Link>
              <Link
                href="/products"
                className="inline-flex items-center justify-center px-8 py-4 bg-white/10 backdrop-blur-sm text-white rounded-lg font-semibold hover:bg-white/20 transition-all border border-white/20"
              >
                Browse Products
              </Link>
            </div>
          </div>
        </div>
        {/* Background decoration */}
        <div className="absolute top-0 right-0 w-96 h-96 bg-white/5 rounded-full blur-3xl"></div>
        <div className="absolute bottom-0 left-0 w-96 h-96 bg-white/5 rounded-full blur-3xl"></div>
      </section>

      {/* How It Works */}
      <section className="py-20 bg-white dark:bg-gray-800">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 dark:text-white mb-4">
              How It Works
            </h2>
            <p className="text-xl text-gray-600 dark:text-gray-400">
              Three simple steps to unlock exclusive products
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-12">
            <div className="text-center">
              <div className="inline-flex p-4 bg-gradient-to-br from-blue-500 to-blue-600 rounded-2xl mb-6">
                <Target className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-3">
                1. Choose Your Goal
              </h3>
              <p className="text-gray-600 dark:text-gray-400">
                Browse milestones and pick challenges that inspire you. From beginner to elite tiers.
              </p>
            </div>

            <div className="text-center">
              <div className="inline-flex p-4 bg-gradient-to-br from-purple-500 to-purple-600 rounded-2xl mb-6">
                <Flame className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-3">
                2. Track Progress
              </h3>
              <p className="text-gray-600 dark:text-gray-400">
                Your fitness data syncs automatically. Watch as you get closer to unlocking rewards.
              </p>
            </div>

            <div className="text-center">
              <div className="inline-flex p-4 bg-gradient-to-br from-pink-500 to-pink-600 rounded-2xl mb-6">
                <Package className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-3">
                3. Unlock & Shop
              </h3>
              <p className="text-gray-600 dark:text-gray-400">
                Complete milestones to unlock exclusive, limited-edition products you've earned.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Featured Tiers */}
      <section className="py-20 bg-gray-50 dark:bg-gray-900">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 dark:text-white mb-4">
              Achievement Tiers
            </h2>
            <p className="text-xl text-gray-600 dark:text-gray-400">
              Progress through tiers and unlock premium products
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            <TierCard
              name="SPARK"
              color="from-orange-400 to-orange-600"
              level="Beginner"
              milestones={3}
            />
            <TierCard
              name="FLAME"
              color="from-red-500 to-red-600"
              level="Intermediate"
              milestones={4}
            />
            <TierCard
              name="INFERNO"
              color="from-red-600 to-red-800"
              level="Advanced"
              milestones={3}
            />
            <TierCard
              name="LEGEND"
              color="from-purple-600 to-purple-800"
              level="Elite"
              milestones={2}
            />
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-20 bg-gradient-to-r from-indigo-600 to-purple-600 text-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-4xl font-bold mb-6">
            Ready to Start Your Journey?
          </h2>
          <p className="text-xl mb-8 text-white/90">
            Join thousands of athletes earning their rewards
          </p>
          <Link
            href="/milestones"
            className="inline-flex items-center px-8 py-4 bg-white text-indigo-600 rounded-lg font-semibold hover:bg-gray-100 transition-all shadow-lg"
          >
            View All Milestones
            <ArrowRight className="w-5 h-5 ml-2" />
          </Link>
        </div>
      </section>
    </div>
  );
}

function TierCard({
  name,
  color,
  level,
  milestones,
}: {
  name: string;
  color: string;
  level: string;
  milestones: number;
}) {
  return (
    <div className="bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden hover:shadow-xl transition-all group">
      <div className={`h-32 bg-gradient-to-br ${color} flex items-center justify-center`}>
        <Trophy className="w-16 h-16 text-white" />
      </div>
      <div className="p-6">
        <h3 className="text-2xl font-bold text-gray-900 dark:text-white mb-1">
          {name}
        </h3>
        <p className="text-gray-600 dark:text-gray-400 mb-4">{level}</p>
        <p className="text-sm text-gray-500 dark:text-gray-500">
          {milestones} Milestones
        </p>
      </div>
    </div>
  );
}
