import { getAllSlugs, getContentMetadata, getMarkdownBody } from "@/utils/content";
import MarkdownContent from "@/components/MarkdownContent";
import ProjectSidebar from "@/components/ProjectSidebar";
import Link from "next/link";
import type { ProjectMeta } from "@/types";
import type { Metadata } from "next";

export async function generateStaticParams() {
  return getAllSlugs("projects").map((slug) => ({ slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const meta = getContentMetadata<ProjectMeta>("projects").find(
    (d) => d.slug === slug
  );
  return {
    title: meta?.title || slug,
    description: meta?.description,
  };
}

export default async function ProjectPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const metadata = getContentMetadata<ProjectMeta>("projects").find(
    (d) => d.slug === slug
  );
  const body = getMarkdownBody("projects", slug);

  if (!metadata) {
    return (
      <div className="container">
        <p>Project not found.</p>
      </div>
    );
  }

  return (
    <div className="container">
      <nav className="breadcrumb">
        <Link href="/">Home</Link> / <Link href="/projects">Projects</Link> /{" "}
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
        <ProjectSidebar project={metadata} />
      </div>
    </div>
  );
}
