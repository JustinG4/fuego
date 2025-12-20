-- Seed FUEGO Demo Data
-- Run this in Supabase SQL Editor after the schema is set up

-- Get the FUEGO tenant ID (should already exist from schema)
DO $$
DECLARE
    fuego_tenant_id UUID;
    tier_spark_id UUID;
    tier_flame_id UUID;
    tier_inferno_id UUID;
    tier_legend_id UUID;
    metric_steps_id UUID;
    metric_distance_id UUID;
    metric_gym_id UUID;
    metric_marathon_id UUID;
BEGIN
    -- Get FUEGO tenant
    SELECT id INTO fuego_tenant_id FROM tenants WHERE slug = 'fuego';

    -- ============================================================================
    -- CREATE MILESTONE TIERS
    -- ============================================================================
    INSERT INTO milestone_tiers (tenant_id, name, display_order, description, color)
    VALUES
        (fuego_tenant_id, 'SPARK', 1, 'Beginner tier - Start your journey', '#FFA500')
        RETURNING id INTO tier_spark_id;

    INSERT INTO milestone_tiers (tenant_id, name, display_order, description, color)
    VALUES
        (fuego_tenant_id, 'FLAME', 2, 'Intermediate tier - Build momentum', '#FF4444')
        RETURNING id INTO tier_flame_id;

    INSERT INTO milestone_tiers (tenant_id, name, display_order, description, color)
    VALUES
        (fuego_tenant_id, 'INFERNO', 3, 'Advanced tier - Push your limits', '#DC2626')
        RETURNING id INTO tier_inferno_id;

    INSERT INTO milestone_tiers (tenant_id, name, display_order, description, color)
    VALUES
        (fuego_tenant_id, 'LEGEND', 4, 'Elite tier - Achieve greatness', '#7C3AED')
        RETURNING id INTO tier_legend_id;

    -- ============================================================================
    -- CREATE METRICS
    -- ============================================================================
    INSERT INTO metrics (tenant_id, name, description, source, data_type, unit, category)
    VALUES
        (fuego_tenant_id, 'Daily Steps', 'Number of steps walked in a single day', 'healthkit', 'number', 'steps', 'Activity')
        RETURNING id INTO metric_steps_id;

    INSERT INTO metrics (tenant_id, name, description, source, data_type, unit, category)
    VALUES
        (fuego_tenant_id, 'Total Distance', 'Cumulative distance run or walked', 'healthkit', 'number', 'km', 'Running')
        RETURNING id INTO metric_distance_id;

    INSERT INTO metrics (tenant_id, name, description, source, data_type, unit, category)
    VALUES
        (fuego_tenant_id, 'Gym Visits', 'Number of gym check-ins', 'manual', 'number', 'visits', 'Gym')
        RETURNING id INTO metric_gym_id;

    INSERT INTO metrics (tenant_id, name, description, source, data_type, unit, category)
    VALUES
        (fuego_tenant_id, 'Marathon Completion', 'Completed a full marathon (42.2km)', 'healthkit', 'boolean', '', 'Achievement')
        RETURNING id INTO metric_marathon_id;

    -- ============================================================================
    -- CREATE MILESTONES
    -- ============================================================================

    -- SPARK TIER
    INSERT INTO milestones (tenant_id, tier_id, name, description, display_order, requirements, requirement_logic, reward_product_ids, reward_message, is_active)
    VALUES
        (fuego_tenant_id, tier_spark_id, 'First Steps', 'Walk 10,000 steps in a single day', 1,
         jsonb_build_array(
             jsonb_build_object('metricId', metric_steps_id::text, 'operator', 'gte', 'targetValue', 10000)
         ),
         'all', ARRAY['spark-tee'], 'Congratulations! You unlocked the SPARK Performance Tee!', true);

    INSERT INTO milestones (tenant_id, tier_id, name, description, display_order, requirements, requirement_logic, reward_product_ids, reward_message, is_active)
    VALUES
        (fuego_tenant_id, tier_spark_id, 'Gym Rookie', 'Visit the gym 5 times', 2,
         jsonb_build_array(
             jsonb_build_object('metricId', metric_gym_id::text, 'operator', 'gte', 'targetValue', 5)
         ),
         'all', ARRAY['spark-shorts'], 'Amazing! You unlocked SPARK Training Shorts!', true);

    INSERT INTO milestones (tenant_id, tier_id, name, description, display_order, requirements, requirement_logic, reward_product_ids, reward_message, is_active)
    VALUES
        (fuego_tenant_id, tier_spark_id, '5K Runner', 'Run a total of 5 kilometers', 3,
         jsonb_build_array(
             jsonb_build_object('metricId', metric_distance_id::text, 'operator', 'gte', 'targetValue', 5)
         ),
         'all', ARRAY['spark-cap'], 'Well done! You unlocked the SPARK Cap!', true);

    -- FLAME TIER
    INSERT INTO milestones (tenant_id, tier_id, name, description, display_order, requirements, requirement_logic, reward_product_ids, reward_message, is_active)
    VALUES
        (fuego_tenant_id, tier_flame_id, 'Distance Runner', 'Run a total of 50 kilometers', 4,
         jsonb_build_array(
             jsonb_build_object('metricId', metric_distance_id::text, 'operator', 'gte', 'targetValue', 50)
         ),
         'all', ARRAY['flame-tank'], 'Incredible! FLAME Training Tank unlocked!', true);

    INSERT INTO milestones (tenant_id, tier_id, name, description, display_order, requirements, requirement_logic, reward_product_ids, reward_message, is_active)
    VALUES
        (fuego_tenant_id, tier_flame_id, 'Consistent Effort', 'Walk 10,000 steps for 7 days straight', 5,
         jsonb_build_array(
             jsonb_build_object('metricId', metric_steps_id::text, 'operator', 'gte', 'targetValue', 10000, 'description', '7 day streak')
         ),
         'all', ARRAY['flame-shorts'], 'Outstanding! FLAME Running Shorts are yours!', true);

    INSERT INTO milestones (tenant_id, tier_id, name, description, display_order, requirements, requirement_logic, reward_product_ids, reward_message, is_active)
    VALUES
        (fuego_tenant_id, tier_flame_id, 'Strength Builder', 'Complete 20 gym visits', 6,
         jsonb_build_array(
             jsonb_build_object('metricId', metric_gym_id::text, 'operator', 'gte', 'targetValue', 20)
         ),
         'all', ARRAY['flame-hoodie'], 'You earned it! FLAME Hoodie unlocked!', true);

    -- INFERNO TIER
    INSERT INTO milestones (tenant_id, tier_id, name, description, display_order, requirements, requirement_logic, reward_product_ids, reward_message, is_active)
    VALUES
        (fuego_tenant_id, tier_inferno_id, 'Marathon Runner', 'Complete a full marathon (42.2km)', 7,
         jsonb_build_array(
             jsonb_build_object('metricId', metric_marathon_id::text, 'operator', 'eq', 'targetValue', true)
         ),
         'all', ARRAY['inferno-kit'], 'Legendary! INFERNO Marathon Kit is yours!', true);

    INSERT INTO milestones (tenant_id, tier_id, name, description, display_order, requirements, requirement_logic, reward_product_ids, reward_message, is_active)
    VALUES
        (fuego_tenant_id, tier_inferno_id, 'Century Runner', 'Run a total of 100 kilometers', 8,
         jsonb_build_array(
             jsonb_build_object('metricId', metric_distance_id::text, 'operator', 'gte', 'targetValue', 100)
         ),
         'all', ARRAY['inferno-jacket'], 'Elite achievement! INFERNO Jacket unlocked!', true);

    -- LEGEND TIER
    INSERT INTO milestones (tenant_id, tier_id, name, description, display_order, requirements, requirement_logic, reward_product_ids, reward_message, is_active)
    VALUES
        (fuego_tenant_id, tier_legend_id, 'Hall of Fame', 'Complete all previous milestones', 9,
         jsonb_build_array(
             jsonb_build_object('metricId', metric_steps_id::text, 'operator', 'gte', 'targetValue', 100000, 'description', 'Total lifetime steps')
         ),
         'all', ARRAY['legend-jersey'], 'HALL OF FAME! You are a LEGEND!', true);

    -- ============================================================================
    -- CREATE PRODUCTS
    -- ============================================================================

    INSERT INTO products (tenant_id, name, description, handle, price, compare_at_price, currency, available_for_sale, required_milestone_ids, category, tags, is_limited_edition)
    VALUES
        (fuego_tenant_id, 'SPARK Performance Tee', 'Premium moisture-wicking fabric for peak performance. Unlock by walking 10,000 steps.',
         'spark-performance-tee', 49.99, 59.99, 'USD', true, ARRAY['spark-tee'], 'Apparel', ARRAY['tee', 'spark', 'beginner'], false);

    INSERT INTO products (tenant_id, name, description, handle, price, currency, available_for_sale, required_milestone_ids, category, tags, is_limited_edition)
    VALUES
        (fuego_tenant_id, 'SPARK Training Shorts', 'Lightweight shorts perfect for any workout. Unlock by visiting the gym 5 times.',
         'spark-training-shorts', 44.99, 'USD', true, ARRAY['spark-shorts'], 'Apparel', ARRAY['shorts', 'spark', 'beginner'], false);

    INSERT INTO products (tenant_id, name, description, handle, price, currency, available_for_sale, required_milestone_ids, category, tags, is_limited_edition)
    VALUES
        (fuego_tenant_id, 'FLAME Running Shorts', 'Advanced running shorts with built-in compression. For the dedicated athlete.',
         'flame-running-shorts', 64.99, 'USD', true, ARRAY['flame-shorts'], 'Premium', ARRAY['shorts', 'flame', 'intermediate'], true);

    INSERT INTO products (tenant_id, name, description, handle, price, compare_at_price, currency, available_for_sale, required_milestone_ids, category, tags, is_limited_edition, max_quantity)
    VALUES
        (fuego_tenant_id, 'INFERNO Marathon Kit', 'Complete marathon gear package. For those who go the distance.',
         'inferno-marathon-kit', 149.99, 179.99, 'USD', true, ARRAY['inferno-kit'], 'Elite', ARRAY['kit', 'inferno', 'advanced'], true, 100);

    INSERT INTO products (tenant_id, name, description, handle, price, currency, available_for_sale, required_milestone_ids, category, tags, is_limited_edition, max_quantity, max_per_user)
    VALUES
        (fuego_tenant_id, 'LEGEND Hall of Fame Jersey', 'Exclusive jersey for ultimate achievers. Limited to 50 worldwide.',
         'legend-hall-of-fame-jersey', 249.99, 'USD', true, ARRAY['legend-jersey'], 'Exclusive', ARRAY['jersey', 'legend', 'elite'], true, 50, 1);

END $$;

-- Verify data was inserted
SELECT 'Tiers:', COUNT(*) FROM milestone_tiers WHERE tenant_id IN (SELECT id FROM tenants WHERE slug = 'fuego');
SELECT 'Metrics:', COUNT(*) FROM metrics WHERE tenant_id IN (SELECT id FROM tenants WHERE slug = 'fuego');
SELECT 'Milestones:', COUNT(*) FROM milestones WHERE tenant_id IN (SELECT id FROM tenants WHERE slug = 'fuego');
SELECT 'Products:', COUNT(*) FROM products WHERE tenant_id IN (SELECT id FROM tenants WHERE slug = 'fuego');
