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
  parent_id uuid references public.comments(id) on delete cascade,
  user_id uuid default auth.uid() references auth.users(id) on delete set null,
  user_email text not null,
  content text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Index for fast lookup by post_slug and parent_id
create index if not exists comments_post_slug_idx on public.comments (post_slug);
create index if not exists comments_parent_id_idx on public.comments (parent_id);

-- 3. Create Comment Votes Table (upvote/downvote)
create table if not exists public.comment_votes (
  id uuid default gen_random_uuid() primary key,
  comment_id uuid not null references public.comments(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  user_email text not null,
  vote smallint not null check (vote in (-1, 1)),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(comment_id, user_email)
);

-- 4. Create Profiles Table (Name, Bio, External Link)
create table if not exists public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  display_name text,
  bio text,
  website text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 5. Create App Configuration Table (stores admin email securely)
create table if not exists public.app_config (
  key text primary key,
  value text not null
);

insert into public.app_config (key, value)
values ('admin_email', 'r86571601@gmail.com')
on conflict (key) do nothing;

-- 6. Enable Row Level Security (RLS)
alter table public.posts enable row level security;
alter table public.comments enable row level security;
alter table public.comment_votes enable row level security;
alter table public.profiles enable row level security;
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

-- 7. RLS Policies for Posts (Idempotent: safe to run multiple times)
drop policy if exists "Posts are publicly readable" on public.posts;
create policy "Posts are publicly readable"
  on public.posts for select
  using (true);

drop policy if exists "Admin can insert posts" on public.posts;
create policy "Admin can insert posts"
  on public.posts for insert
  to authenticated
  with check (public.is_admin());

drop policy if exists "Admin can update posts" on public.posts;
create policy "Admin can update posts"
  on public.posts for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists "Admin can delete posts" on public.posts;
create policy "Admin can delete posts"
  on public.posts for delete
  to authenticated
  using (public.is_admin());

-- 8. RLS Policies for Comments
drop policy if exists "Comments are publicly readable" on public.comments;
create policy "Comments are publicly readable"
  on public.comments for select
  using (true);

drop policy if exists "Authenticated users can post comments" on public.comments;
create policy "Authenticated users can post comments"
  on public.comments for insert
  to authenticated
  with check (
    auth.jwt() ->> 'email' = user_email
  );

drop policy if exists "Authors or admin can delete comments" on public.comments;
create policy "Authors or admin can delete comments"
  on public.comments for delete
  to authenticated
  using (
    auth.uid() = user_id or
    public.is_admin()
  );

-- 9. RLS Policies for Comment Votes
drop policy if exists "Comment votes are publicly readable" on public.comment_votes;
create policy "Comment votes are publicly readable"
  on public.comment_votes for select
  using (true);

drop policy if exists "Authenticated users can vote" on public.comment_votes;
create policy "Authenticated users can vote"
  on public.comment_votes for insert
  to authenticated
  with check (
    auth.jwt() ->> 'email' = user_email
  );

drop policy if exists "Users can change their vote" on public.comment_votes;
create policy "Users can change their vote"
  on public.comment_votes for update
  to authenticated
  using (auth.jwt() ->> 'email' = user_email)
  with check (auth.jwt() ->> 'email' = user_email);

drop policy if exists "Users can remove their vote" on public.comment_votes;
create policy "Users can remove their vote"
  on public.comment_votes for delete
  to authenticated
  using (auth.jwt() ->> 'email' = user_email);

-- 10. RLS Policies for Profiles
drop policy if exists "Profiles are publicly readable" on public.profiles;
create policy "Profiles are publicly readable"
  on public.profiles for select
  using (true);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
  on public.profiles for all
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- 11. RLS Policies for App Config
drop policy if exists "App config readable by authenticated users" on public.app_config;
create policy "App config readable by authenticated users"
  on public.app_config for select
  to authenticated
  using (true);
