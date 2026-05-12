# Local definition of %||% for compatibility with R < 4.4
`%||%` <- function(x, y) if (is.null(x)) y else x


# --- safe_yaml_list() --------------------------------------------------------

#' Convert a character vector to a list safe for YAML serialization
#'
#' Ensures that character values that look like numbers (e.g., "2023") are
#' explicitly quoted in the YAML output to prevent them from being parsed
#' as numeric values.
#'
#' @param x Character vector.
#' @return A list suitable for yaml::as.yaml() with numeric-looking strings
#'   properly quoted.
#' @noRd
safe_yaml_list <- function(x) {
  lapply(x, function(item) {
    if (is.character(item) && grepl("^-?\\d+(\\.\\d+)?$", item)) {
      result <- paste0("\"", item, "\"")
      class(result) <- "verbatim"
      result
    } else {
      item
    }
  })
}


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
    categories  = safe_yaml_list(categories),
    tags        = safe_yaml_list(tags)
  )
  if (!is.null(image) && nzchar(image)) {
    fm$image <- image
  }

  # Auto-derive source/sourceUrl from uses_datasets when not explicitly
  # provided OR when Claude defaulted to the generic "CORI analysis" string.
  # A lookup hit (against the live S3 dataset profiles) takes precedence over
  # those two conditions; an explicit non-generic value is preserved as-is.
  generic_source <- !is.null(data_source) &&
                    identical(trimws(data_source), "CORI analysis")
  needs_source <- is.null(data_source) || !nzchar(data_source %||% "") || generic_source
  needs_url    <- is.null(source_url)  || !nzchar(source_url  %||% "") || generic_source
  if (needs_source || needs_url) {
    derived <- lookup_dataset_source(uses_datasets)
    if (!is.null(derived)) {
      if (needs_source && !is.null(derived$source) && !is.na(derived$source)) {
        data_source <- derived$source
      }
      if (needs_url && !is.null(derived$sourceUrl) && !is.na(derived$sourceUrl)) {
        source_url <- derived$sourceUrl
      }
    }
  }

  chart_block <- list(title = title)
  if (!is.null(chart_type) && nzchar(chart_type)) {
    chart_block$chartType <- chart_type
  }
  chart_block$interactive <- isTRUE(interactive)
  if (!is.null(data_source) && nzchar(data_source %||% "")) {
    chart_block$source <- data_source
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

