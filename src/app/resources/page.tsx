import fs from "fs";
import path from "path";
import matter from "gray-matter";
import MarkdownContent from "@/components/MarkdownContent";
import SearchBar from "@/components/SearchBar";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Resources",
  description: "Tools, guides, and resources for rural data analysis",
};

function getResourcesContent(): string {
  const mdPath = path.join(process.cwd(), "content", "resources", "index.md");
  if (!fs.existsSync(mdPath)) {
    return "> Resources page content not found. Run `quarto render` first.";
  }
  const raw = fs.readFileSync(mdPath, "utf-8");
  const { content } = matter(raw);
  return content
    .replace(/(<[^>]+)\bclass=/g, "$1className=")
    .replace(/(<label[^>]*)\bfor=/g, "$1htmlFor=");
}

export default function ResourcesPage() {
  const content = getResourcesContent();

  return (
    <>
      <SearchBar />
      <div className="container" style={{ padding: "2rem 0" }}>
        <MarkdownContent content={content} />
      </div>
    </>
  );
}
