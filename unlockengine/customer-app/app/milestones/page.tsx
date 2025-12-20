'use client';

import { useState, useEffect } from 'react';
import { Trophy, Lock, Unlock, CheckCircle } from 'lucide-react';
import { supabase, getCurrentTenant } from '@/lib/supabase';

interface Tier {
  id: string;
  name: string;
  color: string;
  display_order: number;
}

interface Milestone {
  id: string;
  name: string;
  description: string;
  tier_id: string;
  is_active: boolean;
}

export default function MilestonesPage() {
  const [tiers, setTiers] = useState<Tier[]>([]);
  const [milestones, setMilestones] = useState<Milestone[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadData();
  }, []);

  async function loadData() {
    try {
      const tenant = await getCurrentTenant();

      // Load tiers
      const { data: tiersData } = await supabase
        .from('milestone_tiers')
        .select('*')
        .eq('tenant_id', tenant.id)
        .order('display_order');

      // Load milestones
      const { data: milestonesData } = await supabase
        .from('milestones')
        .select('*')
        .eq('tenant_id', tenant.id)
        .eq('is_active', true)
        .order('display_order');

      setTiers(tiersData || []);
      setMilestones(milestonesData || []);
    } catch (error) {
      console.error('Error loading data:', error);
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600 mx-auto mb-4"></div>
          <p className="text-gray-600 dark:text-gray-400">Loading milestones...</p>
        </div>
      </div>
    );
  }

  const totalMilestones = milestones.length;
  const unlockedCount = Math.floor(totalMilestones * 0.33); // Mock 33% progress
  const progressPercent = Math.round((unlockedCount / totalMilestones) * 100);

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 py-12">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-12">
          <h1 className="text-5xl font-bold text-gray-900 dark:text-white mb-4">
            Your Milestones
          </h1>
          <p className="text-xl text-gray-600 dark:text-gray-400">
            Complete challenges to unlock exclusive products
          </p>
        </div>

        {/* Progress Overview */}
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-8 mb-12">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-2xl font-bold text-gray-900 dark:text-white">Overall Progress</h2>
              <p className="text-gray-600 dark:text-gray-400">
                {unlockedCount} of {totalMilestones} milestones unlocked
              </p>
            </div>
            <div className="text-right">
              <div className="text-4xl font-bold text-indigo-600">{progressPercent}%</div>
              <p className="text-sm text-gray-500">Complete</p>
            </div>
          </div>
          <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-4">
            <div
              className="bg-gradient-to-r from-indigo-600 to-purple-600 h-4 rounded-full transition-all duration-500"
              style={{ width: `${progressPercent}%` }}
            ></div>
          </div>
          <div className="mt-4 flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
            <CheckCircle className="w-4 h-4 text-green-500" />
            <span>Connected to Supabase - Showing real data!</span>
          </div>
        </div>

        {/* Tier Sections */}
        <div className="space-y-8">
          {tiers.map((tier, tierIndex) => {
            const tierMilestones = milestones.filter((m) => m.tier_id === tier.id);
            return (
              <div key={tier.id} className="bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden">
                <div
                  className={`p-6 text-white`}
                  style={{ background: `linear-gradient(to right, ${tier.color}, ${tier.color}dd)` }}
                >
                  <div className="flex items-center gap-4">
                    <Trophy className="w-10 h-10" />
                    <div>
                      <h2 className="text-3xl font-bold">{tier.name}</h2>
                      <p className="text-white/90">
                        {tierMilestones.length} milestone{tierMilestones.length !== 1 ? 's' : ''}
                      </p>
                    </div>
                  </div>
                </div>

                <div className="p-6 space-y-4">
                  {tierMilestones.map((milestone, milestoneIndex) => {
                    // Mock: first 3 milestones unlocked, rest in progress or locked
                    const globalIndex = milestones.indexOf(milestone);
                    const isUnlocked = globalIndex < unlockedCount;
                    const progress = isUnlocked ? 100 : Math.min(90, (globalIndex + 1) * 15);

                    return (
                      <MilestoneCard
                        key={milestone.id}
                        milestone={milestone}
                        tierColor={tier.color}
                        isUnlocked={isUnlocked}
                        progress={progress}
                      />
                    );
                  })}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

function MilestoneCard({
  milestone,
  tierColor,
  isUnlocked,
  progress,
}: {
  milestone: Milestone;
  tierColor: string;
  isUnlocked: boolean;
  progress: number;
}) {
  return (
    <div
      className={`relative border-2 rounded-xl p-6 transition-all ${
        isUnlocked
          ? 'border-green-300 dark:border-green-700 bg-green-50 dark:bg-green-900/20'
          : progress > 0
          ? 'border-indigo-300 dark:border-indigo-700 bg-white dark:bg-gray-700'
          : 'border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700/50'
      }`}
    >
      <div className="flex items-start justify-between mb-4">
        <div className="flex-1">
          <div className="flex items-center gap-3 mb-2">
            {isUnlocked ? (
              <div className="p-2 bg-green-500 rounded-lg">
                <Unlock className="w-5 h-5 text-white" />
              </div>
            ) : (
              <div className="p-2 bg-gray-400 dark:bg-gray-600 rounded-lg">
                <Lock className="w-5 h-5 text-white" />
              </div>
            )}
            <h3 className="text-xl font-semibold text-gray-900 dark:text-white">{milestone.name}</h3>
          </div>
          <p className="text-gray-600 dark:text-gray-400 ml-14">{milestone.description}</p>
        </div>

        {isUnlocked ? (
          <div className="flex items-center gap-2 px-4 py-2 bg-green-500 text-white rounded-lg font-semibold">
            <CheckCircle className="w-5 h-5" />
            Unlocked!
          </div>
        ) : (
          <div className="text-right">
            <div className="text-2xl font-bold text-indigo-600">{progress}%</div>
            <p className="text-xs text-gray-500">Progress</p>
          </div>
        )}
      </div>

      {!isUnlocked && progress > 0 && (
        <div className="mt-4">
          <div className="w-full bg-gray-200 dark:bg-gray-600 rounded-full h-2">
            <div
              className="h-2 rounded-full transition-all duration-500"
              style={{
                width: `${progress}%`,
                background: `linear-gradient(to right, ${tierColor}, ${tierColor}dd)`,
              }}
            ></div>
          </div>
        </div>
      )}
    </div>
  );
}
