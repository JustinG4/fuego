# 🛍️ Shopify Integration Guide

Complete guide to connecting your Shopify store with UnlockEngine and syncing products.

---

## ✅ What You'll Accomplish

- Connect your Shopify store to UnlockEngine
- Automatically import products from Shopify
- Keep product info synchronized
- Attach milestones to Shopify products

---

## 📋 Prerequisites

1. **Shopify Store**: You need a Shopify store (even a development store works)
2. **Admin Access**: Must have admin access to your Shopify store
3. **UnlockEngine Admin**: Access to http://localhost:3001/settings/shopify

---

## 🔑 Step 1: Get Your Shopify Storefront Access Token

### Option A: Create a Custom App (Recommended)

1. **Login to your Shopify Admin**
   - Go to your Shopify admin dashboard
   - URL format: `https://your-store.myshopify.com/admin`

2. **Navigate to Apps & Sales Channels**
   ```
   Settings → Apps and sales channels → Develop apps
   ```

3. **Create a New App**
   - Click "Create an app"
   - App name: "UnlockEngine"
   - Click "Create app"

4. **Configure Storefront API Access**
   - Go to "Configuration" tab
   - Scroll to "Storefront API" section
   - Click "Configure"

5. **Select Permissions**
   - Check these scopes:
     - ✅ `unauthenticated_read_product_listings`
     - ✅ `unauthenticated_read_product_inventory`
     - ✅ `unauthenticated_read_product_tags`
   - Click "Save"

6. **Install the App**
   - Click "Install app" button
   - Confirm installation

7. **Get Your Access Token**
   - Go to "API credentials" tab
   - Under "Storefront API access token"
   - Click "Copy" to copy the token
   - **SAVE THIS TOKEN** - you'll need it!

### Example Token Format:
```
shpat_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```
(Replace x's with your actual token)

---

## 🔌 Step 2: Connect UnlockEngine to Shopify

1. **Open UnlockEngine Admin**
   ```
   http://localhost:3001/settings/shopify
   ```

2. **Enter Your Store Information**
   - **Store Domain**: `your-store.myshopify.com`
     - Don't include `https://`
     - Include `.myshopify.com`

   - **Storefront Access Token**: `shpat_...`
     - Paste the token you copied from Step 1

   - **Admin API Token**: (Optional for now)
     - Leave blank unless you have Admin API access

3. **Save Credentials**
   - Click "Save Credentials"
   - You should see "Shopify credentials saved successfully!"
   - Status should change to "Store Connected" ✅

---

## 🔄 Step 3: Sync Products

1. **Click "Sync Now" Button**
   - The button appears once credentials are saved
   - Shows "Syncing Products..." with spinning icon

2. **Wait for Sync to Complete**
   - Typically takes 5-30 seconds depending on product count
   - You'll see an alert: "Sync complete! X new products, Y updated."

3. **View Sync Results**
   - Check the "Last Sync Summary" section
   - Shows:
     - Total Products synced
     - New Products created
     - Existing Products updated

---

## 🎯 Step 4: Verify Products Were Imported

1. **Go to Products Page**
   ```
   http://localhost:3001/products
   ```

2. **Check for Shopify Products**
   - You should see all your Shopify products
   - They'll have:
     - Product names from Shopify
     - Prices from Shopify
     - Images from Shopify
     - Product descriptions

3. **Check Customer App**
   ```
   http://localhost:3002/products
   ```
   - Products should appear here too
   - All will be "Unlocked" by default (no milestone requirements)

---

## 🏷️ Step 5: Attach Milestones to Products (Optional)

1. **Edit a Product**
   - Go to Admin → Products
   - Click edit on a Shopify product
   - In "Required Milestones" section
   - Select which milestones unlock this product

2. **Products Without Milestones**
   - Available immediately to all customers
   - Shows as "Unlocked" in customer app

3. **Products With Milestones**
   - Shows as "Locked" until milestone completed
   - Shows which milestone is required

---

## 🔄 Re-Syncing Products

### When to Re-Sync:
- Added new products to Shopify
- Changed product prices
- Updated product images
- Modified product descriptions

### How to Re-Sync:
1. Go to http://localhost:3001/settings/shopify
2. Click "Sync Now"
3. Wait for completion

### What Happens During Sync:
- **New Products**: Created in UnlockEngine
- **Existing Products**: Updated with latest Shopify data
- **Milestone Attachments**: Preserved (not overwritten)
- **Manual Products**: Not affected (only Shopify products updated)

---

## 📊 Product Data Mapping

Here's how Shopify data maps to UnlockEngine:

| Shopify Field | UnlockEngine Field | Notes |
|---------------|-------------------|-------|
| `title` | `name` | Product name |
| `description` | `description` | Full description |
| `handle` | `handle` | URL slug |
| `priceRange.minVariantPrice.amount` | `price` | Product price |
| `compareAtPriceRange` | `compare_at_price` | Original price (if on sale) |
| `images` | `images[]` | Array of image URLs |
| `images[0]` | `thumbnail_url` | First image as thumbnail |
| `variants.availableForSale` | `available_for_sale` | In stock status |
| `variants.quantityAvailable` | `quantity_available` | Stock count |
| `productType` | `category` | Product category |
| `tags` | `tags[]` | Product tags |
| `id` | `external_id` | Shopify product ID |

---

## 🐛 Troubleshooting

### "Shopify API error: 401"
**Problem**: Invalid access token

**Solution**:
1. Double-check token is copied correctly (no extra spaces)
2. Ensure token starts with `shpat_`
3. Verify app is installed in your Shopify store
4. Try regenerating the token

---

### "Shopify API error: 403"
**Problem**: Missing permissions

**Solution**:
1. Go back to Shopify app configuration
2. Ensure Storefront API scopes are checked
3. Save configuration
4. Reinstall the app
5. Copy new token

---

### "No products found"
**Problem**: Store has no products

**Solution**:
1. Add at least one product to your Shopify store
2. Make sure product is "Active" in Shopify
3. Try syncing again

---

### "Sync takes too long"
**Problem**: Large number of products

**Solution**:
- Current implementation syncs first 50 products
- For more products, sync will need to be run multiple times
- Future enhancement: pagination support

---

### "Products not showing in customer app"
**Problem**: Product filter or availability setting

**Solution**:
1. Check `available_for_sale` is true in Shopify
2. In customer app, click "All Products" filter
3. Verify product was actually synced (check admin products page)

---

## 🎯 Best Practices

### 1. Initial Setup
- ✅ Test with development store first
- ✅ Sync a few products before going live
- ✅ Verify data looks correct
- ✅ Attach milestones to test products
- ✅ Test customer experience

### 2. Regular Syncing
- 🔄 Sync after adding new products
- 🔄 Sync after price changes
- 🔄 Sync weekly for inventory updates
- ⚠️ Don't sync too frequently (rate limits)

### 3. Milestone Attachments
- 🎯 Assign milestones manually (not auto-synced)
- 🎯 Group products by tier (SPARK, FLAME, etc.)
- 🎯 Leave some products unlocked for new users

---

## 🚀 Advanced: Using Admin API (Future)

If you also want to create products in Shopify FROM UnlockEngine:

1. Get Admin API token (not Storefront)
2. Request these scopes:
   - `write_products`
   - `read_products`
3. Save in "Admin API Access Token" field
4. Future feature: Create products from UnlockEngine → Sync to Shopify

---

## 📖 Example Workflow

### For a Fitness Brand (FUEGO-style):

1. **Shopify Store**: Sell athletic apparel
   - T-shirts, Shorts, Hoodies, etc.

2. **Connect to UnlockEngine**
   - Sync all 20 products from Shopify

3. **Create Milestones in UnlockEngine**
   - SPARK: Walk 10,000 steps
   - FLAME: Run 5K
   - INFERNO: Complete marathon

4. **Attach Products to Milestones**
   - SPARK Tee → Unlocked by "Walk 10,000 steps"
   - FLAME Shorts → Unlocked by "Run 5K"
   - INFERNO Kit → Unlocked by "Complete marathon"

5. **Customer Journey**
   - Customer visits store
   - Sees products (some locked, some unlocked)
   - Completes milestones
   - Unlocks new products
   - Purchases exclusive items

---

## ✅ Success Checklist

- [ ] Got Shopify Storefront Access Token
- [ ] Saved credentials in UnlockEngine
- [ ] Ran first sync successfully
- [ ] Products appear in admin products page
- [ ] Products appear in customer products page
- [ ] Attached milestones to at least one product
- [ ] Tested lock/unlock flow in customer app

---

## 🆘 Still Having Issues?

1. **Check browser console** for errors
   - Press F12 → Console tab
   - Look for red error messages

2. **Check Supabase logs**
   - Go to Supabase dashboard
   - Logs tab
   - Look for API errors

3. **Verify database**
   - Check `tenants` table has Shopify credentials
   - Check `products` table for `external_id` field

4. **Test API directly**
   - Use Shopify's GraphQL explorer
   - Test your token works
   - https://shopify.dev/docs/api/admin-graphql

---

## 🎉 You're All Set!

Your Shopify store is now connected to UnlockEngine!

Products will automatically sync with all their data including:
- ✅ Names, descriptions, prices
- ✅ Images
- ✅ Inventory status
- ✅ Product categories and tags

Now you can focus on creating awesome milestones and growing your business! 🚀
