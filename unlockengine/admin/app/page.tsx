'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { motion } from 'framer-motion';
import {
  Trophy,
  Package,
  Activity,
  Settings,
  TrendingUp,
  ShoppingCart,
  Zap,
  ArrowRight,
  Sparkles,
  Layers,
} from 'lucide-react';
import { supabase } from '@/lib/supabase';

const container = {
  hidden: { opacity: 0 },
  show: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
    },
  },
};

const item = {
  hidden: { opacity: 0, y: 20 },
  show: { opacity: 1, y: 0 },
};

export default function HomePage() {
  const [stats, setStats] = useState({
    milestones: 0,
    products: 0,
    metrics: 0,
    tiers: 0,
    loading: true,
  });

  useEffect(() => {
    loadStats();
  }, []);

  async function loadStats() {
    try {
      // Get FUEGO tenant
      const { data: tenant } = await supabase
        .from('tenants')
        .select('id')
        .eq('slug', 'fuego')
        .single();

      if (!tenant) return;

      // Load all stats in parallel
      const [milestonesRes, productsRes, metricsRes, tiersRes] = await Promise.all([
        supabase.from('milestones').select('id', { count: 'exact', head: true }).eq('tenant_id', tenant.id).eq('is_active', true),
        supabase.from('products').select('id', { count: 'exact', head: true }).eq('tenant_id', tenant.id),
        supabase.from('metrics').select('id', { count: 'exact', head: true }).eq('tenant_id', tenant.id).eq('is_active', true),
        supabase.from('milestone_tiers').select('id', { count: 'exact', head: true }).eq('tenant_id', tenant.id),
      ]);

      setStats({
        milestones: milestonesRes.count || 0,
        products: productsRes.count || 0,
        metrics: metricsRes.count || 0,
        tiers: tiersRes.count || 0,
        loading: false,
      });
    } catch (error) {
      console.error('Error loading stats:', error);
      setStats(prev => ({ ...prev, loading: false }));
    }
  }

  return (
    <div className="space-y-8">
      {/* Hero Section */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="relative overflow-hidden bg-gradient-brand rounded-2xl p-12 text-white"
      >
        <div className="relative z-10">
          <div className="flex items-center gap-2 mb-4">
            <Sparkles className="w-6 h-6 animate-pulse" />
            <span className="text-sm font-bold uppercase tracking-widest">Admin Dashboard</span>
          </div>
          <h1 className="text-6xl font-bold mb-4 tracking-tight">
            Welcome to UnlockEngine
          </h1>
          <p className="text-xl text-white/90 max-w-3xl leading-relaxed">
            Transform your business with milestone-driven commerce. Configure achievements, connect products, and drive engagement.
          </p>
        </div>
        {/* Gradient orbs */}
        <div className="absolute top-0 right-0 w-96 h-96 bg-white/10 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute bottom-0 left-0 w-96 h-96 bg-white/5 rounded-full blur-3xl"></div>
      </motion.div>

      {/* Stats Grid */}
      <motion.div
        variants={container}
        initial="hidden"
        animate="show"
        className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6"
      >
        <motion.div variants={item}>
          <StatCard
            title="Active Milestones"
            value={stats.loading ? '...' : stats.milestones.toString()}
            change={`${stats.tiers} tiers configured`}
            icon={<Trophy className="w-6 h-6" />}
            trend="up"
          />
        </motion.div>
        <motion.div variants={item}>
          <StatCard
            title="Products"
            value={stats.loading ? '...' : stats.products.toString()}
            change="In catalog"
            icon={<Package className="w-6 h-6" />}
            trend="up"
          />
        </motion.div>
        <motion.div variants={item}>
          <StatCard
            title="Active Metrics"
            value={stats.loading ? '...' : stats.metrics.toString()}
            change="Tracking enabled"
            icon={<Activity className="w-6 h-6" />}
            trend="neutral"
          />
        </motion.div>
        <motion.div variants={item}>
          <StatCard
            title="System Status"
            value="Live"
            change="Connected ✅"
            icon={<TrendingUp className="w-6 h-6" />}
            trend="up"
          />
        </motion.div>
      </motion.div>

      {/* Quick Actions */}
      <motion.div
        variants={container}
        initial="hidden"
        animate="show"
        className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
      >
        <motion.div variants={item}>
          <QuickActionCard
            title="Milestones"
            description="Configure achievement requirements and unlock tiers"
            icon={<Trophy className="w-8 h-8" />}
            href="/milestones"
            badge="Core"
          />
        </motion.div>
        <motion.div variants={item}>
          <QuickActionCard
            title="Products"
            description="Manage products and unlock conditions"
            icon={<Package className="w-8 h-8" />}
            href="/products"
            badge="Core"
          />
        </motion.div>
        <motion.div variants={item}>
          <QuickActionCard
            title="Metrics"
            description="Define tracking metrics and data sources"
            icon={<Activity className="w-8 h-8" />}
            href="/metrics"
            badge="Core"
          />
        </motion.div>
        <motion.div variants={item}>
          <QuickActionCard
            title="Shopify Integration"
            description="Connect and sync your Shopify store"
            icon={<ShoppingCart className="w-8 h-8" />}
            href="/settings/shopify"
            badge="Integration"
          />
        </motion.div>
        <motion.div variants={item}>
          <QuickActionCard
            title="Domain Config"
            description="Configure your business vertical"
            icon={<Zap className="w-8 h-8" />}
            href="/settings/domain"
            badge="Setup"
          />
        </motion.div>
        <motion.div variants={item}>
          <QuickActionCard
            title="Settings"
            description="General platform configuration"
            icon={<Settings className="w-8 h-8" />}
            href="/settings"
            badge="System"
          />
        </motion.div>
      </motion.div>

      {/* Getting Started Section */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.6, duration: 0.5 }}
        className="card-elevated"
      >
        <div className="flex items-center gap-3 mb-6">
          <div className="w-10 h-10 bg-gradient-brand rounded-lg flex items-center justify-center">
            <Layers className="w-5 h-5 text-white" />
          </div>
          <h2 className="text-2xl font-bold text-white">
            Getting Started
          </h2>
        </div>
        <div className="space-y-5">
          <Step
            number={1}
            title="Configure Your Domain"
            description="Choose your business vertical (fitness, gaming, fashion, etc.) and set up branding"
            href="/settings/domain"
          />
          <Step
            number={2}
            title="Define Metrics"
            description="Set up what your users will track (steps, purchases, game levels, etc.)"
            href="/metrics"
          />
          <Step
            number={3}
            title="Create Milestones"
            description="Build achievement tiers and unlock conditions"
            href="/milestones"
          />
          <Step
            number={4}
            title="Connect Products"
            description="Link your Shopify products or create custom products"
            href="/products"
          />
          <Step
            number={5}
            title="Deploy to Production"
            description="Launch your customer-facing app and start unlocking!"
            href="/settings/deploy"
          />
        </div>
      </motion.div>
    </div>
  );
}

function StatCard({
  title,
  value,
  change,
  icon,
  trend,
}: {
  title: string;
  value: string;
  change: string;
  icon: React.ReactNode;
  trend: 'up' | 'down' | 'neutral';
}) {
  const trendColors = {
    up: 'text-emerald-400',
    down: 'text-red-400',
    neutral: 'text-brand-muted',
  };

  return (
    <div className="stat-card group">
      <div className="flex items-start justify-between mb-4">
        <div className="flex-1">
          <p className="text-sm font-semibold text-brand-muted uppercase tracking-wide">
            {title}
          </p>
          <p className="mt-3 text-4xl font-bold text-white">
            {value}
          </p>
        </div>
        <div className="bg-gradient-brand rounded-xl p-3 text-white group-hover:scale-110 group-hover:rotate-6 transition-all duration-300">
          {icon}
        </div>
      </div>
      <p className={`text-sm font-medium ${trendColors[trend]}`}>
        {change}
      </p>
    </div>
  );
}

function QuickActionCard({
  title,
  description,
  icon,
  href,
  badge,
}: {
  title: string;
  description: string;
  icon: React.ReactNode;
  href: string;
  badge: string;
}) {
  return (
    <Link href={href} className="group block">
      <div className="card h-full hover:border-primary-500 hover:shadow-2xl hover:shadow-primary-500/10 transition-all duration-300">
        <div className="flex items-start justify-between mb-4">
          <div className="bg-gradient-brand rounded-xl p-3 text-white group-hover:scale-110 group-hover:rotate-6 transition-all duration-300">
            {icon}
          </div>
          <span className="badge-primary text-xs">
            {badge}
          </span>
        </div>
        <div className="flex items-center justify-between mb-3">
          <h3 className="text-xl font-bold text-white">
            {title}
          </h3>
          <ArrowRight className="w-5 h-5 text-brand-muted group-hover:text-primary-400 group-hover:translate-x-1 transition-all duration-300" />
        </div>
        <p className="text-brand-muted text-sm leading-relaxed">
          {description}
        </p>
      </div>
    </Link>
  );
}

function Step({
  number,
  title,
  description,
  href,
}: {
  number: number;
  title: string;
  description: string;
  href: string;
}) {
  return (
    <div className="flex gap-4 group">
      <div className="flex-shrink-0">
        <div className="w-10 h-10 bg-gradient-brand text-white rounded-xl flex items-center justify-center font-bold text-lg shadow-lg group-hover:scale-110 transition-transform duration-300">
          {number}
        </div>
      </div>
      <div className="flex-1">
        <h3 className="text-lg font-bold text-white mb-1">
          {title}
        </h3>
        <p className="text-brand-muted text-sm leading-relaxed mb-2">
          {description}
        </p>
        <Link
          href={href}
          className="text-primary-400 hover:text-primary-300 font-semibold text-sm inline-flex items-center gap-1 group/link transition-colors"
        >
          Configure
          <ArrowRight className="w-4 h-4 group-hover/link:translate-x-1 transition-transform" />
        </Link>
      </div>
    </div>
  );
}
