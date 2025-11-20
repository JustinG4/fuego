'use client'

import { motion } from 'framer-motion'
import Image from 'next/image'
import { ArrowRightIcon, LightBulbIcon, TrophyIcon, RocketLaunchIcon } from '@heroicons/react/24/outline'

const AboutHero = () => {
  return (
    <div className="pt-16 min-h-screen bg-brand-black text-white">
      {/* Hero Section with Image Spot */}
      <section className="relative min-h-screen flex items-center">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
          {/* Left Content */}
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8 }}
            className="lg:order-1 order-2"
          >
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.2 }}
            >
              <h1 className="text-5xl md:text-7xl font-light tracking-tight mb-8 leading-tight">
                Work. Win.
                <br />
                <span className="text-red-500">Wear</span>
              </h1>
              
              <p className="text-xl md:text-2xl text-gray-300 font-light mb-8 leading-relaxed">
                We're building the world's first milestone-verified commerce engine—software that lets any brand gate exclusive drops behind real-world achievements.
              </p>

              <p className="text-lg text-gray-400 mb-12 leading-relaxed">
                This transforms physical effort, engagement, and lifestyle milestones into unlockable access, creating a new category of <strong className="text-white">"earned commerce"</strong> that makes customers work—not just spend—for what they wear.
              </p>

              <motion.button
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.8, delay: 0.4 }}
                className="group inline-flex items-center btn-primary"
              >
                Start Your Journey
                <ArrowRightIcon className="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform duration-300" />
              </motion.button>
            </motion.div>
          </motion.div>

          {/* Right Image Spot */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8, delay: 0.3 }}
            className="lg:order-2 order-1"
          >
            <div className="relative">
              {/* Cool Geometric Background */}
              <div className="absolute inset-0 bg-gradient-to-br from-brand-accent/20 via-purple-500/10 to-orange-500/20 rounded-2xl transform rotate-6"></div>
              <div className="absolute inset-0 bg-gradient-to-tl from-blue-500/10 via-brand-accent/5 to-pink-500/10 rounded-2xl transform -rotate-3"></div>
              
              {/* Main Image Container */}
              <div className="relative bg-brand-gray rounded-2xl aspect-[4/5] overflow-hidden border border-brand-light-gray">
                {/* Placeholder for Hero Image */}
                <div className="absolute inset-0 bg-gradient-to-br from-slate-600 via-gray-700 to-brand-black flex items-center justify-center">
                  <div className="text-center">
                    <RocketLaunchIcon className="w-24 h-24 text-brand-accent mx-auto mb-4 opacity-50" />
                    <div className="text-gray-400 text-lg font-light">
                      Hero Image Spot
                      <div className="text-sm text-gray-500 mt-2">1200 × 1500px</div>
                    </div>
                  </div>
                </div>

                {/* Floating Achievement Badge */}
                <div className="absolute top-6 right-6 bg-brand-accent text-black px-4 py-2 rounded-full text-sm font-bold uppercase tracking-wide">
                  Earned
                </div>

                {/* Bottom Stats Overlay */}
                <div className="absolute bottom-6 left-6 right-6 bg-black/60 backdrop-blur-sm rounded-lg p-4">
                  <div className="grid grid-cols-3 gap-4 text-center">
                    <div>
                      <div className="text-lg font-bold text-brand-accent">127</div>
                      <div className="text-xs text-gray-300 uppercase">KM Run</div>
                    </div>
                    <div>
                      <div className="text-lg font-bold text-brand-accent">23</div>
                      <div className="text-xs text-gray-300 uppercase">Workouts</div>
                    </div>
                    <div>
                      <div className="text-lg font-bold text-brand-accent">7</div>
                      <div className="text-xs text-gray-300 uppercase">Day Streak</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </section>

      {/* Philosophy Section */}
      <section className="py-24 px-4 sm:px-6 lg:px-8">
        <div className="max-w-6xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 50 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            viewport={{ once: true }}
            className="text-center mb-16"
          >
            <h2 className="text-4xl md:text-5xl font-light tracking-tight mb-8">
              The Philosophy
            </h2>
            <p className="text-xl text-gray-300 max-w-3xl mx-auto leading-relaxed">
              Fashion should represent achievement, not just purchasing power. When you earn something through effort, it carries deeper meaning than anything money alone can buy.
            </p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-12">
            {/* Principle 1 */}
            <motion.div
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.1 }}
              viewport={{ once: true }}
              className="text-center"
            >
              <div className="w-16 h-16 bg-brand-accent/10 rounded-full flex items-center justify-center mx-auto mb-6">
                <TrophyIcon className="w-8 h-8 text-brand-accent" />
              </div>
              <h3 className="text-xl font-medium mb-4">Achievement Over Access</h3>
              <p className="text-gray-400 leading-relaxed">
                True value comes from what you've accomplished, not what you can afford. Each piece tells a story of dedication and progress.
              </p>
            </motion.div>

            {/* Principle 2 */}
            <motion.div
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
              viewport={{ once: true }}
              className="text-center"
            >
              <div className="w-16 h-16 bg-brand-accent/10 rounded-full flex items-center justify-center mx-auto mb-6">
                <LightBulbIcon className="w-8 h-8 text-brand-accent" />
              </div>
              <h3 className="text-xl font-medium mb-4">Innovation Through Restriction</h3>
              <p className="text-gray-400 leading-relaxed">
                By making access scarce and earned, we create deeper appreciation and stronger community bonds around shared achievements.
              </p>
            </motion.div>

            {/* Principle 3 */}
            <motion.div
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.3 }}
              viewport={{ once: true }}
              className="text-center"
            >
              <div className="w-16 h-16 bg-brand-accent/10 rounded-full flex items-center justify-center mx-auto mb-6">
                <RocketLaunchIcon className="w-8 h-8 text-brand-accent" />
              </div>
              <h3 className="text-xl font-medium mb-4">The Future of Fashion</h3>
              <p className="text-gray-400 leading-relaxed">
                We're not just selling clothes—we're building a platform where brands can reward real-world engagement with exclusive access.
              </p>
            </motion.div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-24 px-4 sm:px-6 lg:px-8 bg-brand-gray">
        <div className="max-w-4xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 50 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            viewport={{ once: true }}
            className="text-center mb-16"
          >
            <h2 className="text-4xl font-light tracking-tight mb-8">
              Redefining Value
            </h2>
            <p className="text-xl text-gray-300">
              When customers work for access, they value it more deeply
            </p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.6, delay: 0.1 }}
              viewport={{ once: true }}
              className="text-center p-6 bg-brand-black rounded-lg border border-brand-light-gray"
            >
              <div className="text-3xl font-bold text-brand-accent mb-2">90%</div>
              <div className="text-sm text-gray-400 uppercase tracking-wide">Higher Retention</div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.6, delay: 0.2 }}
              viewport={{ once: true }}
              className="text-center p-6 bg-brand-black rounded-lg border border-brand-light-gray"
            >
              <div className="text-3xl font-bold text-brand-accent mb-2">3x</div>
              <div className="text-sm text-gray-400 uppercase tracking-wide">Brand Loyalty</div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.6, delay: 0.3 }}
              viewport={{ once: true }}
              className="text-center p-6 bg-brand-black rounded-lg border border-brand-light-gray"
            >
              <div className="text-3xl font-bold text-brand-accent mb-2">5x</div>
              <div className="text-sm text-gray-400 uppercase tracking-wide">Engagement</div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.6, delay: 0.4 }}
              viewport={{ once: true }}
              className="text-center p-6 bg-brand-black rounded-lg border border-brand-light-gray"
            >
              <div className="text-3xl font-bold text-brand-accent mb-2">∞</div>
              <div className="text-sm text-gray-400 uppercase tracking-wide">Possibilities</div>
            </motion.div>
          </div>
        </div>
      </section>
    </div>
  )
}

export default AboutHero