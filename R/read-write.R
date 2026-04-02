#' Read and write tines schemas and multiverses to YAML files
#'
#' @param x An object of class `schema` or `multiverse`.
#' @param path A single string specifying the output file path. Optional.
#' @param ... Arguments passed on to `yaml::write_yaml()` or `yaml::read_yaml()`.
#'
#' @returns
#' `write_tines()` returns `NULL` and `read_tines()` returns an object of class `schema` or `multiverse`.
#'
#' @export
#' @rdname read-write
#' @examples
#' \dontrun{
#' schema <- example_schema()
#' temp_path <- withr::local_tempfile(fileext = ".yaml")
#' write_tines(schema, temp_path)
#' schema_read <- read_tines(temp_path)
#' }
#'
write_tines <- function(x, path = NULL, ...){

  if (!inherits(x, c("schema", "multiverse"))) {
    cli::cli_abort(c(
      "The object to write must be of class {.cls schema} or {.cls multiverse}.",
      "i" = "Provided object is of class {.cls {class(x)}}."
    ))
  }

  if (is.null(path)){
    prefix <- if (inherits(x, "schema")) "schema" else "multiverse"
    path <- paste0(prefix, ".yml")
  }

  if (inherits(x, "multiverse")) {
    header <- list(meta = list(type = "multiverse", date = as.character(Sys.Date())))
    output <- c(header, list(schemas = x))
  }

  if (inherits(x, "schema")) {
    header <- list(meta = list(
      type = "schema", 
      date = as.character(Sys.Date()),
      name = attr(x, "name", exact = TRUE)
    ))
    # Convert schema to list format for YAML
    nodes_list <- purrr::pmap(as.data.frame(x), function(...) {
      node <- list(...)
      # Ensure inputs and outputs are proper lists
      if (!is.null(node$inputs)) {
        node$inputs <- if (is.na(node$inputs[[1]])) list() else node$inputs[[1]]
      }
      if (!is.null(node$outputs)) {
        node$outputs <- if (is.na(node$outputs[[1]])) list() else node$outputs[[1]]
      }
      node
    })
    
    schema_list <- list(nodes = nodes_list)
    output <- c(header, schema_list)
  }

  yaml::write_yaml(
    output,
    file = path,
    column.major = FALSE,
    ...
  )

  cli::cli_alert_success("File saved: {.file {path}}")

}

#' @export
#' @rdname read-write
read_tines <- function(path, ...){
  raw <- yaml::read_yaml(path, ...)
  type <- raw$meta$type

  rebuild_schema <- function(raw) {
    nodes <- purrr::map(raw$nodes, function(node) {
      # Keep inputs/outputs as lists, coerce everything else to scalar
      list_cols <- c("inputs", "outputs")
      scalar_fields <- setdiff(names(node), list_cols)
      row <- tibble::as_tibble(lapply(node[scalar_fields], function(x) {
        if (length(x) == 0) NA_character_ else as.character(x[[1]])
      }))
      for (col in list_cols) {
        row[[col]] <- list(if (is.null(node[[col]])) character(0) else as.character(node[[col]]))
      }
      row
    })
    new_schema(
      name = raw$meta$name,
      nodes = dplyr::bind_rows(nodes)
    )
  }

  if (type == "schema") {
    res <- rebuild_schema(raw)
  } else if (type == "multiverse") {
    schemas <- purrr::map(raw$schemas, rebuild_schema)
    res <- do.call(build_multiverse, schemas)
  } else{
    cli::cli_abort(c(
      "Unrecognized type in YAML file: {.val {type}}.",
      "i" = "Expected 'schema' or 'multiverse'."
    ))
  }

  return(res)
}
