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
  const [selectedImage, setSelectedImage] = useState(0)
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
                  src="/flame_logo_transparent.png"
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
          <div className="relative w-full max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-2" style={{height: 'calc(100vh - 120px)'}}>
            {/* Left Side - Product Images Collage */}
            <motion.div
              initial={{ x: -100, opacity: 0 }}
              animate={{ x: 0, opacity: 1 }}
              exit={{ x: -100, opacity: 0 }}
              transition={{ duration: 0.3 }}
              className="relative bg-brand-gray"
            >
              <div className="h-full flex flex-col">
                {/* Main Display Image */}
                <button
                  onClick={() => setSelectedImage(0)}
                  className={`flex-1 relative bg-brand-gray overflow-hidden transition-all duration-300 hover:opacity-90 ${
                    selectedImage === 0 ? 'ring-2 ring-brand-accent' : ''
                  }`}
                >
                  {product.images && product.images.length > 0 ? (
                    <Image
                      src={product.images[selectedImage] || product.images[0]}
                      alt={product.name}
                      fill
                      className="object-cover"
                      sizes="(max-width: 768px) 100vw, 50vw"
                    />
                  ) : (
                    <div className="absolute inset-0 flex items-center justify-center bg-gradient-to-br from-gray-600 to-gray-800">
                      <div className="text-center text-gray-400">
                        <div className="text-xl font-light mb-1">{product.name}</div>
                        <div className="text-sm">Main View</div>
                      </div>
                    </div>
                  )}
                </button>

                {/* Bottom Row - Thumbnail Images */}
                <div className="flex h-32">
                  {product.images && product.images.slice(1, 3).map((image, index) => (
                    <button
                      key={index}
                      onMouseEnter={() => setSelectedImage(index + 1)}
                      onClick={() => setSelectedImage(index + 1)}
                      className={`flex-1 relative bg-brand-gray overflow-hidden transition-all duration-300 hover:opacity-80 ${
                        selectedImage === index + 1 ? 'ring-2 ring-brand-accent' : ''
                      }`}
                    >
                      <Image
                        src={image}
                        alt={`${product.name} view ${index + 2}`}
                        fill
                        className="object-cover"
                        sizes="(max-width: 768px) 50vw, 25vw"
                      />
                    </button>
                  ))}
                  
                  {/* Fill remaining slots if less than 2 additional images */}
                  {product.images && product.images.length < 3 && Array.from({ length: 3 - product.images.length }).map((_, index) => (
                    <div
                      key={`placeholder-${index}`}
                      className="flex-1 relative bg-gradient-to-br from-gray-700 to-gray-900 overflow-hidden"
                    >
                      <div className="absolute inset-0 flex items-center justify-center">
                        <div className="text-center text-gray-400">
                          <div className="text-xs font-medium">View {product.images.length + index + 1}</div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </motion.div>

            {/* Right Side - Product Details */}
            <motion.div
              initial={{ x: 100, opacity: 0 }}
              animate={{ x: 0, opacity: 1 }}
              exit={{ x: 100, opacity: 0 }}
              transition={{ duration: 0.3 }}
              className="bg-brand-black p-4 lg:p-6 flex flex-col h-full overflow-hidden"
            >
              {/* Close Button */}
              <button
                onClick={onClose}
                className="absolute top-6 right-6 z-20 w-10 h-10 flex items-center justify-center text-white hover:text-brand-accent transition-colors duration-300"
              >
                <XMarkIcon className="w-6 h-6" />
              </button>

              <div className="flex-grow flex flex-col justify-between">
                <div>
                  {/* Product Info */}
                  <h1 className="text-3xl font-light text-white mb-3 tracking-tight">
                    {product.name}
                  </h1>
                  
                  <div className="flex items-baseline space-x-4 mb-4">
                    <span className="text-lg text-white font-light">
                      £{product.price.toFixed(2)}
                    </span>
                    {product.compareAtPrice && (
                      <span className="text-sm text-gray-400 line-through">
                        £{product.compareAtPrice.toFixed(2)}
                      </span>
                    )}
                    <span className="text-xs text-brand-accent uppercase tracking-wide font-medium">
                      FREE SHIPPING
                    </span>
                  </div>

                  {/* Size Selection */}
                  <div className="mb-4">
                    <label className="block text-white text-sm font-medium mb-2 tracking-wide uppercase">
                      SIZE
                    </label>
                    <div className="grid grid-cols-4 gap-2">
                      {product.sizes.map((size) => (
                        <button
                          key={size}
                          onClick={() => setSelectedSize(size)}
                          className={`py-2 px-3 border text-sm font-medium tracking-wide transition-all duration-300 ${
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
                    <div className="mb-3">
                      <span className="text-sm text-brand-accent uppercase tracking-wide font-medium">
                        {product.stockLevel}
                      </span>
                    </div>
                  )}
                </div>

                <div>
                  {/* Add to Cart Button */}
                  <div className="mb-4">
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
                  <div className="border-t border-brand-light-gray pt-3">
                    <button
                      onClick={() => setShowDescription(!showDescription)}
                      className="flex items-center justify-between w-full text-left text-white font-medium tracking-wide text-sm uppercase mb-2"
                    >
                      DESCRIPTION
                      <ChevronDownIcon 
                        className={`w-4 h-4 transition-transform duration-300 ${showDescription ? 'rotate-180' : ''}`}
                      />
                    </button>
                    {showDescription && (
                      <div className="text-gray-300 text-sm leading-relaxed mb-3">
                        {product.description}
                      </div>
                    )}
                  </div>

                  {/* Details Section */}
                  <div className="border-t border-brand-light-gray pt-3">
                    <button
                      onClick={() => setShowDetails(!showDetails)}
                      className="flex items-center justify-between w-full text-left text-white font-medium tracking-wide text-sm uppercase mb-2"
                    >
                      DETAILS
                      <ChevronDownIcon 
                        className={`w-4 h-4 transition-transform duration-300 ${showDetails ? 'rotate-180' : ''}`}
                      />
                    </button>
                    {showDetails && (
                      <ul className="text-gray-300 text-sm leading-relaxed space-y-1">
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
              </div>
            </motion.div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  )
}

export default ProductModal