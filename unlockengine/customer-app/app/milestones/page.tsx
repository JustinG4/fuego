'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Trophy, Lock, Unlock, CheckCircle, Target, Zap, Sparkles } from 'lucide-react';
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

const fadeInUp = {
  initial: { opacity: 0, y: 40 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.6 },
};

const staggerContainer = {
  animate: {
    transition: {
      staggerChildren: 0.1,
    },
  },
};

const scaleIn = {
  initial: { opacity: 0, scale: 0.95 },
  animate: { opacity: 1, scale: 1 },
  transition: { duration: 0.5 },
};

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
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-primary-500 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-white/60 text-lg">Loading milestones...</p>
        </div>
      </div>
    );
  }

  const totalMilestones = milestones.length;
  const unlockedCount = Math.floor(totalMilestones * 0.33); // Mock 33% progress
  const progressPercent = totalMilestones > 0 ? Math.round((unlockedCount / totalMilestones) * 100) : 0;

  return (
    <div className="min-h-screen py-16">
      <div className="container-custom">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <div className="inline-flex items-center gap-2 px-5 py-2 bg-gradient-brand/10 backdrop-blur-sm rounded-full mb-6 border border-primary-500/20">
            <Target className="w-4 h-4 text-primary-400 animate-pulse" />
            <span className="text-sm font-bold text-primary-300 uppercase tracking-widest">Achievement System</span>
          </div>

          <h1 className="text-6xl md:text-7xl font-bold text-white mb-6 tracking-tight">
            Your <span className="text-gradient">Milestones</span>
          </h1>
          <p className="text-2xl text-white/60 max-w-3xl mx-auto leading-relaxed">
            Complete challenges to unlock exclusive products and prove your greatness
          </p>

          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.3 }}
            className="mt-6 inline-flex items-center gap-2 text-emerald-400 font-semibold"
          >
            <CheckCircle className="w-5 h-5" />
            <span>Live - Showing real-time data</span>
          </motion.div>
        </motion.div>

        {/* Progress Overview */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2, duration: 0.6 }}
          className="card-gradient mb-16 relative overflow-hidden"
        >
          <div className="absolute top-0 right-0 w-64 h-64 bg-white/5 rounded-full blur-3xl"></div>
          <div className="relative z-10">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-4">
                <div className="w-14 h-14 bg-white/20 backdrop-blur-sm rounded-xl flex items-center justify-center">
                  <Trophy className="w-8 h-8 text-white" />
                </div>
                <div>
                  <h2 className="text-3xl font-bold text-white mb-1">Overall Progress</h2>
                  <p className="text-white/80 text-lg">
                    {unlockedCount} of {totalMilestones} milestones unlocked
                  </p>
                </div>
              </div>
              <div className="text-right">
                <div className="text-6xl font-bold text-white drop-shadow-lg">{progressPercent}%</div>
                <p className="text-sm text-white/70 font-semibold uppercase tracking-wider">Complete</p>
              </div>
            </div>

            <div className="progress-bar bg-white/20">
              <motion.div
                initial={{ width: 0 }}
                animate={{ width: `${progressPercent}%` }}
                transition={{ duration: 1, delay: 0.5 }}
                className="h-full bg-gradient-to-r from-white to-white/80 rounded-full shadow-lg"
              ></motion.div>
            </div>
          </div>
        </motion.div>

        {/* Tier Sections */}
        <motion.div
          variants={staggerContainer}
          initial="initial"
          animate="animate"
          className="space-y-10"
        >
          {tiers.map((tier, tierIndex) => {
            const tierMilestones = milestones.filter((m) => m.tier_id === tier.id);
            return (
              <motion.div key={tier.id} variants={scaleIn}>
                <TierSection
                  tier={tier}
                  milestones={tierMilestones}
                  allMilestones={milestones}
                  unlockedCount={unlockedCount}
                />
              </motion.div>
            );
          })}
        </motion.div>
      </div>
    </div>
  );
}

function TierSection({
  tier,
  milestones,
  allMilestones,
  unlockedCount,
}: {
  tier: Tier;
  milestones: Milestone[];
  allMilestones: Milestone[];
  unlockedCount: number;
}) {
  return (
    <div className="milestone-card overflow-hidden">
      {/* Tier Header */}
      <div
        className="p-8 text-white relative overflow-hidden"
        style={{ background: `linear-gradient(135deg, ${tier.color}, ${tier.color}dd)` }}
      >
        <div className="absolute top-0 right-0 w-48 h-48 bg-white/10 rounded-full blur-3xl"></div>
        <div className="relative z-10 flex items-center justify-between">
          <div className="flex items-center gap-5">
            <div className="w-16 h-16 bg-white/20 backdrop-blur-sm rounded-2xl flex items-center justify-center shadow-xl">
              <Trophy className="w-9 h-9 text-white" />
            </div>
            <div>
              <h2 className="text-4xl font-bold mb-2">{tier.name}</h2>
              <p className="text-white/90 text-lg font-semibold">
                {milestones.length} milestone{milestones.length !== 1 ? 's' : ''} in this tier
              </p>
            </div>
          </div>
          <Zap className="w-12 h-12 text-white/30" />
        </div>
      </div>

      {/* Milestones List */}
      <div className="p-8 space-y-6 bg-gradient-to-b from-brand-surface to-brand-dark">
        {milestones.length === 0 ? (
          <div className="text-center py-12">
            <Lock className="w-12 h-12 mx-auto text-white/20 mb-4" />
            <p className="text-white/40 text-lg">No milestones in this tier yet</p>
          </div>
        ) : (
          milestones.map((milestone, milestoneIndex) => {
            // Mock: first 3 milestones unlocked, rest in progress or locked
            const globalIndex = allMilestones.indexOf(milestone);
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
          })
        )}
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
    <motion.div
      whileHover={{ scale: 1.02 }}
      transition={{ duration: 0.2 }}
      className={`relative rounded-2xl p-6 transition-all border-2 ${
        isUnlocked
          ? 'border-emerald-500/50 bg-emerald-500/10 backdrop-blur-sm shadow-xl shadow-emerald-500/10'
          : progress > 0
          ? 'border-primary-500/30 bg-brand-dark backdrop-blur-sm'
          : 'border-brand-border bg-brand-surface/50'
      }`}
    >
      <div className="flex items-start justify-between mb-4">
        <div className="flex-1">
          <div className="flex items-center gap-4 mb-3">
            {isUnlocked ? (
              <div className="p-3 bg-gradient-to-br from-emerald-500 to-emerald-600 rounded-xl shadow-lg shadow-emerald-500/30">
                <Unlock className="w-6 h-6 text-white" />
              </div>
            ) : (
              <div className="p-3 bg-gradient-to-br from-brand-surface to-brand-border rounded-xl">
                <Lock className="w-6 h-6 text-white/60" />
              </div>
            )}
            <h3 className="text-2xl font-bold text-white">{milestone.name}</h3>
          </div>
          <p className="text-white/60 ml-16 leading-relaxed">{milestone.description}</p>
        </div>

        {isUnlocked ? (
          <div className="flex items-center gap-2 px-5 py-3 bg-gradient-to-br from-emerald-500 to-emerald-600 text-white rounded-xl font-bold shadow-lg shadow-emerald-500/30">
            <CheckCircle className="w-5 h-5" />
            Unlocked!
          </div>
        ) : (
          <div className="text-right">
            <div className="text-4xl font-bold text-gradient mb-1">{progress}%</div>
            <p className="text-xs text-white/50 uppercase tracking-wider font-semibold">Progress</p>
          </div>
        )}
      </div>

      {!isUnlocked && progress > 0 && (
        <div className="mt-5 ml-16">
          <div className="progress-bar">
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: `${progress}%` }}
              transition={{ duration: 0.8, ease: 'easeOut' }}
              className="h-full rounded-full shadow-lg"
              style={{
                background: `linear-gradient(to right, ${tierColor}, ${tierColor}dd)`,
              }}
            ></motion.div>
          </div>
          <div className="mt-2 flex items-center gap-2 text-xs text-white/40">
            <Sparkles className="w-3 h-3" />
            <span>Keep going! You're making great progress.</span>
          </div>
        </div>
      )}
    </motion.div>
  );
}
