-- 1. Tambah kolom parent_id ke tabel comments jika belum ada
alter table public.comments add column if not exists parent_id uuid references public.comments(id) on delete cascade;

-- 2. Buat tabel comment_votes untuk fitur upvote/downvote jika belum ada
create table if not exists public.comment_votes (
  id uuid default gen_random_uuid() primary key,
  comment_id uuid not null references public.comments(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  user_email text not null,
  vote smallint not null check (vote in (-1, 1)),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(comment_id, user_email)
);

-- Enable RLS
alter table public.comment_votes enable row level security;

-- Policies untuk comment_votes (Aman di-run berulang kali)
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

-- 3. Buat tabel profiles jika belum ada
create table if not exists public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  display_name text,
  bio text,
  website text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.profiles enable row level security;

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
