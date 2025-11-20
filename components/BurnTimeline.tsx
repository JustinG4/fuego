'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { LockClosedIcon, CheckBadgeIcon, FireIcon, ViewColumnsIcon, Bars3Icon } from '@heroicons/react/24/outline'

// Mock user data - in real app this would come from user profile/achievements
const userStats = {
  totalMilestones: 12,
  completedMilestones: 5,
  totalDistance: 127.8, // km
  totalWorkouts: 23,
  streak: 7, // days
  burnLevel: 'FLAME', // SPARK, FLAME, INFERNO, LEGEND
}

// Milestone-locked inventory items
const milestoneItems = [
  {
    id: 1,
    title: 'SPARK COLLECTION',
    subtitle: 'First Steps',
    requirement: 'Complete 5 workouts',
    isUnlocked: true,
    items: [
      { name: 'Basic Training Tee', image: '/images/basic-tee.jpg', unlocked: true },
      { name: 'Foundation Shorts', image: '/images/foundation-shorts.jpg', unlocked: true },
    ]
  },
  {
    id: 2,
    title: 'FLAME COLLECTION',
    subtitle: 'Building Momentum', 
    requirement: 'Run 50km total distance',
    isUnlocked: true,
    items: [
      { name: 'Performance Tank', image: '/images/performance-tank.jpg', unlocked: true },
      { name: 'Speed Shorts', image: '/images/speed-shorts.jpg', unlocked: true },
      { name: 'Recovery Hoodie', image: '/images/recovery-hoodie.jpg', unlocked: false },
    ]
  },
  {
    id: 3,
    title: 'INFERNO COLLECTION',
    subtitle: 'Elite Territory',
    requirement: 'Maintain 30-day streak + 100km',
    isUnlocked: false,
    items: [
      { name: 'Elite Racing Kit', image: '/images/elite-kit.jpg', unlocked: false },
      { name: 'Carbon Fiber Jacket', image: '/images/carbon-jacket.jpg', unlocked: false },
      { name: 'Victory Pants', image: '/images/victory-pants.jpg', unlocked: false },
    ]
  },
  {
    id: 4,
    title: 'LEGEND COLLECTION',
    subtitle: 'Mythical Status',
    requirement: 'Complete Marathon + 6 month streak',
    isUnlocked: false,
    items: [
      { name: 'Legendary Champion Jersey', image: '/images/legend-jersey.jpg', unlocked: false },
      { name: 'Mythical Compression Set', image: '/images/mythical-set.jpg', unlocked: false },
      { name: 'Champion Crown Cap', image: '/images/crown-cap.jpg', unlocked: false },
    ]
  }
]

const BurnTimeline = () => {
  const [isHorizontal, setIsHorizontal] = useState(false)
  const progressPercentage = (userStats.completedMilestones / userStats.totalMilestones) * 100

  return (
    <div className="pt-16 min-h-screen bg-brand-black text-white">
      {/* Hero Section */}
      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto text-center">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
          >
            <FireIcon className="w-16 h-16 text-brand-accent mx-auto mb-6" />
            <h1 className="text-6xl md:text-8xl font-light tracking-tight mb-6">
              BURN
            </h1>
            <p className="text-xl md:text-2xl text-gray-300 font-light mb-8 max-w-3xl mx-auto">
              The world's first milestone-verified commerce engine.
              <br />
              <span className="text-brand-accent">Work for what you wear.</span>
            </p>
          </motion.div>

          {/* User Stats Dashboard */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="grid grid-cols-2 lg:grid-cols-4 gap-6 max-w-4xl mx-auto mb-16"
          >
            <div className="bg-brand-gray p-6 rounded border border-brand-light-gray">
              <div className="text-3xl font-bold text-brand-accent mb-2">{userStats.totalDistance}km</div>
              <div className="text-sm text-gray-400 uppercase tracking-wide">Total Distance</div>
            </div>
            <div className="bg-brand-gray p-6 rounded border border-brand-light-gray">
              <div className="text-3xl font-bold text-brand-accent mb-2">{userStats.totalWorkouts}</div>
              <div className="text-sm text-gray-400 uppercase tracking-wide">Workouts</div>
            </div>
            <div className="bg-brand-gray p-6 rounded border border-brand-light-gray">
              <div className="text-3xl font-bold text-brand-accent mb-2">{userStats.streak}</div>
              <div className="text-sm text-gray-400 uppercase tracking-wide">Day Streak</div>
            </div>
            <div className="bg-brand-gray p-6 rounded border border-brand-light-gray">
              <div className="text-3xl font-bold text-brand-accent mb-2">{userStats.burnLevel}</div>
              <div className="text-sm text-gray-400 uppercase tracking-wide">Burn Level</div>
            </div>
          </motion.div>

          {/* Progress Bar */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.4 }}
            className="max-w-2xl mx-auto mb-16"
          >
            <div className="flex justify-between items-center mb-4">
              <span className="text-sm text-gray-400 uppercase tracking-wide">Journey Progress</span>
              <span className="text-sm text-brand-accent font-medium">{userStats.completedMilestones}/{userStats.totalMilestones} Milestones</span>
            </div>
            <div className="w-full bg-brand-light-gray h-3 rounded-full overflow-hidden">
              <motion.div 
                className="h-full bg-gradient-to-r from-brand-accent to-orange-500"
                initial={{ width: 0 }}
                animate={{ width: `${progressPercentage}%` }}
                transition={{ duration: 1.2, delay: 0.6 }}
              />
            </div>
          </motion.div>
        </div>
      </section>

      {/* Milestone Timeline */}
      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col sm:flex-row items-center justify-between mb-16">
            <motion.h2
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
              viewport={{ once: true }}
              className="text-3xl md:text-4xl font-light tracking-tight mb-6 sm:mb-0"
            >
              MILESTONE COLLECTIONS
            </motion.h2>

            {/* View Toggle */}
            <motion.div
              initial={{ opacity: 0, x: 30 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
              viewport={{ once: true }}
              className="flex items-center space-x-4"
            >
              <span className="text-sm text-gray-400 uppercase tracking-wide">View</span>
              <div className="flex items-center bg-brand-gray rounded-lg p-1">
                <button
                  onClick={() => setIsHorizontal(false)}
                  className={`p-2 rounded transition-all duration-300 ${
                    !isHorizontal ? 'bg-brand-accent text-black' : 'text-gray-400 hover:text-white'
                  }`}
                >
                  <Bars3Icon className="w-4 h-4" />
                </button>
                <button
                  onClick={() => setIsHorizontal(true)}
                  className={`p-2 rounded transition-all duration-300 ${
                    isHorizontal ? 'bg-brand-accent text-black' : 'text-gray-400 hover:text-white'
                  }`}
                >
                  <ViewColumnsIcon className="w-4 h-4" />
                </button>
              </div>
            </motion.div>
          </div>

          <div className={isHorizontal ? "grid grid-cols-1 lg:grid-cols-4 gap-8" : "space-y-24"}>
            {milestoneItems.map((milestone, index) => (
              <motion.div
                key={milestone.id}
                initial={{ opacity: 0, y: 50 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.8, delay: index * 0.1 }}
                viewport={{ once: true }}
                className="relative"
              >
                {/* Timeline Connector */}
                {!isHorizontal && index < milestoneItems.length - 1 && (
                  <div className="absolute left-1/2 transform -translate-x-1/2 top-full w-px h-24 bg-gradient-to-b from-brand-accent to-brand-light-gray"></div>
                )}
                {/* Horizontal Timeline Connector */}
                {isHorizontal && index < milestoneItems.length - 1 && (
                  <div className="absolute top-8 -right-4 w-8 h-px bg-gradient-to-r from-brand-accent to-brand-light-gray lg:block hidden"></div>
                )}

                {/* Milestone Header */}
                <div className="text-center mb-12">
                  <div className="inline-flex items-center justify-center w-16 h-16 rounded-full border-2 border-brand-accent mb-6">
                    {milestone.isUnlocked ? (
                      <CheckBadgeIcon className="w-8 h-8 text-brand-accent" />
                    ) : (
                      <LockClosedIcon className="w-8 h-8 text-gray-400" />
                    )}
                  </div>
                  <h3 className={`text-2xl md:text-3xl font-light tracking-tight mb-2 ${milestone.isUnlocked ? 'text-white' : 'text-gray-400'}`}>
                    {milestone.title}
                  </h3>
                  <p className="text-gray-400 mb-4">{milestone.subtitle}</p>
                  <div className={`inline-block px-4 py-2 rounded border text-sm font-medium uppercase tracking-wide ${
                    milestone.isUnlocked 
                      ? 'border-brand-accent text-brand-accent bg-brand-accent/10' 
                      : 'border-gray-400 text-gray-400'
                  }`}>
                    {milestone.requirement}
                  </div>
                </div>

                {/* Items Grid */}
                <div className={`grid gap-4 mx-auto ${
                  isHorizontal 
                    ? "grid-cols-1 max-w-xs" 
                    : "grid-cols-1 md:grid-cols-3 max-w-4xl gap-6"
                }`}>
                  {milestone.items.map((item, itemIndex) => (
                    <motion.div
                      key={itemIndex}
                      initial={{ opacity: 0, scale: 0.9 }}
                      whileInView={{ opacity: 1, scale: 1 }}
                      transition={{ duration: 0.6, delay: itemIndex * 0.1 }}
                      viewport={{ once: true }}
                      className={`relative group aspect-[3/4] bg-brand-gray rounded overflow-hidden ${
                        item.unlocked ? 'cursor-pointer' : ''
                      }`}
                    >
                      {/* Product Image Placeholder */}
                      <div className="absolute inset-0 bg-gradient-to-br from-gray-600 to-gray-800"></div>
                      
                      {/* Lock Overlay */}
                      {!item.unlocked && (
                        <div className="absolute inset-0 bg-black/80 flex items-center justify-center">
                          <div className="text-center">
                            <LockClosedIcon className="w-12 h-12 text-gray-400 mx-auto mb-2" />
                            <div className="text-sm text-gray-400 uppercase tracking-wide">Locked</div>
                          </div>
                        </div>
                      )}

                      {/* Earned Badge */}
                      {item.unlocked && milestone.isUnlocked && (
                        <div className="absolute top-4 right-4 bg-brand-accent text-black px-2 py-1 rounded text-xs font-bold uppercase">
                          Earned
                        </div>
                      )}

                      {/* Item Info */}
                      <div className="absolute bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-black via-black/80 to-transparent">
                        <h4 className={`font-medium text-sm mb-2 ${item.unlocked ? 'text-white' : 'text-gray-400'}`}>
                          {item.name}
                        </h4>
                        {item.unlocked && milestone.isUnlocked && (
                          <button className="text-xs text-brand-accent hover:text-white transition-colors duration-300 uppercase tracking-wide">
                            View Item →
                          </button>
                        )}
                      </div>

                      {/* Hover Effect for Unlocked Items */}
                      {item.unlocked && (
                        <div className="absolute inset-0 bg-brand-accent/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                      )}
                    </motion.div>
                  ))}
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Call to Action */}
      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <div className="max-w-3xl mx-auto text-center">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            viewport={{ once: true }}
          >
            <h3 className="text-2xl md:text-3xl font-light tracking-tight mb-6">
              Ready to Earn Your Next Unlock?
            </h3>
            <p className="text-gray-400 mb-8 text-lg">
              Every step, every workout, every milestone brings you closer to exclusive access.
              <br />This is earned commerce. This is the future.
            </p>
            <button className="btn-primary">
              START YOUR BURN JOURNEY
            </button>
          </motion.div>
        </div>
      </section>
    </div>
  )
}

export default BurnTimeline