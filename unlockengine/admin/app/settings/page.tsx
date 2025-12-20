'use client';

import Link from 'next/link';
import {
  ShoppingCart,
  Palette,
  Globe,
  Key,
  Bell,
  Users,
  ArrowRight,
  Check,
} from 'lucide-react';

export default function SettingsPage() {
  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
          Settings
        </h1>
        <p className="mt-2 text-gray-600 dark:text-gray-400">
          Configure your UnlockEngine platform
        </p>
      </div>

      {/* Settings Sections */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <SettingCard
          title="Shopify Integration"
          description="Connect your Shopify store and sync products"
          icon={<ShoppingCart className="w-6 h-6" />}
          href="/settings/shopify"
          status="connected"
          gradient="from-green-500 to-emerald-600"
        />

        <SettingCard
          title="Domain Configuration"
          description="Set your business vertical and branding"
          icon={<Globe className="w-6 h-6" />}
          href="/settings/domain"
          status="configured"
          gradient="from-blue-500 to-indigo-600"
        />

        <SettingCard
          title="Branding & Theme"
          description="Customize colors, logo, and appearance"
          icon={<Palette className="w-6 h-6" />}
          href="/settings/branding"
          status="not-configured"
          gradient="from-purple-500 to-pink-600"
        />

        <SettingCard
          title="API Keys"
          description="Manage API access and webhooks"
          icon={<Key className="w-6 h-6" />}
          href="/settings/api-keys"
          status="configured"
          gradient="from-orange-500 to-red-600"
        />

        <SettingCard
          title="Notifications"
          description="Configure email and push notifications"
          icon={<Bell className="w-6 h-6" />}
          href="/settings/notifications"
          status="not-configured"
          gradient="from-yellow-500 to-orange-600"
        />

        <SettingCard
          title="Team & Access"
          description="Manage team members and permissions"
          icon={<Users className="w-6 h-6" />}
          href="/settings/team"
          status="configured"
          gradient="from-teal-500 to-cyan-600"
        />
      </div>

      {/* Quick Actions */}
      <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 p-6">
        <h2 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
          Quick Setup Guide
        </h2>
        <div className="space-y-3">
          <QuickSetupStep
            step={1}
            title="Connect Shopify Store"
            completed={true}
            href="/settings/shopify"
          />
          <QuickSetupStep
            step={2}
            title="Configure Domain & Branding"
            completed={true}
            href="/settings/domain"
          />
          <QuickSetupStep
            step={3}
            title="Set Up API Keys"
            completed={true}
            href="/settings/api-keys"
          />
          <QuickSetupStep
            step={4}
            title="Enable Notifications"
            completed={false}
            href="/settings/notifications"
          />
          <QuickSetupStep
            step={5}
            title="Invite Team Members"
            completed={false}
            href="/settings/team"
          />
        </div>
      </div>
    </div>
  );
}

function SettingCard({
  title,
  description,
  icon,
  href,
  status,
  gradient,
}: {
  title: string;
  description: string;
  icon: React.ReactNode;
  href: string;
  status: 'connected' | 'configured' | 'not-configured';
  gradient: string;
}) {
  const statusConfig = {
    connected: {
      label: 'Connected',
      color: 'bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-300',
    },
    configured: {
      label: 'Configured',
      color: 'bg-blue-100 text-blue-700 dark:bg-blue-900 dark:text-blue-300',
    },
    'not-configured': {
      label: 'Not Set Up',
      color: 'bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300',
    },
  };

  return (
    <Link
      href={href}
      className="group block bg-white dark:bg-gray-800 rounded-xl shadow-sm hover:shadow-lg transition-all duration-200 p-6 border border-gray-100 dark:border-gray-700 hover:border-indigo-200 dark:hover:border-indigo-800"
    >
      <div className="flex items-start justify-between mb-4">
        <div className={`bg-gradient-to-br ${gradient} rounded-xl p-3 text-white group-hover:scale-110 transition-transform duration-200`}>
          {icon}
        </div>
        <span className={`px-2.5 py-1 rounded-full text-xs font-medium ${statusConfig[status].color}`}>
          {statusConfig[status].label}
        </span>
      </div>

      <div className="flex items-center justify-between">
        <div className="flex-1">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-1 group-hover:text-indigo-600 dark:group-hover:text-indigo-400 transition-colors">
            {title}
          </h3>
          <p className="text-sm text-gray-600 dark:text-gray-400">{description}</p>
        </div>
        <ArrowRight className="w-5 h-5 text-gray-400 group-hover:text-indigo-500 group-hover:translate-x-1 transition-all duration-200 ml-4" />
      </div>
    </Link>
  );
}

function QuickSetupStep({
  step,
  title,
  completed,
  href,
}: {
  step: number;
  title: string;
  completed: boolean;
  href: string;
}) {
  return (
    <Link
      href={href}
      className="flex items-center gap-3 p-3 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors group"
    >
      <div className={`flex-shrink-0 w-6 h-6 rounded-full flex items-center justify-center text-sm font-semibold ${
        completed
          ? 'bg-green-500 text-white'
          : 'bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-400'
      }`}>
        {completed ? <Check className="w-4 h-4" /> : step}
      </div>
      <span className={`text-sm font-medium flex-1 ${
        completed
          ? 'text-gray-500 dark:text-gray-400 line-through'
          : 'text-gray-900 dark:text-white'
      }`}>
        {title}
      </span>
      {!completed && (
        <ArrowRight className="w-4 h-4 text-gray-400 group-hover:text-indigo-500 group-hover:translate-x-0.5 transition-all" />
      )}
    </Link>
  );
}
