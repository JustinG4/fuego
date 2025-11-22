# Shopify Integration Setup Guide

## Overview
This guide will help you set up Shopify integration with your FUEGO webapp. We're using a headless Shopify approach, keeping your custom Next.js frontend while using Shopify as the backend for products, inventory, and checkout.

## Step 1: Create Your Shopify Store

1. Go to [shopify.com](https://shopify.com) and create a new store
2. Choose a store name (e.g., "fuego-fashion" or "fuego-store")
3. Complete the initial setup process
4. Note your store domain (e.g., `fuego-store.myshopify.com`)

## Step 2: Get Your API Credentials

### Storefront API Access Token:
1. In your Shopify admin, go to **Apps** → **App and sales channel settings**
2. Click **Develop apps** at the bottom
3. Click **Allow custom app development** if prompted
4. Click **Create an app**
5. Name it "FUEGO Frontend" or similar
6. Go to **Configuration** tab
7. Under **Storefront API access scopes**, enable:
   - `unauthenticated_read_product_listings`
   - `unauthenticated_read_product_inventory`
   - `unauthenticated_read_product_tags`
   - `unauthenticated_read_checkouts`
   - `unauthenticated_write_checkouts`
8. Save and click **Install app**
9. Go to **API credentials** tab
10. Copy the **Storefront access token**

### Optional - Admin API Access Token (for webhooks/inventory):
1. In the same app, go to **Configuration** tab
2. Under **Admin API access scopes**, enable needed scopes
3. Go to **API credentials** tab  
4. Copy the **Admin API access token**

## Step 3: Configure Environment Variables

1. Copy `.env.local.example` to `.env.local`
2. Fill in your credentials:

```env
# Required for basic functionality
NEXT_PUBLIC_SHOPIFY_STORE_DOMAIN=your-store.myshopify.com
NEXT_PUBLIC_SHOPIFY_STOREFRONT_ACCESS_TOKEN=your-storefront-access-token

# Optional for admin operations
SHOPIFY_ADMIN_API_ACCESS_TOKEN=your-admin-access-token
SHOPIFY_WEBHOOK_SECRET=your-webhook-secret
```

## Step 4: Add Your Products

1. In Shopify admin, go to **Products** → **All products**
2. Add your FUEGO and INFERNO sets:

### Sample Product Setup:
**FUEGO SET:**
- Title: "FUEGO Set - White Flame"
- Description: "Earned through 5 intense workouts. You can't drip without sweat."
- Images: Upload your fuego_a.png, fuego_b.png, fuego_c.png
- Price: $89.99
- Tags: `fuego`, `set`, `earned-commerce`, `workout-required:5`

**INFERNO SET:**
- Title: "INFERNO Set - Black Flame" 
- Description: "Earned through 10 hardcore sessions. Elite fitness, elite fashion."
- Images: Upload your inferno_a.png, inferno_b.png, inferno_c.png
- Price: $129.99
- Tags: `inferno`, `set`, `earned-commerce`, `workout-required:10`

## Step 5: Create Collections (Optional)

1. Go to **Products** → **Collections**
2. Create collections like:
   - "FUEGO Collection"
   - "INFERNO Collection" 
   - "Earned Sets"

## Step 6: Test the Integration

1. Start your Next.js app: `npm run dev`
2. The app should now fetch real products from Shopify
3. Test the shop page and product modals
4. Verify checkout flow works

## Step 7: Set Up Webhooks (Optional)

For real-time updates when products change:

1. In Shopify admin, go to **Settings** → **Notifications**
2. Scroll to **Webhooks** section
3. Create webhooks for:
   - Product creation/updates
   - Order creation
   - Inventory updates

## Implementation Notes

- **Achievement System**: Use product tags like `workout-required:5` to gate products
- **Custom Logic**: The frontend will check user achievements before showing "Add to Cart"
- **Checkout**: Users get redirected to Shopify checkout after earning access
- **Inventory**: Handled automatically by Shopify
- **SEO**: Products get proper URLs like `/products/fuego-set-white-flame`

## Next Steps

1. Set up user authentication (Auth0, Supabase, or NextAuth.js)
2. Implement achievement tracking system
3. Add Apple Health integration
4. Create admin dashboard for achievement management
5. Set up production domain and SSL

## Testing Without a Store

If you want to test the integration before setting up Shopify:
- Use the mock data currently in the app
- The `ShopifyService` will gracefully handle API errors
- Set up environment variables later when ready