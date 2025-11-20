'use client'

import { useState } from 'react'
import Image from 'next/image'
import Link from 'next/link'
import Navigation from '@/components/Navigation'
import { ChevronDownIcon, MagnifyingGlassIcon } from '@heroicons/react/24/outline'

// Mock product data - replace with Shopify data
const product = {
  name: 'Salt Romper',
  price: 220.00,
  compareAtPrice: null,
  images: [
    '/images/salt-romper-main.jpg',
    '/images/salt-romper-back.jpg',
    '/images/salt-romper-detail.jpg',
  ],
  sizes: ['XS', 'S', 'M', 'L'],
  description: `Designed for effortless movement, we use seaweed-fiber fabric that is naturally anti-bacterial and chlorine resistant. This piece resembles a form-fitting suit made for swimming. Because you know your girl never is off the clock.`,
  details: [
    'High-quality seaweed fiber construction',
    'Anti-bacterial and chlorine resistant',
    'Form-fitting design for active wear',
    'Sustainable materials'
  ],
  inStock: true,
  stockLevel: 'ONLY 3 LEFT IN STOCK'
}

export default function ProductDetail() {
  const [selectedSize, setSelectedSize] = useState('')
  const [selectedImage, setSelectedImage] = useState(0)
  const [showDescription, setShowDescription] = useState(false)
  const [showDetails, setShowDetails] = useState(false)

  return (
    <main className="min-h-screen bg-brand-black">
      <Navigation />
      
      <div className="pt-16 grid grid-cols-1 lg:grid-cols-2 min-h-screen">
        {/* Left Side - Product Images */}
        <div className="relative bg-brand-gray">
          <div className="sticky top-16 h-screen relative">
            <div className="absolute inset-0 bg-gradient-to-br from-purple-600 via-pink-600 to-red-600">
            </div>
            
            {/* Zoom Icon */}
            <button className="absolute top-6 right-6 w-10 h-10 bg-black/20 backdrop-blur-sm rounded-full flex items-center justify-center text-white hover:bg-black/40 transition-colors duration-300">
              <MagnifyingGlassIcon className="w-5 h-5" />
            </button>

            {/* Image Thumbnails */}
            {product.images.length > 1 && (
              <div className="absolute bottom-6 left-1/2 transform -translate-x-1/2 flex space-x-2">
                {product.images.map((_, index) => (
                  <button
                    key={index}
                    onClick={() => setSelectedImage(index)}
                    className={`w-3 h-3 rounded-full transition-colors duration-300 ${
                      selectedImage === index ? 'bg-white' : 'bg-white/40'
                    }`}
                  />
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Right Side - Product Details */}
        <div className="p-8 lg:p-12 flex flex-col">
          <div className="flex-grow">
            {/* Breadcrumb */}
            <nav className="text-sm text-gray-400 mb-8">
              <Link href="/" className="hover:text-white transition-colors duration-300">Home</Link>
              <span className="mx-2">/</span>
              <Link href="/shop" className="hover:text-white transition-colors duration-300">Shop</Link>
              <span className="mx-2">/</span>
              <span className="text-white">{product.name}</span>
            </nav>

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
              <span className="text-sm text-brand-accent uppercase tracking-wide">
                FREE SHIPPING
              </span>
            </div>

            {/* Size Selection */}
            <div className="mb-8">
              <label className="block text-white text-sm font-medium mb-4 tracking-wide">
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

            {/* Add to Cart */}
            <div className="space-y-4 mb-8">
              <button
                disabled={!selectedSize}
                className="w-full btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
              >
                ADD TO CART - £{product.price.toFixed(2)}
              </button>
              <button className="w-full btn-secondary">
                BUY IT NOW
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

            {/* Product Details */}
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
        </div>
      </div>
    </main>
  )
}