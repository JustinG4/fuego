'use client';

import { useState, useEffect } from 'react';
import { ShoppingCart, Check, RefreshCw, AlertCircle, ExternalLink, Save } from 'lucide-react';
import { supabase } from '@/lib/supabase';

interface ShopifyCredentials {
  storeDomain: string;
  storefrontToken: string;
  adminToken: string;
}

interface SyncStats {
  totalProducts: number;
  newProducts: number;
  updatedProducts: number;
}

export default function ShopifySettingsPage() {
  const [tenantId, setTenantId] = useState<string>('');
  const [credentials, setCredentials] = useState<ShopifyCredentials>({
    storeDomain: '',
    storefrontToken: '',
    adminToken: '',
  });
  const [isConnected, setIsConnected] = useState(false);
  const [isSyncing, setIsSyncing] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [lastSync, setLastSync] = useState<Date | null>(null);
  const [syncStats, setSyncStats] = useState<SyncStats>({
    totalProducts: 0,
    newProducts: 0,
    updatedProducts: 0,
  });
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadShopifySettings();
  }, []);

  async function loadShopifySettings() {
    try {
      setLoading(true);

      // Get FUEGO tenant
      const { data: tenant, error: tenantError } = await supabase
        .from('tenants')
        .select('id, shopify_store_domain, shopify_storefront_token, shopify_admin_token')
        .eq('slug', 'fuego')
        .single();

      if (tenantError) throw tenantError;
      if (!tenant) throw new Error('Tenant not found');

      setTenantId(tenant.id);

      const hasCredentials = !!(tenant.shopify_store_domain && tenant.shopify_storefront_token);

      if (hasCredentials) {
        setCredentials({
          storeDomain: tenant.shopify_store_domain || '',
          storefrontToken: tenant.shopify_storefront_token || '',
          adminToken: tenant.shopify_admin_token || '',
        });
        setIsConnected(true);
      } else {
        setIsEditing(true);
      }
    } catch (err: any) {
      console.error('Error loading Shopify settings:', err);
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  async function handleSaveCredentials() {
    try {
      setIsSaving(true);
      setError(null);

      // Validate inputs
      if (!credentials.storeDomain || !credentials.storefrontToken) {
        throw new Error('Store domain and Storefront token are required');
      }

      // Update tenant with Shopify credentials
      const { error: updateError } = await supabase
        .from('tenants')
        .update({
          shopify_store_domain: credentials.storeDomain,
          shopify_storefront_token: credentials.storefrontToken,
          shopify_admin_token: credentials.adminToken || null,
        })
        .eq('id', tenantId);

      if (updateError) throw updateError;

      setIsConnected(true);
      setIsEditing(false);

      // Show success message
      alert('Shopify credentials saved successfully!');
    } catch (err: any) {
      console.error('Error saving credentials:', err);
      setError(err.message);
      alert('Error saving credentials: ' + err.message);
    } finally {
      setIsSaving(false);
    }
  }

  async function handleSync() {
    try {
      setIsSyncing(true);
      setError(null);

      const result = await syncShopifyProducts(credentials, tenantId);

      setSyncStats({
        totalProducts: result.total,
        newProducts: result.created,
        updatedProducts: result.updated,
      });
      setLastSync(new Date());

      alert(`Sync complete! ${result.created} new products, ${result.updated} updated.`);
    } catch (err: any) {
      console.error('Error syncing products:', err);
      setError(err.message);
      alert('Error syncing products: ' + err.message);
    } finally {
      setIsSyncing(false);
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600 mx-auto mb-4"></div>
          <p className="text-gray-600 dark:text-gray-400">Loading Shopify settings...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-4xl">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
          Shopify Integration
        </h1>
        <p className="mt-2 text-gray-600 dark:text-gray-400">
          Connect and sync your Shopify store with UnlockEngine
        </p>
      </div>

      {/* Error Banner */}
      {error && (
        <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl p-4">
          <p className="text-sm text-red-700 dark:text-red-300">{error}</p>
        </div>
      )}

      {/* Connection Status */}
      {isConnected ? (
        <div className="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-xl p-6">
          <div className="flex items-start gap-4">
            <div className="p-3 bg-green-500 rounded-lg">
              <Check className="w-6 h-6 text-white" />
            </div>
            <div className="flex-1">
              <h3 className="text-lg font-semibold text-green-900 dark:text-green-100 mb-1">
                Store Connected
              </h3>
              <p className="text-sm text-green-700 dark:text-green-300 mb-3">
                Your Shopify store is successfully connected and syncing.
              </p>
              <div className="flex items-center gap-4 text-sm">
                <div>
                  <span className="text-green-600 dark:text-green-400 font-medium">Store:</span>{' '}
                  <span className="text-green-900 dark:text-green-100">{credentials.storeDomain}</span>
                </div>
                {lastSync && (
                  <div>
                    <span className="text-green-600 dark:text-green-400 font-medium">Last Sync:</span>{' '}
                    <span className="text-green-900 dark:text-green-100">{lastSync.toLocaleTimeString()}</span>
                  </div>
                )}
              </div>
            </div>
            <button
              onClick={() => setIsEditing(true)}
              className="text-sm text-green-700 dark:text-green-300 hover:underline"
            >
              Edit
            </button>
          </div>
        </div>
      ) : (
        <div className="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-xl p-6">
          <div className="flex items-start gap-4">
            <div className="p-3 bg-yellow-500 rounded-lg">
              <AlertCircle className="w-6 h-6 text-white" />
            </div>
            <div className="flex-1">
              <h3 className="text-lg font-semibold text-yellow-900 dark:text-yellow-100 mb-1">
                No Store Connected
              </h3>
              <p className="text-sm text-yellow-700 dark:text-yellow-300 mb-3">
                Enter your Shopify credentials below to start syncing products.
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Store Configuration */}
      <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
        <div className="p-6 border-b border-gray-200 dark:border-gray-700">
          <h2 className="text-lg font-semibold text-gray-900 dark:text-white">
            Store Configuration
          </h2>
        </div>
        <div className="p-6 space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Store Domain
            </label>
            <input
              type="text"
              value={credentials.storeDomain}
              onChange={(e) => setCredentials({ ...credentials, storeDomain: e.target.value })}
              disabled={!isEditing}
              placeholder="your-store.myshopify.com"
              className="w-full px-4 py-2 border border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white disabled:bg-gray-50 disabled:dark:bg-gray-800"
            />
            <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">
              Your Shopify store domain (e.g., example.myshopify.com)
            </p>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Storefront Access Token
            </label>
            <input
              type={isEditing ? 'text' : 'password'}
              value={credentials.storefrontToken}
              onChange={(e) => setCredentials({ ...credentials, storefrontToken: e.target.value })}
              disabled={!isEditing}
              placeholder="shpat_..."
              className="w-full px-4 py-2 border border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white disabled:bg-gray-50 disabled:dark:bg-gray-800"
            />
            <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">
              Used for fetching products via Storefront API
            </p>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Admin API Access Token (Optional)
            </label>
            <input
              type={isEditing ? 'text' : 'password'}
              value={credentials.adminToken}
              onChange={(e) => setCredentials({ ...credentials, adminToken: e.target.value })}
              disabled={!isEditing}
              placeholder="shpat_... (optional)"
              className="w-full px-4 py-2 border border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white disabled:bg-gray-50 disabled:dark:bg-gray-800"
            />
            <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">
              Used for admin operations and product management
            </p>
          </div>

          {isEditing && (
            <div className="flex gap-3 pt-4">
              <button
                onClick={handleSaveCredentials}
                disabled={isSaving}
                className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors disabled:opacity-50"
              >
                <Save className="w-4 h-4 mr-2" />
                {isSaving ? 'Saving...' : 'Save Credentials'}
              </button>
              {isConnected && (
                <button
                  onClick={() => {
                    setIsEditing(false);
                    loadShopifySettings(); // Reload to reset form
                  }}
                  className="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
                >
                  Cancel
                </button>
              )}
            </div>
          )}
        </div>
      </div>

      {/* Sync Products */}
      {isConnected && (
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
          <div className="p-6 border-b border-gray-200 dark:border-gray-700">
            <h2 className="text-lg font-semibold text-gray-900 dark:text-white">
              Sync Products
            </h2>
          </div>
          <div className="p-6">
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-4">
              Manually sync products from your Shopify store to UnlockEngine
            </p>
            <button
              onClick={handleSync}
              disabled={isSyncing || !isConnected}
              className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <RefreshCw className={`w-4 h-4 mr-2 ${isSyncing ? 'animate-spin' : ''}`} />
              {isSyncing ? 'Syncing Products...' : 'Sync Now'}
            </button>
          </div>
        </div>
      )}

      {/* Sync Status */}
      {lastSync && (
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
          <div className="p-6 border-b border-gray-200 dark:border-gray-700">
            <h2 className="text-lg font-semibold text-gray-900 dark:text-white">
              Last Sync Summary
            </h2>
          </div>
          <div className="p-6">
            <div className="grid grid-cols-3 gap-6">
              <div>
                <p className="text-sm text-gray-600 dark:text-gray-400 mb-1">Total Products</p>
                <p className="text-2xl font-bold text-gray-900 dark:text-white">{syncStats.totalProducts}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600 dark:text-gray-400 mb-1">New Products</p>
                <p className="text-2xl font-bold text-green-600 dark:text-green-400">{syncStats.newProducts}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600 dark:text-gray-400 mb-1">Updated</p>
                <p className="text-2xl font-bold text-blue-600 dark:text-blue-400">{syncStats.updatedProducts}</p>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Help */}
      <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-xl p-6">
        <h3 className="text-sm font-semibold text-blue-900 dark:text-blue-100 mb-2">
          Need Help Setting Up?
        </h3>
        <p className="text-sm text-blue-700 dark:text-blue-300 mb-3">
          Get your Shopify Storefront Access Token from: Settings → Apps and sales channels → Develop apps
        </p>
        <a
          href="https://shopify.dev/docs/api/usage/authentication"
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center text-sm font-medium text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300"
        >
          View Shopify API Docs
          <ExternalLink className="w-4 h-4 ml-1" />
        </a>
      </div>
    </div>
  );
}

// Shopify Product Sync Function
async function syncShopifyProducts(credentials: ShopifyCredentials, tenantId: string) {
  const { storeDomain, storefrontToken } = credentials;

  if (!storeDomain || !storefrontToken) {
    throw new Error('Missing Shopify credentials');
  }

  // Build Shopify Storefront API endpoint
  const shopifyUrl = `https://${storeDomain}/api/2024-01/graphql.json`;

  // GraphQL query to fetch products
  const query = `
    {
      products(first: 50) {
        edges {
          node {
            id
            title
            description
            handle
            priceRange {
              minVariantPrice {
                amount
                currencyCode
              }
            }
            compareAtPriceRange {
              minVariantPrice {
                amount
              }
            }
            images(first: 5) {
              edges {
                node {
                  url
                  altText
                }
              }
            }
            variants(first: 1) {
              edges {
                node {
                  availableForSale
                  quantityAvailable
                }
              }
            }
            productType
            tags
          }
        }
      }
    }
  `;

  try {
    // Fetch products from Shopify
    const response = await fetch(shopifyUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Shopify-Storefront-Access-Token': storefrontToken,
      },
      body: JSON.stringify({ query }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Shopify API error: ${response.status} - ${errorText}`);
    }

    const data = await response.json();

    if (data.errors) {
      throw new Error(`Shopify GraphQL error: ${JSON.stringify(data.errors)}`);
    }

    const products = data.data?.products?.edges || [];

    if (products.length === 0) {
      return { total: 0, created: 0, updated: 0 };
    }

    // Sync products to database
    let created = 0;
    let updated = 0;

    for (const edge of products) {
      const product = edge.node;
      const shopifyId = product.id;

      // Extract image URLs
      const images = product.images.edges.map((img: any) => img.node.url);
      const thumbnailUrl = images[0] || null;

      // Check if product already exists
      const { data: existingProduct } = await supabase
        .from('products')
        .select('id')
        .eq('tenant_id', tenantId)
        .eq('external_id', shopifyId)
        .single();

      const productData = {
        tenant_id: tenantId,
        external_id: shopifyId,
        name: product.title,
        description: product.description,
        handle: product.handle,
        price: parseFloat(product.priceRange.minVariantPrice.amount),
        compare_at_price: product.compareAtPriceRange?.minVariantPrice?.amount
          ? parseFloat(product.compareAtPriceRange.minVariantPrice.amount)
          : null,
        currency: product.priceRange.minVariantPrice.currencyCode,
        images,
        thumbnail_url: thumbnailUrl,
        available_for_sale: product.variants.edges[0]?.node.availableForSale || false,
        quantity_available: product.variants.edges[0]?.node.quantityAvailable || null,
        category: product.productType || null,
        tags: product.tags || [],
        required_milestone_ids: [], // No milestones by default
        unlock_logic: 'all',
        is_limited_edition: false,
      };

      if (existingProduct) {
        // Update existing product
        await supabase
          .from('products')
          .update(productData)
          .eq('id', existingProduct.id);
        updated++;
      } else {
        // Create new product
        await supabase
          .from('products')
          .insert(productData);
        created++;
      }
    }

    return {
      total: products.length,
      created,
      updated,
    };
  } catch (error: any) {
    console.error('Error syncing Shopify products:', error);
    throw new Error(`Failed to sync products: ${error.message}`);
  }
}
