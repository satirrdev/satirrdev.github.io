import { createClient } from '@supabase/supabase-js';

// Ambil variable env publik (aman untuk browser)
const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL || 'https://dummyproject123.supabase.co';
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY || 'dummy_anon_key';

export const ADMIN_EMAIL = 'r86571601@gmail.com';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
