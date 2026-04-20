import { getAllSlugs, getContentMetadata, getMarkdownBody } from "@/utils/content";
import MarkdownContent from "@/components/MarkdownContent";
import DatasetSidebar from "@/components/DatasetSidebar";
import Link from "next/link";
import type { DatasetMeta } from "@/types";
import type { Metadata } from "next";

export async function generateStaticParams() {
  return getAllSlugs("datasets").map((slug) => ({ slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const meta = getContentMetadata<DatasetMeta>("datasets").find(
    (d) => d.slug === slug
  );
  return {
    title: meta?.title || slug,
    description: meta?.description,
  };
}

export default async function DatasetPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const metadata = getContentMetadata<DatasetMeta>("datasets").find(
    (d) => d.slug === slug
  );
  const body = getMarkdownBody("datasets", slug);

  if (!metadata) {
    return (
      <div className="container">
        <p>Dataset not found.</p>
      </div>
    );
  }

  return (
    <div className="container">
      <nav className="breadcrumb">
        <Link href="/">Home</Link> /{" "}
        <Link href="/charts-and-data">Charts &amp; Data</Link> /{" "}
        <Link href="/charts-and-data#datasets">Datasets</Link> /{" "}
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
        <DatasetSidebar dataset={metadata.dataset} />
      </div>
    </div>
  );
}
