#' Remove Stale Rendered Content
#'
#' Deletes `content/<type>/<slug>/` directories whose source
#' `<type>/<slug>/index.qmd` no longer exists. Intended as a Quarto
#' pre-render hook to prevent orphaned rendered output from accumulating
#' after source `.qmd` files are deleted.
#'
#' @param root_dir Character. Project root directory. Defaults to
#'   `here::here()`.
#' @return Invisibly returns a character vector of the directories removed.
#' @export
clean_stale_content <- function(root_dir = here::here()) {
  content_types <- c("datasets", "charts", "packages", "projects", "resources")
  removed <- character(0)

  for (type in content_types) {
    content_type_dir <- file.path(root_dir, "content", type)
    if (!dir.exists(content_type_dir)) next

    slugs <- list.dirs(content_type_dir, full.names = FALSE, recursive = FALSE)
    for (slug in slugs) {
      if (!nzchar(slug)) next
      source_qmd <- file.path(root_dir, type, slug, "index.qmd")
      if (!file.exists(source_qmd)) {
        stale_dir <- file.path(content_type_dir, slug)
        message("clean_stale_content: removing stale ", stale_dir)
        unlink(stale_dir, recursive = TRUE)
        removed <- c(removed, stale_dir)
      }
    }
  }

  posts_content_dir <- file.path(root_dir, "content", "posts")
  if (dir.exists(posts_content_dir)) {
    slugs <- list.dirs(posts_content_dir, full.names = FALSE, recursive = FALSE)
    for (slug in slugs) {
      if (!nzchar(slug)) next
      source_qmd <- file.path(root_dir, "posts", slug, "index.qmd")
      if (!file.exists(source_qmd)) {
        stale_dir <- file.path(posts_content_dir, slug)
        message("clean_stale_content: removing stale ", stale_dir)
        unlink(stale_dir, recursive = TRUE)
        removed <- c(removed, stale_dir)
      }
    }
  }

  invisible(removed)
}
