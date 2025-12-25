'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Package, Lock, Unlock, ShoppingCart } from 'lucide-react';
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
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="w-12 h-12 border-2 border-primary-500 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-gray-400 font-light">Loading products...</p>
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
    <div className="min-h-screen py-16">
      <div className="container-custom">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="text-center mb-16"
        >
          <h1 className="text-5xl md:text-6xl font-light text-white mb-4 tracking-tight">
            Shop Products
          </h1>
          <p className="text-xl text-gray-400 font-light max-w-3xl mx-auto">
            Exclusive products unlocked through your achievements
          </p>
        </motion.div>

        {/* Filter Tags */}
        <div className="flex items-center justify-center gap-2 mb-12">
          {[
            { value: 'all' as const, label: 'All Products', count: products.length },
            { value: 'unlocked' as const, label: 'Unlocked', icon: <Unlock className="w-4 h-4" /> },
            { value: 'locked' as const, label: 'Locked', icon: <Lock className="w-4 h-4" /> }
          ].map((item) => (
            <button
              key={item.value}
              onClick={() => setFilter(item.value)}
              className={`px-6 py-2 text-sm font-medium uppercase tracking-wide transition-all duration-300 ${
                filter === item.value
                  ? 'bg-primary-500 text-black'
                  : 'border border-brand-border text-white hover:border-white'
              } inline-flex items-center gap-2`}
            >
              {item.icon}
              {item.label}
              {item.count !== undefined && ` (${item.count})`}
            </button>
          ))}
        </div>

        {/* Products Grid */}
        {filteredProducts.length === 0 ? (
          <div className="text-center py-20">
            <Package className="w-16 h-16 mx-auto text-gray-600 mb-4" />
            <h3 className="text-xl font-light text-white mb-2">
              No products found
            </h3>
            <p className="text-gray-400 font-light">
              {filter !== 'all' ? 'Try a different filter' : 'Products will appear here once created'}
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {filteredProducts.map((product, index) => (
              <motion.div
                key={product.id}
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: index * 0.1 }}
              >
                <ProductCard product={product} />
              </motion.div>
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
    <div className="product-card group">
      {/* Image */}
      <div className="relative aspect-[3/4] bg-brand-gray overflow-hidden">
        {imageUrl ? (
          <img
            src={imageUrl}
            alt={product.name}
            className="absolute inset-0 w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
            onError={(e) => {
              (e.target as HTMLImageElement).style.display = 'none';
            }}
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center">
            <Package className="w-20 h-20 text-gray-600" />
          </div>
        )}

        {/* Overlay */}
        <div className="absolute inset-0 bg-black/20 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>

        {/* Status Badge */}
        <div className="absolute top-4 right-4 z-10">
          {isLocked ? (
            <div className="badge-locked flex items-center gap-1">
              <Lock className="w-3 h-3" />
              Locked
            </div>
          ) : (
            <div className="badge-unlocked flex items-center gap-1">
              <Unlock className="w-3 h-3" />
              Unlocked
            </div>
          )}
        </div>

        {/* Category */}
        {product.category && (
          <div className="absolute top-4 left-4 z-10">
            <div className="px-2 py-1 bg-black/70 text-white text-xs font-medium uppercase tracking-wide">
              {product.category}
            </div>
          </div>
        )}
      </div>

      {/* Content */}
      <div className="p-4 text-center">
        <h3 className="text-lg font-light text-white mb-1">
          {product.name}
        </h3>
        <p className="text-sm text-gray-400 mb-3">
          ${product.price.toFixed(2)}
          {product.compare_at_price && (
            <span className="ml-2 line-through text-gray-600">
              ${product.compare_at_price.toFixed(2)}
            </span>
          )}
        </p>

        {isLocked ? (
          <p className="text-xs text-gray-500 font-medium uppercase tracking-wide">
            {product.required_milestone_ids.length} Milestone{product.required_milestone_ids.length !== 1 ? 's' : ''} Required
          </p>
        ) : (
          <button className="btn-secondary w-full text-xs py-2">
            <ShoppingCart className="w-3 h-3 inline mr-2" />
            Add to Cart
          </button>
        )}
      </div>
    </div>
  );
}
