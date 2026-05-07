# Local definition of %||% for compatibility with R < 4.4
`%||%` <- function(x, y) if (is.null(x)) y else x


# --- generate_chart_frontmatter() --------------------------------------------

#' Generate Chart YAML Frontmatter
#'
#' Builds a YAML frontmatter block conforming to the `ChartMeta` interface
#' defined in `src/types/index.ts`. Includes the nested `chart:` block and the
#' graph-edge fields (`producedBy`, `usesDatasets`, `usesPackages`,
#' `usesResources`) compatible with `build_graph()`. All slugs are preserved
#' (valid + dangling).
#'
#' @param title Character.
#' @param description Character.
#' @param slug Character. URL slug for the chart (kebab-case, globally unique).
#' @param date Character or Date. Defaults to `Sys.Date()`.
#' @param categories Character vector.
#' @param tags Character vector.
#' @param image Character or `NULL`. Cover/thumbnail image filename relative
#'   to the chart directory (e.g., `"consumer_sentiment_lc.svg"`).
#' @param chart_type Character or `NULL`. Logical chart type
#'   (`"line"`, `"bar"`, `"map"`, `"density"`, `"scatter"`, `"network"`, ...).
#' @param interactive Logical. Defaults to `FALSE`.
#' @param data_source Character or `NULL`. Human-readable data source name
#'   (e.g., `"Quarterly Census of Employment and Wages"`).
#' @param source_url Character or `NULL`. URL to the upstream data source.
#' @param featured Logical. Defaults to `FALSE`.
#' @param produced_by Character or `NULL`. Slug of the project that produced
#'   the chart. Maps to `producedBy` in the YAML.
#' @param uses_datasets Character vector. Dataset slugs (kebab-case).
#' @param uses_packages Character vector. Package slugs.
#' @param uses_resources Character vector. Resource slugs.
#' @return Character string of YAML (with `---` delimiters and a trailing
#'   newline).
#' @export
generate_chart_frontmatter <- function(title,
                                        description,
                                        slug,
                                        date = Sys.Date(),
                                        categories = character(0),
                                        tags = character(0),
                                        image = NULL,
                                        chart_type = NULL,
                                        interactive = FALSE,
                                        data_source = NULL,
                                        source_url = NULL,
                                        featured = FALSE,
                                        produced_by = NULL,
                                        uses_datasets = character(0),
                                        uses_packages = character(0),
                                        uses_resources = character(0)) {
  fm <- list(
    title       = title,
    description = description,
    date        = format(as.Date(date)),
    layout      = "default",
    permalink   = paste0("/charts/", slug, "/"),
    categories  = as.list(categories),
    tags        = as.list(tags)
  )
  if (!is.null(image) && nzchar(image)) {
    fm$image <- image
  }

  # Auto-derive data_source/source_url from uses_datasets when not explicitly
  # provided OR when Claude defaulted to the generic "CORI analysis" string.
  # A lookup hit takes precedence over those two conditions; an explicit
  # non-generic value is preserved as-is.
  needs_source <- is.null(data_source) || !nzchar(data_source %||% "") ||
                  identical(trimws(data_source), "CORI analysis")
  if (needs_source) {
    derived <- lookup_dataset_source_name(uses_datasets)
    if (!is.null(derived)) data_source <- derived
  }
  needs_url <- is.null(source_url) || !nzchar(source_url %||% "")
  if (needs_url) {
    derived_url <- lookup_dataset_source_url(uses_datasets)
    if (!is.null(derived_url)) source_url <- derived_url
  }

  chart_block <- list(title = title)
  if (!is.null(chart_type) && nzchar(chart_type)) {
    chart_block$chartType <- chart_type
  }
  chart_block$interactive <- isTRUE(interactive)
  if (!is.null(data_source) && nzchar(data_source %||% "")) {
    chart_block$dataSource <- data_source
  }
  if (!is.null(source_url) && nzchar(source_url %||% "")) {
    chart_block$sourceUrl <- source_url
  }
  chart_block$featured <- isTRUE(featured)
  fm$chart <- chart_block

  if (!is.null(produced_by) && nzchar(produced_by)) {
    fm$producedBy <- produced_by
  } else {
    fm$producedBy <- ""
  }
  fm$usesDatasets  <- as.list(uses_datasets)
  fm$usesPackages  <- as.list(uses_packages)
  fm$usesResources <- as.list(uses_resources)
  fm$format        <- list(gfm = list(toc = FALSE, wrap = "none"))
  fm$execute       <- list(echo = FALSE, warning = FALSE, message = FALSE)

  yaml_body <- yaml::as.yaml(fm,
                              indent.mapping.sequence = TRUE,
                              handlers = list(logical = function(x) {
                                result <- ifelse(x, "true", "false")
                                class(result) <- "verbatim"
                                result
                              }))
  paste0("---\n", yaml_body, "---\n")
}


# --- generate_chart_body() ---------------------------------------------------

#' Generate Chart Body Content (Quarto Markdown)
#'
#' Produces the Quarto markdown body for a chart's `index.qmd`. Embeds the
#' chart image, optionally lists key findings, links to data sources and
#' related charts, and includes a reproducibility note pointing to the source
#' script.
#'
#' @param overview Character. Brief chart overview prose.
#' @param image_file Character. Image filename relative to the chart dir
#'   (e.g., `"./consumer_sentiment_lc.svg"`). Embedded with markdown image
#'   syntax.
#' @param image_alt Character or `NULL`. Alt text for the image. Defaults to
#'   the overview if not provided.
#' @param source_script Character or `NULL`. Relative path to the producing R
#'   script (rendered in a Reproducibility section).
#' @param key_findings Character vector. Each element rendered as a bullet.
#' @param data_sources `data.frame` or `NULL`. Columns: `slug`, `name`,
#'   `role`, `valid` (logical). Rendered as a table with internal links for
#'   valid slugs.
#' @param related_charts `data.frame` or `NULL`. Columns: `slug`, `name`,
#'   `valid`. Rendered as a bullet list with internal links for valid slugs.
#' @param dangling_note Character or `NULL`. Optional auto-generated note
#'   (callout) listing dangling slugs.
#' @return Character string (Quarto markdown).
#' @export
generate_chart_body <- function(overview,
                                 image_file,
                                 image_alt = NULL,
                                 source_script = NULL,
                                 key_findings = character(0),
                                 data_sources = NULL,
                                 related_charts = NULL,
                                 dangling_note = NULL) {
  parts <- c(
    chart_section_image(image_file, image_alt %||% overview),
    chart_section_overview(overview),
    chart_section_key_findings(key_findings),
    chart_section_data_sources(data_sources),
    chart_section_related_charts(related_charts),
    chart_section_reproducibility(source_script),
    chart_section_dangling_note(dangling_note)
  )
  paste(parts[nzchar(parts)], collapse = "\n\n")
}


# --- generate_chart_qmd() ----------------------------------------------------

#' Generate a Complete Chart index.qmd (and copy image)
#'
#' Combines `validate_project_dependencies()`,
#' `generate_chart_frontmatter()`, and `generate_chart_body()` into a single
#' chart directory containing `index.qmd` plus a copy of the source image.
#'
#' @param frontmatter_args Named list of arguments for
#'   `generate_chart_frontmatter()`. Must include `slug`.
#' @param body_args Named list of arguments for `generate_chart_body()`.
#' @param image_source_path Character. Absolute or working-dir-relative path
#'   to the source image (SVG or PNG) on disk. Will be copied into
#'   `output_dir`.
#' @param output_dir Character. Destination directory for the chart
#'   (typically `<project>/charts/<slug>/`). Created if missing.
#' @param overwrite Logical. Whether to overwrite an existing `index.qmd`
#'   and image. Defaults to `FALSE`.
#' @return Invisibly returns the generated `index.qmd` content.
#' @export
generate_chart_qmd <- function(frontmatter_args,
                                body_args,
                                image_source_path,
                                output_dir,
                                overwrite = FALSE) {
  if (is.null(frontmatter_args[["slug"]]) ||
      !nzchar(frontmatter_args[["slug"]])) {
    stop("frontmatter_args$slug is required.")
  }
  if (!file.exists(image_source_path)) {
    stop("image_source_path does not exist: ", image_source_path)
  }

  validation <- validate_project_dependencies(
    uses_datasets  = frontmatter_args[["uses_datasets"]]  %||% character(0),
    uses_packages  = frontmatter_args[["uses_packages"]]  %||% character(0),
    uses_resources = frontmatter_args[["uses_resources"]] %||% character(0)
  )

  if (is.null(body_args[["dangling_note"]])) {
    body_args$dangling_note <- format_dangling_note(validation)
  }

  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  image_basename  <- basename(image_source_path)
  image_dest_path <- file.path(output_dir, image_basename)
  if (file.exists(image_dest_path) && !isTRUE(overwrite)) {
    message("Image already exists at ", image_dest_path,
            " (overwrite = FALSE; keeping existing).")
  } else {
    file.copy(image_source_path, image_dest_path, overwrite = TRUE)
  }

  if (is.null(frontmatter_args[["image"]]) ||
      !nzchar(frontmatter_args[["image"]] %||% "")) {
    frontmatter_args$image <- image_basename
  }
  if (is.null(body_args[["image_file"]]) ||
      !nzchar(body_args[["image_file"]] %||% "")) {
    body_args$image_file <- paste0("./", image_basename)
  }

  fm  <- do.call(generate_chart_frontmatter, frontmatter_args)
  bod <- do.call(generate_chart_body, body_args)
  content <- paste0(fm, "\n", bod, "\n")

  output_path <- file.path(output_dir, "index.qmd")
  if (file.exists(output_path) && !isTRUE(overwrite)) {
    stop("Chart index.qmd exists: ", output_path,
          " (pass overwrite = TRUE to replace).")
  }
  writeLines(content, output_path)
  message("chart written to: ", output_path)

  invisible(content)
}


# --- internal body section helpers (not exported) ----------------------------

#' @noRd
chart_section_image <- function(image_file, alt) {
  if (is.null(image_file) || !nzchar(image_file)) return("")
  alt <- alt %||% ""
  paste0("![", alt, "](", image_file, ")")
}

#' @noRd
chart_section_overview <- function(overview) {
  if (!nzchar(overview %||% "")) return("")
  paste0("## Overview\n\n", overview)
}

#' @noRd
chart_section_key_findings <- function(findings) {
  if (length(findings) == 0) return("")
  paste0("## Key Findings\n\n",
         paste0("- ", findings, collapse = "\n"))
}

#' @noRd
chart_section_data_sources <- function(df) {
  if (is.null(df) || nrow(df) == 0) return("")
  rows <- vapply(seq_len(nrow(df)), function(i) {
    name_cell <- if (isTRUE(df$valid[i])) {
      paste0("[", df$name[i], "](/datasets/", df$slug[i], "/)")
    } else {
      paste0(df$name[i], " *(slug: `", df$slug[i],
             "` -- node pending)*")
    }
    paste("|", name_cell, "|", df$role[i] %||% "", "|")
  }, character(1))
  paste(c(
    "## Data Sources",
    "",
    "| Source | Role |",
    "|--------|------|",
    rows
  ), collapse = "\n")
}

#' @noRd
chart_section_related_charts <- function(df) {
  if (is.null(df) || nrow(df) == 0) return("")
  rows <- vapply(seq_len(nrow(df)), function(i) {
    if (isTRUE(df$valid[i])) {
      paste0("- [", df$name[i], "](/charts/", df$slug[i], "/)")
    } else {
      paste0("- ", df$name[i], " *(slug: `", df$slug[i],
             "` -- node pending)*")
    }
  }, character(1))
  paste(c("## Related Charts", "", rows), collapse = "\n")
}

#' @noRd
chart_section_reproducibility <- function(source_script) {
  if (is.null(source_script) || !nzchar(source_script)) return("")
  paste0(
    "## Reproducibility\n\n",
    "Generated by `", source_script, "` in the producing project.\n"
  )
}

#' @noRd
chart_section_dangling_note <- function(dangling_note) {
  if (is.null(dangling_note) || !nzchar(dangling_note)) return("")
  dangling_note
}


# --- Dataset slug lookup tables (not exported) --------------------------------

.dataset_source_names <- c(
  "census-population-estimates" = "U.S. Census Bureau, Population Estimates Program",
  "census-pep-components"       = "U.S. Census Bureau, Population Estimates Program",
  "bea-real-gdp"                = "U.S. Bureau of Economic Analysis",
  "qcew-employment-wages"       = "Bureau of Labor Statistics, Quarterly Census of Employment and Wages",
  "american-community-survey"   = "U.S. Census Bureau, American Community Survey",
  "census-bds"                  = "U.S. Census Bureau, Business Dynamics Statistics",
  "census-bfs"                  = "U.S. Census Bureau, Business Formation Statistics",
  "census-building-permits"     = "U.S. Census Bureau, Building Permits Survey",
  "uspto-patents"               = "U.S. Patent and Trademark Office",
  "fcc-broadband"               = "FCC National Broadband Map",
  "irs-migration"               = "IRS Statistics of Income, Migration Data",
  "usda-county-typology"        = "USDA Economic Research Service, County Typology Codes",
  "umich-consumer-sentiment"    = "University of Michigan, Surveys of Consumers",
  "fred-tech-employment"        = "Federal Reserve Bank of St. Louis, FRED",
  "sec-form-d"                  = "U.S. Securities and Exchange Commission, EDGAR",
  "bls-ors-telework"            = "Bureau of Labor Statistics, Occupational Requirements Survey"
)

.dataset_source_urls <- c(
  "census-population-estimates" = "https://www.census.gov/programs-surveys/popest.html",
  "census-pep-components"       = "https://www.census.gov/programs-surveys/popest.html",
  "bea-real-gdp"                = "https://www.bea.gov/",
  "qcew-employment-wages"       = "https://www.bls.gov/cew/",
  "american-community-survey"   = "https://www.census.gov/programs-surveys/acs",
  "census-bds"                  = "https://www.census.gov/programs-surveys/bds.html",
  "census-bfs"                  = "https://www.census.gov/econ/bfs/",
  "census-building-permits"     = "https://www.census.gov/construction/bps/",
  "uspto-patents"               = "https://www.uspto.gov/",
  "fcc-broadband"               = "https://broadbandmap.fcc.gov/",
  "irs-migration"               = "https://www.irs.gov/statistics/soi-tax-stats-migration-data",
  "usda-county-typology"        = "https://www.ers.usda.gov/data-products/rural-urban-continuum-codes/",
  "umich-consumer-sentiment"    = "https://www.sca.isr.umich.edu/",
  "fred-tech-employment"        = "https://fred.stlouisfed.org/",
  "sec-form-d"                  = "https://www.sec.gov/cgi-bin/browse-edgar",
  "bls-ors-telework"            = "https://www.bls.gov/ors/"
)

#' Return the canonical source name for the first recognized dataset slug.
#' When multiple datasets are supplied, names are joined with " and " if both
#' are recognized; otherwise the first recognized name is used.
#' Returns NULL if no slug matches the lookup table.
#' @noRd
lookup_dataset_source_name <- function(slugs) {
  slugs <- slugs[nzchar(slugs %||% "")]
  if (length(slugs) == 0) return(NULL)
  hits <- .dataset_source_names[slugs[slugs %in% names(.dataset_source_names)]]
  if (length(hits) == 0) return(NULL)
  if (length(hits) == 1) return(unname(hits))
  paste(unique(unname(hits)), collapse = " and ")
}

#' Return the canonical source URL for the first recognized dataset slug.
#' Returns NULL if no slug matches.
#' @noRd
lookup_dataset_source_url <- function(slugs) {
  slugs <- slugs[nzchar(slugs %||% "")]
  if (length(slugs) == 0) return(NULL)
  hit <- .dataset_source_urls[slugs[slugs %in% names(.dataset_source_urls)]]
  if (length(hit) == 0) return(NULL)
  unname(hit[[1]])
}
