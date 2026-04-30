import fs from "fs";
import path from "path";
import matter from "gray-matter";
import type {
  ContentMeta,
  ContentType,
  DatasetMeta,
  PackageMeta,
  ProjectMeta,
  BlogPostMeta,
  ChartMeta,
} from "@/types";

const POSTS_DIR = path.join(process.cwd(), "posts");
const CONTENT_DIR = path.join(process.cwd(), "content");

/**
 * Clean markdown content for JSX compatibility.
 * Quarto GFM output contains raw HTML with `class=` attributes;
 * markdown-to-jsx passes these to React which expects `className=`.
 * Also converts `for=` to `htmlFor=` on label elements.
 * Pattern from Real-Currents.github.io reference project.
 */
function cleanMarkdownForJSX(content: string): string {
  return content
    .replace(/(<[^>]+)\bclass=/g, "$1className=")
    .replace(/(<label[^>]*)\bfor=/g, "$1htmlFor=");
}

/** Top-level content type directories (datasets/, charts/, packages/, projects/, resources/) */
const CONTENT_TYPE_DIRS: ContentType[] = [
  "datasets",
  "charts",
  "packages",
  "projects",
  "resources",
];

const ROOT_DIR = process.cwd();

/**
 * Read YAML frontmatter from a .qmd or .md file using gray-matter.
 * Returns the parsed data object plus the slug derived from the directory name.
 */
function readFrontmatter(filePath: string, slug: string): ContentMeta {
  const fileContent = fs.readFileSync(filePath, "utf-8");
  const { data } = matter(fileContent);
  return {
    ...data,
    slug,
    title: data.title || slug,
    categories: data.categories || [],
    tags: data.tags || [],
  } as ContentMeta;
}

/**
 * Get metadata for all items of a given content type (datasets, packages, etc.).
 * Reads frontmatter from posts/[contentType]/[name]/index.qmd files.
 */
export function getContentMetadata<T extends ContentMeta = ContentMeta>(
  contentType: ContentType
): T[] {
  const sourceDir = path.join(ROOT_DIR, contentType);
  const contentTypeDir = path.join(CONTENT_DIR, contentType);
  const items: T[] = [];
  const seen = new Set<string>();

  // Source-backed items: read frontmatter from .qmd
  if (fs.existsSync(sourceDir)) {
    for (const entry of fs.readdirSync(sourceDir, { withFileTypes: true })) {
      if (!entry.isDirectory()) continue;
      const qmdPath = path.join(sourceDir, entry.name, "index.qmd");
      if (!fs.existsSync(qmdPath)) continue;
      const meta = readFrontmatter(qmdPath, entry.name) as T;
      if ((meta as Record<string, unknown>).draft === true) continue;
      items.push(meta);
      seen.add(entry.name);
    }
  }

  // Content-only items (e.g. pulled from S3): read frontmatter from .md
  if (fs.existsSync(contentTypeDir)) {
    for (const entry of fs.readdirSync(contentTypeDir, { withFileTypes: true })) {
      if (!entry.isDirectory()) continue;
      if (seen.has(entry.name)) continue;
      const mdPath = path.join(contentTypeDir, entry.name, "index.md");
      if (!fs.existsSync(mdPath)) continue;
      const meta = readFrontmatter(mdPath, entry.name) as T;
      if ((meta as Record<string, unknown>).draft === true) continue;
      items.push(meta);
      seen.add(entry.name);
    }
  }

  // Sort by date descending
  items.sort((a, b) => {
    const da = a.date ? new Date(a.date).getTime() : 0;
    const db = b.date ? new Date(b.date).getTime() : 0;
    return db - da;
  });

  return items;
}

/**
 * Get metadata for blog posts.
 * Blog posts live in posts/ as numbered directories (01_*, 02_*, etc.)
 * excluding the content type subdirectories.
 */
export function getBlogMetadata(): BlogPostMeta[] {
  const postsContentDir = path.join(CONTENT_DIR, "posts");
  const posts: BlogPostMeta[] = [];
  const seen = new Set<string>();

  // Source-backed posts: read frontmatter from .qmd
  if (fs.existsSync(POSTS_DIR)) {
    for (const entry of fs.readdirSync(POSTS_DIR, { withFileTypes: true })) {
      if (!entry.isDirectory()) continue;
      if (CONTENT_TYPE_DIRS.includes(entry.name as ContentType)) continue;
      if (entry.name.startsWith("_") || entry.name.startsWith(".")) continue;
      const qmdPath = path.join(POSTS_DIR, entry.name, "index.qmd");
      if (!fs.existsSync(qmdPath)) continue;
      const meta = readFrontmatter(qmdPath, entry.name) as BlogPostMeta;
      if (meta.draft === true) continue;
      posts.push(meta);
      seen.add(entry.name);
    }
  }

  // Content-only posts (e.g. pulled from S3): read frontmatter from .md
  if (fs.existsSync(postsContentDir)) {
    for (const entry of fs.readdirSync(postsContentDir, { withFileTypes: true })) {
      if (!entry.isDirectory()) continue;
      if (seen.has(entry.name)) continue;
      const mdPath = path.join(postsContentDir, entry.name, "index.md");
      if (!fs.existsSync(mdPath)) continue;
      const meta = readFrontmatter(mdPath, entry.name) as BlogPostMeta;
      if (meta.draft === true) continue;
      posts.push(meta);
      seen.add(entry.name);
    }
  }

  // Sort by date descending
  posts.sort((a, b) => {
    const da = a.date ? new Date(a.date).getTime() : 0;
    const db = b.date ? new Date(b.date).getTime() : 0;
    return db - da;
  });

  return posts;
}

/**
 * Read the preprocessed GFM markdown body for a content item.
 * Looks in content/[contentType]/[slug]/index.md (or content/{slug}/index.md for blog).
 */
export function getMarkdownBody(
  contentType: ContentType | "blog",
  slug: string
): string {
  // For blog posts, the content is at content/{slug}/index.md
  // For typed content, it's at content/[contentType]/[slug]/index.md
  const mdPath =
    contentType === "blog"
      ? path.join(CONTENT_DIR, "posts", slug, "index.md")
      : path.join(CONTENT_DIR, contentType, slug, "index.md");

  if (!fs.existsSync(mdPath)) {
    // Fallback: try .md file directly
    const altPath = mdPath.replace("/index.md", ".md");
    if (fs.existsSync(altPath)) {
      const raw = fs.readFileSync(altPath, "utf-8");
      const { content } = matter(raw);
      return cleanMarkdownForJSX(content);
    }
    return `> Content not found: ${mdPath}`;
  }

  const raw = fs.readFileSync(mdPath, "utf-8");
  // Strip frontmatter if present (gray-matter leaves it)
  const { content } = matter(raw);
  return cleanMarkdownForJSX(content);
}

/**
 * Get all slugs for a content type. Used by generateStaticParams().
 */
export function getAllSlugs(contentType: ContentType): string[] {
  const sourceDir = path.join(ROOT_DIR, contentType);
  const contentTypeDir = path.join(CONTENT_DIR, contentType);
  const slugs = new Set<string>();

  // Source-backed: has index.qmd in the source tree
  if (fs.existsSync(sourceDir)) {
    for (const entry of fs.readdirSync(sourceDir, { withFileTypes: true })) {
      if (entry.isDirectory() &&
          fs.existsSync(path.join(sourceDir, entry.name, "index.qmd"))) {
        slugs.add(entry.name);
      }
    }
  }

  // Content-only: has index.md in content/ but no source .qmd (e.g. pulled from S3)
  if (fs.existsSync(contentTypeDir)) {
    for (const entry of fs.readdirSync(contentTypeDir, { withFileTypes: true })) {
      if (entry.isDirectory() &&
          fs.existsSync(path.join(contentTypeDir, entry.name, "index.md")) &&
          !fs.existsSync(path.join(sourceDir, entry.name, "index.qmd"))) {
        slugs.add(entry.name);
      }
    }
  }

  return Array.from(slugs);
}

/**
 * Get all blog post slugs. Used by generateStaticParams().
 */
export function getBlogSlugs(): string[] {
  const postsContentDir = path.join(CONTENT_DIR, "posts");
  const slugs = new Set<string>();

  // Source-backed
  if (fs.existsSync(POSTS_DIR)) {
    for (const entry of fs.readdirSync(POSTS_DIR, { withFileTypes: true })) {
      if (!entry.isDirectory()) continue;
      if (CONTENT_TYPE_DIRS.includes(entry.name as ContentType)) continue;
      if (entry.name.startsWith("_") || entry.name.startsWith(".")) continue;
      if (fs.existsSync(path.join(POSTS_DIR, entry.name, "index.qmd"))) {
        slugs.add(entry.name);
      }
    }
  }

  // Content-only (e.g. pulled from S3)
  if (fs.existsSync(postsContentDir)) {
    for (const entry of fs.readdirSync(postsContentDir, { withFileTypes: true })) {
      if (!entry.isDirectory()) continue;
      if (fs.existsSync(path.join(postsContentDir, entry.name, "index.md")) &&
          !fs.existsSync(path.join(POSTS_DIR, entry.name, "index.qmd"))) {
        slugs.add(entry.name);
      }
    }
  }

  return Array.from(slugs);
}

/** Convenience typed getters */
export function getDatasets(): DatasetMeta[] {
  return getContentMetadata<DatasetMeta>("datasets");
}

export function getCharts(): ChartMeta[] {
  return getContentMetadata<ChartMeta>("charts");
}

export function getPackages(): PackageMeta[] {
  return getContentMetadata<PackageMeta>("packages");
}

export function getProjects(): ProjectMeta[] {
  return getContentMetadata<ProjectMeta>("projects");
}
