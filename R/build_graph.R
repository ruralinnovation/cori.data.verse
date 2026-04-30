#' Build a Content Graph Manifest
#'
#' Reads all `.qmd` frontmatter across the project's content-type directories,
#' resolves cross-references, and writes a JSON graph manifest to
#' `content/graph.json`.
#'
#' @param root_dir Character. Project root directory. Defaults to
#'   `here::here()`.
#' @param output_path Character. Path for the output JSON file. Defaults to
#'   `file.path(root_dir, "content", "graph.json")`.
#' @param write Logical. If `TRUE` (default), writes the graph to
#'   `output_path`. If `FALSE`, returns the graph list without writing.
#' @return Invisibly returns the graph as a list with `generated`, `nodes`,
#'   and `edges` elements.
#' @export
build_graph <- function(root_dir = here::here(),
                        output_path = file.path(root_dir, "content",
                                                "graph.json"),
                        write = TRUE) {
  items <- discover_content_items(root_dir)

  nodes <- build_nodes(items)
  edges <- build_edges(items)

  # Collect all node IDs for dangling-edge validation

  node_ids <- vapply(nodes, `[[`, character(1), "id")
  validate_edges(edges, node_ids)

  graph <- list(
    generated = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
    nodes     = nodes,
    edges     = edges
  )

  if (write) {
    dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
    jsonlite::write_json(graph, output_path,
                         pretty = TRUE, auto_unbox = TRUE)
    message("graph.json written to: ", output_path)
  }

  invisible(graph)
}


# --- Internal helpers (not exported) -----------------------------------------

#' Build node list from discovered content items
#' @noRd
build_nodes <- function(items) {
  lapply(items, function(item) {
    fm <- item$frontmatter

    # Extract the type-specific metadata block
    metadata <- switch(item$type,
      dataset  = fm[["dataset"]],
      chart    = fm[["chart"]],
      package  = fm[["package"]],
      project  = fm[c("projectUrl", "status", "team")
                     [c("projectUrl", "status", "team") %in% names(fm)]],
      list()
    )
    if (is.null(metadata)) metadata <- list()

    list(
      id          = paste0(item$type, "/", item$slug),
      type        = item$type,
      slug        = item$slug,
      title       = fm[["title"]] %||% "",
      description = fm[["description"]] %||% "",
      date        = fm[["date"]] %||% "",
      categories  = fm[["categories"]] %||% list(),
      featured    = fm[["featured"]] %||% FALSE,
      metadata    = metadata
    )
  })
}


#' Build edge list from cross-reference fields in frontmatter
#' @noRd
build_edges <- function(items) {
  edges <- list()

  for (item in items) {
    fm <- item$frontmatter
    source_id <- paste0(item$type, "/", item$slug)

    # depends_on edges: package, project, chart, post → dataset/package/resource
    if (item$type %in% c("package", "project", "chart", "post")) {
      edges <- c(edges, make_edges(source_id, "depends_on", "dataset",
                                   fm[["usesDatasets"]]))
      edges <- c(edges, make_edges(source_id, "depends_on", "resource",
                                   fm[["usesResources"]]))
    }
    if (item$type %in% c("project", "chart", "post")) {
      edges <- c(edges, make_edges(source_id, "depends_on", "package",
                                   fm[["usesPackages"]]))
    }

    # produced_by edge: chart → project
    if (item$type == "chart" && !is.null(fm[["producedBy"]]) &&
        nzchar(fm[["producedBy"]])) {
      edges <- c(edges, list(list(
        source   = source_id,
        target   = paste0("project/", fm[["producedBy"]]),
        relation = "produced_by"
      )))
    }

    # references edges: post → any content type (entries are "type/slug")
    if (item$type == "post" && !is.null(fm[["references"]])) {
      for (ref in fm[["references"]]) {
        edges <- c(edges, list(list(
          source   = source_id,
          target   = ref,
          relation = "references"
        )))
      }
    }
  }

  edges
}


#' Create a list of edges from a source to multiple targets of the same type
#' @noRd
make_edges <- function(source_id, relation, target_type, slugs) {
  if (is.null(slugs) || length(slugs) == 0) return(list())
  slugs <- slugs[nzchar(slugs)]
  if (length(slugs) == 0) return(list())
  lapply(slugs, function(slug) {
    list(
      source   = source_id,
      target   = paste0(target_type, "/", slug),
      relation = relation
    )
  })
}


#' Warn about dangling edges (target not in node list)
#' @noRd
validate_edges <- function(edges, node_ids) {
  for (edge in edges) {
    if (!edge$target %in% node_ids) {
      warning("Dangling edge: ", edge$source, " --", edge$relation, "--> ",
              edge$target, " (target node not found)")
    }
  }
}
