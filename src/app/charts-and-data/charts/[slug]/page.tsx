import { getAllSlugs, getContentMetadata, getMarkdownBody } from "@/utils/content";
import MarkdownContent from "@/components/MarkdownContent";
import ChartSidebar from "@/components/ChartSidebar";
import Link from "next/link";
import type { ChartMeta } from "@/types";
import type { Metadata } from "next";

export async function generateStaticParams() {
  return getAllSlugs("charts").map((slug) => ({ slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const meta = getContentMetadata<ChartMeta>("charts").find(
    (c) => c.slug === slug
  );
  return {
    title: meta?.title || slug,
    description: meta?.description,
  };
}

export default async function ChartPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const metadata = getContentMetadata<ChartMeta>("charts").find(
    (c) => c.slug === slug
  );
  const body = getMarkdownBody("charts", slug);

  if (!metadata) {
    return (
      <div className="container">
        <p>Chart not found.</p>
      </div>
    );
  }

  return (
    <div className="container">
      <nav className="breadcrumb">
        <Link href="/">Home</Link> /{" "}
        <Link href="/charts-and-data">Charts &amp; Data</Link> /{" "}
        <Link href="/charts-and-data#charts">Charts</Link> /{" "}
        <span>{metadata.title}</span>
      </nav>

      <h1>{metadata.title}</h1>
      {metadata.description && (
        <p style={{ color: "var(--color-subtitle)", fontSize: "1.1rem" }}>
          {metadata.description}
        </p>
      )}

      {metadata.categories && metadata.categories.length > 0 && (
        <div style={{ marginBottom: "1.5rem" }}>
          {metadata.categories.map((cat) => (
            <span key={cat} className="badge">
              {cat}
            </span>
          ))}
        </div>
      )}

      <div className="content-grid">
        <MarkdownContent content={body} />
        <ChartSidebar chart={metadata.chart} />
      </div>
    </div>
  );
}
