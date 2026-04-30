#!/usr/bin/env node

/**
 * preprocess-markdown.js
 *
 * Runs after `quarto render --to gfm` and before `next build`.
 * Converts Quarto ::: fenced div directives that survive in GFM output
 * into HTML <div data-quarto="..."> markers that markdown-to-jsx can
 * route to React components.
 *
 * Transformations:
 *   ::: {.callout-note}  →  <div data-quarto="callout-note">
 *   ::: {.callout-tip}   →  <div data-quarto="callout-tip">
 *   ::: {.callout-warning} → <div data-quarto="callout-warning">
 *   ::: {.callout-important} → <div data-quarto="callout-important">
 *   ::: {.panel-tabset}  →  <div data-quarto="tabset">
 *   ::: columns           →  <div data-quarto="columns">
 *   ::: {.column width="50%"} → <div data-quarto="column" data-width="50%">
 *   :::                   →  </div>  (closing fence)
 */

import fs from "fs";
import path from "path";

const CONTENT_DIR = path.join(process.cwd(), "content");

/**
 * Recursively find all .md files in a directory.
 */
function findMarkdownFiles(dir) {
  const results = [];
  if (!fs.existsSync(dir)) return results;

  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      results.push(...findMarkdownFiles(fullPath));
    } else if (entry.name.endsWith(".md")) {
      results.push(fullPath);
    }
  }
  return results;
}

/**
 * Process a single markdown file, converting Quarto directives and
 * markdown headings inside HTML divs to proper HTML.
 *
 * Handles both ::: syntax (legacy) and HTML divs (Quarto GFM output).
 */
function processMarkdown(content) {
  const lines = content.split("\n");
  const output = [];
  const divStack = []; // Track open div blocks
  let inCodeFence = false; // Track fenced code blocks (```)

  // Quarto HTML div classes that contain markdown content
  const quartoHtmlDivs = new Set([
    "panel-tabset",
    "callout-note",
    "callout-tip",
    "callout-warning",
    "callout-important",
    "columns",
    "column",
    "aside",
  ]);

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const trimmed = line.trim();

    // Toggle code-fence state on ``` lines (with or without language tag)
    // Pass through unchanged so heading conversion doesn't touch code contents
    if (/^```/.test(trimmed)) {
      inCodeFence = !inCodeFence;
      output.push(line);
      continue;
    }

    // Inside a code fence: pass everything through verbatim
    if (inCodeFence) {
      output.push(line);
      continue;
    }

    // Handle HTML opening divs from Quarto (e.g., <div class="panel-tabset">)
    const htmlDivMatch = trimmed.match(/^<div\s+(?:class|data-[a-z]+)="([^"]+)"/);
    if (htmlDivMatch) {
      const className = htmlDivMatch[1];
      if (
        quartoHtmlDivs.has(className) ||
        className.startsWith("callout-") ||
        className === "column" ||
        className === "columns" ||
        className === "tabset"
      ) {
        divStack.push(className);
        output.push(line);
        continue;
      }
    }

    // Handle closing HTML divs
    if (/^<\/div>/.test(trimmed)) {
      if (divStack.length > 0) {
        divStack.pop();
      }
      output.push(line);
      continue;
    }

    // Opening ::: directives (with class/attributes)
    if (/^:::\s*\{\.callout-(note|tip|warning|important)\}/.test(trimmed)) {
      const type = trimmed.match(
        /callout-(note|tip|warning|important)/
      )[1];
      output.push(`<div data-quarto="callout-${type}">`);
      divStack.push("callout");
      continue;
    }

    if (/^:::\s*\{\.panel-tabset\}/.test(trimmed)) {
      output.push('<div data-quarto="tabset">');
      divStack.push("tabset");
      continue;
    }

    if (/^:::\s*columns/.test(trimmed) || /^:::\s*\{\.columns\}/.test(trimmed)) {
      output.push('<div data-quarto="columns">');
      divStack.push("columns");
      continue;
    }

    if (/^:::\s*\{\.column/.test(trimmed)) {
      const widthMatch = trimmed.match(/width="?(\d+%?)"?/);
      const width = widthMatch ? widthMatch[1] : "50%";
      output.push(`<div data-quarto="column" data-width="${width}">`);
      divStack.push("column");
      continue;
    }

    if (/^:::\s*\{\.aside\}/.test(trimmed)) {
      output.push('<div data-quarto="aside">');
      divStack.push("aside");
      continue;
    }

    // Closing ::: (bare, no attributes)
    if (/^:::$/.test(trimmed)) {
      if (divStack.length > 0) {
        divStack.pop();
        output.push("</div>");
      } else {
        // Orphaned closing fence -- pass through
        output.push(line);
      }
      continue;
    }

    // Convert markdown headings to HTML when inside Quarto divs
    // This ensures markdown-to-jsx can parse them correctly
    if (divStack.length > 0 && /^#+\s+/.test(trimmed)) {
      const headingMatch = line.match(/^(#+)\s+(.*?)$/);
      if (headingMatch) {
        const level = headingMatch[1].length;
        const text = headingMatch[2];
        output.push(`<h${level}>${text}</h${level}>`);
        continue;
      }
    }

    // Convert lightbox image attributes: ![](img){.lightbox} → ![](img)
    // The LightboxImage component wraps all images by default
    if (/{\.lightbox}/.test(line)) {
      output.push(line.replace(/\{\.lightbox\}/g, ""));
      continue;
    }

    // Pass through all other lines unchanged
    output.push(line);
  }

  // Close any unclosed divs (shouldn't happen with well-formed content)
  while (divStack.length > 0) {
    divStack.pop();
    output.push("</div>");
  }

  return output.join("\n");
}

// Main
const files = findMarkdownFiles(CONTENT_DIR);

if (files.length === 0) {
  console.log(
    "preprocess-markdown: No .md files found in content/. Run quarto render first."
  );
  process.exit(0);
}

let processed = 0;
for (const filePath of files) {
  const content = fs.readFileSync(filePath, "utf-8");
  const result = processMarkdown(content);
  if (result !== content) {
    fs.writeFileSync(filePath, result, "utf-8");
    processed++;
  }
}

console.log(
  `preprocess-markdown: Processed ${processed}/${files.length} files in content/`
);
