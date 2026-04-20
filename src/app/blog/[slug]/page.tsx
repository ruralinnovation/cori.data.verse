import { getBlogSlugs, getBlogMetadata, getMarkdownBody } from "@/utils/content";
import MarkdownContent from "@/components/MarkdownContent";
import Link from "next/link";
import type { BlogPostMeta } from "@/types";
import type { Metadata } from "next";

/** Normalize author field: can be string, array of strings, or array of {name} objects */
function formatAuthor(author: unknown): string | null {
  if (!author) return null;
  if (typeof author === "string") return author;
  if (Array.isArray(author)) {
    return author
      .map((a) => (typeof a === "string" ? a : a?.name || ""))
      .filter(Boolean)
      .join(", ");
  }
  if (typeof author === "object" && "name" in (author as Record<string, unknown>)) {
    return (author as { name: string }).name;
  }
  return String(author);
}

export async function generateStaticParams() {
  return getBlogSlugs().map((slug) => ({ slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const meta = getBlogMetadata().find((p) => p.slug === slug);
  return {
    title: meta?.title || slug,
    description: meta?.description || meta?.subtitle,
  };
}

export default async function BlogPostPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const metadata = getBlogMetadata().find(
    (p) => p.slug === slug
  ) as BlogPostMeta | undefined;
  const body = getMarkdownBody("blog", slug);

  if (!metadata) {
    return (
      <div className="container">
        <p>Post not found.</p>
      </div>
    );
  }

  return (
    <div className="container">
      <article>
        <nav className="breadcrumb">
          <Link href="/">Home</Link> / <Link href="/blog">Blog</Link> /{" "}
          <span>{metadata.title}</span>
        </nav>

        <header style={{ marginBottom: "2rem" }}>
          <h1>{metadata.title}</h1>
          {metadata.subtitle && (
            <p style={{ color: "var(--color-subtitle)", fontSize: "1.15rem" }}>
              {metadata.subtitle}
            </p>
          )}
          <div style={{ display: "flex", gap: "1rem", alignItems: "center", fontSize: "0.9rem", color: "var(--color-subtitle)" }}>
            {metadata.author && <span>By {formatAuthor(metadata.author)}</span>}
            {metadata.date && (
              <span>
                {new Date(metadata.date).toLocaleDateString("en-US", {
                  year: "numeric",
                  month: "long",
                  day: "numeric",
                })}
              </span>
            )}
          </div>
          {metadata.categories && metadata.categories.length > 0 && (
            <div style={{ marginTop: "0.75rem" }}>
              {metadata.categories.map((cat) => (
                <span key={cat} className="badge">
                  {cat}
                </span>
              ))}
            </div>
          )}
        </header>

        <MarkdownContent content={body} />

        {metadata.tags && metadata.tags.length > 0 && (
          <footer style={{ marginTop: "2rem", paddingTop: "1rem", borderTop: "1px solid var(--color-border)" }}>
            <strong>Tags: </strong>
            {metadata.tags.map((tag) => (
              <span key={tag} className="badge">
                {tag}
              </span>
            ))}
          </footer>
        )}
      </article>
    </div>
  );
}
