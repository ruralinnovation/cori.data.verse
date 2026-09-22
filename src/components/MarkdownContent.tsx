"use client";

import { Children, isValidElement } from "react";
import Markdown from "markdown-to-jsx";
import Link from "next/link";
import Callout from "@/components/quarto/Callout";
import { Columns, Column } from "@/components/quarto/Columns";
import LightboxImage from "@/components/quarto/LightboxImage";
import PanelTabset from "@/components/quarto/PanelTabset";

/**
 * Custom link component that uses Next.js Link for internal navigation,
 * which automatically prepends the basePath.
 */
function MarkdownLink(props: Record<string, unknown>) {
  const href = props.href as string;
  const children = props.children as React.ReactNode;

  // External links: open in a new tab
  if (href && href.startsWith("http")) {
    return (
      <a {...props} target="_blank" rel="noopener noreferrer">
        {children}
      </a>
    );
  }

  // Anchors and mailto links: use regular <a>
  if (!href || href.startsWith("#") || href.startsWith("mailto:")) {
    return <a {...props}>{children}</a>;
  }

  // Internal links: use Next.js Link for basePath support
  return <Link href={href}>{children}</Link>;
}

/** Quarto's own div class names, mapped to the type names used below. */
const QUARTO_DIV_CLASSES: Record<string, string> = {
  columns: "columns",
  column: "column",
  "panel-tabset": "tabset",
  aside: "aside",
};

/**
 * Quarto emits class-based divs (`<div class="columns">`) while the
 * preprocessor emits `data-quarto` markers. Accept either.
 *
 * Deliberately does not map `callout-*` classes: real callouts reach us as GFM
 * alert blockquotes, so a div with that class means an invalid callout type,
 * which should stay visibly unstyled rather than be silently rescued.
 */
function quartoTypeOf(props: Record<string, unknown>): string | undefined {
  const marker = props["data-quarto"] as string | undefined;
  if (marker) return marker;

  const className = (props.className ?? props.class) as string | undefined;
  if (!className) return undefined;

  for (const name of String(className).split(/\s+/)) {
    if (name in QUARTO_DIV_CLASSES) return QUARTO_DIV_CLASSES[name];
  }
  return undefined;
}

/** Flatten a node tree to plain text, for use as a tab label. */
function nodeText(node: React.ReactNode): string {
  if (node === null || node === undefined || typeof node === "boolean") return "";
  if (typeof node === "string" || typeof node === "number") return String(node);
  if (Array.isArray(node)) return node.map(nodeText).join("");
  if (isValidElement(node)) {
    return nodeText((node.props as { children?: React.ReactNode }).children);
  }
  return "";
}

const HEADING_TAGS = new Set(["h1", "h2", "h3", "h4", "h5", "h6"]);

/**
 * Quarto delimits tabs with headings inside the tabset div. Depending on
 * whether the preprocessor has converted them, those arrive as raw <h3>
 * elements or as headings parsed from markdown -- either way they are heading
 * elements by the time we see them, so split on any heading tag.
 */
function splitIntoTabs(children: React.ReactNode) {
  const tabs: { label: string; content: React.ReactNode[] }[] = [];

  Children.forEach(children, (child) => {
    const isHeading =
      isValidElement(child) &&
      typeof child.type === "string" &&
      HEADING_TAGS.has(child.type);

    if (isHeading) {
      tabs.push({ label: nodeText(child), content: [] });
    } else if (tabs.length > 0) {
      tabs[tabs.length - 1].content.push(child);
    }
  });

  return tabs;
}

/**
 * Routes Quarto's fenced-div output to the appropriate React components.
 */
function QuartoDiv(props: Record<string, unknown>) {
  const quartoType = quartoTypeOf(props);
  const children = props.children as React.ReactNode;

  if (!quartoType) {
    // Regular div -- pass through
    return <div {...props}>{children}</div>;
  }

  // Callout types (only reachable via an explicit data-quarto marker)
  if (quartoType.startsWith("callout-")) {
    const type = quartoType.replace("callout-", "") as
      | "note"
      | "tip"
      | "warning"
      | "important";
    return <Callout type={type}>{children}</Callout>;
  }

  // Tabset -- headings inside the div delimit the tabs
  if (quartoType === "tabset") {
    const tabs = splitIntoTabs(children);
    if (tabs.length === 0) return <div>{children}</div>;
    return <PanelTabset tabs={tabs} />;
  }

  // Columns
  if (quartoType === "columns") {
    return <Columns>{children}</Columns>;
  }

  // Column -- Quarto writes the width as a plain attribute, the preprocessor
  // as data-width.
  if (quartoType === "column") {
    const width = (props["data-width"] ?? props.width) as string | undefined;
    return <Column width={width}>{children}</Column>;
  }

  // Aside
  if (quartoType === "aside") {
    return (
      <aside style={{ fontSize: "0.85em", color: "var(--color-subtitle)", borderLeft: "3px solid var(--color-border)", paddingLeft: "1em", margin: "1em 0" }}>
        {children}
      </aside>
    );
  }

  // Unknown quarto type -- render as div
  return <div>{children}</div>;
}

/**
 * Custom image component that wraps all images with lightbox behavior.
 * Prepends basePath to absolute image paths for proper GitHub Pages deployment.
 */
function MarkdownImage(props: Record<string, unknown>) {
  let src = props.src as string;

  // Prepend basePath to absolute paths (e.g., /content/...) unless already external
  if (src && src.startsWith("/") && !src.startsWith("http")) {
    const basePath = process.env.NEXT_PUBLIC_BASE_PATH || "";
    src = basePath + src;
  }

  return (
    <LightboxImage
      src={src}
      alt={(props.alt as string) || ""}
    />
  );
}

interface MarkdownContentProps {
  content: string;
}

export default function MarkdownContent({ content }: MarkdownContentProps) {
  return (
    <div className="markdown-body">
      <Markdown
        options={{
          forceBlock: true,
          overrides: {
            a: { component: MarkdownLink },
            div: { component: QuartoDiv },
            img: { component: MarkdownImage },
          },
        }}
      >
        {content}
      </Markdown>
    </div>
  );
}
