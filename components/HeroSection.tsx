'use client'

import { motion } from 'framer-motion'
import Link from 'next/link'
import Image from 'next/image'

const HeroSection = () => {
  return (
    <section className="relative h-screen flex">
      {/* Left Side - Fire Background with Content */}
      <motion.div 
        initial={{ opacity: 0, x: -50 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ duration: 0.8 }}
        className="w-1/2 relative overflow-hidden"
      >
        {/* Kettlebell Background */}
        <div className="absolute inset-0">
          <Image
            src="/kettlebell.jpg"
            alt="Kettlebell Background"
            fill
            className="object-cover"
            priority
            quality={100}
          />
          {/* Dark overlay for text readability */}
          <div className="absolute inset-0 bg-black/40"></div>
        </div>
        
        {/* Left Side Content */}
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="text-center z-10 px-8">
            <motion.h1 
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.2 }}
              className="text-4xl md:text-6xl font-light text-white mb-6 tracking-tight leading-tight"
            >
              You can't <em>Drip</em> without <em>Sweat</em>.
            </motion.h1>
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.4 }}
            >
              <Link href="/shop" className="btn-primary">
                SHOP THE COLLECTION
              </Link>
            </motion.div>
          </div>
        </div>
      </motion.div>

      {/* Right Side - Right Background Image */}
      <motion.div 
        initial={{ opacity: 0, x: 50 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ duration: 0.8, delay: 0.3 }}
        className="w-1/2 relative overflow-hidden"
      >
        {/* Right Background */}
        <div className="absolute inset-0">
          <Image
            src="/right_bg.jpg"
            alt="Right Background"
            fill
            className="object-cover"
            priority
            quality={100}
          />
          {/* Subtle overlay for visual continuity */}
          <div className="absolute inset-0 bg-gradient-to-l from-black/20 to-transparent"></div>
        </div>
      </motion.div>
    </section>
  )
}

export default HeroSection