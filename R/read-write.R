#' Read and write tines schemas and multiverses to YAML files
#'
#' @description
#' [write_tines()] writes a schema (or a multiverse) to YAML, and
#' [read_tines()] reads it back.
#'
#' A schema's data reference is written under `meta.data`, with a file path
#' stored relative to the YAML file, so the two can be moved or shared
#' together. A schema whose data was given as a data frame has no reference
#' to write; supply the data again with `read_tines(path, data = )`.
#'
#' When a mapped schema is read, it is checked against its data: the
#' columns are looked up (never the data itself) and each step's inputs are
#' checked with [validate_schema()]. A plain schema has nothing to check
#' against the data, so its data is not touched. If the data comes from an R
#' script, running it means running code from the file, so `validate`
#' decides whether that happens.
#'
#' @param x An object of class `schema` or `multiverse`.
#' @param path A single string specifying the file path. Required for both
#'   functions: [write_tines()] does not pick a default location.
#' @param data Optional. Data to check the schema against instead of the one
#'   the file references; see [update_data()] for the forms it takes.
#' @param validate How to handle a data source that is an R script:
#'   `"ask"` (the default) asks in an interactive session and skips the check
#'   otherwise, `"always"` runs it without asking, and `"never"` skips
#'   looking up the data's columns altogether.
#' @param ... Arguments passed on to `yaml::as.yaml()` or
#'   `yaml::read_yaml()`.
#'
#' @returns
#' [write_tines()] invisibly returns `path`, and [read_tines()] returns an
#' object of class `schema` or `multiverse`.
#'
#' @export
#' @rdname read-write
#' @examples
#' schema <- example_hdi()
#' temp_path <- withr::local_tempfile(fileext = ".yml")
#' write_tines(schema, temp_path)
#' schema_read <- read_tines(temp_path)
#'
#' # a mapped schema, checked against a data frame on read
#' my_data <- data.frame(age = c(25, 30, 35), income = c(50000, 60000, 70000))
#' mapped <- build_schema("Income") |>
#'   add_step(
#'     id = "step-log", decision = "log-transform income",
#'     inputs = "income", outputs = "log_income"
#'   )
#' write_tines(mapped, temp_path)
#' read_tines(temp_path, data = my_data)
#'
write_tines <- function(x, path, ...) {
  if (missing(path)) abort_missing_path("path")
  if (!inherits(x, c("schema", "multiverse"))) {
    cli::cli_abort(c(
      paste0(
        "The object to write must be of class {.cls schema} or ",
        "{.cls multiverse}."
      ),
      "i" = "Provided object is of class {.cls {class(x)}}."
    ))
  }


  if (inherits(x, "multiverse")) {
    header <- list(meta = list(
      type = "multiverse",
      date = as.character(Sys.Date())
    ))
    output <- c(header, list(schemas = purrr::map(x, schema_to_yaml_list, path = path)))
    unwritable <- any(purrr::map_lgl(x, data_is_unwritable))
  }

  if (inherits(x, "schema")) {
    body <- schema_to_yaml_list(x, path = path)
    body$meta <- c(
      list(type = "schema", date = as.character(Sys.Date())),
      body$meta[setdiff(names(body$meta), "type")]
    )
    output <- body
    unwritable <- data_is_unwritable(x)
  }

  txt <- yaml::as.yaml(output, column.major = FALSE, ...)
  txt <- collapse_io_lists(txt)
  writeLines(txt, path)

  cli::cli_alert_success("File saved: {.file {path}}")
  if (unwritable) {
    cli::cli_inform(c(
      "i" = "The data was given as a data frame, so no data reference was written.",
      " " = "Supply it again with {.code read_tines(path, data = )}."
    ))
  }
  invisible(path)
}

data_is_unwritable <- function(x) {
  ref <- attr(x, "data", exact = TRUE)
  !is.null(ref) && is.null(ref$source)
}

# Converts a single `schema` object into the list-of-nodes shape expected by
# both the standalone schema file format and each entry under a multiverse
# file's `schemas:` field -- shared so a multiverse's schemas serialize
# identically to a standalone schema. `path` is the file being written, which
# a data file's path is made relative to.
schema_to_yaml_list <- function(x, path = NULL) {
  with_io <- has_io(x)
  nodes_list <- purrr::pmap(as.data.frame(x), function(...) {
    node <- list(...)
    if (with_io) {
      # A field not yet given is left out; as.list() writes a step with none
      # as `[]`. An incomplete mapping is written as it stands, so it can be
      # finished later.
      for (field in c("inputs", "outputs")) {
        node[field] <- if (io_missing(node[[field]])) list(NULL) else list(as.list(node[[field]]))
      }
      node <- node[!vapply(node, is.null, logical(1))]
    }
    # `source_schema` is provenance for steps pulled in by import_step(); an
    # unset one says nothing, so it is omitted rather than written out as a
    # typed null (`source_schema: .na.character`) on every step.
    if (!is.null(node$source_schema) && is.na(node$source_schema)) {
      node$source_schema <- NULL
    }
    node
  })

  meta <- list(type = "schema", name = attr(x, "name", exact = TRUE))
  ref <- attr(x, "data", exact = TRUE)
  if (!is.null(ref$source)) {
    src <- if (is.null(path)) ref$source else source_for_file(ref$source, path)
    meta$data <- purrr::compact(list(source = src, object = ref$object))
  }

  list(meta = purrr::compact(meta), nodes = nodes_list)
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
read_tines <- function(path, data = NULL, validate = c("ask", "always", "never"), ...) {
  validate <- match.arg(validate)
  raw <- yaml::read_yaml(path, ...)
  type <- raw$meta$type

  # One lookup per distinct source, so the branches of a multiverse file
  # sharing a script ask (and run it) once.
  looked_up <- list()
  rebuild <- function(raw) {
    x <- rebuild_schema(raw, path)
    if (!is.null(data)) {
      attr(x, "data") <- data_ref(data)
    } else if (is_mapped(x) && has_data(x)) {
      ref <- attr(x, "data", exact = TRUE)
      key <- paste(ref$source, ref$object %||% "")
      if (is.null(looked_up[[key]])) looked_up[[key]] <<- resolve_columns(ref, validate)
      attr(x, "data") <- looked_up[[key]]
    }
    check_schema(x)
  }

  if (identical(type, "schema")) {
    rebuild(raw)
  } else if (identical(type, "multiverse")) {
    new_multiverse(purrr::map(raw$schemas, rebuild))
  } else {
    cli::cli_abort(c(
      "Unrecognized type in YAML file: {.val {type}}.",
      "i" = "Expected 'schema' or 'multiverse'."
    ))
  }
}

# One schema's `meta` + `nodes` -> a `schema` object. A file in which no
# step declares inputs or outputs gives a plain schema; if any step does, a
# step without them is left unset (NA), leaving the mapping incomplete.
rebuild_schema <- function(raw, path) {
  io_fields <- c("inputs", "outputs")
  mapped <- any(purrr::map_lgl(raw$nodes, function(n) any(io_fields %in% names(n))))

  nodes <- purrr::map(raw$nodes, function(node) {
    scalar_fields <- setdiff(names(node), io_fields)
    row <- tibble::as_tibble(lapply(node[scalar_fields], function(x) {
      if (length(x) == 0) NA_character_ else as.character(x[[1]])
    }))
    if (mapped) {
      for (col in io_fields) {
        # A missing field and `inputs: null` both arrive as NULL, which as_io()
        # turns into NA (not given). `[]` arrives as an empty list.
        row[[col]] <- list(as_io(node[[col]]))
      }
    }
    row
  })

  ref <- raw$meta$data
  if (is.character(ref)) ref <- list(source = ref)
  if (!is.null(ref$source)) {
    ref <- list(source = source_from_file(ref$source, path), object = ref$object, columns = NULL)
  } else {
    ref <- NULL
  }

  nodes <- if (length(nodes) == 0) {
    tibble::tibble(
      id = character(), objective = character(), decision = character(),
      rationale = character()
    )
  } else {
    dplyr::bind_rows(nodes)
  }
  new_schema(name = raw$meta$name, nodes = nodes, data = ref)
}
