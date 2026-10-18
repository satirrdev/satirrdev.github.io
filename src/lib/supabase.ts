import { createClient } from '@supabase/supabase-js';

export const ADMIN_EMAIL = import.meta.env.PUBLIC_ADMIN_EMAIL || '';

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL || '';
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY || '';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
