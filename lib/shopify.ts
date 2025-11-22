import { createStorefrontApiClient } from '@shopify/storefront-api-client';

const domain = process.env.NEXT_PUBLIC_SHOPIFY_STORE_DOMAIN!;
const storefrontAccessToken = process.env.NEXT_PUBLIC_SHOPIFY_STOREFRONT_ACCESS_TOKEN!;

if (!domain || !storefrontAccessToken) {
  throw new Error('Missing Shopify environment variables');
}

export const shopifyClient = createStorefrontApiClient({
  storeDomain: domain,
  apiVersion: '2025-01',
  publicAccessToken: storefrontAccessToken,
});

export interface ShopifyProduct {
  id: string;
  title: string;
  handle: string;
  description: string;
  images: {
    edges: Array<{
      node: {
        url: string;
        altText?: string;
      };
    }>;
  };
  variants: {
    edges: Array<{
      node: {
        id: string;
        price: {
          amount: string;
          currencyCode: string;
        };
        compareAtPrice?: {
          amount: string;
          currencyCode: string;
        };
        availableForSale: boolean;
        selectedOptions: Array<{
          name: string;
          value: string;
        }>;
      };
    }>;
  };
  tags: string[];
}

export interface ShopifyCollection {
  id: string;
  title: string;
  handle: string;
  description: string;
  products: {
    edges: Array<{
      node: ShopifyProduct;
    }>;
  };
}

export interface CheckoutLineItem {
  variantId: string
  quantity: number
}

export const PRODUCTS_QUERY = `
  query getProducts($first: Int!) {
    products(first: $first) {
      edges {
        node {
          id
          title
          handle
          description
          tags
          images(first: 10) {
            edges {
              node {
                url
                altText
              }
            }
          }
          variants(first: 10) {
            edges {
              node {
                id
                price {
                  amount
                  currencyCode
                }
                compareAtPrice {
                  amount
                  currencyCode
                }
                availableForSale
                selectedOptions {
                  name
                  value
                }
              }
            }
          }
        }
      }
    }
  }
`;

export const COLLECTION_QUERY = `
  query getCollection($handle: String!, $first: Int!) {
    collection(handle: $handle) {
      id
      title
      handle
      description
      products(first: $first) {
        edges {
          node {
            id
            title
            handle
            description
            tags
            images(first: 10) {
              edges {
                node {
                  url
                  altText
                }
              }
            }
            variants(first: 10) {
              edges {
                node {
                  id
                  price {
                    amount
                    currencyCode
                  }
                  compareAtPrice {
                    amount
                    currencyCode
                  }
                  availableForSale
                  selectedOptions {
                    name
                    value
                  }
                }
              }
            }
          }
        }
      }
    }
  }
`;

export const PRODUCT_BY_HANDLE_QUERY = `
  query getProductByHandle($handle: String!) {
    product(handle: $handle) {
      id
      title
      handle
      description
      tags
      images(first: 10) {
        edges {
          node {
            url
            altText
          }
        }
      }
      variants(first: 10) {
        edges {
          node {
            id
            price {
              amount
              currencyCode
            }
            compareAtPrice {
              amount
              currencyCode
            }
            availableForSale
            selectedOptions {
              name
              value
            }
          }
        }
      }
    }
  }
`;

export class ShopifyService {
  static async getProducts(first = 20): Promise<ShopifyProduct[]> {
    try {
      const { data } = await shopifyClient.request(PRODUCTS_QUERY, {
        variables: { first },
      });
      
      return data.products.edges.map((edge: any) => edge.node);
    } catch (error) {
      console.error('Error fetching products:', error);
      return [];
    }
  }

  static async getProductByHandle(handle: string): Promise<ShopifyProduct | null> {
    try {
      const { data } = await shopifyClient.request(PRODUCT_BY_HANDLE_QUERY, {
        variables: { handle },
      });
      
      return data.product;
    } catch (error) {
      console.error('Error fetching product by handle:', error);
      return null;
    }
  }

  static async getCollection(handle: string, first = 20): Promise<ShopifyCollection | null> {
    try {
      const { data } = await shopifyClient.request(COLLECTION_QUERY, {
        variables: { handle, first },
      });
      
      return data.collection;
    } catch (error) {
      console.error('Error fetching collection:', error);
      return null;
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

export function formatPrice(price: string, currencyCode: string): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: currencyCode,
  }).format(parseFloat(price));
}