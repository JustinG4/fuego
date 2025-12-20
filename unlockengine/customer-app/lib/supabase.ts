import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables. Please check your .env.local file');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Helper function to get current tenant (hardcoded to FUEGO for now)
export const CURRENT_TENANT_SLUG = 'fuego';

export async function getCurrentTenant() {
  const { data, error } = await supabase
    .from('tenants')
    .select('*')
    .eq('slug', CURRENT_TENANT_SLUG)
    .single();

  if (error) throw error;
  return data;
}
