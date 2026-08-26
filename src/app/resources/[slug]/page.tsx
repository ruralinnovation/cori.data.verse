import { getAllSlugs, getContentMetadata, getMarkdownBody } from "@/utils/content";
import MarkdownContent from "@/components/MarkdownContent";
import Link from "next/link";
import type { ContentMeta } from "@/types";
import type { Metadata } from "next";

export async function generateStaticParams() {
  return getAllSlugs("resources").map((slug) => ({ slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const meta = getContentMetadata<ContentMeta>("resources").find(
    (d) => d.slug === slug
  );
  return {
    title: meta?.title || slug,
    description: meta?.description,
  };
}

export default async function ResourcePage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const metadata = getContentMetadata<ContentMeta>("resources").find(
    (d) => d.slug === slug
  );
  const body = getMarkdownBody("resources", slug);

  if (!metadata) {
    return (
      <div className="container">
        <p>Resource not found.</p>
      </div>
    );
  }

  return (
    <div className="container">
      <nav className="breadcrumb">
        <Link href="/">Home</Link> / <Link href="/resources">Resources</Link> /{" "}
        <span>{metadata.title}</span>
      </nav>

      <h1>{metadata.title}</h1>
      {metadata.description && (
        <p style={{ color: "var(--color-subtitle)", fontSize: "1.1rem" }}>
          {metadata.description}
        </p>
      )}

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
    </div>
  );
}
