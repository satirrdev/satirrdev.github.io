import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL || '';
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY || '';

// Admin email configured via environment variable without hardcoding in the codebase
export const ADMIN_EMAIL = import.meta.env.PUBLIC_ADMIN_EMAIL || '';

// Check if Supabase has real, non-dummy credentials
export const isSupabaseConfigured = Boolean(
  supabaseUrl &&
  !supabaseUrl.includes('dummyproject123') &&
  !supabaseUrl.includes('your-project-id') &&
  supabaseAnonKey &&
  !supabaseAnonKey.includes('dummy') &&
  !supabaseAnonKey.includes('your-anon-key')
);

export const supabase = createClient(
  isSupabaseConfigured ? supabaseUrl : 'https://placeholder.supabase.co',
  isSupabaseConfigured ? supabaseAnonKey : 'placeholder_key'
);
