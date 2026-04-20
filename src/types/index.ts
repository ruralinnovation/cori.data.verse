/** Base metadata shared across all content types */
export interface ContentMeta {
  title: string;
  description?: string;
  author?: string;
  date?: string;
  slug: string;
  categories?: string[];
  tags?: string[];
  image?: string;
  featured?: boolean;
}

/** Dataset-specific frontmatter (nested under `dataset:` key in .qmd) */
export interface DatasetInfo {
  name: string;
  source: string;
  sourceUrl?: string;
  accessMethod?: string;
  updateFrequency?: string;
  geographicLevel?: string;
  dataFormat?: string[];
  featured?: boolean;
}

export interface DatasetMeta extends ContentMeta {
  dataset?: DatasetInfo;
}

/** R Package-specific frontmatter (nested under `package:` key in .qmd) */
export interface PackageInfo {
  name: string;
  githubUrl?: string;
  installCommand?: string;
  status?: string;
  version?: string;
  maintainer?: string;
  featured?: boolean;
}

export interface PackageMeta extends ContentMeta {
  package?: PackageInfo;
}

/** Project-specific frontmatter */
export interface ProjectMeta extends ContentMeta {
  projectUrl?: string;
  status?: string;
  team?: string[];
  usesDatasets?: string[];
  usesPackages?: string[];
  usesResources?: string[];
}

/** Blog post frontmatter */
export interface BlogPostMeta extends ContentMeta {
  subtitle?: string;
  draft?: boolean;
}

/** Chart-specific frontmatter (nested under `chart:` key in .qmd) */
export interface ChartInfo {
  title?: string;
  chartType?: string;
  interactive?: boolean;
  dataSource?: string;
  sourceUrl?: string;
  featured?: boolean;
}

export interface ChartMeta extends ContentMeta {
  chart?: ChartInfo;
}

/** Content type identifiers */
export type ContentType = "datasets" | "packages" | "projects" | "resources" | "charts";
