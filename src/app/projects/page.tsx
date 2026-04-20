import { getProjects } from "@/utils/content";
import ListingGrid from "@/components/ListingGrid";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Projects",
  description: "Research projects and analyses from the CORI MDA team",
};

export default function ProjectsPage() {
  const projects = getProjects();

  return (
    <div className="container">
      <div className="page-header">
        <h1>Projects</h1>
        <p>Research projects and analyses from the CORI MDA team</p>
      </div>
      <ListingGrid items={projects} basePath="/projects" />
    </div>
  );
}
