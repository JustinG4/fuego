'use client'

import { motion } from 'framer-motion'
import Image from 'next/image'
import Link from 'next/link'
import { TrashIcon, MinusIcon, PlusIcon } from '@heroicons/react/24/outline'
import Navigation from '../../components/Navigation'
import { useCart } from '../../hooks/useCart'

const CartPage = () => {
  const { cart, removeFromCart, updateQuantity, getCartTotal, clearCart, createCheckout, isLoading } = useCart()

  const formatPrice = (price: number) => `£${price.toFixed(2)}`

  if (cart.length === 0) {
    return (
      <div className="min-h-screen bg-brand-black text-white">
        <Navigation />
        
        <div className="pt-32 px-4 sm:px-6 lg:px-8">
          <div className="max-w-4xl mx-auto text-center">
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
            >
              <h1 className="text-4xl font-light tracking-tight mb-8">Your Cart</h1>
              <p className="text-xl text-gray-400 mb-8">Your cart is currently empty</p>
              <Link href="/shop" className="btn-primary">
                CONTINUE SHOPPING
              </Link>
            </motion.div>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-brand-black text-white">
      <Navigation />
      
      <div className="pt-32 px-4 sm:px-6 lg:px-8">
        <div className="max-w-6xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
          >
            <div className="flex items-center justify-between mb-12">
              <h1 className="text-4xl font-light tracking-tight">Your Cart</h1>
              <button
                onClick={clearCart}
                className="text-gray-400 hover:text-white transition-colors duration-300 text-sm font-medium"
              >
                CLEAR CART
              </button>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
              {/* Cart Items */}
              <div className="lg:col-span-2">
                <div className="space-y-8">
                  {cart.map((item) => (
                    <motion.div
                      key={`${item.variantId}`}
                      initial={{ opacity: 0, x: -30 }}
                      animate={{ opacity: 1, x: 0 }}
                      exit={{ opacity: 0, x: -30 }}
                      className="flex items-center space-x-6 p-6 bg-brand-gray rounded-lg border border-brand-light-gray"
                    >
                      {/* Product Image */}
                      <div className="w-24 h-24 bg-gradient-to-br from-purple-600 via-pink-600 to-red-600 rounded-lg flex-shrink-0">
                        {item.image && (
                          <Image
                            src={item.image}
                            alt={item.title}
                            width={96}
                            height={96}
                            className="w-full h-full object-cover rounded-lg"
                          />
                        )}
                      </div>

                      {/* Product Details */}
                      <div className="flex-grow">
                        <h3 className="text-lg font-medium text-white mb-2">{item.title}</h3>
                        <p className="text-gray-400 text-sm mb-2">Size: {item.variant}</p>
                        <div className="flex items-center space-x-4">
                          <span className="text-lg font-light text-white">
                            {formatPrice(item.price)}
                          </span>
                          {item.compareAtPrice && (
                            <span className="text-gray-400 line-through text-sm">
                              {formatPrice(item.compareAtPrice)}
                            </span>
                          )}
                        </div>
                      </div>

                      {/* Quantity Controls */}
                      <div className="flex items-center space-x-4">
                        <div className="flex items-center border border-brand-light-gray rounded-lg">
                          <button
                            onClick={() => updateQuantity(item.variantId, item.quantity - 1)}
                            className="p-2 hover:bg-brand-light-gray/20 transition-colors duration-300"
                          >
                            <MinusIcon className="w-4 h-4" />
                          </button>
                          <span className="px-4 py-2 text-center min-w-[3rem]">{item.quantity}</span>
                          <button
                            onClick={() => updateQuantity(item.variantId, item.quantity + 1)}
                            className="p-2 hover:bg-brand-light-gray/20 transition-colors duration-300"
                          >
                            <PlusIcon className="w-4 h-4" />
                          </button>
                        </div>

                        {/* Remove Button */}
                        <button
                          onClick={() => removeFromCart(item.variantId)}
                          className="p-2 text-gray-400 hover:text-red-500 transition-colors duration-300"
                        >
                          <TrashIcon className="w-5 h-5" />
                        </button>
                      </div>

                      {/* Item Total */}
                      <div className="text-right">
                        <div className="text-lg font-medium text-white">
                          {formatPrice(item.price * item.quantity)}
                        </div>
                      </div>
                    </motion.div>
                  ))}
                </div>
              </div>

              {/* Order Summary */}
              <div className="lg:col-span-1">
                <motion.div
                  initial={{ opacity: 0, x: 30 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ duration: 0.6, delay: 0.2 }}
                  className="bg-brand-gray rounded-lg border border-brand-light-gray p-8 sticky top-32"
                >
                  <h2 className="text-2xl font-light tracking-tight mb-8">Order Summary</h2>
                  
                  <div className="space-y-4 mb-8">
                    <div className="flex justify-between text-gray-300">
                      <span>Subtotal</span>
                      <span>{formatPrice(getCartTotal())}</span>
                    </div>
                    <div className="flex justify-between text-gray-300">
                      <span>Shipping</span>
                      <span className="text-brand-accent font-medium">FREE</span>
                    </div>
                    <div className="border-t border-brand-light-gray pt-4">
                      <div className="flex justify-between text-xl font-medium text-white">
                        <span>Total</span>
                        <span>{formatPrice(getCartTotal())}</span>
                      </div>
                    </div>
                  </div>

                  <button
                    onClick={createCheckout}
                    disabled={isLoading}
                    className="w-full btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isLoading ? 'PROCESSING...' : 'CHECKOUT'}
                  </button>

                  <div className="mt-6 text-center">
                    <Link
                      href="/shop"
                      className="text-brand-accent hover:text-white transition-colors duration-300 text-sm font-medium"
                    >
                      Continue Shopping
                    </Link>
                  </div>

                  {/* Security & Shipping Info */}
                  <div className="mt-8 pt-8 border-t border-brand-light-gray">
                    <div className="text-sm text-gray-400 space-y-2">
                      <p className="flex items-center">
                        <span className="w-2 h-2 bg-green-500 rounded-full mr-2"></span>
                        Secure payment processing
                      </p>
                      <p className="flex items-center">
                        <span className="w-2 h-2 bg-brand-accent rounded-full mr-2"></span>
                        Free shipping on all orders
                      </p>
                      <p className="flex items-center">
                        <span className="w-2 h-2 bg-blue-500 rounded-full mr-2"></span>
                        Easy returns within 30 days
                      </p>
                    </div>
                  </div>
                </motion.div>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </div>
  )
}

export default CartPage