# _targets.R
#
# targets pipeline driver for S3 content sync.
# Run from the project root: targets::tar_make()

library(targets)
source("data-raw/sync_content_s3.R")

if (!require("cori.data.verse")) {
  devtools::install()
}

tar_option_set(
  packages = c(
    "quarto",
    "cori.db",
    "cori.data.verse",
    "here",
    "jsonlite", 
    "paws.storage"
  )
)

#' Prompt for confirmation before writing to the production S3 prefix.
confirm_production_write <- function(prefix) {
  if (!startsWith(prefix, "main/")) return(TRUE)
  if (!interactive()) {
    message("Non-interactive session: skipping production sync (main/ prefix)")
    return(FALSE)
  }
  answer <- readline(
    "You are on 'main'. Sync to PRODUCTION (s3://cori.data.verse/main/content/)? [y/N] "
  )
  tolower(trimws(answer)) == "y"
}

list(
  tar_target(s3_bucket, "cori.data.verse"),
  tar_target(s3_prefix, get_s3_prefix(),
             cue = tar_cue(mode = "always")),
  tar_target(confirmed, confirm_production_write(s3_prefix),
             cue = tar_cue(mode = "always")),
  tar_target(
    render_result,
    {
      quarto::quarto_render(as_job = FALSE)
      Sys.time()
    },
    cue = tar_cue(mode = "always")
  ),
  tar_target(
    sync_result,
    {
      render_result
      if (!confirmed) {
        message("Production sync declined. Skipping.")
        return(NULL)
      }
      sync_content_s3(
        content_dir = here::here("content"),
        bucket      = s3_bucket,
        prefix      = s3_prefix
      )
    },
    cue = tar_cue(mode = "always")
  )
)
