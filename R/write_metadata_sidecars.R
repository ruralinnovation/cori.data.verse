# write_metadata_sidecars.R
#
# Render-time emission of structured-frontmatter sidecars next to every
# Quarto-rendered .md file. Quarto's GFM render strips the YAML frontmatter
# from output; the sidecar preserves it as JSON for downstream consumers
# (the Next.js site, lookup_dataset_source(), other-language readers, etc.)
# that don't have the source .qmd repo cloned.
#
# Naming: content/<type>/<slug>/index.md   (rendered, frontmatter stripped)
#         content/<type>/<slug>/index.md.metadata.json  (sidecar, full FM)
#
# Wired into _targets.R as a tar_target between render_result and the S3
# sync; runs every render.

#' Write metadata sidecars for every rendered .md file in `content/`.
#'
#' Walks the rendered content tree and, for each `<type>/<slug>/index.md`,
#' parses the source `<type>/<slug>/index.qmd`'s YAML frontmatter (via
#' [read_qmd_frontmatter()]) and writes the parsed object as JSON to
#' `<type>/<slug>/index.md.metadata.json`. The sidecar contains the full
#' frontmatter — every field, including nested blocks like `dataset:` and
#' `chart:` — so downstream consumers can read structured metadata that
#' would otherwise be lost during Quarto's GFM render.
#'
#' Idempotent: re-running on an unchanged repo regenerates byte-identical
#' sidecars (within JSON serialization variability).
#'
#' Project-root rendered files (`content/index.md`, `content/about.md`)
#' are also handled: they read frontmatter from `index.qmd` / `about.qmd`
#' at the project root.
#'
#' @param root_dir Project root containing both source `.qmd` directories
#'   (`datasets/`, `charts/`, `packages/`, `projects/`, `posts/`,
#'   `resources/`) AND the rendered `content/` tree. Defaults to
#'   [here::here()].
#' @param content_dir Subdirectory of `root_dir` containing the rendered
#'   `.md` output. Defaults to `"content"`.
#' @return Invisibly returns the character vector of sidecar paths written
#'   (relative to `root_dir`).
#' @export
write_metadata_sidecars <- function(root_dir    = here::here(),
                                     content_dir = "content") {
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("jsonlite is required by write_metadata_sidecars()")
  }

  abs_content <- file.path(root_dir, content_dir)
  if (!dir.exists(abs_content)) {
    warning("content directory not found: ", abs_content,
            "; nothing to do.", call. = FALSE)
    return(invisible(character(0)))
  }

  # Enumerate every rendered <something>/index.md (and the project-root
  # files content/index.md and content/about.md).
  md_files <- list.files(
    abs_content,
    pattern    = "\\.md$",
    recursive  = TRUE,
    full.names = TRUE
  )
  # Skip our own sidecars (in case a previous run produced any) and any
  # other non-content files. We accept index.md, about.md, and any
  # <slug>/index.md (e.g., posts may have body files at non-index paths).
  md_files <- md_files[!grepl("\\.metadata\\.json$", md_files)]
  if (length(md_files) == 0) {
    return(invisible(character(0)))
  }

  written <- character(0)
  for (md_path in md_files) {
    rel_md  <- sub(paste0("^", normalizePath(abs_content, mustWork = FALSE), "/"), "",
                   normalizePath(md_path, mustWork = FALSE))

    # Resolve the source .qmd path. content/index.md → index.qmd at root;
    # everything else maps content/X.md → X.qmd at root.
    src_rel <- sub("\\.md$", ".qmd", rel_md)
    src_path <- file.path(root_dir, src_rel)

    if (!file.exists(src_path)) {
      # Some rendered .md files have no .qmd source (e.g. partial includes
      # or generated files). Skip them silently — there's no frontmatter
      # to capture.
      next
    }

    fm <- tryCatch(
      read_qmd_frontmatter(src_path),
      error = function(e) {
        warning("Failed to parse frontmatter from ", src_path, ": ",
                conditionMessage(e), call. = FALSE)
        NULL
      }
    )
    if (is.null(fm) || length(fm) == 0) next

    # Force a few known list-of-slug fields to stay as arrays even when
    # they contain a single element, so JSON consumers can rely on them
    # being arrays. Without this, jsonlite's auto_unbox collapses
    # single-element vectors to scalars (e.g. usesDatasets: "x" instead of
    # usesDatasets: ["x"]), which would break downstream array readers.
    array_fields <- c("categories", "tags", "usesDatasets", "usesPackages",
                      "usesResources", "team")
    for (f in array_fields) {
      if (!is.null(fm[[f]]) && length(fm[[f]]) > 0 && !is.list(fm[[f]])) {
        fm[[f]] <- I(as.character(fm[[f]]))
      }
    }
    # Likewise for dataset.dataFormat which is conventionally an array.
    if (!is.null(fm$dataset) && !is.null(fm$dataset$dataFormat)) {
      fm$dataset$dataFormat <- I(as.character(fm$dataset$dataFormat))
    }

    sidecar_path <- paste0(md_path, ".metadata.json")
    json_text <- jsonlite::toJSON(
      fm,
      pretty     = TRUE,
      auto_unbox = TRUE,
      null       = "null",
      na         = "null"
    )
    writeLines(json_text, sidecar_path)
    written <- c(written, sub(paste0("^", normalizePath(root_dir, mustWork = FALSE), "/"),
                              "", normalizePath(sidecar_path, mustWork = FALSE)))
  }

  message("write_metadata_sidecars: ", length(written), " sidecar(s) written.")
  invisible(written)
}
