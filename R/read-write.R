#' Read and write tines schemas and multiverses to YAML files
#'
#' @param x An object of class `schema` or `multiverse`.
#' @param path A single string specifying the output file path. Optional.
#' @param data Optional data frame or path to data file for validation (for
#'   `read_tines()` only).
#' @param ... Arguments passed on to `yaml::write_yaml()` or
#'   `yaml::read_yaml()`.
#'
#' @returns
#' `write_tines()` returns `NULL` and `read_tines()` returns an object of
#' class `schema` or `multiverse`.
#'
#' @export
#' @rdname read-write
#' @examples
#' schema <- example_schema()
#' temp_path <- withr::local_tempfile(fileext = ".yaml")
#' write_tines(schema, temp_path)
#' schema_read <- read_tines(temp_path)
#'
#' # Read and validate against a data frame or file path
#' my_data <- data.frame(age = c(25, 30, 35), income = c(50000, 60000, 70000))
#' schema_read <- read_tines(temp_path, data = my_data)
#'
write_tines <- function(x, path = NULL, ...) {
  if (!inherits(x, c("schema", "multiverse"))) {
    cli::cli_abort(c(
      paste0(
        "The object to write must be of class {.cls schema} or ",
        "{.cls multiverse}."
      ),
      "i" = "Provided object is of class {.cls {class(x)}}."
    ))
  }

  if (is.null(path)) {
    prefix <- if (inherits(x, "schema")) "schema" else "multiverse"
    path <- paste0(prefix, ".yml")
  }

  if (inherits(x, "multiverse")) {
    header <- list(meta = list(
      type = "multiverse",
      date = as.character(Sys.Date())
    ))
    output <- c(header, list(schemas = purrr::map(x, schema_to_yaml_list)))
  }

  if (inherits(x, "schema")) {
    header <- list(meta = list(
      type = "schema",
      date = as.character(Sys.Date()),
      name = attr(x, "name", exact = TRUE)
    ))
    output <- c(header, list(nodes = schema_to_yaml_list(x)$nodes))
  }

  txt <- yaml::as.yaml(output, column.major = FALSE, ...)
  txt <- collapse_io_lists(txt)
  writeLines(txt, path)

  cli::cli_alert_success("File saved: {.file {path}}")
}

# Converts a single `schema` object into the list-of-nodes shape expected by
# both the standalone schema file format and each entry under a multiverse
# file's `schemas:` field -- shared so a multiverse's schemas serialize
# identically to a standalone schema (required for read_tines() to be able
# to rebuild them the same way via rebuild_schema()).
schema_to_yaml_list <- function(x) {
  nodes_list <- purrr::pmap(as.data.frame(x), function(...) {
    node <- list(...)
    # Ensure inputs and outputs are proper lists
    if (!is.null(node$inputs)) node$inputs <- normalize_io_field(node$inputs)
    if (!is.null(node$outputs)) node$outputs <- normalize_io_field(node$outputs)
    node
  })

  list(
    meta = list(type = "schema", name = attr(x, "name", exact = TRUE)),
    nodes = nodes_list
  )
}

# A schema's inputs/outputs list-column shows up in two different shapes
# depending on how the schema was produced: gen_io()/update_io() store each
# row as list(vector) (one level of list-wrapping per row, from `<-` on a
# single element of an existing list-column), while a schema freshly rebuilt
# by read_tines() yields a plain vector per row (possibly character(0) for
# an empty `[]`, or a length-1 NA sentinel for "unset"). The old
# `if (is.na(node$inputs[[1]]))` check assumed the vector always had exactly
# one element and broke ("the condition has length > 1") on any node with
# more than one input/output. Normalize both shapes into a plain R list of
# strings (possibly empty) instead.
normalize_io_field <- function(field) {
  if (is.list(field) && length(field) == 1 && !is.list(field[[1]])) {
    field <- field[[1]]
  }
  if (length(field) == 0) return(list())
  if (length(field) == 1 && is.na(field)) return(list())
  as.list(field)
}

# yaml::write_yaml()/as.yaml() always emit sequences in block style:
#   inputs:
#   - a
#   - b
# but tines schemas are conventionally authored/read with inputs/outputs as
# single-line flow lists (`inputs: [a, b]`). The R yaml package has no option
# for flow-style sequences, so collapse them back into that form as a text
# post-processing pass over the rendered YAML.
collapse_io_lists <- function(txt) {
  lines <- strsplit(txt, "\n")[[1]]
  out <- character(0)
  i <- 1
  n <- length(lines)
  while (i <= n) {
    line <- lines[i]
    m <- regmatches(line, regexec("^([ ]*)(inputs|outputs):[ ]*$", line))[[1]]
    if (length(m) == 3) {
      indent <- m[2]
      field <- m[3]
      item_prefix <- paste0(indent, "- ")
      items <- character(0)
      j <- i + 1
      while (j <= n && startsWith(lines[j], item_prefix)) {
        val <- sub(paste0("^", item_prefix), "", lines[j])
        val <- sub("^'(.*)'$", "\\1", val)
        items <- c(items, val)
        j <- j + 1
      }
      if (length(items) > 0) {
        out <- c(out, paste0(indent, field, ": [", paste(items, collapse = ", "), "]"))
        i <- j
        next
      }
    }
    out <- c(out, line)
    i <- i + 1
  }
  paste(out, collapse = "\n")
}

#' @export
#' @rdname read-write
read_tines <- function(path, data = NULL, ...) {
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
        row[[col]] <- list(
          if (is.null(node[[col]])) character(0) else as.character(node[[col]])
        )
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

    # Attach and validate data if provided
    if (!is.null(data)) {
      res <- update_data(res, data)
    }
  } else if (type == "multiverse") {
    schemas <- purrr::map(raw$schemas, rebuild_schema)
    res <- do.call(build_multiverse, schemas)

    # Attach data to all schemas if provided
    if (!is.null(data)) {
      res <- purrr::map(res, function(s) update_data(s, data))
      class(res) <- c("multiverse", "list")
    }
  } else {
    cli::cli_abort(c(
      "Unrecognized type in YAML file: {.val {type}}.",
      "i" = "Expected 'schema' or 'multiverse'."
    ))
  }

  return(res)
}
