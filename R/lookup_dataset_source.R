# lookup_dataset_source.R
#
# S3-backed lookup helpers for the canonical dataset source-attribution
# vocabulary. The dataset profiles at
# s3://cori.data.verse/dev/content/datasets/<slug>/index.qmd are the single
# source of truth for `dataset.source` (institution) and `dataset.sourceUrl`
# (canonical program page) values.
#
# These helpers replace the previous hardcoded constants
# `.dataset_source_names` and `.dataset_source_urls` in generate_chart_qmd.R.
# Local definition of %||% for compatibility with R < 4.4
`%||%` <- function(x, y) if (is.null(x)) y else x


# In-process cache keyed by paste0(s3_bucket, "::", s3_prefix). Holds a list
# of records: each list element has $slug, $name, $source, $sourceUrl.
.dataset_profile_cache <- new.env(parent = emptyenv())


#' Fetch all dataset profiles from S3 and parse their frontmatter.
#'
#' Lists `s3://<bucket>/<prefix>datasets/`, downloads each `<slug>/index.qmd`,
#' parses its YAML frontmatter via `read_qmd_frontmatter()`, and returns a
#' list of records keyed by slug. Cached in-process so multiple lookups
#' within a single function call don't re-fetch.
#'
#' Returns an empty list (with a warning) on S3 failure.
#'
#' @param s3_bucket Character. Default `"cori.data.verse"`.
#' @param s3_prefix Character. S3 key prefix. Default `"dev/content/"`.
#' @param refresh Logical. If `TRUE`, ignore the cache and re-fetch.
#'   Default `FALSE`.
#' @return Named list. Names are dataset slugs. Each element is a list with
#'   `$slug`, `$name`, `$source`, `$sourceUrl`.
#' @noRd
fetch_dataset_profiles_from_s3 <- function(s3_bucket = "cori.data.verse",
                                            s3_prefix = "dev/content/",
                                            refresh   = FALSE) {
  cache_key <- paste0(s3_bucket, "::", s3_prefix)
  if (!refresh && exists(cache_key, envir = .dataset_profile_cache, inherits = FALSE)) {
    return(get(cache_key, envir = .dataset_profile_cache))
  }

  # Use the existing inventory helper to enumerate dataset slugs.
  inv <- tryCatch(
    list_dataverse_content(s3_bucket = s3_bucket, s3_prefix = s3_prefix),
    error = function(e) {
      warning("S3 listing failed for dataset-source lookup (",
              conditionMessage(e), "); returning empty profile cache.",
              call. = FALSE)
      NULL
    }
  )
  if (is.null(inv) || nrow(inv) == 0) {
    assign(cache_key, list(), envir = .dataset_profile_cache)
    return(list())
  }
  ds_rows <- inv[inv$type == "dataset", , drop = FALSE]
  if (nrow(ds_rows) == 0) {
    assign(cache_key, list(), envir = .dataset_profile_cache)
    return(list())
  }

  if (!requireNamespace("paws.storage", quietly = TRUE)) {
    warning("paws.storage not installed; cannot fetch dataset profile bodies.",
            call. = FALSE)
    assign(cache_key, list(), envir = .dataset_profile_cache)
    return(list())
  }

  s3 <- paws.storage::s3()

  records <- list()
  for (i in seq_len(nrow(ds_rows))) {
    slug <- ds_rows$slug[i]

    # Primary path: read the metadata sidecar produced by
    # write_metadata_sidecars() during render. The sidecar holds the full
    # parsed YAML frontmatter as JSON.
    sidecar_key <- paste0(s3_prefix, "datasets/", slug,
                           "/index.md.metadata.json")

    parsed <- tryCatch({
      obj <- s3$get_object(Bucket = s3_bucket, Key = sidecar_key)
      txt <- rawToChar(obj$Body)
      fm  <- jsonlite::fromJSON(txt, simplifyVector = FALSE)
      list(
        slug      = slug,
        name      = fm$dataset$name      %||% NA_character_,
        source    = fm$dataset$source    %||% NA_character_,
        sourceUrl = fm$dataset$sourceUrl %||% NA_character_
      )
    }, error = function(e) NULL)

    if (is.null(parsed)) {
      warning("Could not fetch metadata sidecar for slug ", slug,
              " (key: ", sidecar_key,
              "). Has write_metadata_sidecars() run since the last render?",
              call. = FALSE)
    } else {
      records[[slug]] <- parsed
    }
  }

  assign(cache_key, records, envir = .dataset_profile_cache)
  records
}


#' Look up canonical (source, sourceUrl) for a vector of dataset slugs.
#'
#' Reads dataset profiles from S3 (cached in-process via
#' `fetch_dataset_profiles_from_s3()`). Returns a list with `$source` and
#' `$sourceUrl` derived from the first matching slug; `NULL` if no slug
#' matches or S3 is unreachable.
#'
#' When multiple slugs are supplied and more than one is recognized, the
#' first recognized slug wins. (`generate_chart_qmd()` calls this with the
#' chart's `usesDatasets` vector, where the first slug is the primary
#' dependency.)
#'
#' @param slugs Character vector of dataset slugs.
#' @param s3_bucket Character. Default `"cori.data.verse"`.
#' @param s3_prefix Character. S3 key prefix. Default `"dev/content/"`.
#' @return List with `$source` and `$sourceUrl`, or `NULL` if no match.
#' @export
lookup_dataset_source <- function(slugs,
                                  s3_bucket = "cori.data.verse",
                                  s3_prefix = "dev/content/") {
  slugs <- slugs[nzchar(slugs %||% "")]
  if (length(slugs) == 0) return(NULL)

  profiles <- fetch_dataset_profiles_from_s3(s3_bucket = s3_bucket,
                                              s3_prefix = s3_prefix)
  if (length(profiles) == 0) return(NULL)

  for (slug in slugs) {
    if (!is.null(profiles[[slug]])) {
      return(list(
        source    = profiles[[slug]]$source,
        sourceUrl = profiles[[slug]]$sourceUrl
      ))
    }
  }
  NULL
}


#' Return the deduplicated set of `dataset.source` institution strings
#' currently in use across the S3 dataset profiles, with the count of
#' datasets per institution.
#'
#' Used by the `/generate-dataverse-datasets` skill to constrain new
#' `source:` values to the existing controlled vocabulary unless the
#' analyst explicitly opts in to extending it.
#'
#' @param s3_bucket Character. Default `"cori.data.verse"`.
#' @param s3_prefix Character. S3 key prefix. Default `"dev/content/"`.
#' @return A `data.frame` with columns `source` (institution string) and
#'   `n_datasets` (count of datasets attributing to that institution),
#'   sorted by `n_datasets` descending then `source` alphabetically.
#'   Returns a 0-row data.frame on S3 failure.
#' @export
list_existing_sources <- function(s3_bucket = "cori.data.verse",
                                  s3_prefix = "dev/content/") {
  profiles <- fetch_dataset_profiles_from_s3(s3_bucket = s3_bucket,
                                              s3_prefix = s3_prefix)
  if (length(profiles) == 0) {
    return(data.frame(source = character(0), n_datasets = integer(0),
                      stringsAsFactors = FALSE))
  }
  sources <- vapply(profiles, function(p) p$source %||% NA_character_,
                    character(1))
  sources <- sources[!is.na(sources) & nzchar(sources)]
  if (length(sources) == 0) {
    return(data.frame(source = character(0), n_datasets = integer(0),
                      stringsAsFactors = FALSE))
  }
  tab <- table(sources)
  out <- data.frame(
    source     = names(tab),
    n_datasets = as.integer(tab),
    stringsAsFactors = FALSE
  )
  out[order(-out$n_datasets, out$source), , drop = FALSE]
}
