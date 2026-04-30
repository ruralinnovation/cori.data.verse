#' Remove Stale Rendered Content and Quarto Cache Entries
#'
#' Deletes `content/<type>/<slug>/` directories and `.quarto/idx/<type>/<slug>/`
#' cache directories whose source `<type>/<slug>/index.qmd` no longer exists.
#' Intended as a Quarto pre-render hook to prevent orphaned rendered output and
#' stale index cache entries from accumulating after source `.qmd` files are
#' deleted.
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
    idx_type_dir     <- file.path(root_dir, ".quarto", "idx", type)

    # Clean content/ output
    if (dir.exists(content_type_dir)) {
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

    # Clean .quarto/idx/ cache
    if (dir.exists(idx_type_dir)) {
      slugs <- list.dirs(idx_type_dir, full.names = FALSE, recursive = FALSE)
      for (slug in slugs) {
        if (!nzchar(slug)) next
        source_qmd <- file.path(root_dir, type, slug, "index.qmd")
        if (!file.exists(source_qmd)) {
          stale_dir <- file.path(idx_type_dir, slug)
          message("clean_stale_content: removing stale cache ", stale_dir)
          unlink(stale_dir, recursive = TRUE)
          removed <- c(removed, stale_dir)
        }
      }
    }
  }

  # posts/ — clean both content/posts/ and .quarto/idx/posts/
  for (posts_base in list(
    list(content = file.path(root_dir, "content", "posts"),
         idx     = file.path(root_dir, ".quarto", "idx", "posts"),
         source  = file.path(root_dir, "posts"))
  )) {
    for (target_dir in c(posts_base$content, posts_base$idx)) {
      if (!dir.exists(target_dir)) next
      slugs <- list.dirs(target_dir, full.names = FALSE, recursive = FALSE)
      for (slug in slugs) {
        if (!nzchar(slug)) next
        source_qmd <- file.path(posts_base$source, slug, "index.qmd")
        if (!file.exists(source_qmd)) {
          stale_dir <- file.path(target_dir, slug)
          message("clean_stale_content: removing stale ", stale_dir)
          unlink(stale_dir, recursive = TRUE)
          removed <- c(removed, stale_dir)
        }
      }
    }
  }

  invisible(removed)
}
