import type { MarkdownToJSX } from "markdown-to-jsx";

/**
 * Override options for markdown-to-jsx that route Quarto-preprocessed
 * HTML markers to React components.
 *
 * The preprocess-markdown.js script converts Quarto ::: directives to
 * <div data-quarto="..."> markers. This config maps those to components.
 *
 * Components are imported dynamically in MarkdownContent.tsx to avoid
 * circular dependencies.
 */
export function getMarkdownOptions(overrides: MarkdownToJSX.Overrides = {}): MarkdownToJSX.Options {
  return {
    forceBlock: true,
    overrides: {
      ...overrides,
    },
  };
}
