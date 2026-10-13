# satirr ai

Blog dinamis berbasis **Astro** dan **Supabase**, dirancang untuk performa tinggi, desain minimalis sesuai `DESIGN.MD`, dan di-host gratis di **GitHub Pages**.

## Fitur

- **Autentikasi Supabase**: Login dan Register untuk pengguna/pembaca.
- **Admin Publishing**: Khusus email admin (`r86571601@gmail.com`) dapat menulis, mempublikasikan, dan menghapus artikel langsung dari web tanpa perlu push Git.
- **Sistem Komentar Realtime**: Pembaca yang terautentikasi dapat memberikan komentar di setiap artikel.
- **Row Level Security (RLS)**: Keamanan database terjamin di level PostgreSQL. Kunci `anon` publik aman ditaruh di browser.
- **Desain Minimalis**: Sesuai panduan `DESIGN.MD`, tipografi terbaca jelas, mode gelap otomatis (`prefers-color-scheme`).

---

## Persiapan Supabase (Sekali Saja)

1. Buat project baru di [supabase.com](https://supabase.com).
2. Buka menu **SQL Editor** di dashboard Supabase.
3. Buka file `supabase-schema.sql` di repository ini, salin seluruh kodenya, lalu jalankan (**Run**) di SQL Editor Supabase.
4. Buka menu **Authentication -> Providers -> Email**:
   - Pastikan provider Email aktif.
   - (Opsional) Matikan *Confirm email* jika ingin user bisa langsung login tanpa verifikasi tautan email.
5. Buat akun dengan email admin kamu (`r86571601@gmail.com`) di menu **Authentication -> Users** atau langsung melalui form pendaftaran di blog.

---

## Konfigurasi Kunci API (Di GitHub Repo)

Agar GitHub Actions dapat mem-build website dengan benar tanpa membocorkan kunci ke file kode publik:

1. Buka repository GitHub kamu di browser.
2. Masuk ke **Settings** -> **Secrets and variables** -> **Actions**.
3. Klik **New repository secret** dan tambahkan dua variabel ini (ambil dari Supabase: **Settings -> API**):
   - `PUBLIC_SUPABASE_URL` : URL project Supabase kamu (contoh: `https://xyz.supabase.co`)
   - `PUBLIC_SUPABASE_ANON_KEY` : Anon Public API key dari Supabase.
4. Buka **Settings -> Pages**:
   - Ubah opsi **Source** menjadi **GitHub Actions**.

---

## Menjalankan di Komputer Lokal

1. Salin `.env.example` menjadi `.env`:
   ```bash
   cp .env.example .env
   ```
2. Isi `PUBLIC_SUPABASE_URL` dan `PUBLIC_SUPABASE_ANON_KEY` dengan kunci Supabase kamu.
3. Install dependensi dan jalankan server lokal:
   ```bash
   npm install
   npm run dev
   ```
4. Buka `http://localhost:4321` di browser.
