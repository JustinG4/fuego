'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import Image from 'next/image'
import { ChevronDownIcon, AdjustmentsHorizontalIcon, XMarkIcon } from '@heroicons/react/24/outline'
import Navigation from '../../components/Navigation'
import ProductModal from '../../components/ProductModal'

const products = [
  {
    id: 1,
    name: 'Nina',
    type: 'BIKINI SET',
    price: 85,
    colors: 3,
    isNew: true,
    image: '/product1.jpg',
    images: ['/product1.jpg', '/product1-back.jpg'],
    sizes: ['XS', 'S', 'M', 'L'],
    description: 'Designed for effortless movement, we use seaweed-fiber fabric that is naturally anti-bacterial and chlorine resistant. This piece resembles a form-fitting suit made for swimming.',
    details: [
      'High-quality seaweed fiber construction',
      'Anti-bacterial and chlorine resistant', 
      'Form-fitting design for active wear',
      'Sustainable materials'
    ],
    inStock: true,
    stockLevel: 'ONLY 3 LEFT IN STOCK'
  },
  {
    id: 2,
    name: 'Gili',
    type: 'BIKINI SET',
    price: 90,
    colors: 3,
    isNew: true,
    image: '/product2.jpg',
    images: ['/product2.jpg', '/product2-back.jpg'],
    sizes: ['XS', 'S', 'M', 'L'],
    description: 'Premium bikini set crafted for comfort and style. Perfect for beach days and poolside lounging with its elegant design.',
    details: [
      'Premium fabric blend',
      'Quick-dry technology', 
      'UV protection',
      'Adjustable straps'
    ],
    inStock: true,
    stockLevel: 'IN STOCK'
  },
  {
    id: 3,
    name: 'Esme',
    type: 'BIKINI SET',
    price: 75,
    colors: 3,
    isNew: false,
    image: '/product3.jpg',
    images: ['/product3.jpg', '/product3-back.jpg'],
    sizes: ['XS', 'S', 'M', 'L'],
    description: 'Classic bikini set with modern touches. Features supportive design and comfortable fit for all-day wear.',
    details: [
      'Supportive construction',
      'Comfortable fit', 
      'Classic design',
      'Easy care'
    ],
    inStock: true,
    stockLevel: 'IN STOCK'
  },
  {
    id: 4,
    name: 'Cara',
    type: 'ONE PIECE',
    price: 95,
    colors: 2,
    isNew: false,
    image: '/product4.jpg',
    images: ['/product4.jpg', '/product4-back.jpg'],
    sizes: ['XS', 'S', 'M', 'L'],
    description: 'Elegant one-piece swimsuit with sophisticated styling. Perfect for swimming laps or lounging by the pool.',
    details: [
      'Elegant design',
      'Full coverage', 
      'Sophisticated styling',
      'Perfect for swimming'
    ],
    inStock: true,
    stockLevel: 'IN STOCK'
  },
  {
    id: 5,
    name: 'Luna',
    type: 'BIKINI SET',
    price: 88,
    colors: 4,
    isNew: true,
    image: '/product5.jpg',
    images: ['/product5.jpg', '/product5-back.jpg'],
    sizes: ['XS', 'S', 'M', 'L'],
    description: 'Modern bikini set with contemporary design elements. Features unique details and premium construction.',
    details: [
      'Contemporary design',
      'Premium construction', 
      'Unique details',
      'Modern fit'
    ],
    inStock: true,
    stockLevel: 'IN STOCK'
  },
  {
    id: 6,
    name: 'Sage',
    type: 'ONE PIECE',
    price: 92,
    colors: 2,
    isNew: false,
    image: '/product6.jpg',
    images: ['/product6.jpg', '/product6-back.jpg'],
    sizes: ['XS', 'S', 'M', 'L'],
    description: 'Sleek one-piece with minimalist design. Offers excellent support and comfort for active swimmers.',
    details: [
      'Minimalist design',
      'Excellent support', 
      'Comfort for active wear',
      'Sleek styling'
    ],
    inStock: true,
    stockLevel: 'IN STOCK'
  }
]

const ShopPage = () => {
  const [showFilters, setShowFilters] = useState(true)
  const [sortBy, setSortBy] = useState('FEATURED')
  const [selectedCollection, setSelectedCollection] = useState('SETS')
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [selectedProduct, setSelectedProduct] = useState<any>(null)

  const collections = ['SETS', 'BOTTOMS', 'TOPS', 'ACCESSORIES']
  const sizes = ['XS', 'S', 'M', 'L']

  const handleProductClick = (product: any) => {
    console.log('Product clicked:', product)
    setSelectedProduct(product)
    setIsModalOpen(true)
  }

  return (
    <div className="min-h-screen bg-brand-black text-white">
      <Navigation />
      
      <div className="pt-20">

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col lg:flex-row gap-8">
            
            {/* Left Sidebar - Filters */}
            {showFilters && (
              <motion.aside
                initial={{ opacity: 0, x: -50 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -50 }}
                className="lg:w-64 space-y-8"
              >
                {/* Collections */}
                <div>
                  <h3 className="text-sm font-medium text-white mb-4 uppercase tracking-wide">
                    Collections
                  </h3>
                  <div className="space-y-2">
                    {collections.map((collection) => (
                      <button
                        key={collection}
                        onClick={() => setSelectedCollection(collection)}
                        className={`block text-left text-sm transition-colors duration-300 ${
                          selectedCollection === collection
                            ? 'text-brand-accent font-medium'
                            : 'text-gray-400 hover:text-white'
                        }`}
                      >
                        {collection}
                      </button>
                    ))}
                  </div>
                </div>


                {/* Size */}
                <div>
                  <h3 className="text-sm font-medium text-white mb-4 uppercase tracking-wide">
                    Size
                  </h3>
                  <div className="grid grid-cols-3 gap-2">
                    {sizes.map((size) => (
                      <button
                        key={size}
                        className="py-2 px-3 border border-brand-light-gray text-xs font-medium text-gray-400 hover:text-white hover:border-white transition-colors duration-300"
                      >
                        {size}
                      </button>
                    ))}
                  </div>
                </div>
              </motion.aside>
            )}

            {/* Main Content */}
            <div className="flex-1">
              {/* Top Controls */}
              <div className="flex items-center justify-between mb-8">
                <button
                  onClick={() => setShowFilters(!showFilters)}
                  className="flex items-center text-sm font-medium text-white hover:text-brand-accent transition-colors duration-300"
                >
                  {showFilters ? (
                    <>
                      <XMarkIcon className="w-4 h-4 mr-2" />
                      HIDE FILTERS
                    </>
                  ) : (
                    <>
                      <AdjustmentsHorizontalIcon className="w-4 h-4 mr-2" />
                      SHOW FILTERS
                    </>
                  )}
                </button>

                <div className="flex items-center space-x-4">
                  <div className="relative">
                    <select
                      value={sortBy}
                      onChange={(e) => setSortBy(e.target.value)}
                      className="appearance-none bg-transparent border-none text-sm font-medium text-white cursor-pointer pr-6 focus:outline-none"
                    >
                      <option value="FEATURED" className="bg-brand-black">FEATURED</option>
                      <option value="PRICE_LOW" className="bg-brand-black">PRICE: LOW TO HIGH</option>
                      <option value="PRICE_HIGH" className="bg-brand-black">PRICE: HIGH TO LOW</option>
                      <option value="NEWEST" className="bg-brand-black">NEWEST</option>
                    </select>
                    <ChevronDownIcon className="w-4 h-4 absolute right-0 top-1/2 transform -translate-y-1/2 pointer-events-none" />
                  </div>
                </div>
              </div>

              {/* Products Grid */}
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ duration: 0.6, delay: 0.2 }}
                className={`grid gap-6 ${
                  showFilters ? 'grid-cols-1 md:grid-cols-2 lg:grid-cols-3' : 'grid-cols-1 md:grid-cols-3 lg:grid-cols-4'
                }`}
              >
                {products.map((product, index) => (
                  <motion.div
                    key={product.id}
                    initial={{ opacity: 0, y: 30 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.6, delay: index * 0.1 }}
                    className="group cursor-pointer"
                    onClick={() => handleProductClick(product)}
                  >
                    <div className="relative aspect-[3/4] bg-brand-gray rounded-lg overflow-hidden mb-4">
                      {/* Product Image Placeholder */}
                      <div className="absolute inset-0 bg-gradient-to-br from-gray-600 to-gray-800">
                        <div className="absolute inset-0 flex items-center justify-center">
                          <div className="text-center text-gray-500">
                            <div className="text-lg font-medium">{product.name}</div>
                            <div className="text-sm">{product.type}</div>
                          </div>
                        </div>
                      </div>
                      
                      {/* NEW Badge */}
                      {product.isNew && (
                        <div className="absolute top-4 left-4 bg-brand-accent text-black px-2 py-1 text-xs font-bold uppercase tracking-wide">
                          NEW
                        </div>
                      )}

                      {/* Hover Overlay */}
                      <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                    </div>

                    {/* Product Info */}
                    <div className="text-center">
                      <h3 className="text-lg font-light text-white mb-1">{product.name}</h3>
                      <p className="text-sm text-gray-400 mb-2">{product.type}</p>
                      <p className="text-lg font-medium text-white mb-2">£{product.price}</p>
                      <p className="text-xs text-gray-400 uppercase tracking-wide">
                        {product.colors} COLOUR{product.colors !== 1 ? 'S' : ''} AVAILABLE
                      </p>
                    </div>
                  </motion.div>
                ))}
              </motion.div>
            </div>
          </div>
        </div>
      </div>

      {/* Product Modal */}
      {selectedProduct && (
        <ProductModal
          isOpen={isModalOpen}
          onClose={() => setIsModalOpen(false)}
          product={{
            name: selectedProduct.name,
            price: selectedProduct.price,
            compareAtPrice: selectedProduct.compareAtPrice,
            images: selectedProduct.images,
            sizes: selectedProduct.sizes,
            description: selectedProduct.description,
            details: selectedProduct.details,
            inStock: selectedProduct.inStock,
            stockLevel: selectedProduct.stockLevel,
          }}
        />
      )}
    </div>
  )
}

export default ShopPage