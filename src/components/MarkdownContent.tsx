"use client";

import Markdown from "markdown-to-jsx";
import Callout from "@/components/quarto/Callout";
import { Columns, Column } from "@/components/quarto/Columns";
import LightboxImage from "@/components/quarto/LightboxImage";

/**
 * Routes <div data-quarto="..."> markers from preprocessed markdown
 * to the appropriate Quarto React components.
 */
function QuartoDiv(props: Record<string, unknown>) {
  const quartoType = props["data-quarto"] as string | undefined;
  const children = props.children as React.ReactNode;

  if (!quartoType) {
    // Regular div -- pass through
    return <div {...props}>{children}</div>;
  }

  // Callout types
  if (quartoType.startsWith("callout-")) {
    const type = quartoType.replace("callout-", "") as
      | "note"
      | "tip"
      | "warning"
      | "important";
    return <Callout type={type}>{children}</Callout>;
  }

  // Tabset -- children should contain ## headings as tab delimiters
  // For now, render as sequential content (full tabset parsing requires
  // splitting children by h2 headings, which is complex in React)
  if (quartoType === "tabset") {
    return (
      <div style={{ border: "1px solid var(--color-border)", borderRadius: "6px", padding: "1.25em", margin: "1.5em 0" }}>
        {children}
      </div>
    );
  }

  // Columns
  if (quartoType === "columns") {
    return <Columns>{children}</Columns>;
  }

  // Column
  if (quartoType === "column") {
    const width = props["data-width"] as string | undefined;
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
 */
function MarkdownImage(props: Record<string, unknown>) {
  return (
    <LightboxImage
      src={props.src as string}
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
