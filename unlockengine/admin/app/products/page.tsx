'use client';

import { useState, useEffect } from 'react';
import {
  Plus,
  Edit2,
  Trash2,
  Package,
  Lock,
  Unlock,
  DollarSign,
  Image as ImageIcon,
  Search,
  Filter,
} from 'lucide-react';
import { supabase } from '@/lib/supabase';
import ProductCreateModal from '@/components/ProductCreateModal';

interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  compare_at_price?: number;
  category: string;
  required_milestone_ids: string[];
  available_for_sale: boolean;
  max_quantity?: number;
}

export default function ProductsPage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [filterStatus, setFilterStatus] = useState<string>('all');
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [tenantId, setTenantId] = useState<string>('');

  useEffect(() => {
    console.log('[Products Page] Component mounted, loading data...');
    loadData();
  }, []);

  async function loadData() {
    try {
      setLoading(true);
      console.log('[Products Page] Starting data load...');

      // Get FUEGO tenant
      const { data: tenant, error: tenantError } = await supabase
        .from('tenants')
        .select('id')
        .eq('slug', 'fuego')
        .single();

      console.log('[Products Page] Tenant query result:', { tenant, tenantError });

      if (tenantError) throw tenantError;
      if (!tenant) throw new Error('FUEGO tenant not found');

      setTenantId(tenant.id);

      // Load products
      const { data: productsData, error: productsError } = await supabase
        .from('products')
        .select('*')
        .eq('tenant_id', tenant.id)
        .order('created_at');

      console.log('[Products Page] Products query result:', {
        count: productsData?.length,
        products: productsData,
        error: productsError
      });

      if (productsError) throw productsError;

      setProducts(productsData || []);
      console.log('[Products Page] Successfully loaded', productsData?.length, 'products');
    } catch (err: any) {
      console.error('[Products Page] Error loading data:', err);
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600 mx-auto mb-4"></div>
          <p className="text-gray-600 dark:text-gray-400">Loading products...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-6">
        <h3 className="text-red-800 dark:text-red-200 font-semibold mb-2">Error Loading Products</h3>
        <p className="text-red-600 dark:text-red-400">{error}</p>
        <button
          onClick={loadData}
          className="mt-4 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
        >
          Retry
        </button>
      </div>
    );
  }

  const filteredProducts = products.filter((product) => {
    const matchesSearch = product.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesFilter = filterStatus === 'all' ||
      (filterStatus === 'available' && product.available_for_sale) ||
      (filterStatus === 'unavailable' && !product.available_for_sale);
    return matchesSearch && matchesFilter;
  });

  console.log('[Products Page] Rendering with', products.length, 'products');

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-start">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
            Products
          </h1>
          <p className="mt-2 text-gray-600 dark:text-gray-400">
            Manage products and their unlock requirements
          </p>
        </div>
        <button
          onClick={() => setShowCreateModal(true)}
          className="inline-flex items-center px-4 py-2 border border-transparent rounded-lg shadow-sm text-sm font-medium text-white bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 transition-all"
        >
          <Plus className="w-4 h-4 mr-2" />
          Add Product
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6">
          <p className="text-sm text-gray-600 dark:text-gray-400">Total Products</p>
          <p className="text-3xl font-bold text-gray-900 dark:text-white mt-2">{products.length}</p>
        </div>
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6">
          <p className="text-sm text-gray-600 dark:text-gray-400">Available for Sale</p>
          <p className="text-3xl font-bold text-green-600 dark:text-green-400 mt-2">
            {products.filter(p => p.available_for_sale).length}
          </p>
        </div>
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6">
          <p className="text-sm text-gray-600 dark:text-gray-400">Locked</p>
          <p className="text-3xl font-bold text-red-600 dark:text-red-400 mt-2">
            {products.filter(p => !p.available_for_sale).length}
          </p>
        </div>
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6">
          <p className="text-sm text-gray-600 dark:text-gray-400">Connected to</p>
          <p className="text-lg font-bold text-indigo-600 dark:text-indigo-400 mt-2">Supabase ✅</p>
        </div>
      </div>

      {/* Search and Filters */}
      <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 border border-gray-100 dark:border-gray-700">
        <div className="flex flex-col sm:flex-row gap-4">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="Search products..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-200 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            />
          </div>
          <div className="flex gap-2">
            <button
              onClick={() => setFilterStatus('all')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${
                filterStatus === 'all'
                  ? 'bg-indigo-100 text-indigo-700 dark:bg-indigo-900 dark:text-indigo-300'
                  : 'bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300'
              }`}
            >
              All
            </button>
            <button
              onClick={() => setFilterStatus('available')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${
                filterStatus === 'available'
                  ? 'bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-300'
                  : 'bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300'
              }`}
            >
              Available
            </button>
            <button
              onClick={() => setFilterStatus('unavailable')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${
                filterStatus === 'unavailable'
                  ? 'bg-red-100 text-red-700 dark:bg-red-900 dark:text-red-300'
                  : 'bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300'
              }`}
            >
              Locked
            </button>
          </div>
        </div>
      </div>

      {/* Products Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredProducts.map((product) => (
          <ProductCard key={product.id} product={product} />
        ))}
      </div>

      {filteredProducts.length === 0 && (
        <div className="text-center py-12 bg-white dark:bg-gray-800 rounded-xl">
          <Package className="w-16 h-16 mx-auto text-gray-400 mb-4" />
          <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2">
            No products found
          </h3>
          <p className="text-gray-600 dark:text-gray-400">
            Try adjusting your search or filters
          </p>
        </div>
      )}

      {/* Create Modal */}
      <ProductCreateModal
        isOpen={showCreateModal}
        onClose={() => setShowCreateModal(false)}
        onSuccess={loadData}
        tenantId={tenantId}
      />
    </div>
  );
}

function ProductCard({ product }: { product: Product }) {
  const status = product.available_for_sale
    ? {
        icon: <Unlock className="w-4 h-4" />,
        bg: 'bg-green-100 dark:bg-green-900',
        text: 'text-green-700 dark:text-green-300',
        label: 'Available',
      }
    : {
        icon: <Lock className="w-4 h-4" />,
        bg: 'bg-red-100 dark:bg-red-900',
        text: 'text-red-700 dark:text-red-300',
        label: 'Locked',
      };

  return (
    <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm hover:shadow-lg transition-all duration-200 overflow-hidden border border-gray-100 dark:border-gray-700 group">
      {/* Image */}
      <div className="aspect-video bg-gradient-to-br from-gray-100 to-gray-200 dark:from-gray-700 dark:to-gray-600 flex items-center justify-center relative overflow-hidden">
        <ImageIcon className="w-16 h-16 text-gray-400" />
        <div className="absolute top-3 right-3">
          <span className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium ${status.bg} ${status.text}`}>
            {status.icon}
            {status.label}
          </span>
        </div>
      </div>

      {/* Content */}
      <div className="p-5">
        <div className="flex items-start justify-between mb-3">
          <div className="flex-1">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-1 group-hover:text-indigo-600 dark:group-hover:text-indigo-400 transition-colors">
              {product.name}
            </h3>
            <span className="inline-block px-2 py-0.5 text-xs font-medium bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded">
              {product.category}
            </span>
          </div>
        </div>

        <div className="flex items-baseline gap-2 mb-3">
          <span className="text-2xl font-bold text-gray-900 dark:text-white">
            ${product.price.toFixed(2)}
          </span>
          {product.compare_at_price && (
            <span className="text-sm text-gray-500 line-through">
              ${product.compare_at_price.toFixed(2)}
            </span>
          )}
        </div>

        <div className="space-y-2 mb-4">
          {product.max_quantity && (
            <div className="flex items-center justify-between text-sm">
              <span className="text-gray-600 dark:text-gray-400">Max Quantity</span>
              <span className="font-medium text-gray-900 dark:text-white">
                {product.max_quantity} units
              </span>
            </div>
          )}
          <div className="text-sm">
            <p className="text-gray-600 dark:text-gray-400 mb-1">
              Required Milestones: {product.required_milestone_ids.length}
            </p>
            <div className="flex flex-wrap gap-1">
              {product.required_milestone_ids.slice(0, 3).map((milestoneId, idx) => (
                <span
                  key={idx}
                  className="inline-block px-2 py-0.5 text-xs bg-indigo-50 dark:bg-indigo-900/30 text-indigo-700 dark:text-indigo-300 rounded"
                >
                  {milestoneId}
                </span>
              ))}
              {product.required_milestone_ids.length > 3 && (
                <span className="inline-block px-2 py-0.5 text-xs bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-400 rounded">
                  +{product.required_milestone_ids.length - 3} more
                </span>
              )}
            </div>
          </div>
        </div>

        <div className="flex gap-2">
          <button className="flex-1 inline-flex items-center justify-center px-3 py-2 border border-gray-200 dark:border-gray-600 rounded-lg text-sm font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
            <Edit2 className="w-4 h-4 mr-1.5" />
            Edit
          </button>
          <button className="px-3 py-2 border border-red-200 dark:border-red-800 rounded-lg text-sm font-medium text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors">
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  );
}
