/**
 * Brand Configuration
 * Customize this file to match your brand identity
 */

export const brandConfig = {
  // Brand Name
  name: 'UnlockEngine Store',
  tagline: 'Earn Your Rewards',

  // Domain Configuration
  domain: 'fitness', // Options: 'fitness', 'gaming', 'fashion', 'education', 'custom'

  // Colors (Tailwind classes or hex values)
  colors: {
    primary: '#EF4444',        // Main brand color
    secondary: '#3B82F6',      // Secondary accent
    success: '#10B981',        // Success/unlocked state
    warning: '#F59E0B',        // Warning/in-progress state
    locked: '#6B7280',         // Locked state
  },

  // Logo & Assets
  logo: '/logo.svg',
  icon: '/icon.svg',
  favicon: '/favicon.ico',

  // Typography
  fonts: {
    heading: 'Inter',
    body: 'Inter',
  },

  // Feature Flags
  features: {
    showLeaderboard: true,
    showSocialSharing: true,
    allowManualTracking: false,
    showProgressPercentages: true,
    enableNotifications: true,
  },

  // Milestone Tier Names (customize for your domain)
  tiers: [
    { id: 'tier1', name: 'SPARK', color: '#FFA500' },
    { id: 'tier2', name: 'FLAME', color: '#FF4444' },
    { id: 'tier3', name: 'INFERNO', color: '#DC2626' },
    { id: 'tier4', name: 'LEGEND', color: '#7C3AED' },
  ],

  // Social Links
  social: {
    twitter: 'https://twitter.com/yourbrand',
    instagram: 'https://instagram.com/yourbrand',
    facebook: 'https://facebook.com/yourbrand',
  },

  // Contact
  contact: {
    email: 'support@yourbrand.com',
    support: 'https://support.yourbrand.com',
  },
};

// Domain-specific configurations
export const domainPresets = {
  fitness: {
    tiers: [
      { id: 'beginner', name: 'ROOKIE', color: '#10B981' },
      { id: 'intermediate', name: 'ATHLETE', color: '#3B82F6' },
      { id: 'advanced', name: 'PRO', color: '#F59E0B' },
      { id: 'elite', name: 'LEGEND', color: '#EF4444' },
    ],
    tagline: 'Earn Your Gear',
  },
  gaming: {
    tiers: [
      { id: 'bronze', name: 'BRONZE', color: '#CD7F32' },
      { id: 'silver', name: 'SILVER', color: '#C0C0C0' },
      { id: 'gold', name: 'GOLD', color: '#FFD700' },
      { id: 'platinum', name: 'PLATINUM', color: '#E5E4E2' },
    ],
    tagline: 'Level Up Your Rewards',
  },
  fashion: {
    tiers: [
      { id: 'essential', name: 'ESSENTIAL', color: '#6B7280' },
      { id: 'premium', name: 'PREMIUM', color: '#3B82F6' },
      { id: 'luxury', name: 'LUXURY', color: '#7C3AED' },
      { id: 'exclusive', name: 'EXCLUSIVE', color: '#1F2937' },
    ],
    tagline: 'Unlock Exclusive Style',
  },
  education: {
    tiers: [
      { id: 'student', name: 'STUDENT', color: '#10B981' },
      { id: 'scholar', name: 'SCHOLAR', color: '#3B82F6' },
      { id: 'expert', name: 'EXPERT', color: '#7C3AED' },
      { id: 'master', name: 'MASTER', color: '#F59E0B' },
    ],
    tagline: 'Learn. Achieve. Unlock.',
  },
};
