'use client'

import { motion, AnimatePresence } from 'framer-motion'
import Image from 'next/image'
import { XMarkIcon, MinusIcon, PlusIcon, TrashIcon, ShoppingBagIcon } from '@heroicons/react/24/outline'
import { useCart } from '../hooks/useCart'

const CartSidebar = () => {
  const { 
    cart, 
    isCartOpen, 
    setIsCartOpen, 
    removeFromCart, 
    updateQuantity, 
    getCartTotal, 
    getCartCount, 
    createCheckout, 
    isLoading 
  } = useCart()

  const formatPrice = (price: number) => `£${price.toFixed(2)}`

  return (
    <AnimatePresence>
      {isCartOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-black/60 backdrop-blur-sm z-40"
            onClick={() => setIsCartOpen(false)}
          />

          {/* Sidebar */}
          <motion.div
            initial={{ x: '100%' }}
            animate={{ x: 0 }}
            exit={{ x: '100%' }}
            transition={{ type: 'spring', damping: 25, stiffness: 200 }}
            className="fixed right-0 top-0 h-full w-full max-w-md bg-brand-black border-l border-brand-light-gray z-50 overflow-hidden"
          >
            <div className="flex flex-col h-full">
              {/* Header */}
              <div className="flex items-center justify-between p-6 border-b border-brand-light-gray">
                <h2 className="text-xl font-medium text-white">
                  Cart ({getCartCount()})
                </h2>
                <button
                  onClick={() => setIsCartOpen(false)}
                  className="p-2 text-gray-400 hover:text-white transition-colors duration-300"
                >
                  <XMarkIcon className="w-6 h-6" />
                </button>
              </div>

              {/* Cart Content */}
              <div className="flex-1 overflow-y-auto">
                {cart.length === 0 ? (
                  /* Empty Cart */
                  <div className="flex flex-col items-center justify-center h-full text-center px-6">
                    <ShoppingBagIcon className="w-16 h-16 text-gray-600 mb-4" />
                    <h3 className="text-lg font-medium text-white mb-2">Your cart is empty</h3>
                    <p className="text-gray-400 mb-6">Add some items to get started</p>
                    <button
                      onClick={() => setIsCartOpen(false)}
                      className="btn-primary"
                    >
                      Continue Shopping
                    </button>
                  </div>
                ) : (
                  /* Cart Items */
                  <div className="p-6 space-y-6">
                    {cart.map((item) => (
                      <motion.div
                        key={item.variantId}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -20 }}
                        className="flex items-start space-x-4 p-4 bg-brand-gray rounded-lg border border-brand-light-gray"
                      >
                        {/* Product Image */}
                        <div className="w-16 h-16 bg-gradient-to-br from-purple-600 via-pink-600 to-red-600 rounded-lg flex-shrink-0">
                          {item.image && (
                            <Image
                              src={item.image}
                              alt={item.title}
                              width={64}
                              height={64}
                              className="w-full h-full object-cover rounded-lg"
                            />
                          )}
                        </div>

                        {/* Product Details */}
                        <div className="flex-1 min-w-0">
                          <h4 className="text-sm font-medium text-white truncate mb-1">
                            {item.title}
                          </h4>
                          <p className="text-xs text-gray-400 mb-2">Size: {item.variant}</p>
                          <div className="flex items-center justify-between">
                            <span className="text-sm font-medium text-white">
                              {formatPrice(item.price)}
                            </span>
                            <button
                              onClick={() => removeFromCart(item.variantId)}
                              className="p-1 text-gray-400 hover:text-red-500 transition-colors duration-300"
                            >
                              <TrashIcon className="w-4 h-4" />
                            </button>
                          </div>

                          {/* Quantity Controls */}
                          <div className="flex items-center mt-2 space-x-2">
                            <button
                              onClick={() => updateQuantity(item.variantId, item.quantity - 1)}
                              className="p-1 text-gray-400 hover:text-white transition-colors duration-300"
                            >
                              <MinusIcon className="w-4 h-4" />
                            </button>
                            <span className="text-sm text-white min-w-[2rem] text-center">
                              {item.quantity}
                            </span>
                            <button
                              onClick={() => updateQuantity(item.variantId, item.quantity + 1)}
                              className="p-1 text-gray-400 hover:text-white transition-colors duration-300"
                            >
                              <PlusIcon className="w-4 h-4" />
                            </button>
                          </div>
                        </div>
                      </motion.div>
                    ))}
                  </div>
                )}
              </div>

              {/* Footer */}
              {cart.length > 0 && (
                <div className="border-t border-brand-light-gray p-6 bg-brand-gray">
                  <div className="space-y-4">
                    {/* Total */}
                    <div className="flex justify-between items-center">
                      <span className="text-lg font-medium text-white">Total</span>
                      <span className="text-lg font-bold text-white">
                        {formatPrice(getCartTotal())}
                      </span>
                    </div>

                    {/* Checkout Button */}
                    <button
                      onClick={createCheckout}
                      disabled={isLoading}
                      className="w-full btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {isLoading ? 'PROCESSING...' : 'CHECKOUT'}
                    </button>

                    {/* Continue Shopping */}
                    <button
                      onClick={() => setIsCartOpen(false)}
                      className="w-full text-center text-sm text-gray-400 hover:text-white transition-colors duration-300"
                    >
                      Continue Shopping
                    </button>
                  </div>
                </div>
              )}
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}

export default CartSidebar