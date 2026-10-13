export interface PostItem {
  slug: string;
  title: string;
  summary: string;
  content: string;
  created_at: string;
}

export const DUMMY_POSTS: PostItem[] = [
  {
    slug: 'hello-world',
    title: 'Hello World',
    summary: 'Welcome to satirr ai blog. A quick glance at the new design and dynamic features.',
    content: `# Hello World

Welcome to the new **satirr ai** blog.

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
