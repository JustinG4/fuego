'use client'

import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import Image from 'next/image'
import { XMarkIcon, ChevronDownIcon } from '@heroicons/react/24/outline'
import { useCart } from '../hooks/useCart'

interface ProductModalProps {
  isOpen: boolean
  onClose: () => void
  product: {
    name: string
    price: number
    compareAtPrice?: number
    images: string[]
    sizes: string[]
    description: string
    details: string[]
    inStock: boolean
    stockLevel?: string
  }
}

const ProductModal = ({ isOpen, onClose, product }: ProductModalProps) => {
  const [selectedSize, setSelectedSize] = useState('')
  const [showDescription, setShowDescription] = useState(false)
  const [showDetails, setShowDetails] = useState(false)
  const { addToCart, isLoading } = useCart()

  // Reset state when modal opens
  useEffect(() => {
    if (isOpen) {
      setSelectedSize('')
      setShowDescription(false)
      setShowDetails(false)
    }
  }, [isOpen])

  // Prevent body scroll when modal is open
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden'
    } else {
      document.body.style.overflow = 'unset'
    }

    return () => {
      document.body.style.overflow = 'unset'
    }
  }, [isOpen])

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 z-50"
        >
          {/* Backdrop */}
          <div
            className="absolute inset-0 bg-black/80 backdrop-blur-sm"
            onClick={onClose}
          />

          {/* Navigation Bar at Top */}
          <div className="relative z-10 w-full">
            <nav className="flex justify-center items-center space-x-8 py-6 text-sm text-white font-medium tracking-wide bg-transparent">
              <span>SHOP</span>
              <span>ABOUT</span>
              <span>BURN</span>
              
              {/* Logo in center */}
              <div className="mx-8">
                <Image
                  src="/center_logo.png"
                  alt="Brand Logo"
                  width={48}
                  height={48}
                  className="object-contain"
                />
              </div>
              
              <span>ACCOUNT</span>
              <span>SEARCH</span>
              <span>CART</span>
            </nav>
          </div>

          {/* Modal Content */}
          <div className="relative w-full max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-2" style={{height: 'calc(100vh - 64px)'}}>
            {/* Left Side - Product Image */}
            <motion.div
              initial={{ x: -100, opacity: 0 }}
              animate={{ x: 0, opacity: 1 }}
              exit={{ x: -100, opacity: 0 }}
              transition={{ duration: 0.3 }}
              className="relative bg-brand-gray"
            >
              <div className="h-full relative">
                <div className="absolute inset-0 bg-gradient-to-br from-purple-600 via-pink-600 to-red-600">
                </div>
              </div>
            </motion.div>

            {/* Right Side - Product Details */}
            <motion.div
              initial={{ x: 100, opacity: 0 }}
              animate={{ x: 0, opacity: 1 }}
              exit={{ x: 100, opacity: 0 }}
              transition={{ duration: 0.3 }}
              className="bg-brand-black p-8 lg:p-12 flex flex-col h-full overflow-y-auto pt-4"
            >
              {/* Close Button */}
              <button
                onClick={onClose}
                className="absolute top-6 right-6 z-20 w-10 h-10 flex items-center justify-center text-white hover:text-brand-accent transition-colors duration-300"
              >
                <XMarkIcon className="w-6 h-6" />
              </button>

              <div className="flex-grow">

                {/* Product Info */}
                <h1 className="text-4xl font-light text-white mb-4 tracking-tight">
                  {product.name}
                </h1>
                
                <div className="flex items-baseline space-x-4 mb-8">
                  <span className="text-2xl text-white font-light">
                    £{product.price.toFixed(2)}
                  </span>
                  {product.compareAtPrice && (
                    <span className="text-lg text-gray-400 line-through">
                      £{product.compareAtPrice.toFixed(2)}
                    </span>
                  )}
                  <span className="text-sm text-brand-accent uppercase tracking-wide font-medium">
                    FREE SHIPPING
                  </span>
                </div>

                {/* Size Selection */}
                <div className="mb-8">
                  <label className="block text-white text-sm font-medium mb-4 tracking-wide uppercase">
                    SIZE
                  </label>
                  <div className="grid grid-cols-4 gap-3">
                    {product.sizes.map((size) => (
                      <button
                        key={size}
                        onClick={() => setSelectedSize(size)}
                        className={`py-3 px-4 border text-sm font-medium tracking-wide transition-all duration-300 ${
                          selectedSize === size
                            ? 'border-brand-accent bg-brand-accent text-black'
                            : 'border-white text-white hover:bg-white hover:text-black'
                        }`}
                      >
                        {size}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Stock Status */}
                {product.stockLevel && (
                  <div className="mb-8">
                    <span className="text-sm text-brand-accent uppercase tracking-wide font-medium">
                      {product.stockLevel}
                    </span>
                  </div>
                )}

                {/* Fit Guide */}
                <div className="text-center mb-6">
                  <span className="text-white text-sm tracking-wide">
                    FIND YOUR FIT
                  </span>
                </div>

                {/* Stock and Price Summary */}
                <div className="text-center mb-8">
                  <div className="text-white text-sm mb-2">ADD TO CART - £220</div>
                </div>

                {/* Add to Cart Button */}
                <div className="mb-8">
                  <button
                    disabled={!selectedSize || isLoading}
                    onClick={async () => {
                      if (selectedSize) {
                        await addToCart({
                          variantId: `variant-${product.name}-${selectedSize}`,
                          productId: product.name,
                          title: product.name,
                          price: product.price,
                          compareAtPrice: product.compareAtPrice,
                          image: product.images[0],
                          variant: selectedSize,
                        })
                        onClose()
                      }
                    }}
                    className="w-full btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isLoading ? 'ADDING...' : 'ADD TO CART'}
                  </button>
                </div>

                {/* Product Description */}
                <div className="border-t border-brand-light-gray pt-6">
                  <button
                    onClick={() => setShowDescription(!showDescription)}
                    className="flex items-center justify-between w-full text-left text-white font-medium tracking-wide text-sm uppercase mb-4"
                  >
                    DESCRIPTION
                    <ChevronDownIcon 
                      className={`w-4 h-4 transition-transform duration-300 ${showDescription ? 'rotate-180' : ''}`}
                    />
                  </button>
                  {showDescription && (
                    <div className="text-gray-300 text-sm leading-relaxed mb-6">
                      {product.description}
                    </div>
                  )}
                </div>

                {/* Information Section */}
                <div className="border-t border-brand-light-gray pt-6">
                  <button
                    className="flex items-center justify-between w-full text-left text-white font-medium tracking-wide text-sm uppercase mb-4"
                  >
                    INFORMATION
                    <ChevronDownIcon className="w-4 h-4" />
                  </button>
                </div>

                {/* Details Section */}
                <div className="border-t border-brand-light-gray pt-6">
                  <button
                    onClick={() => setShowDetails(!showDetails)}
                    className="flex items-center justify-between w-full text-left text-white font-medium tracking-wide text-sm uppercase mb-4"
                  >
                    DETAILS
                    <ChevronDownIcon 
                      className={`w-4 h-4 transition-transform duration-300 ${showDetails ? 'rotate-180' : ''}`}
                    />
                  </button>
                  {showDetails && (
                    <ul className="text-gray-300 text-sm leading-relaxed space-y-2">
                      {product.details.map((detail, index) => (
                        <li key={index} className="flex items-start">
                          <span className="mr-2">•</span>
                          {detail}
                        </li>
                      ))}
                    </ul>
                  )}
                </div>
              </div>
            </motion.div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  )
}

export default ProductModal