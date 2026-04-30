#' Read YAML Frontmatter from a Quarto (.qmd) File
#'
#' Extracts and parses the YAML frontmatter block (delimited by `---`) from
#' a `.qmd` file.
#'
#' @param file_path Character. Path to a `.qmd` file.
#' @return A named list of parsed YAML fields. Returns an empty list with a
#'   warning if no valid frontmatter is found.
#' @export
read_qmd_frontmatter <- function(file_path) {
  if (!file.exists(file_path)) {
    warning("File not found: ", file_path)
    return(list())
  }

  lines <- readLines(file_path, warn = FALSE)
  delimiters <- which(lines == "---")

  if (length(delimiters) < 2) {
    warning("No valid YAML frontmatter found in: ", file_path)
    return(list())
  }

  yaml_text <- paste(lines[(delimiters[1] + 1):(delimiters[2] - 1)],
                     collapse = "\n")
  yaml::yaml.load(yaml_text)
}


#' Discover All Content Items in the Project
#'
#' Walks the six content-type directories (`datasets/`, `charts/`, `packages/`,
#' `projects/`, `resources/`, `posts/`) and returns parsed frontmatter for each
#' item that has an `index.qmd`.
#'
#' @param root_dir Character. Project root directory. Defaults to
#'   `here::here()`.
#' @return A list of lists, each with keys:
#'   \describe{
#'     \item{type}{Singular content type (`"dataset"`, `"chart"`, etc.)}
#'     \item{slug}{Directory name (used as the URL slug)}
#'     \item{path}{Full path to the `index.qmd` file}
#'     \item{frontmatter}{Named list of parsed YAML fields}
#'   }
#' @export
discover_content_items <- function(root_dir = here::here()) {
  # Map directory names (plural) to singular type names
  type_dirs <- c(
    datasets  = "dataset",
    charts    = "chart",
    packages  = "package",
    projects  = "project",
    resources = "resource",
    posts     = "post"
  )

  items <- list()

  for (dir_name in names(type_dirs)) {
    type_singular <- type_dirs[[dir_name]]
    dir_path <- file.path(root_dir, dir_name)

    if (!dir.exists(dir_path)) next

    subdirs <- list.dirs(dir_path, recursive = FALSE, full.names = FALSE)

    # For posts/, filter out subdirectories that share names with other
    # content-type directories (those are handled separately)
    if (dir_name == "posts") {
      content_type_names <- setdiff(names(type_dirs), "posts")
      subdirs <- subdirs[!subdirs %in% content_type_names]
    }

    for (slug in subdirs) {
      qmd_path <- file.path(dir_path, slug, "index.qmd")
      if (!file.exists(qmd_path)) next

      fm <- read_qmd_frontmatter(qmd_path)
      items <- c(items, list(list(
        type        = type_singular,
        slug        = slug,
        path        = qmd_path,
        frontmatter = fm
      )))
    }
  }

  items
}
