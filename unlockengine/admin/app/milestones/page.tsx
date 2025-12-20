'use client';

import { useState, useEffect } from 'react';
import { Plus, Edit2, Trash2, Trophy, CheckCircle } from 'lucide-react';
import { supabase } from '@/lib/supabase';
import MilestoneCreateModal from '@/components/MilestoneCreateModal';

interface Tier {
  id: string;
  name: string;
  color: string;
  display_order: number;
  description: string | null;
}

interface Milestone {
  id: string;
  name: string;
  description: string;
  display_order: number;
  tier_id: string;
  requirements: any[];
  reward_product_ids: string[];
  is_active: boolean;
}

export default function MilestonesPage() {
  const [tiers, setTiers] = useState<Tier[]>([]);
  const [milestones, setMilestones] = useState<Milestone[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [tenantId, setTenantId] = useState<string>('');

  useEffect(() => {
    console.log('[Milestones Page] Component mounted, loading data...');
    loadData();
  }, []);

  async function loadData() {
    try {
      setLoading(true);
      console.log('[Milestones Page] Starting data load...');

      // Get FUEGO tenant
      const { data: tenant, error: tenantError } = await supabase
        .from('tenants')
        .select('id')
        .eq('slug', 'fuego')
        .single();

      console.log('[Milestones Page] Tenant query result:', { tenant, tenantError });

      if (tenantError) throw tenantError;
      if (!tenant) throw new Error('FUEGO tenant not found');

      setTenantId(tenant.id);

      // Load tiers
      const { data: tiersData, error: tiersError } = await supabase
        .from('milestone_tiers')
        .select('*')
        .eq('tenant_id', tenant.id)
        .order('display_order');

      console.log('[Milestones Page] Tiers query result:', {
        count: tiersData?.length,
        tiers: tiersData,
        error: tiersError
      });

      if (tiersError) throw tiersError;

      // Load milestones
      const { data: milestonesData, error: milestonesError } = await supabase
        .from('milestones')
        .select('*')
        .eq('tenant_id', tenant.id)
        .order('display_order');

      console.log('[Milestones Page] Milestones query result:', {
        count: milestonesData?.length,
        milestones: milestonesData,
        error: milestonesError
      });

      if (milestonesError) throw milestonesError;

      setTiers(tiersData || []);
      setMilestones(milestonesData || []);
      console.log('[Milestones Page] Successfully loaded', tiersData?.length, 'tiers and', milestonesData?.length, 'milestones');
    } catch (err: any) {
      setError(err.message);
      console.error('[Milestones Page] Error loading data:', err);
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600 mx-auto mb-4"></div>
          <p className="text-gray-600 dark:text-gray-400">Loading milestones...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-6">
        <h3 className="text-red-800 dark:text-red-200 font-semibold mb-2">Error Loading Data</h3>
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

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
            Milestones
          </h1>
          <p className="mt-2 text-gray-600 dark:text-gray-400">
            Configure achievement requirements and unlock tiers
          </p>
        </div>
        <button
          onClick={() => setShowCreateModal(true)}
          className="inline-flex items-center px-4 py-2 border border-transparent rounded-lg shadow-sm text-sm font-medium text-white bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700"
        >
          <Plus className="w-4 h-4 mr-2" />
          Create Milestone
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6">
          <p className="text-sm text-gray-600 dark:text-gray-400">Total Tiers</p>
          <p className="text-3xl font-bold text-gray-900 dark:text-white mt-2">{tiers.length}</p>
        </div>
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6">
          <p className="text-sm text-gray-600 dark:text-gray-400">Total Milestones</p>
          <p className="text-3xl font-bold text-gray-900 dark:text-white mt-2">{milestones.length}</p>
        </div>
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6">
          <p className="text-sm text-gray-600 dark:text-gray-400">Active</p>
          <p className="text-3xl font-bold text-green-600 dark:text-green-400 mt-2">
            {milestones.filter(m => m.is_active).length}
          </p>
        </div>
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6">
          <p className="text-sm text-gray-600 dark:text-gray-400">Connected to</p>
          <p className="text-lg font-bold text-indigo-600 dark:text-indigo-400 mt-2">Supabase ✅</p>
        </div>
      </div>

      {/* Tier Sections */}
      <div className="space-y-6">
        {tiers.map((tier) => (
          <TierSection
            key={tier.id}
            tier={tier}
            milestones={milestones.filter(m => m.tier_id === tier.id)}
          />
        ))}
      </div>

      {tiers.length === 0 && (
        <div className="text-center py-12 bg-white dark:bg-gray-800 rounded-xl">
          <Trophy className="w-16 h-16 mx-auto text-gray-400 mb-4" />
          <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2">
            No milestones yet
          </h3>
          <p className="text-gray-600 dark:text-gray-400">
            Create your first milestone to get started
          </p>
        </div>
      )}

      {/* Create Modal */}
      <MilestoneCreateModal
        isOpen={showCreateModal}
        onClose={() => setShowCreateModal(false)}
        onSuccess={loadData}
        tenantId={tenantId}
      />
    </div>
  );
}

function TierSection({ tier, milestones }: { tier: Tier; milestones: Milestone[] }) {
  return (
    <div className="border border-gray-200 dark:border-gray-700 rounded-xl overflow-hidden">
      <div
        className="px-6 py-4"
        style={{
          backgroundColor: `${tier.color}20`,
          borderLeftColor: tier.color,
          borderLeftWidth: '4px',
        }}
      >
        <div className="flex items-center gap-3">
          <Trophy className="w-6 h-6" style={{ color: tier.color }} />
          <div>
            <h3 className="text-xl font-bold text-gray-900 dark:text-white">
              {tier.name}
            </h3>
            {tier.description && (
              <p className="text-sm text-gray-600 dark:text-gray-400">{tier.description}</p>
            )}
          </div>
          <div className="ml-auto">
            <span className="px-3 py-1 bg-white dark:bg-gray-800 rounded-full text-sm font-medium text-gray-700 dark:text-gray-300">
              {milestones.length} milestones
            </span>
          </div>
        </div>
      </div>
      <div className="divide-y divide-gray-200 dark:divide-gray-700">
        {milestones.length === 0 ? (
          <div className="px-6 py-8 text-center text-gray-500 dark:text-gray-400">
            No milestones in this tier
          </div>
        ) : (
          milestones.map((milestone) => (
            <MilestoneRow key={milestone.id} milestone={milestone} />
          ))
        )}
      </div>
    </div>
  );
}

function MilestoneRow({ milestone }: { milestone: Milestone }) {
  return (
    <div className="px-6 py-4 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
      <div className="flex justify-between items-start">
        <div className="flex-1">
          <div className="flex items-center gap-2">
            <CheckCircle className="w-5 h-5 text-green-500" />
            <h4 className="text-lg font-semibold text-gray-900 dark:text-white">
              {milestone.name}
            </h4>
            {milestone.is_active && (
              <span className="px-2 py-0.5 bg-green-100 dark:bg-green-900 text-green-700 dark:text-green-300 rounded-full text-xs font-medium">
                Active
              </span>
            )}
          </div>
          <p className="text-gray-600 dark:text-gray-400 mt-1">
            {milestone.description}
          </p>
          <div className="mt-2 flex flex-wrap gap-2">
            {milestone.requirements.map((req: any, idx: number) => (
              <span
                key={idx}
                className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 dark:bg-blue-900/50 dark:text-blue-200"
              >
                Requirement {idx + 1}
              </span>
            ))}
          </div>
          {milestone.reward_product_ids.length > 0 && (
            <div className="mt-2">
              <span className="text-xs text-gray-500 dark:text-gray-400">
                Unlocks: {milestone.reward_product_ids.join(', ')}
              </span>
            </div>
          )}
        </div>
        <div className="flex gap-2 ml-4">
          <button className="p-2 text-gray-400 hover:text-blue-500 transition-colors">
            <Edit2 className="w-4 h-4" />
          </button>
          <button className="p-2 text-gray-400 hover:text-red-500 transition-colors">
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  );
}
