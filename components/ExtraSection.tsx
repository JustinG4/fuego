'use client'

import { motion } from 'framer-motion'
import { PlayIcon } from '@heroicons/react/24/solid'

const ExtraSection = () => {
  return (
    <section className="relative bg-brand-black text-white overflow-hidden">
      {/* Scrolling Text Banner */}
      <div className="relative overflow-hidden bg-white text-black py-4">
        <motion.div
          className="flex whitespace-nowrap"
          animate={{
            x: [0, -1920]
          }}
          transition={{
            x: {
              repeat: Infinity,
              repeatType: "loop",
              duration: 20,
              ease: "linear",
            },
          }}
        >
          {/* Repeat city names multiple times for seamless scroll */}
          {Array(10).fill(null).map((_, i) => (
            <div key={i} className="flex items-center space-x-16 mx-16">
              <span className="text-2xl font-bold tracking-wider">PARIS</span>
              <span className="text-2xl font-bold tracking-wider">LOS ANGELES</span>
              <span className="text-2xl font-bold tracking-wider">NEW YORK</span>
              <span className="text-2xl font-bold tracking-wider">BANGKOK</span>
              <span className="text-2xl font-bold tracking-wider">LONDON</span>
              <span className="text-2xl font-bold tracking-wider">TOKYO</span>
            </div>
          ))}
        </motion.div>
      </div>

      {/* Main Split Content */}
      <div className="grid grid-cols-1 lg:grid-cols-2 min-h-screen">
        {/* Left Side - Dark Section with Product Card */}
        <motion.div
          initial={{ opacity: 0, x: -50 }}
          whileInView={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.8 }}
          viewport={{ once: true }}
          className="bg-black flex items-center justify-center p-8 lg:p-16"
        >
          <div className="text-center">
            {/* Collection Title */}
            <motion.h2
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
              viewport={{ once: true }}
              className="text-lg tracking-[0.3em] text-white mb-12 uppercase font-light"
            >
              ULUWATU DREAMS
            </motion.h2>

            {/* Product Card */}
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.6, delay: 0.4 }}
              viewport={{ once: true }}
              className="relative bg-brand-gray rounded-lg overflow-hidden max-w-sm mx-auto group cursor-pointer"
            >
              {/* Save Badge */}
              <div className="absolute top-4 left-4 z-10 bg-brand-accent text-black px-3 py-1 text-xs font-bold uppercase tracking-wide">
                SAVE £10
              </div>

              {/* Product Image */}
              <div className="relative aspect-[3/4] bg-gradient-to-br from-gray-600 to-gray-800">
                <div className="absolute inset-0 flex items-center justify-center">
                  <div className="text-center text-gray-400">
                    <div className="text-lg font-light">Salt Romper</div>
                    <div className="text-sm">Eucalyptus</div>
                  </div>
                </div>
                
                {/* Hover Overlay */}
                <div className="absolute inset-0 bg-black/20 opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
              </div>

              {/* Product Info */}
              <div className="p-6 text-center">
                <h3 className="text-lg font-light text-white mb-2">Salt Romper Eucalyptus</h3>
                <div className="flex items-center justify-center space-x-3">
                  <span className="text-lg text-white font-medium">£40.00</span>
                  <span className="text-sm text-gray-400 line-through">£50.00</span>
                </div>
              </div>

              {/* Navigation Dots */}
              <div className="absolute bottom-4 left-1/2 transform -translate-x-1/2 flex space-x-2">
                <div className="w-2 h-2 bg-brand-accent rounded-full"></div>
                <div className="w-2 h-2 bg-gray-600 rounded-full"></div>
                <div className="w-2 h-2 bg-gray-600 rounded-full"></div>
              </div>
            </motion.div>
          </div>
        </motion.div>

        {/* Right Side - Fashion Photo with Play Button */}
        <motion.div
          initial={{ opacity: 0, x: 50 }}
          whileInView={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.8, delay: 0.3 }}
          viewport={{ once: true }}
          className="relative bg-gray-300 overflow-hidden group cursor-pointer"
        >
          {/* Background Image Placeholder */}
          <div className="absolute inset-0 bg-gradient-to-br from-gray-200 via-gray-300 to-gray-400">
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="text-center text-gray-600">
                <div className="text-2xl font-light mb-2">Fashion Photo</div>
                <div className="text-sm">Video Content</div>
              </div>
            </div>
          </div>

          {/* Play Button Overlay */}
          <div className="absolute inset-0 flex items-center justify-center">
            <motion.button
              whileHover={{ scale: 1.1 }}
              whileTap={{ scale: 0.95 }}
              className="w-20 h-20 bg-white/90 rounded-full flex items-center justify-center shadow-2xl backdrop-blur-sm group-hover:bg-white transition-colors duration-300"
            >
              <PlayIcon className="w-8 h-8 text-black ml-1" />
            </motion.button>
          </div>

          {/* Dark Overlay for Better Contrast */}
          <div className="absolute inset-0 bg-black/20 group-hover:bg-black/30 transition-colors duration-300" />
        </motion.div>
      </div>
    </section>
  )
}

export default ExtraSection