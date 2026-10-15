export interface PostItem {
  id?: string;
  slug: string;
  title: string;
  summary: string;
  content: string;
  created_at: string;
}

export interface CommentItem {
  id: string;
  post_slug: string;
  parent_id?: string | null;
  user_id?: string | null;
  user_email: string;
  author_name?: string;
  content: string;
  score?: number;
  userVote?: number; // 1 for upvote, -1 for downvote, 0 for none
  created_at: string;
}

export const DUMMY_POSTS: PostItem[] = [
  {
    slug: 'hello-world',
    title: 'Hello World',
    summary: 'Welcome to aBlog by Satirr. A quick glance at the new design and dynamic features.',
    content: `# Hello World

Welcome to the new **aBlog by Satirr**.

This site is built with **Astro** and designed with an editorial aesthetic inspired by Claude's clean typography.

### What is this blog about?

I write here about software engineering, minimalist web craft, and technical experiments I am exploring.

> Clear ideas executed with restraint remain more valuable and pleasant to use than intricate, noisy features.

\`\`\`javascript
function createExperience() {
  return {
    fast: true,
    minimal: true,
    accessible: true
  };
}
\`\`\`

Feel free to leave a comment below to test the discussion section!`,
    created_at: new Date().toISOString()
  },
  {
    slug: 'minimalist-web-design',
    title: 'Principles of Minimalist Web Design',
    summary: 'Why removing unnecessary decorations leads to better user comprehension and focus.',
    content: `# Principles of Minimalist Web Design

When designing user interfaces, every element should earn its place on the screen.

## 1. Content First
The purpose of a reading interface is to make text effortless to consume. Generous margins, calculated line-heights, and clear typographic hierarchy do more for readability than decorative illustrations.

## 2. Restraint Over Abundance
By keeping color palettes constrained to neutral tones with a single warm accent, attention naturally flows to what matters: the ideas being communicated.

> Simplicity is not the absence of clutter, that's a consequence of simplicity. Simplicity is somehow essentially describing the purpose and place of an object and product.

Drop your thoughts in the comments below.`,
    created_at: new Date(Date.now() - 86400000).toISOString()
  }
];

const LOCAL_STORAGE_KEY = 'satirr_local_posts';
const LOCAL_COMMENTS_KEY = 'satirr_local_comments';
const DELETED_SLUGS_KEY = 'satirr_deleted_slugs';
const LOCAL_VOTES_KEY = 'satirr_local_votes'; // Record user votes: { [commentId_userEmail]: 1 or -1 }

export function getDeletedSlugs(): string[] {
  if (typeof window === 'undefined') return [];
  try {
    const raw = localStorage.getItem(DELETED_SLUGS_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch (e) {
    return [];
  }
}

export function markSlugDeleted(slug: string) {
  if (typeof window === 'undefined') return;
  try {
    const deleted = getDeletedSlugs();
    if (!deleted.includes(slug)) {
      deleted.push(slug);
      localStorage.setItem(DELETED_SLUGS_KEY, JSON.stringify(deleted));
    }
  } catch (e) {
    console.error('Failed to mark slug deleted', e);
  }
}

export function unmarkSlugDeleted(slug: string) {
  if (typeof window === 'undefined') return;
  try {
    const deleted = getDeletedSlugs().filter(s => s !== slug);
    localStorage.setItem(DELETED_SLUGS_KEY, JSON.stringify(deleted));
  } catch (e) {}
}

export function getLocalPosts(): PostItem[] {
  if (typeof window === 'undefined') return [];
  try {
    const raw = localStorage.getItem(LOCAL_STORAGE_KEY);
    const deleted = getDeletedSlugs();
    const posts: PostItem[] = raw ? JSON.parse(raw) : [];
    return posts.filter(p => !deleted.includes(p.slug));
  } catch (e) {
    return [];
  }
}

export function saveLocalPost(post: PostItem) {
  if (typeof window === 'undefined') return;
  try {
    unmarkSlugDeleted(post.slug);
    const existing = getLocalPosts().filter(p => p.slug !== post.slug);
    existing.unshift(post);
    localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(existing));
  } catch (e) {
    console.error('Failed to save post locally', e);
  }
}

export function deleteLocalPost(slug: string) {
  if (typeof window === 'undefined') return;
  try {
    markSlugDeleted(slug);
    const filtered = getLocalPosts().filter(p => p.slug !== slug);
    localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(filtered));
  } catch (e) {
    console.error('Failed to delete post locally', e);
  }
}

export function getLocalComments(postSlug: string): CommentItem[] {
  if (typeof window === 'undefined') return [];
  try {
    const raw = localStorage.getItem(LOCAL_COMMENTS_KEY);
    const all: CommentItem[] = raw ? JSON.parse(raw) : [];
    return all.filter(c => c.post_slug === postSlug);
  } catch (e) {
    return [];
  }
}

export function saveLocalComment(comment: CommentItem) {
  if (typeof window === 'undefined') return;
  try {
    const raw = localStorage.getItem(LOCAL_COMMENTS_KEY);
    const all: CommentItem[] = raw ? JSON.parse(raw) : [];
    const index = all.findIndex(c => c.id === comment.id);
    if (index >= 0) {
      all[index] = comment;
    } else {
      all.push(comment);
    }
    localStorage.setItem(LOCAL_COMMENTS_KEY, JSON.stringify(all));
  } catch (e) {
    console.error('Failed to save comment locally', e);
  }
}

export function deleteLocalComment(id: string) {
  if (typeof window === 'undefined') return;
  try {
    const raw = localStorage.getItem(LOCAL_COMMENTS_KEY);
    const all: CommentItem[] = raw ? JSON.parse(raw) : [];
    // Also delete any replies attached to this comment
    const filtered = all.filter(c => c.id !== id && c.parent_id !== id);
    localStorage.setItem(LOCAL_COMMENTS_KEY, JSON.stringify(filtered));
  } catch (e) {
    console.error('Failed to delete comment locally', e);
  }
}

export function getLocalVote(commentId: string, userEmail: string): number {
  if (typeof window === 'undefined') return 0;
  try {
    const raw = localStorage.getItem(LOCAL_VOTES_KEY);
    const votes = raw ? JSON.parse(raw) : {};
    return votes[`${commentId}_${userEmail}`] || 0;
  } catch (e) {
    return 0;
  }
}

export function saveLocalVote(commentId: string, userEmail: string, vote: number) {
  if (typeof window === 'undefined') return;
  try {
    const raw = localStorage.getItem(LOCAL_VOTES_KEY);
    const votes = raw ? JSON.parse(raw) : {};
    if (vote === 0) {
      delete votes[`${commentId}_${userEmail}`];
    } else {
      votes[`${commentId}_${userEmail}`] = vote;
    }
    localStorage.setItem(LOCAL_VOTES_KEY, JSON.stringify(votes));
  } catch (e) {
    console.error('Failed to save vote locally', e);
  }
}
