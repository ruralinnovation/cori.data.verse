#!/usr/bin/env node

/**
 * generate-search-index.js
 *
 * Reads frontmatter from all content items (datasets, charts, packages, projects,
 * resources) and produces a flat JSON search index at public/content/search-index.json.
 * Consumed client-side by the SearchBar component for instant filtering.
 *
 * Run after quarto render (so .md + .metadata.json sidecars exist).
 */

import fs from "fs";
import path from "path";
import matter from "gray-matter";

const ROOT_DIR = process.cwd();
const CONTENT_DIR = path.join(ROOT_DIR, "content");
const OUTPUT_DIR = path.join(ROOT_DIR, "public", "content");

const CONTENT_TYPES = [
  {
    key: "charts",
    urlPrefix: "/charts-and-data/charts",
  },
  {
    key: "datasets",
    urlPrefix: "/charts-and-data/datasets",
  },
  {
    key: "packages",
    urlPrefix: "/packages",
  },
  {
    key: "projects",
    urlPrefix: "/projects",
  },
  {
    key: "resources",
    urlPrefix: "/resources",
  },
];

/**
 * Compare two content titles for alphabetical (A-Z) ordering.
 * Mirrors compareByTitle() in src/utils/content.ts so listings and search agree.
 */
function compareByTitle(a, b) {
  return a.localeCompare(b, undefined, { numeric: true, sensitivity: "base" });
}

/**
 * Read frontmatter from a .qmd or .md file.
 * For .md files, prefer the .metadata.json sidecar written by R's write_metadata_sidecars().
 */
function readFrontmatter(filePath, slug) {
  let data = {};

  if (filePath.endsWith(".md")) {
    const sidecarPath = filePath + ".metadata.json";
    if (fs.existsSync(sidecarPath)) {
      try {
        data = JSON.parse(fs.readFileSync(sidecarPath, "utf-8"));
      } catch (err) {
        console.warn(`Failed to parse sidecar ${sidecarPath}:`, err);
      }
    } else {
      const fileContent = fs.readFileSync(filePath, "utf-8");
      data = matter(fileContent).data;
      console.warn(
        `Metadata sidecar missing for ${filePath}. Frontmatter may be incomplete.`
      );
    }
  } else {
    const fileContent = fs.readFileSync(filePath, "utf-8");
    data = matter(fileContent).data;
  }

  return {
    title: data.title || slug,
    description: data.description || null,
    author: data.author || null,
    date: data.date || null,
    categories: Array.isArray(data.categories) ? data.categories : [],
    tags: Array.isArray(data.tags) ? data.tags : [],
    featured: Boolean(data.featured),
  };
}

function buildIndex() {
  const allItems = [];
  const allCategories = new Set();
  const allTags = new Set();

  for (const { key, urlPrefix } of CONTENT_TYPES) {
    const sourceDir = path.join(ROOT_DIR, key);
    const contentTypeDir = path.join(CONTENT_DIR, key);
    const seen = new Set();

    // Source-backed items: .qmd files
    if (fs.existsSync(sourceDir)) {
      for (const entry of fs.readdirSync(sourceDir, { withFileTypes: true })) {
        if (!entry.isDirectory()) continue;
        if (entry.name === "_templates" || entry.name.startsWith(".")) continue;
        const qmdPath = path.join(sourceDir, entry.name, "index.qmd");
        if (!fs.existsSync(qmdPath)) continue;

        const meta = readFrontmatter(qmdPath, entry.name);
        if (meta.draft === true) continue;

        allItems.push({
          type: key,
          slug: entry.name,
          ...meta,
          url: `${urlPrefix}/${entry.name}`,
        });
        seen.add(entry.name);

        meta.categories.forEach((c) => allCategories.add(c));
        meta.tags.forEach((t) => allTags.add(t));
      }
    }

    // Content-only items (S3-fetched): .md + metadata sidecar
    if (fs.existsSync(contentTypeDir)) {
      for (const entry of fs.readdirSync(contentTypeDir, { withFileTypes: true })) {
        if (!entry.isDirectory()) continue;
        if (seen.has(entry.name)) continue;
        const mdPath = path.join(contentTypeDir, entry.name, "index.md");
        if (!fs.existsSync(mdPath)) continue;

        const meta = readFrontmatter(mdPath, entry.name);
        if (meta.draft === true) continue;

        allItems.push({
          type: key,
          slug: entry.name,
          ...meta,
          url: `${urlPrefix}/${entry.name}`,
        });

        meta.categories.forEach((c) => allCategories.add(c));
        meta.tags.forEach((t) => allTags.add(t));
      }
    }
  }

  // Sort by title ascending
  allItems.sort((a, b) => compareByTitle(a.title, b.title));

  const index = {
    items: allItems,
    facets: {
      types: CONTENT_TYPES.map((ct) => ct.key),
      categories: [...allCategories].sort(),
      tags: [...allTags].sort(),
    },
    generatedAt: new Date().toISOString(),
  };

  // Ensure output directory exists
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  const outputPath = path.join(OUTPUT_DIR, "search-index.json");
  fs.writeFileSync(outputPath, JSON.stringify(index, null, 2), "utf-8");

  console.log(
    `generate-search-index: Wrote ${allItems.length} items (${allCategories.size} categories, ${allTags.size} tags) to ${path.relative(ROOT_DIR, outputPath)}`
  );
}

buildIndex();
