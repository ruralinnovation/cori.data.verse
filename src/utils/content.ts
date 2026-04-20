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
 * Read YAML frontmatter from a .qmd file using gray-matter.
 * Returns the parsed data object plus the slug derived from the directory name.
 */
function readQmdFrontmatter(filePath: string, slug: string): ContentMeta {
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
  const dir = path.join(ROOT_DIR, contentType);
  if (!fs.existsSync(dir)) return [];

  const entries = fs.readdirSync(dir, { withFileTypes: true });
  const items: T[] = [];

  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    const qmdPath = path.join(dir, entry.name, "index.qmd");
    if (!fs.existsSync(qmdPath)) continue;

    const meta = readQmdFrontmatter(qmdPath, entry.name) as T;
    // Skip drafts
    if ((meta as Record<string, unknown>).draft === true) continue;
    items.push(meta);
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
  if (!fs.existsSync(POSTS_DIR)) return [];

  const entries = fs.readdirSync(POSTS_DIR, { withFileTypes: true });
  const posts: BlogPostMeta[] = [];

  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    // Skip content type directories
    if (CONTENT_TYPE_DIRS.includes(entry.name as ContentType)) continue;
    // Skip hidden/special directories
    if (entry.name.startsWith("_") || entry.name.startsWith(".")) continue;

    const qmdPath = path.join(POSTS_DIR, entry.name, "index.qmd");
    if (!fs.existsSync(qmdPath)) continue;

    const meta = readQmdFrontmatter(qmdPath, entry.name) as BlogPostMeta;
    if (meta.draft === true) continue;
    posts.push(meta);
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
  const dir = path.join(ROOT_DIR, contentType);
  if (!fs.existsSync(dir)) return [];

  return fs
    .readdirSync(dir, { withFileTypes: true })
    .filter((entry) => {
      if (!entry.isDirectory()) return false;
      return fs.existsSync(path.join(dir, entry.name, "index.qmd"));
    })
    .map((entry) => entry.name);
}

/**
 * Get all blog post slugs. Used by generateStaticParams().
 */
export function getBlogSlugs(): string[] {
  if (!fs.existsSync(POSTS_DIR)) return [];

  return fs
    .readdirSync(POSTS_DIR, { withFileTypes: true })
    .filter((entry) => {
      if (!entry.isDirectory()) return false;
      if (CONTENT_TYPE_DIRS.includes(entry.name as ContentType)) return false;
      if (entry.name.startsWith("_") || entry.name.startsWith("."))
        return false;
      return fs.existsSync(path.join(POSTS_DIR, entry.name, "index.qmd"));
    })
    .map((entry) => entry.name);
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
