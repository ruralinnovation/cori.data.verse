import { getAllSlugs, getContentMetadata, getMarkdownBody } from "@/utils/content";
import MarkdownContent from "@/components/MarkdownContent";
import PackageSidebar from "@/components/PackageSidebar";
import Link from "next/link";
import type { PackageMeta } from "@/types";
import type { Metadata } from "next";

export async function generateStaticParams() {
  return getAllSlugs("packages").map((slug) => ({ slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const meta = getContentMetadata<PackageMeta>("packages").find(
    (d) => d.slug === slug
  );
  return {
    title: meta?.title || slug,
    description: meta?.description,
  };
}

export default async function PackagePage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const metadata = getContentMetadata<PackageMeta>("packages").find(
    (d) => d.slug === slug
  );
  const body = getMarkdownBody("packages", slug);

  if (!metadata) {
    return (
      <div className="container">
        <p>Package not found.</p>
      </div>
    );
  }

  return (
    <div className="container">
      <nav className="breadcrumb">
        <Link href="/">Home</Link> / <Link href="/packages">R Packages</Link> /{" "}
        <span>{metadata.title}</span>
      </nav>

      <h1>{metadata.title}</h1>
      {metadata.description && (
        <p style={{ color: "var(--color-subtitle)", fontSize: "1.1rem" }}>
          {metadata.description}
        </p>
      )}

      <div className="content-grid">
        <MarkdownContent content={body} />
        <PackageSidebar pkg={metadata.package} />
      </div>
    </div>
  );
}
