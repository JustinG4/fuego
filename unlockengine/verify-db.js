// Quick script to verify Supabase database setup
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: './admin/.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Missing Supabase credentials in admin/.env.local');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function verifyDatabase() {
  console.log('🔍 Verifying Supabase database setup...\n');

  try {
    // Check for FUEGO tenant
    const { data: tenant, error: tenantError } = await supabase
      .from('tenants')
      .select('*')
      .eq('slug', 'fuego')
      .single();

    if (tenantError) {
      console.log('❌ FUEGO tenant not found');
      console.log('   Error:', tenantError.message);
      console.log('\n📋 Action needed: Run supabase-schema.sql in Supabase SQL Editor');
      return false;
    }

    console.log('✅ FUEGO tenant found:', tenant.name);

    // Check for tiers
    const { data: tiers, error: tiersError } = await supabase
      .from('milestone_tiers')
      .select('*')
      .eq('tenant_id', tenant.id);

    console.log(`✅ Milestone tiers: ${tiers?.length || 0} found`);

    // Check for milestones
    const { data: milestones, error: milestonesError } = await supabase
      .from('milestones')
      .select('*')
      .eq('tenant_id', tenant.id);

    console.log(`✅ Milestones: ${milestones?.length || 0} found`);

    // Check for products
    const { data: products, error: productsError } = await supabase
      .from('products')
      .select('*')
      .eq('tenant_id', tenant.id);

    console.log(`✅ Products: ${products?.length || 0} found`);

    // Check for metrics
    const { data: metrics, error: metricsError } = await supabase
      .from('metrics')
      .select('*')
      .eq('tenant_id', tenant.id);

    console.log(`✅ Metrics: ${metrics?.length || 0} found`);

    if ((tiers?.length || 0) === 0) {
      console.log('\n⚠️  No seed data found');
      console.log('📋 Action needed: Run seed-fuego-data.sql in Supabase SQL Editor');
      return false;
    }

    console.log('\n✨ Database is fully set up and ready!');
    return true;

  } catch (err) {
    console.error('❌ Error verifying database:', err.message);
    return false;
  }
}

verifyDatabase().then(success => {
  process.exit(success ? 0 : 1);
});
