# Local definition of %||% for compatibility with R < 4.4
`%||%` <- function(x, y) if (is.null(x)) y else x


# --- 1.0 list_dataverse_content() --------------------------------------------

#' List All Dataverse Content Nodes (Local + S3)
#'
#' Enumerates every content item across the local content directories and the
#' remote S3 prefix, returning a unified inventory keyed by type and slug.
#' Each item is tagged with its location(s): "local", "remote", or "both".
#'
#' Use this before slug mapping/validation so the caller can pick existing
#' slugs by reuse, spot near-matches, and decide which discovered dependencies
#' will be dangling.
#'
#' @param dataverse_root Character. Root of the Dataverse project. Defaults to
#'   `here::here()`.
#' @param s3_bucket Character. Default `"cori.data.verse"`.
#' @param s3_prefix Character or `NULL`. If `NULL`, auto-detects via the
#'   internal `detect_s3_prefix()` (branch-aware: `"main/content/"` on main,
#'   else `"dev/content/"`).
#' @param check_s3 Logical. Default `TRUE`. Set `FALSE` to skip S3.
#' @return A `data.frame` with columns:
#'   \describe{
#'     \item{type}{Character. One of `"dataset"`, `"chart"`, `"package"`,
#'       `"project"`, `"resource"`, `"post"`.}
#'     \item{slug}{Character. URL slug (kebab-case directory name).}
#'     \item{location}{Character. `"local"`, `"remote"`, or `"both"`.}
#'     \item{local_path}{Character or `NA`. Path to local index.qmd if present.}
#'     \item{s3_key}{Character or `NA`. S3 key if present.}
#'   }
#'   Sorted by type, then slug. Includes attribute `s3_prefix_used`.
#' @export
list_dataverse_content <- function(dataverse_root = here::here(),
                                   s3_bucket = "cori.data.verse",
                                   s3_prefix = NULL,
                                   check_s3 = TRUE) {
  local_df <- collect_local_inventory(dataverse_root)

  prefix_used <- NA_character_
  remote_df <- empty_inventory_df()

  if (isTRUE(check_s3)) {
    if (is.null(s3_prefix)) s3_prefix <- detect_s3_prefix(dataverse_root)
    prefix_used <- s3_prefix
    remote_df <- tryCatch(
      collect_s3_inventory(s3_bucket, s3_prefix),
      error = function(e) {
        warning("S3 listing failed (", conditionMessage(e),
                "); proceeding with local-only inventory.", call. = FALSE)
        empty_inventory_df()
      }
    )
  }

  inventory <- merge_inventories(local_df, remote_df)
  attr(inventory, "s3_prefix_used") <- prefix_used
  inventory
}


# --- 1.1 validate_project_dependencies() -------------------------------------

#' Validate Project Dependencies Against Dataverse Content (Local + S3)
#'
#' Compares inferred dataset/package/resource slugs against existing Dataverse
#' content in two locations: the local content directory and the remote S3
#' prefix (`s3://cori.data.verse/{branch}/content/`). A slug present in either
#' location is "valid"; one missing from both is "dangling." Dangling
#' references are intentionally preserved in the caller's slug vectors so
#' they surface as future content needs in the graph.
#'
#' @param uses_datasets Character vector of dataset slugs (kebab-case).
#' @param uses_packages Character vector of package slugs.
#' @param uses_resources Character vector of resource slugs.
#' @param dataverse_root Character. Root of Dataverse project. Defaults to
#'   `here::here()`.
#' @param s3_bucket Character. Default `"cori.data.verse"`.
#' @param s3_prefix Character or `NULL`. If `NULL`, auto-detects from current
#'   git branch.
#' @param check_s3 Logical. Default `TRUE`. Set `FALSE` to skip S3.
#' @return A list with three per-type partitions plus context:
#'   \describe{
#'     \item{datasets}{`list(valid_local, valid_remote, dangling)`}
#'     \item{packages}{`list(valid_local, valid_remote, dangling)`}
#'     \item{resources}{`list(valid_local, valid_remote, dangling)`}
#'     \item{s3_prefix_used}{The prefix queried, or `NA` if skipped.}
#'     \item{summary}{Character. Human-readable report.}
#'   }
#' @export
validate_project_dependencies <- function(uses_datasets = character(0),
                                          uses_packages = character(0),
                                          uses_resources = character(0),
                                          dataverse_root = here::here(),
                                          s3_bucket = "cori.data.verse",
                                          s3_prefix = NULL,
                                          check_s3 = TRUE) {
  inventory <- list_dataverse_content(
    dataverse_root = dataverse_root,
    s3_bucket      = s3_bucket,
    s3_prefix      = s3_prefix,
    check_s3       = check_s3
  )
  prefix_used <- attr(inventory, "s3_prefix_used")

  ds <- partition_slugs(uses_datasets,  inventory, "dataset")
  pk <- partition_slugs(uses_packages,  inventory, "package")
  rs <- partition_slugs(uses_resources, inventory, "resource")

  summary_text <- format_validation_summary(ds, pk, rs, prefix_used)
  message(summary_text)

  list(
    datasets       = ds,
    packages       = pk,
    resources      = rs,
    s3_prefix_used = prefix_used,
    summary        = summary_text
  )
}


# --- 1.2 generate_project_frontmatter() --------------------------------------

#' Generate Project YAML Frontmatter
#'
#' Builds a YAML frontmatter block conforming to the `ProjectMeta` interface
#' defined in `src/types/index.ts`. Includes graph-edge fields
#' (`usesDatasets`, `usesPackages`, `usesResources`) compatible with
#' `build_graph()`. All slugs are preserved (valid + dangling).
#'
#' @param title Character.
#' @param description Character.
#' @param slug Character. URL slug for the project.
#' @param date Character or Date. Defaults to `Sys.Date()`.
#' @param categories Character vector.
#' @param tags Character vector.
#' @param featured Logical.
#' @param project_url Character. Repository or site URL.
#' @param status Character (e.g., `"active"`, `"completed"`).
#' @param team Character vector.
#' @param uses_datasets Character vector. Dataset slugs (kebab-case).
#' @param uses_packages Character vector. Package slugs.
#' @param uses_resources Character vector. Resource slugs.
#' @return Character string of YAML (with `---` delimiters and a trailing
#'   newline).
#' @export
generate_project_frontmatter <- function(title,
                                         description,
                                         slug,
                                         date = Sys.Date(),
                                         categories = character(0),
                                         tags = character(0),
                                         featured = FALSE,
                                         project_url = NULL,
                                         status = "active",
                                         team = character(0),
                                         uses_datasets = character(0),
                                         uses_packages = character(0),
                                         uses_resources = character(0)) {
  fm <- list(
    title       = title,
    description = description,
    date        = format(as.Date(date)),
    layout      = "default",
    permalink   = paste0("/projects/", slug, "/"),
    categories  = as.list(categories),
    tags        = as.list(tags),
    featured    = isTRUE(featured)
  )
  if (!is.null(project_url) && nzchar(project_url)) {
    fm$projectUrl <- project_url
  }
  fm$status         <- status
  fm$team           <- as.list(team)
  fm$usesDatasets   <- as.list(uses_datasets)
  fm$usesPackages   <- as.list(uses_packages)
  fm$usesResources  <- as.list(uses_resources)
  fm$format         <- list(gfm = list(toc = FALSE, wrap = "none"))
  fm$execute        <- list(echo = FALSE, warning = FALSE, message = FALSE)

  yaml_body <- yaml::as.yaml(fm,
                             indent.mapping.sequence = TRUE,
                             handlers = list(logical = function(x) {
                               result <- ifelse(x, "true", "false")
                               class(result) <- "verbatim"
                               result
                             }))
  paste0("---\n", yaml_body, "---\n")
}


# --- 1.3 generate_project_body() ---------------------------------------------

#' Generate Project Body Content (Quarto Markdown)
#'
#' Produces the Quarto markdown body for a project `index.qmd`. Accepts a
#' structured input and arranges it with Dataverse conventions (callouts,
#' panel-tabsets, columns, internal links to existing nodes, plain text for
#' dangling refs).
#'
#' @param overview Character. Project overview prose.
#' @param github_url Character or `NULL`. Quick-link URL.
#' @param database_schema Character or `NULL`.
#' @param key_questions Named list of question -> answer.
#' @param methodology Named list. May include `data_strategy`, `etl_pipeline`
#'   (mermaid block content), `geographic_classification`,
#'   `temporal_coverage`, `inflation_adjustment`.
#' @param data_sources Named list of `data.frame`s, one per category. Each
#'   row: `slug`, `name`, `variables`, `years`, `key_metrics`, `valid`
#'   (logical).
#' @param technical_implementation Named list with `quality_controls`,
#'   `reproducibility`.
#' @param outputs Named list of output category vectors.
#' @param r_packages `data.frame` or `NULL`. Columns: `slug`, `name`,
#'   `purpose`, `valid`.
#' @param dangling_note Character or `NULL`. Optional auto-generated note.
#' @return Character string (Quarto markdown).
#' @export
generate_project_body <- function(overview,
                                  github_url = NULL,
                                  database_schema = NULL,
                                  key_questions = list(),
                                  methodology = list(),
                                  data_sources = list(),
                                  technical_implementation = list(),
                                  outputs = list(),
                                  r_packages = NULL,
                                  dangling_note = NULL) {
  parts <- c(
    section_overview(overview),
    section_quick_links(github_url, database_schema),
    section_key_questions(key_questions),
    section_methodology(methodology),
    section_data_sources(data_sources),
    section_technical_implementation(technical_implementation),
    section_outputs(outputs),
    section_r_packages(r_packages),
    section_dangling_note(dangling_note)
  )
  paste(parts[nzchar(parts)], collapse = "\n\n")
}


# --- 1.4 generate_project_qmd() ----------------------------------------------

#' Generate a Complete Project index.qmd
#'
#' Combines `validate_project_dependencies()`,
#' `generate_project_frontmatter()`, and `generate_project_body()` into a
#' single `index.qmd` file. Designed to be called by Claude Code after
#' README parsing, structure scanning, and dependency inference. Discovered
#' slugs that don't yet exist in Dataverse are preserved as dangling
#' graph edges.
#'
#' @param frontmatter_args Named list of arguments for
#'   `generate_project_frontmatter()`.
#' @param body_args Named list of arguments for `generate_project_body()`.
#' @param output_path Character or `NULL`. Where to write the file. If `NULL`,
#'   returns the content without writing.
#' @param dataverse_root Character. Root of Dataverse project. Defaults to
#'   `here::here()`.
#' @param overwrite Logical. Whether to overwrite existing file. Defaults to
#'   `FALSE`.
#' @return Invisibly returns the generated content (character string).
#' @export
generate_project_qmd <- function(frontmatter_args,
                                 body_args,
                                 output_path = NULL,
                                 dataverse_root = here::here(),
                                 overwrite = FALSE) {
  validation <- validate_project_dependencies(
    uses_datasets  = frontmatter_args[["uses_datasets"]]  %||% character(0),
    uses_packages  = frontmatter_args[["uses_packages"]]  %||% character(0),
    uses_resources = frontmatter_args[["uses_resources"]] %||% character(0),
    dataverse_root = dataverse_root
  )

  if (is.null(body_args[["dangling_note"]])) {
    body_args$dangling_note <- format_dangling_note(validation)
  }

  fm  <- do.call(generate_project_frontmatter, frontmatter_args)
  bod <- do.call(generate_project_body, body_args)
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


# --- Internal helpers (not exported) -----------------------------------------

#' Detect S3 prefix from current git branch
#' @noRd
detect_s3_prefix <- function(dataverse_root) {
  branch <- tryCatch(
    suppressWarnings(system2(
      "git", c("-C", dataverse_root, "rev-parse", "--abbrev-ref", "HEAD"),
      stdout = TRUE, stderr = FALSE
    )),
    error = function(e) "dev"
  )
  branch <- branch[length(branch)]
  if (length(branch) == 0 || is.na(branch)) branch <- "dev"
  if (identical(branch, "main")) "main/content/" else "dev/content/"
}


#' Empty inventory data.frame skeleton
#' @noRd
empty_inventory_df <- function() {
  data.frame(
    type       = character(0),
    slug       = character(0),
    local_path = character(0),
    s3_key     = character(0),
    stringsAsFactors = FALSE
  )
}


#' Build local inventory from discover_content_items()
#' @noRd
collect_local_inventory <- function(dataverse_root) {
  items <- discover_content_items(dataverse_root)
  if (length(items) == 0) return(empty_inventory_df())
  data.frame(
    type       = vapply(items, `[[`, character(1), "type"),
    slug       = vapply(items, `[[`, character(1), "slug"),
    local_path = vapply(items, `[[`, character(1), "path"),
    s3_key     = NA_character_,
    stringsAsFactors = FALSE
  )
}


#' List S3 keys under a prefix and extract (type, slug)
#' @noRd
collect_s3_inventory <- function(s3_bucket, s3_prefix) {
  keys <- list_s3_keys(s3_bucket, s3_prefix)
  if (length(keys) == 0) return(empty_inventory_df())

  pattern <- paste0("^", regex_escape(s3_prefix),
                    "([^/]+)/([^/]+)/index\\.(qmd|md)$")
  matches <- regmatches(keys, regexec(pattern, keys))
  parsed <- do.call(rbind, lapply(seq_along(matches), function(i) {
    m <- matches[[i]]
    if (length(m) < 4) return(NULL)
    plural <- m[2]
    slug   <- m[3]
    type   <- plural_to_singular(plural)
    if (is.na(type)) return(NULL)
    data.frame(type = type, slug = slug, s3_key = keys[i],
               stringsAsFactors = FALSE)
  }))
  if (is.null(parsed) || nrow(parsed) == 0) return(empty_inventory_df())

  parsed <- parsed[!duplicated(parsed[, c("type", "slug")]), , drop = FALSE]
  parsed$local_path <- NA_character_
  parsed[, c("type", "slug", "local_path", "s3_key")]
}


#' List all S3 keys under a bucket, filtered to those starting with a prefix.
#' Tries cori.db first, then falls back to paws.storage.
#' @noRd
list_s3_keys <- function(s3_bucket, s3_prefix) {
  if (requireNamespace("cori.db", quietly = TRUE)) {
    df <- cori.db::list_s3_objects(bucket_name = s3_bucket)
    if (is.null(df) || !"key" %in% names(df)) return(character(0))
    keys <- as.character(df$key)
    return(keys[startsWith(keys, s3_prefix)])
  }
  if (requireNamespace("paws.storage", quietly = TRUE)) {
    s3 <- paws.storage::s3()
    keys <- character(0)
    token <- NULL
    repeat {
      args <- list(Bucket = s3_bucket, Prefix = s3_prefix, MaxKeys = 1000L)
      if (!is.null(token)) args$ContinuationToken <- token
      resp <- do.call(s3$list_objects_v2, args)
      contents <- resp$Contents
      if (length(contents) > 0) {
        keys <- c(keys, vapply(contents, function(x) x$Key, character(1)))
      }
      if (isTRUE(resp$IsTruncated)) {
        token <- resp$NextContinuationToken
      } else {
        break
      }
    }
    return(keys)
  }
  stop("Neither cori.db nor paws.storage is installed; cannot list S3.")
}


#' Map plural directory name to singular content type
#' @noRd
plural_to_singular <- function(plural) {
  map <- c(datasets = "dataset", charts = "chart", packages = "package",
           projects = "project", resources = "resource", posts = "post")
  unname(map[plural])
}


#' Escape a string for use as a literal in a regex
#' @noRd
regex_escape <- function(s) {
  gsub("([][{}().+*?^$|\\\\])", "\\\\\\1", s)
}


#' Merge local and remote inventory data.frames
#' @noRd
merge_inventories <- function(local_df, remote_df) {
  combined <- merge(local_df, remote_df,
                    by = c("type", "slug"), all = TRUE,
                    suffixes = c(".loc", ".rem"))
  if (nrow(combined) == 0) {
    out <- data.frame(
      type = character(0), slug = character(0), location = character(0),
      local_path = character(0), s3_key = character(0),
      stringsAsFactors = FALSE
    )
    return(out)
  }
  local_path <- ifelse(!is.na(combined$local_path.loc),
                       combined$local_path.loc, combined$local_path.rem)
  s3_key <- ifelse(!is.na(combined$s3_key.rem),
                   combined$s3_key.rem, combined$s3_key.loc)
  has_local  <- !is.na(local_path)
  has_remote <- !is.na(s3_key)
  location <- ifelse(has_local & has_remote, "both",
                     ifelse(has_local, "local", "remote"))

  out <- data.frame(
    type       = combined$type,
    slug       = combined$slug,
    location   = location,
    local_path = local_path,
    s3_key     = s3_key,
    stringsAsFactors = FALSE
  )
  out <- out[order(out$type, out$slug), , drop = FALSE]
  rownames(out) <- NULL
  out
}


#' Partition input slugs against the inventory for a given type.
#' Returns list(valid_local, valid_remote, dangling).
#' @noRd
partition_slugs <- function(slugs, inventory, type) {
  slugs <- unique(slugs[nzchar(slugs)])
  if (length(slugs) == 0) {
    return(list(valid_local  = character(0),
                valid_remote = character(0),
                dangling     = character(0)))
  }
  type_inv <- inventory[inventory$type == type, , drop = FALSE]
  local_set  <- type_inv$slug[type_inv$location %in% c("local", "both")]
  remote_set <- type_inv$slug[type_inv$location %in% c("remote", "both")]

  valid_local  <- intersect(slugs, local_set)
  valid_remote <- setdiff(intersect(slugs, remote_set), valid_local)
  dangling     <- setdiff(slugs, c(local_set, remote_set))
  list(valid_local = valid_local,
       valid_remote = valid_remote,
       dangling = dangling)
}


#' Format a one-block validation summary
#' @noRd
format_validation_summary <- function(ds, pk, rs, prefix_used) {
  fmt <- function(label, part) {
    sprintf("  %s: %d local, %d S3-only, %d dangling%s",
            label, length(part$valid_local), length(part$valid_remote),
            length(part$dangling),
            if (length(part$dangling))
              paste0(" (", paste(part$dangling, collapse = ", "), ")")
            else "")
  }
  prefix_msg <- if (is.na(prefix_used)) "S3 check skipped"
                else paste0("S3 prefix: ", prefix_used)
  paste(c(
    paste0("Dataverse dependency validation [", prefix_msg, "]"),
    fmt("datasets",  ds),
    fmt("packages",  pk),
    fmt("resources", rs)
  ), collapse = "\n")
}


#' Build a callout note listing dangling slugs (or NULL if none)
#' @noRd
format_dangling_note <- function(validation) {
  dangling <- c(
    paste0("dataset/",  validation$datasets$dangling),
    paste0("package/",  validation$packages$dangling),
    paste0("resource/", validation$resources$dangling)
  )
  dangling <- dangling[!grepl("/$", dangling)]
  if (length(dangling) == 0) return(NULL)
  paste0(
    "::: {.callout-note}\n",
    "## Dangling references\n\n",
    "The following slugs are referenced by this project but do not yet ",
    "have nodes in Dataverse (local or S3). They are intentionally ",
    "preserved as future content needs:\n\n",
    paste0("- `", dangling, "`", collapse = "\n"),
    "\n:::"
  )
}


# --- Body section helpers (Quarto markdown) ----------------------------------

#' @noRd
section_overview <- function(overview) {
  if (!nzchar(overview %||% "")) return("")
  paste0("## Project Overview\n\n", overview)
}

#' @noRd
section_quick_links <- function(github_url, database_schema) {
  if (is.null(github_url) && is.null(database_schema)) return("")
  bullets <- character(0)
  if (!is.null(github_url) && nzchar(github_url)) {
    bullets <- c(bullets, paste0("- [GitHub Repository](", github_url, ")"))
  }
  if (!is.null(database_schema) && nzchar(database_schema)) {
    bullets <- c(bullets,
                 paste0("- Database Schema: `", database_schema, "`"))
  }
  if (length(bullets) == 0) return("")
  paste0("::: {.callout-tip icon=false}\n## Quick Links\n\n",
         paste(bullets, collapse = "\n"), "\n:::")
}

#' @noRd
section_key_questions <- function(key_questions) {
  if (length(key_questions) == 0) return("")
  tabs <- vapply(names(key_questions), function(nm) {
    paste0("### ", nm, "\n\n", key_questions[[nm]])
  }, character(1))
  paste0("## Key Questions\n\n::: {.panel-tabset}\n\n",
         paste(tabs, collapse = "\n\n"),
         "\n\n:::")
}

#' @noRd
section_methodology <- function(methodology) {
  if (length(methodology) == 0) return("")
  parts <- "## Methodology"

  if (!is.null(methodology$data_strategy)) {
    parts <- c(parts,
               paste0("::: {.callout-note}\n## Data Integration Strategy\n\n",
                      methodology$data_strategy, "\n:::"))
  }
  if (!is.null(methodology$etl_pipeline)) {
    parts <- c(parts,
               "### ETL Pipeline",
               paste0("```mermaid\n", methodology$etl_pipeline, "\n```"))
  }
  if (!is.null(methodology$geographic_classification) ||
      !is.null(methodology$temporal_coverage)) {
    cols <- character(0)
    if (!is.null(methodology$geographic_classification)) {
      cols <- c(cols, paste0(
        "::: {.column width=\"48%\"}\n### Geographic Classification\n\n",
        methodology$geographic_classification, "\n:::"))
    }
    cols <- c(cols, "::: {.column width=\"4%\"}\n:::")
    if (!is.null(methodology$temporal_coverage)) {
      cols <- c(cols, paste0(
        "::: {.column width=\"48%\"}\n### Temporal Coverage\n\n",
        methodology$temporal_coverage, "\n:::"))
    }
    parts <- c(parts,
               paste0(":::: {.columns}\n\n",
                      paste(cols, collapse = "\n\n"),
                      "\n\n::::"))
  }
  if (!is.null(methodology$inflation_adjustment)) {
    parts <- c(parts,
               "### Inflation Adjustment",
               paste0("::: {.callout-note}\n## Price Adjustment Methods\n\n",
                      methodology$inflation_adjustment, "\n:::"))
  }
  paste(parts, collapse = "\n\n")
}

#' @noRd
section_data_sources <- function(data_sources) {
  if (length(data_sources) == 0) return("")
  parts <- "## Data Sources & Integration"
  for (cat_name in names(data_sources)) {
    df <- data_sources[[cat_name]]
    if (is.null(df) || nrow(df) == 0) next
    parts <- c(parts,
               paste0("### ", cat_name),
               render_dataset_table(df))
  }
  paste(parts, collapse = "\n\n")
}

#' @noRd
render_dataset_table <- function(df) {
  rows <- vapply(seq_len(nrow(df)), function(i) {
    name_cell <- if (isTRUE(df$valid[i])) {
      paste0("[", df$name[i], "](/datasets/", df$slug[i], "/)")
    } else {
      paste0(df$name[i], " *(slug: `", df$slug[i], "` -- node pending)*")
    }
    paste("|", name_cell,
          "|", df$variables[i] %||% "",
          "|", df$years[i] %||% "",
          "|", df$key_metrics[i] %||% "", "|")
  }, character(1))
  paste(c(
    "| Dataset | Variables | Years | Key Metrics |",
    "|---------|-----------|-------|-------------|",
    rows
  ), collapse = "\n")
}

#' @noRd
section_technical_implementation <- function(ti) {
  if (length(ti) == 0) return("")
  parts <- "## Technical Implementation"
  if (!is.null(ti$quality_controls)) {
    parts <- c(parts, "### Data Quality Controls",
               paste0("::: {.callout-note}\n## Quality Assurance Process\n\n",
                      ti$quality_controls, "\n:::"))
  }
  if (!is.null(ti$reproducibility)) {
    parts <- c(parts, "### Reproducibility", ti$reproducibility)
  }
  paste(parts, collapse = "\n\n")
}

#' @noRd
section_outputs <- function(outputs) {
  if (length(outputs) == 0) return("")
  tabs <- vapply(names(outputs), function(nm) {
    val <- outputs[[nm]]
    body <- if (is.character(val) && length(val) > 1) {
      paste0("- ", val, collapse = "\n")
    } else {
      as.character(val)
    }
    paste0("### ", nm, "\n\n", body)
  }, character(1))
  paste0("## Outputs\n\n::: {.panel-tabset}\n\n",
         paste(tabs, collapse = "\n\n"),
         "\n\n:::")
}

#' @noRd
section_r_packages <- function(r_packages) {
  if (is.null(r_packages) || nrow(r_packages) == 0) return("")
  rows <- vapply(seq_len(nrow(r_packages)), function(i) {
    name_cell <- if (isTRUE(r_packages$valid[i])) {
      paste0("[", r_packages$name[i], "](/packages/",
             r_packages$slug[i], "/)")
    } else {
      paste0(r_packages$name[i], " *(slug: `",
             r_packages$slug[i], "` -- node pending)*")
    }
    paste("|", name_cell, "|", r_packages$purpose[i] %||% "", "|")
  }, character(1))
  paste(c(
    "## R Packages",
    "",
    "| Package | Purpose |",
    "|---------|---------|",
    rows
  ), collapse = "\n")
}

#' @noRd
section_dangling_note <- function(dangling_note) {
  if (is.null(dangling_note) || !nzchar(dangling_note)) return("")
  dangling_note
}
