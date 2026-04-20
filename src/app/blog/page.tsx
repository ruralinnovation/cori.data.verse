import { getBlogMetadata } from "@/utils/content";
import ListingGrid from "@/components/ListingGrid";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Blog",
  description: "Data stories, analyses, and insights from the CORI MDA team",
};

export default function BlogPage() {
  const posts = getBlogMetadata();

  return (
    <div className="container">
      <div className="page-header">
        <h1>Blog</h1>
        <p>Data stories, analyses, and insights from the CORI MDA team</p>
      </div>
      <ListingGrid items={posts} basePath="/blog" />
    </div>
  );
}
