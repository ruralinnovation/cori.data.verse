# Local definition of %||% for compatibility with R < 4.4
`%||%` <- function(x, y) if (is.null(x)) y else x


# --- 1.0 generate_package_frontmatter() ---------------------------------------

#' Generate Package YAML Frontmatter
#'
#' Builds a YAML frontmatter block conforming to the `PackageMeta` interface
#' defined in `src/types/index.ts`. Includes nested `package:` block and
#' graph-edge fields (`usesDatasets`, `usesResources`).
#'
#' @param title Character. Package title (usually package name).
#' @param description Character. Package description.
#' @param author Character. Primary author/maintainer.
#' @param date Character or Date. Defaults to `Sys.Date()`.
#' @param categories Character vector.
#' @param tags Character vector.
#' @param package Named list with PackageInfo fields: `name`, `githubUrl`,
#'   `installCommand`, `status`, `version`, `maintainer`, `featured`.
#' @param uses_datasets Character vector. Dataset slugs (kebab-case).
#' @param uses_resources Character vector. Resource slugs (kebab-case).
#' @return Character string of YAML (with `---` delimiters and trailing newline).
#' @export
generate_package_frontmatter <- function(title,
                                         description,
                                         author,
                                         date = Sys.Date(),
                                         categories = character(0),
                                         tags = character(0),
                                         package = list(),
                                         uses_datasets = character(0),
                                         uses_resources = character(0)) {
  if (is.null(package$name) || !nzchar(package$name)) {
    stop("package$name is required")
  }

  fm <- list(
    title       = title,
    description = description,
    author      = author,
    date        = format(as.Date(date)),
    categories  = as.list(categories),
    tags        = as.list(tags)
  )

  fm$package <- list(
    name           = package$name,
    githubUrl      = package$githubUrl      %||% "",
    installCommand = package$installCommand %||% "",
    status         = package$status         %||% "development",
    version        = package$version        %||% "0.0.0",
    maintainer     = package$maintainer     %||% "",
    featured       = isTRUE(package$featured)
  )

  fm$usesDatasets  <- as.list(uses_datasets)
  fm$usesResources <- as.list(uses_resources)

  fm$execute <- list(echo = TRUE, warning = FALSE, message = FALSE)
  fm$editor  <- list(markdown = list(wrap = 72L))

  yaml_body <- yaml::as.yaml(fm,
                             indent.mapping.sequence = TRUE,
                             handlers = list(logical = function(x) {
                               result <- ifelse(x, "true", "false")
                               class(result) <- "verbatim"
                               result
                             }))
  paste0("---\n", yaml_body, "---\n")
}


# --- 2.0 generate_package_body() ----------------------------------------------

#' Generate Package Body Content (Quarto Markdown)
#'
#' Produces the Quarto markdown body for a package `index.qmd`. Sections:
#' Overview, Installation, Quick Start, Key Features, Core Functions,
#' Data Sources, Use Cases, Performance Tips, Known Limitations,
#' Related Resources, Documentation.
#'
#' @param overview Character. Package overview prose.
#' @param github_url Character or `NULL`. Repository URL.
#' @param install_command Character or `NULL`. Installation command.
#' @param quick_start Character or `NULL`. Quick start code block content.
#' @param exported_functions `data.frame` or `NULL`. Columns: `name`,
#'   `description`, `category` (optional).
#' @param key_features Named list of feature descriptions.
#' @param data_sources `data.frame` or `NULL`. Columns: `slug`, `name`, `role`,
#'   `valid` (logical).
#' @param use_cases Character vector. List of use cases.
#' @param related_packages `data.frame` or `NULL`. Columns: `slug`, `name`,
#'   `purpose`, `valid`.
#' @param related_datasets `data.frame` or `NULL`. Columns: `slug`, `name`,
#'   `valid`.
#' @param performance_tips Character or `NULL`. Performance optimization notes.
#' @param known_limitations Character or `NULL`. Known issues/limitations.
#' @param dangling_note Character or `NULL`. Note about dangling slugs.
#' @return Character string (Quarto markdown).
#' @export
generate_package_body <- function(overview,
                                  github_url = NULL,
                                  install_command = NULL,
                                  quick_start = NULL,
                                  exported_functions = NULL,
                                  key_features = list(),
                                  data_sources = NULL,
                                  use_cases = character(0),
                                  related_packages = NULL,
                                  related_datasets = NULL,
                                  performance_tips = NULL,
                                  known_limitations = NULL,
                                  dangling_note = NULL) {
  parts <- c(
    pkg_section_overview(overview),
    pkg_section_key_features(key_features),
    pkg_section_installation(install_command, github_url),
    pkg_section_quick_start(quick_start),
    pkg_section_core_functions(exported_functions),
    pkg_section_data_sources(data_sources),
    pkg_section_use_cases(use_cases),
    pkg_section_performance_tips(performance_tips),
    pkg_section_known_limitations(known_limitations),
    pkg_section_related_resources(related_packages, related_datasets),
    pkg_section_documentation(github_url),
    pkg_section_dangling_note(dangling_note)
  )
  paste(parts[nzchar(parts)], collapse = "\n\n")
}


# --- 3.0 generate_package_qmd() -----------------------------------------------

#' Generate a Complete Package index.qmd
#'
#' Combines `validate_project_dependencies()`,
#' `generate_package_frontmatter()`, and `generate_package_body()` into a
#' single `index.qmd` file. Designed to be called by Claude Code after
#' DESCRIPTION/README parsing and dependency inference.
#'
#' @param frontmatter_args Named list of arguments for
#'   `generate_package_frontmatter()`.
#' @param body_args Named list of arguments for `generate_package_body()`.
#' @param output_path Character or `NULL`. Where to write the file. If `NULL`,
#'   returns the content without writing.
#' @param dataverse_root Character. Root of Dataverse project. Defaults to
#'   `here::here()`.
#' @param overwrite Logical. Whether to overwrite existing file. Defaults to
#'   `FALSE`.
#' @return Invisibly returns the generated content (character string).
#' @export
generate_package_qmd <- function(frontmatter_args,
                                 body_args,
                                 output_path = NULL,
                                 dataverse_root = here::here(),
                                 overwrite = FALSE) {
  validation <- validate_project_dependencies(
    uses_datasets  = frontmatter_args[["uses_datasets"]]  %||% character(0),
    uses_packages  = character(0),
    uses_resources = frontmatter_args[["uses_resources"]] %||% character(0),
    dataverse_root = dataverse_root
  )

  if (is.null(body_args[["dangling_note"]])) {
    body_args$dangling_note <- format_package_dangling_note(validation)
  }

  fm  <- do.call(generate_package_frontmatter, frontmatter_args)
  bod <- do.call(generate_package_body, body_args)
  content <- paste0(fm, "\n", bod, "\n")

  if (!is.null(output_path)) {
    if (file.exists(output_path) && !isTRUE(overwrite)) {
      stop("Output file exists: ", output_path,
           " (pass overwrite = TRUE to replace).")
    }
    dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
    writeLines(content, output_path)
    message("index.qmd written to: ", output_path)
  }

  invisible(content)
}


# --- Internal helpers (not exported) ------------------------------------------

#' @noRd
pkg_section_overview <- function(overview) {
  if (!nzchar(overview %||% "")) return("")
  paste0("## Overview\n\n", overview)
}

#' @noRd
pkg_section_key_features <- function(key_features) {
  if (length(key_features) == 0) return("")
  parts <- "::: callout-note\n## Why Use This Package\n\n"
  bullets <- vapply(names(key_features), function(nm) {
    paste0("- **", nm, "** - ", key_features[[nm]])
  }, character(1))
  paste0(parts, paste(bullets, collapse = "\n"), "\n:::")
}

#' @noRd
pkg_section_installation <- function(install_command, github_url) {
  if (is.null(install_command) && is.null(github_url)) return("")
  parts <- "## Installation\n\n::: panel-tabset\n### GitHub\n\n```{r}\n#| eval: false\n\n"
  if (!is.null(install_command) && nzchar(install_command)) {
    parts <- c(parts, install_command)
  } else if (!is.null(github_url) && nzchar(github_url)) {
    repo <- gsub("https://github.com/", "", github_url)
    parts <- c(parts, paste0('devtools::install_github("', repo, '")'))
  }
  parts <- c(parts, "\n```\n:::")
  paste(parts, collapse = "")
}

#' @noRd
pkg_section_quick_start <- function(quick_start) {
  if (is.null(quick_start) || !nzchar(quick_start)) return("")
  paste0("## Quick Start\n\n```{r}\n#| eval: false\n\n", quick_start, "\n```")
}

#' @noRd
pkg_section_core_functions <- function(exported_functions) {
  if (is.null(exported_functions) || nrow(exported_functions) == 0) return("")

  if ("category" %in% names(exported_functions) &&
      length(unique(exported_functions$category)) > 1) {
    categories <- unique(exported_functions$category)
    parts <- "## Core Functions\n\n::: panel-tabset"
    for (cat in categories) {
      subset <- exported_functions[exported_functions$category == cat, ]
      rows <- vapply(seq_len(nrow(subset)), function(i) {
        paste0("| `", subset$name[i], "()` | ", subset$description[i], " |")
      }, character(1))
      parts <- c(parts,
                 paste0("### ", cat, "\n\n| Function | Description |\n|----------|-------------|\n",
                        paste(rows, collapse = "\n")))
    }
    paste(c(parts, ":::"), collapse = "\n\n")
  } else {
    rows <- vapply(seq_len(nrow(exported_functions)), function(i) {
      paste0("| `", exported_functions$name[i], "()` | ",
             exported_functions$description[i], " |")
    }, character(1))
    paste0("## Core Functions\n\n| Function | Description |\n|----------|-------------|\n",
           paste(rows, collapse = "\n"))
  }
}

#' @noRd
pkg_section_data_sources <- function(data_sources) {
  if (is.null(data_sources) || nrow(data_sources) == 0) return("")
  rows <- vapply(seq_len(nrow(data_sources)), function(i) {
    name_cell <- if (isTRUE(data_sources$valid[i])) {
      paste0("[", data_sources$name[i], "](/datasets/", data_sources$slug[i], "/)")
    } else {
      paste0(data_sources$name[i], " *(pending)*")
    }
    paste("|", name_cell, "|", data_sources$role[i] %||% "", "|")
  }, character(1))
  paste(c(
    "## Data Sources",
    "",
    "| Dataset | Role |",
    "|---------|------|",
    rows
  ), collapse = "\n")
}

#' @noRd
pkg_section_use_cases <- function(use_cases) {
  if (length(use_cases) == 0) return("")
  bullets <- paste0("- ", use_cases, collapse = "\n")
  paste0("## Use Cases at CORI\n\nThis package is used in:\n\n", bullets)
}

#' @noRd
pkg_section_performance_tips <- function(performance_tips) {
  if (is.null(performance_tips) || !nzchar(performance_tips)) return("")
  paste0("::: callout-tip\n## Optimization Tips\n\n", performance_tips, "\n:::")
}

#' @noRd
pkg_section_known_limitations <- function(known_limitations) {
  if (is.null(known_limitations) || !nzchar(known_limitations)) return("")
  paste0("::: callout-warning\n## Known Limitations\n\n", known_limitations, "\n:::")
}

#' @noRd
pkg_section_related_resources <- function(related_packages, related_datasets) {
  parts <- character(0)

  if (!is.null(related_datasets) && nrow(related_datasets) > 0) {
    bullets <- vapply(seq_len(nrow(related_datasets)), function(i) {
      if (isTRUE(related_datasets$valid[i])) {
        paste0("- [", related_datasets$name[i], "](/datasets/",
               related_datasets$slug[i], "/)")
      } else {
        paste0("- ", related_datasets$name[i], " *(pending)*")
      }
    }, character(1))
    parts <- c(parts, "### Datasets\n", paste(bullets, collapse = "\n"))
  }

  if (!is.null(related_packages) && nrow(related_packages) > 0) {
    bullets <- vapply(seq_len(nrow(related_packages)), function(i) {
      if (isTRUE(related_packages$valid[i])) {
        paste0("- [", related_packages$name[i], "](/packages/",
               related_packages$slug[i], "/)")
      } else {
        paste0("- ", related_packages$name[i])
      }
    }, character(1))
    parts <- c(parts, "### Related Packages\n", paste(bullets, collapse = "\n"))
  }

  if (length(parts) == 0) return("")
  paste(c("## Related Resources\n", parts), collapse = "\n\n")
}

#' @noRd
pkg_section_documentation <- function(github_url) {
  if (is.null(github_url) || !nzchar(github_url)) return("")
  paste0(
    "## Documentation\n\n",
    "- [GitHub Repository](", github_url, ")\n",
    "- [Full README](", github_url, "/blob/main/README.md)\n",
    "- [Function Documentation](", github_url, "/tree/main/man)"
  )
}

#' @noRd
pkg_section_dangling_note <- function(dangling_note) {
  if (is.null(dangling_note) || !nzchar(dangling_note)) return("")
  dangling_note
}

#' Build a callout note listing dangling slugs for packages (or NULL if none)
#' @noRd
format_package_dangling_note <- function(validation) {
  dangling <- c(
    paste0("dataset/",  validation$datasets$dangling),
    paste0("resource/", validation$resources$dangling)
  )
  dangling <- dangling[!grepl("/$", dangling)]
  if (length(dangling) == 0) return(NULL)
  paste0(
    "::: {.callout-note}\n",
    "## Dangling references\n\n",
    "The following slugs are referenced by this package but do not yet ",
    "have nodes in Dataverse:\n\n",
    paste0("- `", dangling, "`", collapse = "\n"),
    "\n:::"
  )
}
