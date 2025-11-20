'use client'

import { useState, useEffect, createContext, useContext, ReactNode } from 'react'
import { ShopifyService, CheckoutLineItem } from '../lib/shopify'

interface CartItem {
  variantId: string
  productId: string
  title: string
  price: number
  compareAtPrice?: number
  quantity: number
  image?: string
  variant: string
}

interface CartContextType {
  cart: CartItem[]
  isLoading: boolean
  checkoutUrl: string | null
  isCartOpen: boolean
  setIsCartOpen: (open: boolean) => void
  toggleCart: () => void
  addToCart: (item: Omit<CartItem, 'quantity'>, quantity?: number) => Promise<void>
  removeFromCart: (variantId: string) => Promise<void>
  updateQuantity: (variantId: string, quantity: number) => Promise<void>
  clearCart: () => void
  getCartTotal: () => number
  getCartCount: () => number
  createCheckout: () => Promise<void>
}

const CartContext = createContext<CartContextType | undefined>(undefined)

export function CartProvider({ children }: { children: ReactNode }) {
  const [cart, setCart] = useState<CartItem[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [checkoutUrl, setCheckoutUrl] = useState<string | null>(null)
  const [checkoutId, setCheckoutId] = useState<string | null>(null)
  const [isCartOpen, setIsCartOpen] = useState(false)

  useEffect(() => {
    const savedCart = localStorage.getItem('cart')
    const savedCheckoutId = localStorage.getItem('checkoutId')
    
    if (savedCart) {
      setCart(JSON.parse(savedCart))
    }
    
    if (savedCheckoutId) {
      setCheckoutId(savedCheckoutId)
    }
  }, [])

  useEffect(() => {
    localStorage.setItem('cart', JSON.stringify(cart))
  }, [cart])

  const addToCart = async (item: Omit<CartItem, 'quantity'>, quantity = 1) => {
    setIsLoading(true)
    
    try {
      const existingItem = cart.find(cartItem => cartItem.variantId === item.variantId)
      
      if (existingItem) {
        const newQuantity = existingItem.quantity + quantity
        setCart(cart.map(cartItem => 
          cartItem.variantId === item.variantId 
            ? { ...cartItem, quantity: newQuantity }
            : cartItem
        ))
      } else {
        setCart([...cart, { ...item, quantity }])
      }

      if (checkoutId) {
        await ShopifyService.addToCheckout(checkoutId, [{ 
          variantId: item.variantId, 
          quantity 
        }])
      }
    } catch (error) {
      console.error('Error adding to cart:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const removeFromCart = async (variantId: string) => {
    setIsLoading(true)
    
    try {
      setCart(cart.filter(item => item.variantId !== variantId))

      if (checkoutId) {
        const checkout = await ShopifyService.getCheckout(checkoutId)
        if (checkout) {
          const lineItem = checkout.lineItems.find((item: any) => item.variant.id === variantId)
          if (lineItem) {
            await ShopifyService.removeFromCheckout(checkoutId, [lineItem.id])
          }
        }
      }
    } catch (error) {
      console.error('Error removing from cart:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const updateQuantity = async (variantId: string, quantity: number) => {
    if (quantity <= 0) {
      await removeFromCart(variantId)
      return
    }

    setIsLoading(true)
    
    try {
      setCart(cart.map(item => 
        item.variantId === variantId 
          ? { ...item, quantity }
          : item
      ))

      if (checkoutId) {
        const checkout = await ShopifyService.getCheckout(checkoutId)
        if (checkout) {
          const lineItem = checkout.lineItems.find((item: any) => item.variant.id === variantId)
          if (lineItem) {
            await ShopifyService.updateCheckoutLineItem(checkoutId, lineItem.id, quantity)
          }
        }
      }
    } catch (error) {
      console.error('Error updating quantity:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const clearCart = () => {
    setCart([])
    setCheckoutUrl(null)
    setCheckoutId(null)
    localStorage.removeItem('cart')
    localStorage.removeItem('checkoutId')
  }

  const toggleCart = () => {
    setIsCartOpen(!isCartOpen)
  }

  const getCartTotal = () => {
    return cart.reduce((total, item) => total + (item.price * item.quantity), 0)
  }

  const getCartCount = () => {
    return cart.reduce((count, item) => count + item.quantity, 0)
  }

  const createCheckout = async () => {
    if (cart.length === 0) return

    setIsLoading(true)
    
    try {
      const lineItems: CheckoutLineItem[] = cart.map(item => ({
        variantId: item.variantId,
        quantity: item.quantity,
      }))

      const url = await ShopifyService.createCheckout(lineItems)
      setCheckoutUrl(url)
      
      window.open(url, '_blank')
    } catch (error) {
      console.error('Error creating checkout:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const value: CartContextType = {
    cart,
    isLoading,
    checkoutUrl,
    isCartOpen,
    setIsCartOpen,
    toggleCart,
    addToCart,
    removeFromCart,
    updateQuantity,
    clearCart,
    getCartTotal,
    getCartCount,
    createCheckout,
  }

  return (
    <CartContext.Provider value={value}>
      {children}
    </CartContext.Provider>
  )
}

export function useCart() {
  const context = useContext(CartContext)
  if (context === undefined) {
    throw new Error('useCart must be used within a CartProvider')
  }
  return context
}