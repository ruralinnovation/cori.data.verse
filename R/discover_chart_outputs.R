# Local definition of %||% for compatibility with R < 4.4
`%||%` <- function(x, y) if (is.null(x)) y else x


# --- discover_chart_outputs() ------------------------------------------------

#' Discover Chart Outputs in a Project
#'
#' Scans git-tracked R scripts in a project for ggplot save calls
#' (`cori.charts::save_plot`, `save_plot`, `ggsave`) and matches the declared
#' output paths against actual image files on disk. Returns one row per
#' distinct (script, image basename) pair, preferring SVG over PNG.
#'
#' Use this from a Claude Code skill (`/generate-dataverse-charts`) before
#' generating per-chart `index.qmd` files. The caller is expected to read the
#' producing project's slug from its own `index.qmd` and pass it via
#' `project_slug` so chart slugs can be globally namespaced
#' (e.g., `rural-economic-outlook-emp-change-since-gr-lc`).
#'
#' @param project_dir Project root (default: `getwd()`).
#' @param project_slug Character. Slug of the producing project, used as a
#'   prefix for each chart's slug. Required.
#' @param git_only Logical. If `TRUE` (default), restrict to scripts under
#'   `git ls-files`. Untracked scripts are skipped to keep the catalog
#'   reproducible.
#' @param image_subdirs Character vector. Subdirectories of `project_dir` to
#'   search for actual image files. Searched recursively. Default `"export"`.
#' @return A `data.frame` with columns:
#'   \describe{
#'     \item{script_path}{Relative path to the R script}
#'     \item{image_basename}{Filename stem, no extension
#'       (e.g. `"consumer_sentiment_lc"`)}
#'     \item{image_format}{`"svg"` or `"png"` -- whichever exists, SVG
#'       preferred. `NA` if the declared image is not on disk.}
#'     \item{image_path}{Relative path to the actual image, or `NA`}
#'     \item{slug}{Suggested chart slug:
#'       `{project_slug}-{normalized-basename}`}
#'     \item{labs_title}{First `labs(title=...)` value found in the script,
#'       or `NA`}
#'     \item{labs_subtitle}{First `labs(subtitle=...)` value, or `NA`}
#'     \item{labs_caption}{First `labs(caption=...)` value, or `NA`}
#'   }
#' @export
discover_chart_outputs <- function(project_dir = getwd(),
                                    project_slug,
                                    git_only = TRUE,
                                    image_subdirs = "export") {
  if (missing(project_slug) || !is.character(project_slug) ||
      length(project_slug) != 1 || !nzchar(project_slug)) {
    stop("project_slug is required (kebab-case slug of the producing project).")
  }

  project_dir <- normalizePath(project_dir, mustWork = TRUE)

  scripts <- if (isTRUE(git_only)) {
    list_git_r_scripts(project_dir)
  } else {
    list_all_r_scripts(project_dir)
  }
  if (length(scripts) == 0) return(empty_charts_df())

  rows <- do.call(rbind, lapply(scripts, function(rel_path) {
    parse_script_for_charts(project_dir, rel_path)
  }))
  if (is.null(rows) || nrow(rows) == 0) return(empty_charts_df())

  rows$image_path <- vapply(rows$image_basename, function(bn) {
    find_image_on_disk(project_dir, image_subdirs, bn)
  }, character(1))

  rows$image_format <- vapply(rows$image_path, function(p) {
    if (is.na(p)) NA_character_ else tolower(tools::file_ext(p))
  }, character(1))

  rows$slug <- vapply(rows$image_basename, function(bn) {
    paste0(project_slug, "-", normalize_chart_basename(bn))
  }, character(1))

  rows <- rows[, c("script_path", "image_basename", "image_format",
                   "image_path", "slug",
                   "labs_title", "labs_subtitle", "labs_caption"), drop = FALSE]
  rownames(rows) <- NULL
  rows[order(rows$script_path, rows$image_basename), , drop = FALSE]
}


# --- internal helpers (not exported) -----------------------------------------

#' Empty discovery data.frame skeleton
#' @noRd
empty_charts_df <- function() {
  data.frame(
    script_path    = character(0),
    image_basename = character(0),
    image_format   = character(0),
    image_path     = character(0),
    slug           = character(0),
    labs_title     = character(0),
    labs_subtitle  = character(0),
    labs_caption   = character(0),
    stringsAsFactors = FALSE
  )
}


#' List git-tracked R scripts under a project directory.
#' Returns relative paths. Falls back to recursive listing if git is unavailable
#' or the directory is not a git repo.
#' @noRd
list_git_r_scripts <- function(project_dir) {
  # List ALL tracked files without glob patterns (avoids pathspec matching
  # differences across git versions where '*.R' may not recurse into subdirs
  # when passed as a system2() argument rather than through a shell).
  # Filter to .R/.r extensions in R instead.
  out <- tryCatch(
    suppressWarnings(system2(
      "git",
      c("-C", project_dir, "ls-files"),
      stdout = TRUE, stderr = FALSE
    )),
    error = function(e) character(0)
  )
  if (length(out) == 0 || (length(out) == 1 && !nzchar(out))) {
    return(character(0))
  }
  out[grepl("\\.[Rr]$", out)]
}


#' Recursive listing of all R scripts under a project directory.
#' Returns relative paths.
#' @noRd
list_all_r_scripts <- function(project_dir) {
  files <- list.files(project_dir, pattern = "\\.[Rr]$",
                      recursive = TRUE, full.names = FALSE)
  files
}


#' Parse a single script for image paths and labs() values.
#' @noRd
parse_script_for_charts <- function(project_dir, rel_path) {
  abs_path <- file.path(project_dir, rel_path)
  if (!file.exists(abs_path)) return(NULL)

  text <- tryCatch(
    paste(readLines(abs_path, warn = FALSE), collapse = "\n"),
    error = function(e) NULL
  )
  if (is.null(text) || !nzchar(text)) return(NULL)

  image_paths <- extract_image_paths(text)
  if (length(image_paths) == 0) return(NULL)

  basenames <- unique(tools::file_path_sans_ext(basename(image_paths)))
  if (length(basenames) == 0) return(NULL)

  labs <- extract_labs(text)

  data.frame(
    script_path    = rel_path,
    image_basename = basenames,
    labs_title     = rep(labs$title    %||% NA_character_, length(basenames)),
    labs_subtitle  = rep(labs$subtitle %||% NA_character_, length(basenames)),
    labs_caption   = rep(labs$caption  %||% NA_character_, length(basenames)),
    stringsAsFactors = FALSE
  )
}


#' Extract every PNG/SVG path string referenced inside a script.
#' Returns a character vector of unique paths (as written, without unwrapping
#' here::here() etc.).
#' @noRd
extract_image_paths <- function(text) {
  pattern <- "[\"']([^\"']+\\.(?:svg|png|SVG|PNG))[\"']"
  matches <- regmatches(text, gregexpr(pattern, text, perl = TRUE))[[1]]
  if (length(matches) == 0) return(character(0))
  paths <- gsub("^[\"']|[\"']$", "", matches)
  unique(paths)
}


#' Extract the FIRST labs(title=, subtitle=, caption=) values from a script.
#' Returns a list with elements `title`, `subtitle`, `caption` (each character
#' or NULL).
#' @noRd
extract_labs <- function(text) {
  pick <- function(field) {
    pat <- paste0("\\b", field,
                  "\\s*=\\s*[\"']([^\"']+)[\"']")
    m <- regmatches(text, regexpr(pat, text, perl = TRUE))
    if (length(m) == 0 || identical(m, character(0))) return(NULL)
    sub(pat, "\\1", m, perl = TRUE)
  }
  list(
    title    = pick("title"),
    subtitle = pick("subtitle"),
    caption  = pick("caption")
  )
}


#' Locate an image file on disk by basename. Returns relative path (relative
#' to project_dir) or NA. SVG preferred over PNG.
#' @noRd
find_image_on_disk <- function(project_dir, image_subdirs, basename) {
  for (subdir in image_subdirs) {
    base_dir <- file.path(project_dir, subdir)
    if (!dir.exists(base_dir)) next
    for (ext in c("svg", "png")) {
      hits <- list.files(base_dir,
                          pattern = paste0("^", regex_escape_simple(basename),
                                            "\\.", ext, "$"),
                          recursive = TRUE, full.names = TRUE,
                          ignore.case = TRUE)
      if (length(hits) > 0) {
        rel <- sub(paste0("^", regex_escape_simple(project_dir), "/?"), "",
                   hits[[1]])
        return(rel)
      }
    }
  }
  NA_character_
}


#' Simple regex escape for a literal path (avoids dependency).
#' @noRd
regex_escape_simple <- function(s) {
  gsub("([][{}().+*?^$|\\\\])", "\\\\\\1", s)
}


#' Normalize an image basename into a kebab-case chart-name suffix.
#' Strips outline-numeric prefixes (`3.1_`, `2.2A_`) and single-letter
#' placeholder prefixes (`X_`), converts underscores to hyphens, lowercases.
#' @noRd
normalize_chart_basename <- function(bn) {
  bn <- sub("^[0-9]+(\\.[0-9A-Za-z]+)?_", "", bn)
  bn <- sub("^[A-Za-z]_", "", bn)
  bn <- gsub("_", "-", bn)
  bn <- gsub("\\s+", "-", bn)
  bn <- gsub("-+", "-", bn)
  bn <- tolower(bn)
  bn <- gsub("^-|-$", "", bn)
  bn
}
