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
import { execSync } from "child_process";
import os from "os";

const CONTENT_DIR = path.join(process.cwd(), "content");
const PUBLIC_CONTENT_DIR = path.join(process.cwd(), "public", "content");

/**
 * Render all ```mermaid code blocks in a markdown string to SVG files,
 * saving them alongside the content file in public/content/, and replacing
 * the code block with a relative ![](mermaid-N.svg) image reference.
 *
 * @param {string} content  - Markdown file content
 * @param {string} filePath - Absolute path to the .md file in content/
 * @returns {string} Updated markdown content
 */
function renderMermaidBlocks(content, filePath) {
  // Relative dir of this file within content/ (e.g. "projects/rural-economic-outlook")
  const relDir = path.relative(CONTENT_DIR, path.dirname(filePath));
  const outDir = path.join(PUBLIC_CONTENT_DIR, relDir);

  // Match ``` mermaid ... ``` blocks (Quarto GFM uses a space before "mermaid")
  const MERMAID_RE = /^``` ?mermaid\n([\s\S]*?)^```/gm;
  let index = 0;

  return content.replace(MERMAID_RE, (_match, diagram) => {
    const imgName = `mermaid-${index++}.svg`;
    const imgPath = path.join(outDir, imgName);

    // Write diagram to a temp file and render with mmdc
    const tmpInput = path.join(os.tmpdir(), `mermaid-${Date.now()}.mmd`);
    try {
      fs.mkdirSync(outDir, { recursive: true });
      fs.writeFileSync(tmpInput, diagram.trim());
      const mmdc = path.join(process.cwd(), "node_modules", ".bin", "mmdc");
      execSync(`"${mmdc}" -i "${tmpInput}" -o "${imgPath}" --quiet`, {
        stdio: "pipe",
      });
      console.log(`  mermaid → ${path.relative(process.cwd(), imgPath)}`);
    } catch (err) {
      console.warn(`  mermaid render failed: ${err.message}`);
      return _match; // leave block unchanged on error
    } finally {
      if (fs.existsSync(tmpInput)) fs.unlinkSync(tmpInput);
    }

    // Use an HTML img tag (not markdown syntax) to avoid markdown-to-jsx
    // wrapping it in a <p>, which would cause a hydration error when
    // LightboxImage renders its overlay <div> inside the paragraph.
    const relContentDir = path.relative(CONTENT_DIR, path.dirname(filePath));
    return `<img src="/content/${relContentDir.replace(/\\/g, "/")}/${imgName}" alt="Diagram" />`;
  });
}

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
  let codeFenceLang = ""; // Language of current code fence (when inside div)
  let codeFenceLines = []; // Collected lines inside fence (when inside div)
  let codeFenceInDiv = false; // Whether current fence started inside a div

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

    // Handle code fence boundaries
    if (/^```/.test(trimmed)) {
      if (!inCodeFence) {
        // Opening fence
        inCodeFence = true;
        codeFenceInDiv = divStack.length > 0;

        if (codeFenceInDiv) {
          // Inside div: extract language and start collecting
          const langMatch = trimmed.match(/^```\s*([a-zA-Z]*)/);
          codeFenceLang = langMatch ? langMatch[1] : "";
          codeFenceLines = [];
        } else {
          // Outside div: pass through (normalize ``` r to ```r)
          output.push(line.replace(/^(```) ([a-zA-Z]+)/, "$1$2"));
        }
      } else {
        // Closing fence
        inCodeFence = false;

        if (codeFenceInDiv) {
          // Inside div: emit as HTML <pre> (no inner <code> - markdown-to-jsx escapes it)
          const langClass = codeFenceLang ? ` class="language-${codeFenceLang}"` : "";
          const escaped = codeFenceLines.join("\n")
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;");
          output.push(`<pre${langClass}>${escaped}</pre>`);
        } else {
          // Outside div: pass through
          output.push(line);
        }

        codeFenceLang = "";
        codeFenceLines = [];
        codeFenceInDiv = false;
      }
      continue;
    }

    // Inside a code fence
    if (inCodeFence) {
      if (codeFenceInDiv) {
        codeFenceLines.push(line);
      } else {
        output.push(line);
      }
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

    // Convert markdown tables to HTML when inside Quarto divs
    if (divStack.length > 0 && /^\|.*\|$/.test(trimmed)) {
      // Collect all consecutive table lines
      const tableLines = [line];
      let j = i + 1;
      while (j < lines.length && /^\|.*\|$/.test(lines[j].trim())) {
        tableLines.push(lines[j]);
        j++;
      }
      i = j - 1; // Advance loop counter

      // Parse table: first line = header, second = separator, rest = body
      if (tableLines.length >= 2) {
        const parseRow = (row) => {
          return row.trim().slice(1, -1).split("|").map(cell => cell.trim());
        };

        const headerCells = parseRow(tableLines[0]);
        const bodyRows = tableLines.slice(2).map(parseRow); // Skip separator line

        let html = "<table>\n<thead>\n<tr>";
        for (const cell of headerCells) {
          html += `<th>${cell}</th>`;
        }
        html += "</tr>\n</thead>\n<tbody>\n";
        for (const row of bodyRows) {
          html += "<tr>";
          for (const cell of row) {
            html += `<td>${cell}</td>`;
          }
          html += "</tr>\n";
        }
        html += "</tbody>\n</table>";
        output.push(html);
      } else {
        // Not enough lines for a valid table, pass through
        for (const tl of tableLines) {
          output.push(tl);
        }
      }
      continue;
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
  const afterMermaid = renderMermaidBlocks(content, filePath);
  const result = processMarkdown(afterMermaid);
  if (result !== content) {
    fs.writeFileSync(filePath, result, "utf-8");
    processed++;
  }
}

console.log(
  `preprocess-markdown: Processed ${processed}/${files.length} files in content/`
);
