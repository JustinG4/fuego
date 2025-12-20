'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import {
  Trophy,
  Package,
  Activity,
  Settings,
  TrendingUp,
  Users,
  ShoppingCart,
  Zap,
  ArrowRight,
  Sparkles,
} from 'lucide-react';
import { supabase } from '@/lib/supabase';

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
      <div className="relative overflow-hidden bg-gradient-to-br from-indigo-500 via-purple-500 to-pink-500 rounded-2xl p-8 text-white">
        <div className="relative z-10">
          <div className="flex items-center gap-2 mb-3">
            <Sparkles className="w-6 h-6" />
            <span className="text-sm font-semibold uppercase tracking-wider">Admin Dashboard</span>
          </div>
          <h1 className="text-5xl font-bold mb-3">
            Welcome to UnlockEngine
          </h1>
          <p className="text-xl text-white/90 max-w-2xl">
            Transform your business with milestone-driven commerce. Configure achievements, connect products, and drive engagement.
          </p>
        </div>
        <div className="absolute top-0 right-0 w-64 h-64 bg-white/10 rounded-full blur-3xl"></div>
        <div className="absolute bottom-0 left-0 w-96 h-96 bg-white/5 rounded-full blur-3xl"></div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Active Milestones"
          value={stats.loading ? '...' : stats.milestones.toString()}
          change={`${stats.tiers} tiers`}
          icon={<Trophy className="w-6 h-6" />}
          gradient="from-blue-500 to-blue-600"
        />
        <StatCard
          title="Products"
          value={stats.loading ? '...' : stats.products.toString()}
          change="In catalog"
          icon={<Package className="w-6 h-6" />}
          gradient="from-green-500 to-emerald-600"
        />
        <StatCard
          title="Metrics"
          value={stats.loading ? '...' : stats.metrics.toString()}
          change="Active tracking"
          icon={<Activity className="w-6 h-6" />}
          gradient="from-purple-500 to-purple-600"
        />
        <StatCard
          title="Database"
          value="Live"
          change="Connected to Supabase ✅"
          icon={<TrendingUp className="w-6 h-6" />}
          gradient="from-orange-500 to-red-500"
        />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <QuickActionCard
          title="Milestones"
          description="Configure achievement requirements and tiers"
          icon={<Trophy className="w-8 h-8" />}
          href="/milestones"
          color="bg-blue-500"
        />
        <QuickActionCard
          title="Products"
          description="Manage products and unlock conditions"
          icon={<Package className="w-8 h-8" />}
          href="/products"
          color="bg-green-500"
        />
        <QuickActionCard
          title="Metrics"
          description="Define tracking metrics and data sources"
          icon={<Activity className="w-8 h-8" />}
          href="/metrics"
          color="bg-purple-500"
        />
        <QuickActionCard
          title="Shopify Integration"
          description="Connect your Shopify store"
          icon={<ShoppingCart className="w-8 h-8" />}
          href="/settings/shopify"
          color="bg-orange-500"
        />
        <QuickActionCard
          title="Domain Config"
          description="Configure your business vertical"
          icon={<Zap className="w-8 h-8" />}
          href="/settings/domain"
          color="bg-pink-500"
        />
        <QuickActionCard
          title="Settings"
          description="General platform settings"
          icon={<Settings className="w-8 h-8" />}
          href="/settings"
          color="bg-gray-500"
        />
      </div>

      <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
          Getting Started
        </h2>
        <ol className="space-y-4">
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
            title="Deploy"
            description="Launch your customer-facing app and start unlocking!"
            href="/settings/deploy"
          />
        </ol>
      </div>
    </div>
  );
}

function StatCard({
  title,
  value,
  change,
  icon,
  gradient,
}: {
  title: string;
  value: string;
  change: string;
  icon: React.ReactNode;
  gradient: string;
}) {
  return (
    <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm hover:shadow-md transition-all duration-200 overflow-hidden group">
      <div className="p-6">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <p className="text-sm font-medium text-gray-600 dark:text-gray-400">
              {title}
            </p>
            <p className="mt-2 text-3xl font-bold text-gray-900 dark:text-white">
              {value}
            </p>
            <p className="mt-1 text-xs text-green-600 dark:text-green-400 font-medium">
              {change}
            </p>
          </div>
          <div className={`bg-gradient-to-br ${gradient} rounded-lg p-3 text-white group-hover:scale-110 transition-transform duration-200`}>
            {icon}
          </div>
        </div>
      </div>
      <div className={`h-1 bg-gradient-to-r ${gradient}`}></div>
    </div>
  );
}

function QuickActionCard({
  title,
  description,
  icon,
  href,
  color,
}: {
  title: string;
  description: string;
  icon: React.ReactNode;
  href: string;
  color: string;
}) {
  return (
    <Link
      href={href}
      className="group block bg-white dark:bg-gray-800 rounded-xl shadow-sm hover:shadow-lg transition-all duration-200 p-6 border border-gray-100 dark:border-gray-700 hover:border-indigo-200 dark:hover:border-indigo-800"
    >
      <div className={`${color} rounded-xl p-3 text-white w-fit mb-4 group-hover:scale-110 transition-transform duration-200`}>
        {icon}
      </div>
      <div className="flex items-center justify-between mb-2">
        <h3 className="text-xl font-bold text-gray-900 dark:text-white">
          {title}
        </h3>
        <ArrowRight className="w-5 h-5 text-gray-400 group-hover:text-indigo-500 group-hover:translate-x-1 transition-all duration-200" />
      </div>
      <p className="text-gray-600 dark:text-gray-400 text-sm">{description}</p>
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
    <div className="flex gap-4">
      <div className="flex-shrink-0">
        <div className="w-8 h-8 bg-brand-500 text-white rounded-full flex items-center justify-center font-bold">
          {number}
        </div>
      </div>
      <div>
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
          {title}
        </h3>
        <p className="text-gray-600 dark:text-gray-400 mt-1">{description}</p>
        <Link
          href={href}
          className="text-brand-500 hover:text-brand-600 font-medium mt-2 inline-block"
        >
          Configure →
        </Link>
      </div>
    </div>
  );
}
