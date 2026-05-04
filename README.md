# Rural Dataverse by the Center on Rural Innovation (CORI)

A universe of rural innovation data, tools, research, and analysis from the [Center on Rural Innovation (CORI)](https://ruralinnovation.us/).

This project combines **Quarto** for content authoring with **Next.js** for the site shell, producing a static site that showcases CORI's datasets, R packages, research projects, charts, and blog posts. Next.js relies on the Node Package Manager (`npm`), so the first thing you need to do is run:

```bash
npm install
```

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

#### 4. Render all .qmd files to @`content/` and sync with S3:

```bash
npm run render      # Run the targets pipeline
# Rscript -e "targets::tar_make()" # ... same
```

#### 5. Build the full site

```bash
npm run build       # Build the Next.js static site
npm run start       # Serve the built site locally (so you can review and commit)
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

## GitHub Pages Deployment

The site deploys to GitHub Pages automatically when changes are pushed to `main`. The CI pipeline:

1. Syncs rendered content from S3 (`s3://cori.data.verse/main/content/`)
2. Runs preprocessing and asset copying (`npm run prebuild`)
3. Builds the Next.js static site (`npm run build`)
4. Deploys `out/` to GitHub Pages

Note: Quarto rendering happens locally, not in CI. The `content/` directory in CI is populated solely from S3.

### Setting Up AWS Credentials

The GitHub Actions workflows require AWS credentials to sync content from S3. Add these secrets to your repository:

1. Go to **Settings > Secrets and variables > Actions**
2. Click **New repository secret**
3. Add the following secrets:

| Secret Name | Description |
|-------------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key with S3 read permissions |
| `AWS_SECRET_ACCESS_KEY` | AWS secret access key |

The IAM user/role needs `s3:GetObject` and `s3:ListBucket` permissions on the `cori.data.verse` bucket.

### Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `build.yml` | PRs to `main`, pushes to `dev/**` | Build verification (no deploy) |
| `deploy.yml` | Push to `main` | Build and deploy to GitHub Pages |

### Enabling GitHub Pages

1. Go to **Settings > Pages**
2. Under **Build and deployment**, select **GitHub Actions** as the source
3. The first push to `main` will trigger the deployment

## License

ISC
