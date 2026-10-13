-- 1. Buat Tabel Posts
create table if not exists public.posts (
  id uuid default gen_random_uuid() primary key,
  slug text unique not null,
  title text not null,
  summary text not null,
  content text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Index slug untuk query cepat
create index if not exists posts_slug_idx on public.posts (slug);

-- 2. Buat Tabel Comments
create table if not exists public.comments (
  id uuid default gen_random_uuid() primary key,
  post_slug text not null references public.posts(slug) on delete cascade,
  user_id uuid default auth.uid() references auth.users(id) on delete set null,
  user_email text not null,
  content text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Index post_slug untuk query komentar per post
create index if not exists comments_post_slug_idx on public.comments (post_slug);

-- 3. Aktifkan Row Level Security (RLS)
alter table public.posts enable row level security;
alter table public.comments enable row level security;

-- 4. Kebijakan RLS untuk Posts:
-- Siapa saja (anon & authenticated) boleh membaca artikel
create policy "Posts dapat dibaca oleh publik"
  on public.posts for select
  using (true);

-- Hanya admin (email: r86571601@gmail.com) yang boleh menambah artikel
create policy "Admin boleh menambah post"
  on public.posts for insert
  to authenticated
  with check (auth.jwt() ->> 'email' = 'r86571601@gmail.com');

-- Hanya admin yang boleh mengedit artikel
create policy "Admin boleh mengubah post"
  on public.posts for update
  to authenticated
  using (auth.jwt() ->> 'email' = 'r86571601@gmail.com')
  with check (auth.jwt() ->> 'email' = 'r86571601@gmail.com');

-- Hanya admin yang boleh menghapus artikel
create policy "Admin boleh menghapus post"
  on public.posts for delete
  to authenticated
  using (auth.jwt() ->> 'email' = 'r86571601@gmail.com');

-- 5. Kebijakan RLS untuk Comments:
-- Siapa saja boleh membaca komentar
create policy "Komentar dapat dibaca oleh publik"
  on public.comments for select
  using (true);

-- User yang login (authenticated) boleh mengirim komentar
create policy "User terautentikasi boleh mengirim komentar"
  on public.comments for insert
  to authenticated
  with check (
    auth.uid() = user_id and
    auth.jwt() ->> 'email' = user_email
  );

-- Pemilik komentar atau admin boleh menghapus komentar
create policy "Pemilik atau admin boleh menghapus komentar"
  on public.comments for delete
  to authenticated
  using (
    auth.uid() = user_id or
    auth.jwt() ->> 'email' = 'r86571601@gmail.com'
  );

-- Sample Data (Opsional)
insert into public.posts (slug, title, summary, content)
values (
  'halo-dunia',
  'Halo Dunia!',
  'Artikel pertama di blog satirr ai menggunakan Astro dan Supabase.',
  '# Halo Dunia!\n\nSelamat datang di blog **satirr ai** yang baru.\n\nSistem ini sekarang menggunakan **Astro** dan **Supabase** untuk backend database serta autentikasi.\n\n> Admin dapat langsung menulis postingan baru melalui halaman browser tanpa perlu git push manual setiap kali posting!\n\nKalian juga dapat memberikan komentar di bawah.'
) on conflict (slug) do nothing;
