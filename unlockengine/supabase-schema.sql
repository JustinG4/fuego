-- UnlockEngine Database Schema for Supabase
-- Run this in Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TENANTS
-- ============================================================================
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    domain_config_id UUID,

    -- Shopify Integration
    shopify_store_domain VARCHAR(255),
    shopify_storefront_token TEXT,
    shopify_admin_token TEXT,

    -- Branding
    brand_name VARCHAR(255),
    brand_color VARCHAR(7) DEFAULT '#EF4444',
    logo_url TEXT,

    -- Status
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    metadata JSONB DEFAULT '{}'::jsonb
);

-- ============================================================================
-- DOMAIN CONFIGS
-- ============================================================================
CREATE TABLE domain_configs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,

    -- Branding
    brand_color VARCHAR(7) DEFAULT '#EF4444',

    -- Features
    features JSONB DEFAULT '{
        "allowManualMetricEntry": true,
        "enableSocialSharing": true,
        "enableLeaderboards": false,
        "enableTeamChallenges": false,
        "enableNotifications": true
    }'::jsonb,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

-- ============================================================================
-- METRICS
-- ============================================================================
CREATE TABLE metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,

    name VARCHAR(255) NOT NULL,
    description TEXT,
    source VARCHAR(50) NOT NULL, -- healthkit, manual, shopify, etc.
    data_type VARCHAR(50) NOT NULL, -- number, boolean, string, date
    unit VARCHAR(50),
    category VARCHAR(100),
    icon VARCHAR(255),

    -- Configuration
    config JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT true,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster tenant queries
CREATE INDEX idx_metrics_tenant ON metrics(tenant_id);

-- ============================================================================
-- MILESTONE TIERS
-- ============================================================================
CREATE TABLE milestone_tiers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,

    name VARCHAR(255) NOT NULL,
    display_order INTEGER NOT NULL,
    description TEXT,
    color VARCHAR(7) DEFAULT '#6B7280',
    icon VARCHAR(255),

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_tiers_tenant ON milestone_tiers(tenant_id);

-- ============================================================================
-- MILESTONES
-- ============================================================================
CREATE TABLE milestones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
    tier_id UUID REFERENCES milestone_tiers(id) ON DELETE SET NULL,

    name VARCHAR(255) NOT NULL,
    description TEXT,
    display_order INTEGER NOT NULL,

    -- Requirements (stored as JSONB array)
    requirements JSONB NOT NULL DEFAULT '[]'::jsonb,
    requirement_logic VARCHAR(20) DEFAULT 'all', -- all, any, custom
    custom_logic TEXT, -- JavaScript expression for custom logic

    -- Rewards
    reward_product_ids TEXT[] DEFAULT '{}',
    reward_message TEXT,
    reward_badge VARCHAR(255),

    -- Configuration
    is_active BOOLEAN DEFAULT true,
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    max_unlocks INTEGER,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_milestones_tenant ON milestones(tenant_id);
CREATE INDEX idx_milestones_tier ON milestones(tier_id);

-- ============================================================================
-- PRODUCTS
-- ============================================================================
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,

    external_id VARCHAR(255), -- Shopify product ID
    name VARCHAR(255) NOT NULL,
    description TEXT,
    handle VARCHAR(255) NOT NULL,

    -- Pricing
    price DECIMAL(10, 2) NOT NULL,
    compare_at_price DECIMAL(10, 2),
    currency VARCHAR(3) DEFAULT 'USD',

    -- Media
    images TEXT[] DEFAULT '{}',
    thumbnail_url TEXT,

    -- Inventory
    available_for_sale BOOLEAN DEFAULT true,
    quantity_available INTEGER,

    -- Unlock Configuration
    required_milestone_ids TEXT[] DEFAULT '{}',
    unlock_logic VARCHAR(20) DEFAULT 'all', -- all, any

    -- Scarcity
    is_limited_edition BOOLEAN DEFAULT false,
    max_quantity INTEGER,
    max_per_user INTEGER,

    -- Categorization
    category VARCHAR(100),
    tags TEXT[] DEFAULT '{}',

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_products_tenant ON products(tenant_id);
CREATE INDEX idx_products_handle ON products(handle);

-- ============================================================================
-- USERS
-- ============================================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,

    external_id VARCHAR(255), -- From auth system
    email VARCHAR(255),
    name VARCHAR(255),
    avatar_url TEXT,

    -- Preferences
    notifications_enabled BOOLEAN DEFAULT true,
    share_progress_enabled BOOLEAN DEFAULT false,

    -- Status
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_active_at TIMESTAMP WITH TIME ZONE,

    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_users_tenant ON users(tenant_id);
CREATE INDEX idx_users_external_id ON users(external_id);

-- ============================================================================
-- METRIC VALUES
-- ============================================================================
CREATE TABLE metric_values (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    metric_id UUID REFERENCES metrics(id) ON DELETE CASCADE,

    value JSONB NOT NULL, -- Stores number, boolean, string, or date
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_metric_values_user ON metric_values(user_id);
CREATE INDEX idx_metric_values_metric ON metric_values(metric_id);
CREATE INDEX idx_metric_values_recorded ON metric_values(recorded_at DESC);

-- ============================================================================
-- MILESTONE PROGRESS
-- ============================================================================
CREATE TABLE milestone_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    milestone_id UUID REFERENCES milestones(id) ON DELETE CASCADE,

    is_unlocked BOOLEAN DEFAULT false,
    unlocked_at TIMESTAMP WITH TIME ZONE,
    unlock_count INTEGER DEFAULT 0,
    current_progress DECIMAL(5, 2), -- 0-100 percentage

    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(user_id, milestone_id)
);

CREATE INDEX idx_progress_user ON milestone_progress(user_id);
CREATE INDEX idx_progress_milestone ON milestone_progress(milestone_id);

-- ============================================================================
-- PRODUCT UNLOCKS
-- ============================================================================
CREATE TABLE product_unlocks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,

    status VARCHAR(50) DEFAULT 'locked', -- locked, unlocked, partially_unlocked
    unlocked_at TIMESTAMP WITH TIME ZONE,
    unlocked_options TEXT[] DEFAULT '{}',

    purchase_count INTEGER DEFAULT 0,
    last_purchased_at TIMESTAMP WITH TIME ZONE,

    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(user_id, product_id)
);

CREATE INDEX idx_unlocks_user ON product_unlocks(user_id);
CREATE INDEX idx_unlocks_product ON product_unlocks(product_id);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE domain_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE milestone_tiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE metric_values ENABLE ROW LEVEL SECURITY;
ALTER TABLE milestone_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_unlocks ENABLE ROW LEVEL SECURITY;

-- For now, allow all operations (we'll tighten this later with auth)
CREATE POLICY "Allow all for development" ON tenants FOR ALL USING (true);
CREATE POLICY "Allow all for development" ON domain_configs FOR ALL USING (true);
CREATE POLICY "Allow all for development" ON metrics FOR ALL USING (true);
CREATE POLICY "Allow all for development" ON milestone_tiers FOR ALL USING (true);
CREATE POLICY "Allow all for development" ON milestones FOR ALL USING (true);
CREATE POLICY "Allow all for development" ON products FOR ALL USING (true);
CREATE POLICY "Allow all for development" ON users FOR ALL USING (true);
CREATE POLICY "Allow all for development" ON metric_values FOR ALL USING (true);
CREATE POLICY "Allow all for development" ON milestone_progress FOR ALL USING (true);
CREATE POLICY "Allow all for development" ON product_unlocks FOR ALL USING (true);

-- ============================================================================
-- SEED DATA: Create FUEGO tenant
-- ============================================================================

-- Insert FUEGO tenant
INSERT INTO tenants (name, slug, brand_name, brand_color, is_active)
VALUES ('FUEGO Athletics', 'fuego', 'FUEGO', '#EF4444', true);

-- Insert fitness domain config
INSERT INTO domain_configs (name, slug, description, brand_color)
VALUES (
    'Fitness & Wellness',
    'fitness',
    'Health, fitness, and wellness brands',
    '#EF4444'
);

-- ============================================================================
-- SUCCESS!
-- ============================================================================

-- Verify tables were created
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
