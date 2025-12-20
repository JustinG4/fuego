'use client';

import { useState, useEffect } from 'react';
import { Package, Lock, Unlock, ShoppingCart, CheckCircle } from 'lucide-react';
import { supabase, getCurrentTenant } from '@/lib/supabase';

interface Product {
  id: string;
  name: string;
  description: string | null;
  price: number;
  compare_at_price: number | null;
  category: string | null;
  required_milestone_ids: string[];
  available_for_sale: boolean;
  images: string[];
  thumbnail_url: string | null;
}

export default function ProductsPage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<'all' | 'unlocked' | 'locked'>('all');

  useEffect(() => {
    loadProducts();
  }, []);

  async function loadProducts() {
    try {
      const tenant = await getCurrentTenant();

      const { data: productsData } = await supabase
        .from('products')
        .select('*')
        .eq('tenant_id', tenant.id)
        .eq('available_for_sale', true)
        .order('created_at');

      setProducts(productsData || []);
    } catch (error) {
      console.error('Error loading products:', error);
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600 mx-auto mb-4"></div>
          <p className="text-gray-600 dark:text-gray-400">Loading products...</p>
        </div>
      </div>
    );
  }

  const filteredProducts = products.filter((product) => {
    if (filter === 'unlocked') return product.required_milestone_ids.length === 0;
    if (filter === 'locked') return product.required_milestone_ids.length > 0;
    return true;
  });

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 py-12">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-12">
          <h1 className="text-5xl font-bold text-gray-900 dark:text-white mb-4">
            Shop Products
          </h1>
          <p className="text-xl text-gray-600 dark:text-gray-400">
            Exclusive products unlocked through your achievements
          </p>
          <div className="mt-4 flex items-center justify-center gap-2 text-sm text-green-600 dark:text-green-400">
            <CheckCircle className="w-4 h-4" />
            <span>Connected to Supabase - Showing real data!</span>
          </div>
        </div>

        {/* Filter Tags */}
        <div className="flex flex-wrap gap-3 justify-center mb-12">
          <button
            onClick={() => setFilter('all')}
            className={`px-6 py-2 rounded-full font-semibold transition-colors ${
              filter === 'all'
                ? 'bg-indigo-600 text-white'
                : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600'
            }`}
          >
            All Products ({products.length})
          </button>
          <button
            onClick={() => setFilter('unlocked')}
            className={`px-6 py-2 rounded-full font-semibold transition-colors ${
              filter === 'unlocked'
                ? 'bg-indigo-600 text-white'
                : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600'
            }`}
          >
            Unlocked Only
          </button>
          <button
            onClick={() => setFilter('locked')}
            className={`px-6 py-2 rounded-full font-semibold transition-colors ${
              filter === 'locked'
                ? 'bg-indigo-600 text-white'
                : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600'
            }`}
          >
            Locked
          </button>
        </div>

        {/* Products Grid */}
        {filteredProducts.length === 0 ? (
          <div className="text-center py-12">
            <Package className="w-16 h-16 mx-auto text-gray-400 mb-4" />
            <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
              No products found
            </h3>
            <p className="text-gray-600 dark:text-gray-400">
              {filter !== 'all' ? 'Try a different filter' : 'Products will appear here once created'}
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {filteredProducts.map((product) => (
              <ProductCard key={product.id} product={product} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function ProductCard({ product }: { product: Product }) {
  const isLocked = product.required_milestone_ids.length > 0;
  const imageUrl = product.thumbnail_url || product.images[0] || null;

  return (
    <div className={`bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden hover:shadow-xl transition-all group ${
      isLocked ? 'opacity-75' : ''
    }`}>
      {/* Image */}
      <div className="relative aspect-square bg-gradient-to-br from-gray-200 to-gray-300 dark:from-gray-700 dark:to-gray-600">
        {imageUrl ? (
          <img
            src={imageUrl}
            alt={product.name}
            className="absolute inset-0 w-full h-full object-cover"
            onError={(e) => {
              (e.target as HTMLImageElement).style.display = 'none';
            }}
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center">
            <Package className="w-24 h-24 text-gray-400" />
          </div>
        )}

        {/* Status Badge */}
        <div className="absolute top-4 right-4">
          {isLocked ? (
            <div className="flex items-center gap-1.5 px-3 py-1.5 bg-red-500 text-white rounded-lg font-semibold text-sm">
              <Lock className="w-4 h-4" />
              Locked
            </div>
          ) : (
            <div className="flex items-center gap-1.5 px-3 py-1.5 bg-green-500 text-white rounded-lg font-semibold text-sm">
              <Unlock className="w-4 h-4" />
              Unlocked
            </div>
          )}
        </div>

        {/* Category Badge */}
        {product.category && (
          <div className="absolute top-4 left-4">
            <div className="px-3 py-1 bg-black/50 backdrop-blur-sm text-white rounded-lg font-semibold text-xs">
              {product.category}
            </div>
          </div>
        )}
      </div>

      {/* Content */}
      <div className="p-6">
        <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2 group-hover:text-indigo-600 dark:group-hover:text-indigo-400 transition-colors">
          {product.name}
        </h3>

        {product.description && (
          <p className="text-sm text-gray-600 dark:text-gray-400 mb-4 line-clamp-2">
            {product.description}
          </p>
        )}

        {/* Price */}
        <div className="flex items-baseline gap-2 mb-4">
          <span className="text-2xl font-bold text-gray-900 dark:text-white">
            ${product.price.toFixed(2)}
          </span>
          {product.compare_at_price && (
            <span className="text-sm text-gray-500 line-through">
              ${product.compare_at_price.toFixed(2)}
            </span>
          )}
        </div>

        {/* Locked Message */}
        {isLocked && product.required_milestone_ids.length > 0 && (
          <div className="mb-4 p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg">
            <p className="text-sm text-red-700 dark:text-red-300">
              <span className="font-semibold">Required:</span> Complete {product.required_milestone_ids.length} milestone{product.required_milestone_ids.length !== 1 ? 's' : ''}
            </p>
          </div>
        )}

        {/* Action Button */}
        {isLocked ? (
          <button
            disabled
            className="w-full py-3 bg-gray-300 dark:bg-gray-700 text-gray-500 dark:text-gray-400 rounded-lg font-semibold cursor-not-allowed"
          >
            <Lock className="w-4 h-4 inline mr-2" />
            Unlock to Purchase
          </button>
        ) : (
          <button className="w-full py-3 bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 text-white rounded-lg font-semibold transition-all flex items-center justify-center gap-2">
            <ShoppingCart className="w-4 h-4" />
            Add to Cart
          </button>
        )}
      </div>
    </div>
  );
}
