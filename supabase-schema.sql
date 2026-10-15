-- 1. Create Posts Table
create table if not exists public.posts (
  id uuid default gen_random_uuid() primary key,
  slug text unique not null,
  title text not null,
  summary text not null,
  content text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Index for fast lookup by slug
create index if not exists posts_slug_idx on public.posts (slug);

-- 2. Create Comments Table
create table if not exists public.comments (
  id uuid default gen_random_uuid() primary key,
  post_slug text not null references public.posts(slug) on delete cascade,
  user_id uuid default auth.uid() references auth.users(id) on delete set null,
  user_email text not null,
  content text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Index for fast lookup by post_slug
create index if not exists comments_post_slug_idx on public.comments (post_slug);

-- 3. Create App Configuration Table (stores admin email securely in database)
create table if not exists public.app_config (
  key text primary key,
  value text not null
);

-- Insert placeholder admin email (replace with your real admin email in Supabase)
insert into public.app_config (key, value)
values ('admin_email', 'admin@example.com')
on conflict (key) do nothing;

-- 4. Enable Row Level Security (RLS)
alter table public.posts enable row level security;
alter table public.comments enable row level security;
alter table public.app_config enable row level security;

-- Helper function to check if current user is admin
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1
    from public.app_config
    where key = 'admin_email'
      and value = auth.jwt() ->> 'email'
  );
$$;

-- 5. RLS Policies for Posts
create policy "Posts are publicly readable"
  on public.posts for select
  using (true);

create policy "Admin can insert posts"
  on public.posts for insert
  to authenticated
  with check (public.is_admin());

create policy "Admin can update posts"
  on public.posts for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admin can delete posts"
  on public.posts for delete
  to authenticated
  using (public.is_admin());

-- 6. RLS Policies for Comments
create policy "Comments are publicly readable"
  on public.comments for select
  using (true);

create policy "Authenticated users can post comments"
  on public.comments for insert
  to authenticated
  with check (
    auth.uid() = user_id and
    auth.jwt() ->> 'email' = user_email
  );

create policy "Authors or admin can delete comments"
  on public.comments for delete
  to authenticated
  using (
    auth.uid() = user_id or
    public.is_admin()
  );

-- 7. RLS Policies for App Config
create policy "App config readable by authenticated users"
  on public.app_config for select
  to authenticated
  using (true);

-- Sample starter post
insert into public.posts (slug, title, summary, content)
values (
  'hello-world',
  'Hello World',
  'Welcome to the new aBlog by Satirr built with Astro and Supabase.',
  '# Hello World\n\nWelcome to the updated **aBlog by Satirr**.\n\nThis site is built with **Astro** and powered by **Supabase** for database storage and user authentication.\n\n> Authors can publish and manage posts directly through the browser without needing manual git pushes.\n\nFeel free to join the conversation in the comments section below.'
) on conflict (slug) do nothing;

-- 8. Create Profiles Table (Stores user name, bio, and external website link)
create table if not exists public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  display_name text,
  bio text,
  website text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for Profiles
alter table public.profiles enable row level security;

-- Profiles policies
create policy "Profiles are publicly readable"
  on public.profiles for select
  using (true);

create policy "Users can update own profile"
  on public.profiles for all
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);
