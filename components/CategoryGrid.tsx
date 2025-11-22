'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import Link from 'next/link'
import Image from 'next/image'
import ProductModal from './ProductModal'

const categories = [
  { title: 'FUEGO SET', href: '/shop/fuego-set' },
  { title: 'INFERNO SET', href: '/shop/inferno-set' },
  { title: 'LAYER JACKET', href: '/shop/jackets' },
  { title: 'RAIN PARKA', href: '/shop/outerwear' },
]

const products = {
  'FUEGO SET': {
    name: 'Fuego Set',
    price: 180.00,
    compareAtPrice: 220.00,
    images: [
      '/fuego_a.png',
      '/fuego_b.png',
      '/fuego_c.png',
    ],
    sizes: ['XS', 'S', 'M', 'L'],
    description: 'Ignite your workout with the Fuego Set. Designed for high-intensity training and maximum performance. This premium set combines style with functionality for those who earn their drip.',
    details: [
      'Premium moisture-wicking fabric',
      'Four-way stretch for maximum mobility', 
      'Anti-odor technology',
      'Seamless construction for comfort',
      'Reflective logo details'
    ],
    inStock: true,
    stockLevel: 'LIMITED EDITION'
  },
  'INFERNO SET': {
    name: 'Inferno Set',
    price: 200.00,
    compareAtPrice: 250.00,
    images: [
      '/inferno_a.png',
      '/inferno_b.png',
      '/inferno_c.png',
    ],
    sizes: ['XS', 'S', 'M', 'L'],
    description: 'Turn up the heat with the Inferno Set. Built for those who push beyond limits and redefine what\'s possible. Earn your style through pure dedication and fire.',
    details: [
      'Elite performance fabric blend',
      'Temperature-regulating technology', 
      'Compression zones for support',
      'Quick-dry material',
      'Premium construction'
    ],
    inStock: true,
    stockLevel: 'EXCLUSIVE COLLECTION'
  }
}

function CategoryGrid() {
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [selectedProduct, setSelectedProduct] = useState(null)
  
  const handleCategoryClick = (categoryTitle) => {
    if (products[categoryTitle]) {
      setSelectedProduct(products[categoryTitle])
      setIsModalOpen(true)
    }
  }

  return (
    <section className="py-16 px-4 sm:px-6 lg:px-8 bg-brand-black">
      <div className="max-w-7xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          viewport={{ once: true }}
          className="text-center mb-12 mt-8"
        >
          <h2 className="text-3xl md:text-4xl font-light text-white tracking-tight">
            SHOP BY CATEGORY
          </h2>
        </motion.div>

        <div className="grid grid-cols-2 lg:grid-cols-4 gap-2">
          {categories.map((category, index) => (
            <motion.div
              key={category.title}
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: index * 0.1 }}
              viewport={{ once: true }}
              className="group relative overflow-hidden bg-brand-gray aspect-[3/4] cursor-pointer"
              onClick={() => handleCategoryClick(category.title)}
            >
              <div className="absolute inset-0 bg-gradient-to-br from-gray-600 to-gray-800 transition-transform duration-700 group-hover:scale-110"></div>
              <div className="absolute inset-0 bg-black/20 group-hover:bg-black/40 transition-colors duration-300"></div>
              <div className="absolute bottom-6 left-6 right-6">
                <div className="flex items-center justify-between">
                  <h3 className="text-white font-medium text-sm tracking-wide">
                    {category.title}
                  </h3>
                  <div className="w-8 h-8 border border-white rounded-full flex items-center justify-center group-hover:bg-white group-hover:border-white transition-all duration-300">
                    <svg 
                      className="w-4 h-4 text-white group-hover:text-black transition-colors duration-300" 
                      fill="none" 
                      stroke="currentColor" 
                      viewBox="0 0 24 24"
                    >
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-2 mt-8">
          <motion.div
            initial={{ opacity: 0, x: -30 }}
            whileInView={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6 }}
            viewport={{ once: true }}
            className="relative aspect-[16/9] bg-brand-gray overflow-hidden group"
          >
            <div className="absolute inset-0 bg-gradient-to-br from-slate-700 to-gray-900 transition-transform duration-700 group-hover:scale-105"></div>
            <div className="absolute inset-0 bg-black/30"></div>
            <div className="absolute inset-0 flex items-center justify-center">
              <Link href="/shop/men" className="btn-secondary">
                SHOP MEN
              </Link>
            </div>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, x: 30 }}
            whileInView={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6 }}
            viewport={{ once: true }}
            className="relative aspect-[16/9] bg-brand-gray overflow-hidden group"
          >
            <div className="absolute inset-0 bg-gradient-to-br from-orange-600 to-red-700 transition-transform duration-700 group-hover:scale-105"></div>
            <div className="absolute inset-0 bg-gradient-to-r from-orange-500/20 to-red-500/20"></div>
            <div className="absolute inset-0 flex items-center justify-center">
              <Link href="/shop/women" className="btn-secondary">
                SHOP WOMEN
              </Link>
            </div>
          </motion.div>
        </div>
      </div>

      {selectedProduct && (
        <ProductModal 
          isOpen={isModalOpen}
          onClose={() => setIsModalOpen(false)}
          product={selectedProduct}
        />
      )}
    </section>
  )
}

export default CategoryGrid