import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL || 'https://dummyproject123.supabase.co';
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY || 'dummy_anon_key';

// Admin email configured via environment variable without hardcoding in the codebase
export const ADMIN_EMAIL = import.meta.env.PUBLIC_ADMIN_EMAIL || '';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
