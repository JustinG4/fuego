import Client from 'shopify-buy'

const domain = process.env.NEXT_PUBLIC_SHOPIFY_DOMAIN || ''
const storefrontAccessToken = process.env.NEXT_PUBLIC_SHOPIFY_STOREFRONT_ACCESS_TOKEN || ''

export const shopifyClient = Client.buildClient({
  domain,
  storefrontAccessToken,
})

export interface ShopifyProduct {
  id: string
  title: string
  description: string
  handle: string
  images: {
    src: string
    altText: string
  }[]
  variants: {
    id: string
    title: string
    price: number
    compareAtPrice?: number
    available: boolean
  }[]
  vendor: string
  productType: string
  tags: string[]
}

export interface CheckoutLineItem {
  variantId: string
  quantity: number
}

export class ShopifyService {
  static async getProducts(): Promise<ShopifyProduct[]> {
    try {
      const products = await shopifyClient.product.fetchAll()
      return products.map((product: any) => ({
        id: product.id,
        title: product.title,
        description: product.description,
        handle: product.handle,
        images: product.images.map((img: any) => ({
          src: img.src,
          altText: img.altText || product.title,
        })),
        variants: product.variants.map((variant: any) => ({
          id: variant.id,
          title: variant.title,
          price: parseFloat(variant.price),
          compareAtPrice: variant.compareAtPrice ? parseFloat(variant.compareAtPrice) : undefined,
          available: variant.available,
        })),
        vendor: product.vendor,
        productType: product.productType,
        tags: product.tags,
      }))
    } catch (error) {
      console.error('Error fetching products:', error)
      return []
    }
  }

  static async getProductByHandle(handle: string): Promise<ShopifyProduct | null> {
    try {
      const product = await shopifyClient.product.fetchByHandle(handle)
      if (!product) return null

      return {
        id: product.id,
        title: product.title,
        description: product.description,
        handle: product.handle,
        images: product.images.map((img: any) => ({
          src: img.src,
          altText: img.altText || product.title,
        })),
        variants: product.variants.map((variant: any) => ({
          id: variant.id,
          title: variant.title,
          price: parseFloat(variant.price),
          compareAtPrice: variant.compareAtPrice ? parseFloat(variant.compareAtPrice) : undefined,
          available: variant.available,
        })),
        vendor: product.vendor,
        productType: product.productType,
        tags: product.tags,
      }
    } catch (error) {
      console.error('Error fetching product by handle:', error)
      return null
    }
  }

  static async createCheckout(lineItems: CheckoutLineItem[]): Promise<string> {
    try {
      const checkout = await shopifyClient.checkout.create()
      
      const lineItemsForCheckout = lineItems.map(item => ({
        variantId: item.variantId,
        quantity: item.quantity,
      }))

      const updatedCheckout = await shopifyClient.checkout.addLineItems(checkout.id, lineItemsForCheckout)
      
      return updatedCheckout.webUrl
    } catch (error) {
      console.error('Error creating checkout:', error)
      throw new Error('Failed to create checkout')
    }
  }

  static async getCheckout(checkoutId: string) {
    try {
      return await shopifyClient.checkout.fetch(checkoutId)
    } catch (error) {
      console.error('Error fetching checkout:', error)
      return null
    }
  }

  static async addToCheckout(checkoutId: string, lineItems: CheckoutLineItem[]) {
    try {
      const lineItemsForCheckout = lineItems.map(item => ({
        variantId: item.variantId,
        quantity: item.quantity,
      }))

      return await shopifyClient.checkout.addLineItems(checkoutId, lineItemsForCheckout)
    } catch (error) {
      console.error('Error adding to checkout:', error)
      throw new Error('Failed to add items to checkout')
    }
  }

  static async updateCheckoutLineItem(checkoutId: string, lineItemId: string, quantity: number) {
    try {
      const lineItemsToUpdate = [{
        id: lineItemId,
        quantity: quantity,
      }]

      return await shopifyClient.checkout.updateLineItems(checkoutId, lineItemsToUpdate)
    } catch (error) {
      console.error('Error updating checkout line item:', error)
      throw new Error('Failed to update checkout item')
    }
  }

  static async removeFromCheckout(checkoutId: string, lineItemIds: string[]) {
    try {
      return await shopifyClient.checkout.removeLineItems(checkoutId, lineItemIds)
    } catch (error) {
      console.error('Error removing from checkout:', error)
      throw new Error('Failed to remove items from checkout')
    }
  }
}