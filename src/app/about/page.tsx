import fs from "fs";
import path from "path";
import matter from "gray-matter";
import MarkdownContent from "@/components/MarkdownContent";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "About",
  description: "About the Rural Dataverse and the CORI MDA team",
};

function getAboutContent(): string {
  const mdPath = path.join(process.cwd(), "content", "about.md");
  if (!fs.existsSync(mdPath)) {
    return "> About page content not found. Run `quarto render` first.";
  }
  const raw = fs.readFileSync(mdPath, "utf-8");
  const { content } = matter(raw);
  return content
    .replace(/(<[^>]+)\bclass=/g, "$1className=")
    .replace(/(<label[^>]*)\bfor=/g, "$1htmlFor=");
}

export default function AboutPage() {
  const content = getAboutContent();

  return (
    <div className="container" style={{ padding: "2rem 0" }}>
      <MarkdownContent content={content} />
    </div>
  );
}
