#!/usr/bin/env node

/**
 * copy-post-assets.js
 *
 * Copies non-.qmd, non-.md asset files (images, data, etc.) from posts/
 * subdirectories to public/content/, maintaining directory structure.
 * This ensures image references in GFM markdown resolve correctly
 * when served by NextJS from the public/ directory.
 */

import fs from "fs";
import path from "path";

const POSTS_DIR = path.join(process.cwd(), "posts");
const CONTENT_DIR = path.join(process.cwd(), "content");
const PUBLIC_CONTENT_DIR = path.join(process.cwd(), "public", "content");

/** File extensions to skip (source files, not assets) */
const SKIP_EXTENSIONS = new Set([".qmd", ".md", ".yml", ".yaml", ".Rmd"]);

/** Directories to skip entirely */
const SKIP_DIRS = new Set(["_freeze", ".quarto", "node_modules", "_site"]);

/**
 * Recursively copy asset files from src to dest, maintaining structure.
 */
function copyAssets(srcDir, destDir, basePath = "") {
  if (!fs.existsSync(srcDir)) return 0;

  const entries = fs.readdirSync(srcDir, { withFileTypes: true });
  let copied = 0;

  for (const entry of entries) {
    const srcPath = path.join(srcDir, entry.name);
    const destPath = path.join(destDir, entry.name);

    if (entry.isDirectory()) {
      if (SKIP_DIRS.has(entry.name)) continue;
      copied += copyAssets(srcPath, destPath, path.join(basePath, entry.name));
    } else {
      const ext = path.extname(entry.name).toLowerCase();
      if (SKIP_EXTENSIONS.has(ext)) continue;

      // Create destination directory if needed
      fs.mkdirSync(destDir, { recursive: true });
      fs.copyFileSync(srcPath, destPath);
      copied++;
    }
  }

  return copied;
}

/**
 * Copy a single file from content/ to public/content/ if it exists.
 */
function copySingleFile(relPath) {
  const srcPath = path.join(process.cwd(), "content", relPath);
  const destPath = path.join(PUBLIC_CONTENT_DIR, relPath);
  if (!fs.existsSync(srcPath)) return 0;
  fs.mkdirSync(path.dirname(destPath), { recursive: true });
  fs.copyFileSync(srcPath, destPath);
  return 1;
}

// Main

// Blog posts: posts/<slug>/ → public/content/<slug>/
let copied = copyAssets(POSTS_DIR, PUBLIC_CONTENT_DIR);

// Other content types: <type>/<slug>/ → public/content/<type>/<slug>/
const CONTENT_TYPE_DIRS = ["datasets", "charts", "packages", "projects", "resources"];
for (const type of CONTENT_TYPE_DIRS) {
  const typeDir = path.join(process.cwd(), type);
  const destTypeDir = path.join(PUBLIC_CONTENT_DIR, type);
  if (fs.existsSync(typeDir)) {
    copied += copyAssets(typeDir, destTypeDir);
  }
}

// Copy Quarto-generated assets (e.g. index_files/ figures) from content/ to public/content/.
// SKIP_EXTENSIONS already excludes .md, so only non-markdown outputs (images, etc.) are copied.
copied += copyAssets(CONTENT_DIR, PUBLIC_CONTENT_DIR);

// Copy graph.json from content/ to public/content/
copied += copySingleFile("graph.json");

console.log(`copy-post-assets: Copied ${copied} asset files to public/content/`);
