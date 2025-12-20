'use client';

import { useState, useEffect } from 'react';
import {
  Plus,
  Activity,
  Heart,
  TrendingUp,
  Zap,
  Target,
  Award,
  Edit2,
  Trash2,
  Search,
} from 'lucide-react';
import { supabase } from '@/lib/supabase';

interface Metric {
  id: string;
  name: string;
  description: string;
  source: string;
  data_type: string;
  unit: string;
  category: string;
}

const sourceColors: Record<string, string> = {
  healthkit: 'bg-red-100 text-red-700 dark:bg-red-900 dark:text-red-300',
  manual: 'bg-blue-100 text-blue-700 dark:bg-blue-900 dark:text-blue-300',
  shopify: 'bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-300',
  custom_api: 'bg-purple-100 text-purple-700 dark:bg-purple-900 dark:text-purple-300',
};

const getIconForCategory = (category: string) => {
  switch (category.toLowerCase()) {
    case 'activity': return <Activity className="w-5 h-5" />;
    case 'running': return <TrendingUp className="w-5 h-5" />;
    case 'gym': return <Zap className="w-5 h-5" />;
    case 'health': return <Heart className="w-5 h-5" />;
    case 'achievement': return <Award className="w-5 h-5" />;
    default: return <Target className="w-5 h-5" />;
  }
};

export default function MetricsPage() {
  const [metrics, setMetrics] = useState<Metric[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    console.log('[Metrics Page] Component mounted, loading data...');
    loadData();
  }, []);

  async function loadData() {
    try {
      setLoading(true);
      console.log('[Metrics Page] Starting data load...');

      // Get FUEGO tenant
      const { data: tenant, error: tenantError } = await supabase
        .from('tenants')
        .select('id')
        .eq('slug', 'fuego')
        .single();

      console.log('[Metrics Page] Tenant query result:', { tenant, tenantError });

      if (tenantError) throw tenantError;
      if (!tenant) throw new Error('FUEGO tenant not found');

      // Load metrics
      const { data: metricsData, error: metricsError } = await supabase
        .from('metrics')
        .select('*')
        .eq('tenant_id', tenant.id)
        .order('created_at');

      console.log('[Metrics Page] Metrics query result:', {
        count: metricsData?.length,
        metrics: metricsData,
        error: metricsError
      });

      if (metricsError) throw metricsError;

      setMetrics(metricsData || []);
      console.log('[Metrics Page] Successfully loaded', metricsData?.length, 'metrics');
    } catch (err: any) {
      console.error('[Metrics Page] Error loading data:', err);
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
          <p className="text-gray-600 dark:text-gray-400">Loading metrics...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-6">
        <h3 className="text-red-800 dark:text-red-200 font-semibold mb-2">Error Loading Metrics</h3>
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

  const filteredMetrics = metrics.filter((metric) =>
    metric.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    metric.description.toLowerCase().includes(searchQuery.toLowerCase())
  );

  console.log('[Metrics Page] Rendering with', metrics.length, 'metrics');

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-start">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
            Metrics
          </h1>
          <p className="mt-2 text-gray-600 dark:text-gray-400">
            Define what your users track to unlock products
          </p>
        </div>
        <button className="inline-flex items-center px-4 py-2 border border-transparent rounded-lg shadow-sm text-sm font-medium text-white bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 transition-all">
          <Plus className="w-4 h-4 mr-2" />
          Add Metric
        </button>
      </div>

      {/* Stats Overview */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6">
          <p className="text-sm text-gray-600 dark:text-gray-400">Total Metrics</p>
          <p className="text-3xl font-bold text-gray-900 dark:text-white mt-2">{metrics.length}</p>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6">
          <p className="text-sm text-gray-600 dark:text-gray-400">HealthKit</p>
          <p className="text-3xl font-bold text-red-600 dark:text-red-400 mt-2">
            {metrics.filter(m => m.source === 'healthkit').length}
          </p>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6">
          <p className="text-sm text-gray-600 dark:text-gray-400">Data Sources</p>
          <p className="text-3xl font-bold text-purple-600 dark:text-purple-400 mt-2">
            {new Set(metrics.map(m => m.source)).size}
          </p>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6">
          <p className="text-sm text-gray-600 dark:text-gray-400">Connected to</p>
          <p className="text-lg font-bold text-indigo-600 dark:text-indigo-400 mt-2">Supabase ✅</p>
        </div>
      </div>

      {/* Search */}
      <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 border border-gray-100 dark:border-gray-700">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
          <input
            type="text"
            placeholder="Search metrics..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-200 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
          />
        </div>
      </div>

      {/* Metrics List */}
      <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 dark:bg-gray-900 border-b border-gray-200 dark:border-gray-700">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Metric
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Source
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Type
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Category
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
              {filteredMetrics.map((metric) => (
                <tr
                  key={metric.id}
                  className="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
                >
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className="p-2 bg-indigo-100 dark:bg-indigo-900 text-indigo-600 dark:text-indigo-300 rounded-lg">
                        {getIconForCategory(metric.category)}
                      </div>
                      <div>
                        <p className="text-sm font-medium text-gray-900 dark:text-white">
                          {metric.name}
                        </p>
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          {metric.description}
                        </p>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <span className={`inline-flex px-2.5 py-0.5 rounded-full text-xs font-medium ${sourceColors[metric.source] || 'bg-gray-100 text-gray-700'}`}>
                      {metric.source}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm">
                      <p className="text-gray-900 dark:text-white font-medium">
                        {metric.data_type}
                      </p>
                      {metric.unit && (
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          {metric.unit}
                        </p>
                      )}
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <span className="inline-flex px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300">
                      {metric.category}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-2">
                      <button className="p-2 text-gray-400 hover:text-indigo-600 dark:hover:text-indigo-400 transition-colors">
                        <Edit2 className="w-4 h-4" />
                      </button>
                      <button className="p-2 text-gray-400 hover:text-red-600 dark:hover:text-red-400 transition-colors">
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {filteredMetrics.length === 0 && (
        <div className="text-center py-12 bg-white dark:bg-gray-800 rounded-xl">
          <Activity className="w-16 h-16 mx-auto text-gray-400 mb-4" />
          <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2">
            No metrics found
          </h3>
          <p className="text-gray-600 dark:text-gray-400">
            Try adjusting your search
          </p>
        </div>
      )}
    </div>
  );
}
