# sync_content_s3.R
#
# S3 content sync functions for cori.data.verse.
# These are standalone scripts (NOT exported) because they depend on cori.db
# (a private package). They live in data-raw/ per R package convention.
#
# The _targets.R pipeline in the project root is the user-facing entry point.

# --- Branch-aware prefix routing ---------------------------------------------

#' Determine the S3 prefix based on the current git branch.
#' main -> "prod/content/", anything else -> "dev/content/"
get_s3_prefix <- function() {
  branch <- system2("git", c("rev-parse", "--abbrev-ref", "HEAD"),
                    stdout = TRUE)
  if (identical(branch, "main")) "prod/content/" else "dev/content/"
}

# --- Git-aware deletion helpers ----------------------------------------------

#' Return relative paths of .qmd files git considers deleted (staged or unstaged).
get_git_deleted_qmds <- function() {
  lines <- system2("git", c("status", "--porcelain"), stdout = TRUE)
  if (length(lines) == 0) return(character(0))
  # Lines where the first OR second status character is 'D', ending in .qmd
  deleted <- lines[grepl("^[ D]D .+\\.qmd$", lines)]
  # Strip the two-character status prefix + space
  sub("^.{3}", "", deleted)
}

# --- Sync manifest -----------------------------------------------------------

#' Build a sync manifest comparing local files to S3 objects.
#'
#' @param content_dir Character. Local content directory path.
#' @param bucket Character. S3 bucket name.
#' @param prefix Character. S3 key prefix.
#' @return A data.frame with columns: rel_path, local_mtime, s3_mtime,
#'   s3_key, action ("push", "pull", or "skip").
build_sync_manifest <- function(content_dir, bucket, prefix) {
  # Enumerate local files
  local_files <- list.files(content_dir, recursive = TRUE, full.names = FALSE)
  local_df <- data.frame(
    rel_path    = local_files,
    local_mtime = as.POSIXct(
      file.mtime(file.path(content_dir, local_files)),
      tz = "UTC"
    ),
    stringsAsFactors = FALSE
  )

  # Enumerate S3 objects (list_s3_objects returns columns: key, last_modified)
  s3_objects <- cori.db::list_s3_objects(bucket_name = bucket)

  # Coerce key column to character vector (rbind returns a matrix)
  s3_keys <- as.character(s3_objects$key)
  s3_mtimes <- s3_objects$last_modified

  # Handle empty bucket
  if (length(s3_keys) == 0 || all(is.na(s3_keys))) {
    s3_df <- data.frame(
      s3_key   = character(0),
      s3_mtime = as.POSIXct(character(0)),
      rel_path = character(0),
      stringsAsFactors = FALSE
    )
  } else {
    # Filter to our prefix
    mask <- startsWith(s3_keys, prefix)
    s3_df <- data.frame(
      s3_key   = s3_keys[mask],
      s3_mtime = as.POSIXct(s3_mtimes[mask], tz = "UTC"),
      stringsAsFactors = FALSE
    )
    # Strip prefix to get relative paths
    s3_df$rel_path <- sub(paste0("^", prefix), "", s3_df$s3_key)
  }

  # Full outer join on rel_path
  manifest <- merge(local_df, s3_df, by = "rel_path", all = TRUE)

  # Determine action
  manifest$action <- mapply(function(local_t, s3_t) {
    if (is.na(local_t))                  return("pull")
    if (is.na(s3_t))                     return("push")
    if (as.numeric(local_t) > as.numeric(s3_t)) return("push")
    if (as.numeric(s3_t) > as.numeric(local_t)) return("pull")
    "skip"
  }, manifest$local_mtime, manifest$s3_mtime, USE.NAMES = FALSE)

  # Fill in missing s3_key for push-only files
  manifest$s3_key[is.na(manifest$s3_key)] <-
    paste0(prefix, manifest$rel_path[is.na(manifest$s3_key)])

  manifest
}

# --- Push --------------------------------------------------------------------

#' Upload local content files that are newer or missing on S3.
#'
#' @param content_dir Character. Local content directory path.
#' @param bucket Character. S3 bucket name.
#' @param prefix Character. S3 key prefix.
#' @param dry_run Logical. If TRUE, only report what would be uploaded.
push_content_to_s3 <- function(content_dir, bucket, prefix,
                               dry_run = FALSE) {
  manifest <- build_sync_manifest(content_dir, bucket, prefix)
  to_push <- manifest[manifest$action == "push", ]

  if (nrow(to_push) == 0) {
    message("push: Nothing to upload.")
    return(invisible(to_push))
  }

  message("push: ", nrow(to_push), " file(s) to upload.")

  if (dry_run) {
    message("  [dry run] Would upload:")
    for (i in seq_len(nrow(to_push))) {
      message("    ", to_push$rel_path[i], " -> ", to_push$s3_key[i])
    }
    return(invisible(to_push))
  }

  # Initialize S3 client for direct uploads (bypasses cori.db overwrite guard
  # on non-dev/test keys)
  s3_client <- paws.storage::s3()

  for (i in seq_len(nrow(to_push))) {
    local_path <- file.path(content_dir, to_push$rel_path[i])
    s3_key <- to_push$s3_key[i]

    if (startsWith(s3_key, "dev/") || startsWith(s3_key, "test/")) {
      # Use cori.db for dev/test prefixes (overwrite is allowed)
      cori.db::put_s3_object(
        bucket_name  = bucket,
        s3_key_path  = s3_key,
        file_path    = local_path
      )
    } else {
      # Bypass cori.db overwrite guard for production keys
      s3_client$put_object(
        Bucket = bucket,
        Key    = s3_key,
        Body   = readBin(local_path, "raw", file.info(local_path)$size)
      )
    }
    message("  uploaded: ", to_push$rel_path[i])
  }

  invisible(to_push)
}

# --- Pull --------------------------------------------------------------------

#' Download S3 content objects that are newer or missing locally.
#'
#' @param content_dir Character. Local content directory path.
#' @param bucket Character. S3 bucket name.
#' @param prefix Character. S3 key prefix.
#' @param dry_run Logical. If TRUE, only report what would be downloaded.
pull_content_from_s3 <- function(content_dir, bucket, prefix,
                                 dry_run = FALSE) {
  manifest <- build_sync_manifest(content_dir, bucket, prefix)
  to_pull <- manifest[manifest$action == "pull", ]

  if (nrow(to_pull) == 0) {
    message("pull: Nothing to download.")
    return(invisible(to_pull))
  }

  message("pull: ", nrow(to_pull), " file(s) to download.")

  if (dry_run) {
    message("  [dry run] Would download:")
    for (i in seq_len(nrow(to_pull))) {
      message("    ", to_pull$s3_key[i], " -> ", to_pull$rel_path[i])
    }
    return(invisible(to_pull))
  }

  s3_client <- paws.storage::s3()
  for (i in seq_len(nrow(to_pull))) {
    local_path <- file.path(content_dir, to_pull$rel_path[i])
    dir.create(dirname(local_path), recursive = TRUE, showWarnings = FALSE)
    s3_client$download_file(
      Bucket   = bucket,
      Key      = to_pull$s3_key[i],
      Filename = local_path
    )
    message("  downloaded: ", to_pull$rel_path[i])
  }

  invisible(to_pull)
}

# --- Bidirectional sync ------------------------------------------------------

#' Bidirectional newest-wins sync between local content/ and S3.
#'
#' @param content_dir Character. Local content directory path.
#' @param bucket Character. S3 bucket name.
#' @param prefix Character. S3 key prefix.
#' @param dry_run Logical. If TRUE, only report what would happen.
sync_content_s3 <- function(content_dir, bucket, prefix,
                            dry_run = FALSE) {
  # S3 keys that correspond to source .qmd files git considers deleted.
  # These are promoted from "pull" to "delete_from_s3" rather than pulled down.
  deleted_qmds    <- get_git_deleted_qmds()
  deleted_s3_keys <- vapply(deleted_qmds, function(q) {
    paste0(prefix, sub("\\.qmd$", ".md", q))
  }, character(1))

  manifest <- build_sync_manifest(content_dir, bucket, prefix)

  # Promote pull → delete_from_s3 only for git-deleted sources
  if (length(deleted_s3_keys) > 0) {
    manifest$action[
      manifest$action == "pull" &
      manifest$s3_key %in% deleted_s3_keys
    ] <- "delete_from_s3"
  }

  to_push   <- manifest[manifest$action == "push",           ]
  to_pull   <- manifest[manifest$action == "pull",           ]
  to_delete <- manifest[manifest$action == "delete_from_s3", ]
  skipped   <- manifest[manifest$action == "skip",           ]

  message("sync: ", nrow(to_push),   " to push, ",
                    nrow(to_pull),   " to pull, ",
                    nrow(to_delete), " to delete from S3, ",
                    nrow(skipped),   " unchanged.")

  if (dry_run) {
    if (nrow(to_push) > 0) {
      message("  [dry run] Would push:")
      for (i in seq_len(nrow(to_push)))
        message("    ", to_push$rel_path[i])
    }
    if (nrow(to_pull) > 0) {
      message("  [dry run] Would pull:")
      for (i in seq_len(nrow(to_pull)))
        message("    ", to_pull$rel_path[i])
    }
    if (nrow(to_delete) > 0) {
      message("  [dry run] Would delete from S3:")
      for (i in seq_len(nrow(to_delete)))
        message("    ", to_delete$s3_key[i])
    }
    return(invisible(manifest))
  }

  # Execute pushes
  if (nrow(to_push) > 0) {
    s3_client <- paws.storage::s3()
    for (i in seq_len(nrow(to_push))) {
      local_path <- file.path(content_dir, to_push$rel_path[i])
      s3_key <- to_push$s3_key[i]
      if (startsWith(s3_key, "dev/") || startsWith(s3_key, "test/")) {
        cori.db::put_s3_object(bucket_name = bucket, s3_key_path = s3_key, file_path = local_path)
      } else {
        s3_client$put_object(
          Bucket = bucket, Key = s3_key,
          Body = readBin(local_path, "raw", file.info(local_path)$size)
        )
      }
      message("  pushed: ", to_push$rel_path[i])
    }
  }

  # Execute pulls
  if (nrow(to_pull) > 0) {
    s3_pull <- paws.storage::s3()
    for (i in seq_len(nrow(to_pull))) {
      local_path <- file.path(content_dir, to_pull$rel_path[i])
      dir.create(dirname(local_path), recursive = TRUE, showWarnings = FALSE)
      s3_pull$download_file(
        Bucket   = bucket,
        Key      = to_pull$s3_key[i],
        Filename = local_path
      )
      message("  pulled: ", to_pull$rel_path[i])
    }
  }

  # Delete from S3 (and locally) for git-deleted source .qmd files
  if (nrow(to_delete) > 0) {
    s3_del <- paws.storage::s3()
    for (i in seq_len(nrow(to_delete))) {
      local_path <- file.path(content_dir, to_delete$rel_path[i])
      if (file.exists(local_path)) {
        unlink(dirname(local_path), recursive = TRUE)
        message("  deleted local: ", to_delete$rel_path[i])
      }
      s3_del$delete_object(Bucket = bucket, Key = to_delete$s3_key[i])
      message("  deleted from S3: ", to_delete$s3_key[i])
    }
  }

  invisible(manifest)
}
