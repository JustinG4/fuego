import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Database types (simplified - will auto-generate later)
export type Tenant = {
  id: string;
  name: string;
  slug: string;
  brand_name: string;
  brand_color: string;
  is_active: boolean;
  created_at: string;
};

export type Milestone = {
  id: string;
  tenant_id: string;
  tier_id: string | null;
  name: string;
  description: string;
  display_order: number;
  requirements: any[];
  requirement_logic: string;
  reward_product_ids: string[];
  reward_message: string | null;
  is_active: boolean;
  created_at: string;
};

export type MilestoneTier = {
  id: string;
  tenant_id: string;
  name: string;
  display_order: number;
  description: string | null;
  color: string;
  icon: string | null;
  created_at: string;
};

export type Product = {
  id: string;
  tenant_id: string;
  external_id: string | null;
  name: string;
  description: string | null;
  handle: string;
  price: number;
  compare_at_price: number | null;
  currency: string;
  images: string[];
  thumbnail_url: string | null;
  available_for_sale: boolean;
  quantity_available: number | null;
  required_milestone_ids: string[];
  unlock_logic: string;
  is_limited_edition: boolean;
  category: string | null;
  tags: string[];
  created_at: string;
};

export type Metric = {
  id: string;
  tenant_id: string;
  name: string;
  description: string | null;
  source: string;
  data_type: string;
  unit: string | null;
  category: string | null;
  icon: string | null;
  is_active: boolean;
  created_at: string;
};
