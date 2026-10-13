# satirr ai

A minimalist, high-performance personal blog built with **Astro** and powered by **Supabase**. Designed to be hosted statically on **GitHub Pages** while retaining full dynamic capabilities for content publishing and community discussions.

## Overview

- **Static Front-end Performance**: Pre-rendered static pages using Astro with client-side dynamic fetching for real-time interactivity.
- **Publishing Workflow**: Authorized administrators can compose, preview, publish, and delete Markdown posts directly through the browser without committing to Git.
- **Reader Engagement**: Visitors can create accounts, sign in, and post comments on individual articles.
- **Row-Level Security (RLS)**: PostgreSQL-level access control via Supabase ensures database queries are securely validated regardless of client-side requests.
- **Editorial Design**: Adheres to strict typography, a focused reading width (680px), and automatic dark mode support via CSS color-scheme queries.
