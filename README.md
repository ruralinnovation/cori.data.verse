# Rural Dataverse by the Center on Rural Innovation (CORI)

A universe of rural innovation data, tools, research, and analysis from the [Center on Rural Innovation (CORI)](https://ruralinnovation.us/).

This project combines **Quarto** for content authoring with **Next.js** for the site shell, producing a static site that showcases CORI's datasets, R packages, research projects, charts, and blog posts.

### Adding New Content (Quarto Markdown)

Content lives in top-level directories (`datasets/`, `packages/`, `projects/`, `charts/`, `posts/`, `resources/`). Each content item is a folder containing an `index.qmd` file.

#### 1. Create a new content item

```bash
mkdir datasets/my-new-dataset
touch datasets/my-new-dataset/index.qmd
```

#### 2. Add frontmatter

Each content type has specific frontmatter fields. Example for a dataset:

```yaml
---
title: "My New Dataset"
description: "A brief description of the dataset"
author: "Your Name"
date: "2026-04-29"
categories: [category1, category2]
dataset:
  name: "my-new-dataset"
  source: "Data Provider Name"
  sourceUrl: "https://example.com/data"
  accessMethod: "API"
  updateFrequency: "Annual"
  geographicLevel: "County"
  dataFormat: "CSV"
  featured: false
---

Your content here...
```

#### 3. Preview your content

```bash
quarto preview datasets/my-new-dataset/index.qmd
```

#### 4. Build the full site

```bash
npm run render      # Render all .qmd files to content/
npm run build       # Build the Next.js static site
npm run start       # Serve the built site locally (so you can review and commit)
```

#### 5. Run the targets pipeline to sync local content with S3:

```bash
Rscript -e "targets::tar_make()"
```

## Content Types

| Type | Directory | Frontmatter Key | Description |
|------|-----------|-----------------|-------------|
| Dataset | `datasets/` | `dataset:` | Data sources used in CORI research |
| Package | `packages/` | `package:` | R packages maintained by CORI |
| Project | `projects/` | (root level) | Research projects and initiatives |
| Chart | `charts/` | `chart:` | Data visualizations |
| Post | `posts/` | (root level) | Blog posts and articles |
| Resource | `resources/` | `resource:` | External resources and links |

## Project Structure

```
cori.data.verse/
├── datasets/           # Dataset content (.qmd sources)
├── packages/           # R package documentation (.qmd sources)
├── projects/           # Research project pages (.qmd sources)
├── charts/             # Data visualizations (.qmd sources)
├── posts/              # Blog posts (.qmd sources)
├── resources/          # External resource links (.qmd sources)
├── content/            # Rendered GFM markdown (Quarto output)
├── src/
│   ├── app/            # Next.js App Router pages
│   ├── components/     # React components
│   ├── types/          # TypeScript interfaces
│   └── utils/          # Content utilities
├── public/             # Static assets (images, fonts)
├── scripts/            # Build scripts (preprocess, copy assets)
├── R/                  # R package functions (content graph)
└── out/                # Built static site
```

## Development Workflows

### Developing Site Features (Next.js)

The Next.js App Router handles navigation, layout, and page rendering. Source files live in `src/`.

#### Build Pipeline

The full build has four steps:

```bash
# 1. Render Quarto .qmd files to GFM markdown in content/
npm run render

# 2. Preprocess Quarto directives (:::) to HTML data-quarto markers
npm run preprocess

# 3. Copy images and assets from source directories to public/content/
npm run copy

# 4. Build the Next.js static site to out/
npm run build
```

The `prebuild` script runs steps 2 and 3 automatically before `npm run build`.

#### Key locations

- `src/app/layout.tsx` — Root layout (nav, footer)
- `src/app/page.tsx` — Home page
- `src/app/datasets/page.tsx` — Dataset listing
- `src/app/[slug]/page.tsx` — Dynamic content pages
- `src/components/` — Reusable React components
- `src/types/index.ts` — TypeScript interfaces for content types
- `src/utils/content.ts` — Content reading utilities (frontmatter, markdown)

#### Run the dev server

```bash
npm run dev
```

This starts the Next.js dev server with hot reloading. Changes to React components and pages will reflect immediately. Note that content changes (`.qmd` files) require a Quarto re-render.

#### Type checking

```bash
npm run type:check
```

## R Package Component

This project also functions as an R package providing functions for building a content dependency graph:

- `R/utils_frontmatter.R` — Read frontmatter from `.qmd` files
- `R/build_graph.R` — Generate `content/graph.json` from content relationships

Run the targets pipeline to sync content with S3:

```bash
Rscript -e "targets::tar_make()"
```

## License

ISC
