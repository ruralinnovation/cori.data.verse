import { getContentMetadata } from "@/utils/content";
import ListingGrid from "@/components/ListingGrid";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Resources",
  description: "Tools, guides, and resources for rural data analysis",
};

export default function ResourcesPage() {
  const resources = getContentMetadata("resources");

  return (
    <div className="container">
      <div className="page-header">
        <h1>Resources</h1>
        <p>Tools, guides, and resources for rural data analysis</p>
      </div>
      <ListingGrid items={resources} basePath="/resources" />
    </div>
  );
}
