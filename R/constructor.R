#' Construct a schema
#'
#' A schema records one analysis as an ordered sequence of decisions.
#' [build_schema()] starts an empty one and [add_step()] appends a decision to
#' it; [as_schema()] coerces an existing table of steps; [new_schema()] is the
#' low-level constructor the others are built on.
#'
#' @param nodes A data frame (typically a `tibble`) defining the steps of the
#'   schema.
#' @param name An optional name for the schema.
#' @param object A `schema` object.
#' @param id,objective,decision,rationale Character strings describing the
#'   step.
#' @param inputs,outputs Optional character vectors naming the variables the
#'   step reads and creates (`character(0)` for none). A schema is mapped
#'   once every step has both; until then the mapping is incomplete and not
#'   used. See [update_io()].
#' @param x An object to be coerced into a `schema`.
#' @param ... Passed on to methods.
#' @param row.names NULL or a character vector giving the row names for the
#'   data frame.
#' @param optional logical. If TRUE, setting row names and converting column
#'   names is optional.
#' @param width Width for printing output.
#' @return An object of class `schema`: a tibble with one row per step.
#'
#' @seealso [as_multiverse()] to collect several schemas together, and
#'   [expand_tines()] to expand one into a multiverse.
#' @rdname schema-constructor
#' @export
#'
#' @examples
#' schema <- build_schema("HDI Example") |>
#'   add_step(
#'     id = "step-scaling",
#'     objective = "variables are in different scales",
#'     decision = "apply min-max scaling to each variable",
#'     rationale = "to put them on the same scale for combination"
#'   ) |>
#'   add_step(
#'     id = "step-combine",
#'     objective = "combine the three dimensions into a single index",
#'     decision = "use the geometric mean",
#'     rationale = "the geometric mean penalizes uneven development"
#'   )
#'
#' schema
#'
#' # coerce a table of steps that was catalogued elsewhere
#' as_schema(data.frame(
#'   id = "step-clean", objective = "handle missing values",
#'   decision = "drop incomplete cases", rationale = "keeps it simple"
#' ))
#'
new_schema <- function(name = NULL, nodes = tibble::tibble(), data = NULL) {
  stopifnot(is.data.frame(nodes))
  res <- nodes
  class(res) <- c("schema", "tbl_df", "tbl", "data.frame")
  attr(res, "name") <- name
  attr(res, "data") <- data
  res
}

#' @param data Optional. The data the schema runs on -- a file path, a
#'   `"package::dataset"` string, an R script that builds the data, or a data
#'   frame. See [update_data()].
#' @rdname schema-constructor
#' @export
build_schema <- function(name = NULL, data = NULL) {
  nodes <- tibble::tibble(
    id = character(), objective = character(), decision = character(),
    rationale = character()
  )
  ref <- if (!is.null(data)) data_ref(data) else NULL
  new_schema(name = name, nodes = nodes, data = ref)
}


#' Construct a multiverse
#'
#' A multiverse is a collection of related schemas. It is never authored from
#' scratch: [as_multiverse()] collects schemas you already have, and
#' [expand_tines()] derives one from a schema and an alternatives file.
#' [new_multiverse()] is the low-level constructor.
#'
#' Branches follow list conventions -- they may be named or not, exactly as
#' the list you pass in leaves them.
#'
#' @param schemas A list of `schema` objects.
#' @param x A `schema`, a `multiverse`, or a list of either to be coerced.
#' @param ... Passed on to methods.
#' @return An object of class `c("multiverse", "list")`.
#'
#' @seealso [build_schema()] to make the schemas in the first place.
#' @rdname multiverse-constructor
#' @export
#'
#' @examples
#' s1 <- example_hdi()
#' s2 <- example_football_grp5()
#'
#' as_multiverse(list(hdi = s1, football = s2))
#'
#' # names are optional, as in any list
#' as_multiverse(list(s1, s2))
#'
new_multiverse <- function(schemas = list()) {
  stopifnot(is.list(schemas))

  is_valid <- vapply(schemas, inherits, "schema", FUN.VALUE = logical(1))

  if (!all(is_valid) && length(schemas) > 0) {
    invalid_idx <- which(!is_valid)
    cli::cli_abort(c(
      "All elements in a multiverse must be of class {.cls schema}.",
      "i" = "Arguments at positions {invalid_idx} are invalid."
    ))
  }

  structure(
    schemas,
    class = c("multiverse", "list")
  )
}

########################################################################
########################################################################
#' @rdname schema-constructor
#' @export
add_step <- function(object, id, objective = "", decision = "",
                     rationale = "", inputs = NULL, outputs = NULL, ...) {
  if (!inherits(object, "schema")) {
    cli::cli_abort("object must be of class {.cls schema}")
  }
  if (id %in% object$id) cli::cli_abort("Id {.val {id}} already exists!")

  new_node <- tibble::tibble(
    id = id, objective = objective, decision = decision, rationale = rationale
  )

  # Giving inputs or outputs adds them to the schema; a step added without
  # them to a schema that has them is left unset (NA), which leaves the
  # mapping incomplete until the step is given them.
  if (!is.null(inputs) || !is.null(outputs)) object <- add_io_columns(object)
  if (has_io(object)) {
    new_node$inputs <- list(as_io(inputs))
    new_node$outputs <- list(as_io(outputs))
  }

  # A schema composed with the internal import_step() carries a
  # `source_schema` provenance column; keep its shape so bind_rows() lines the
  # new step up against it rather than widening every other row.
  if ("source_schema" %in% names(object)) new_node$source_schema <- NA_character_

  baseline <- schema_issues(object)
  keep <- schema_attrs(object)

  # bind_rows() rather than rbind(): a schema read from a file carries only
  # the fields its YAML declared, so its columns need not line up with the
  # new step's. rbind() failed outright on any file-read schema.
  object <- restore_schema(dplyr::bind_rows(object, new_node), keep)

  check_schema(object, baseline = baseline)
}

#' @export
#' @rdname schema-constructor
as_schema <- function(x, ...) UseMethod("as_schema")

#' @export
#' @rdname schema-constructor
as_schema.default <- function(x, ...) {
  cli::cli_abort(
    "Cannot coerce an object of class {.cls {class(x)}} to a {.cls schema}."
  )
}

#' @rdname schema-constructor
#' @export
as_schema.schema <- function(x, ...) x

#' @rdname schema-constructor
#' @export
as_schema.data.frame <- function(x, name = NULL, ...) {
  required <- c("id", "objective", "decision", "rationale")
  missing_cols <- setdiff(required, names(x))
  if (length(missing_cols) > 0) {
    cli::cli_abort(c(
      "Cannot coerce to a {.cls schema}: column{?s} {.field {missing_cols}} {?is/are} missing.",
      "i" = "A schema needs one row per step, with columns {.field {required}}."
    ))
  }
  nodes <- tibble::as_tibble(x)
  # One of the two columns alone gives the other, unset
  if (any(c("inputs", "outputs") %in% names(nodes))) {
    for (col in c("inputs", "outputs")) {
      nodes[[col]] <- if (col %in% names(nodes)) {
        lapply(as.list(nodes[[col]]), as_io)
      } else {
        rep(list(NA_character_), nrow(nodes))
      }
    }
  }
  check_schema(new_schema(name = name, nodes = nodes))
}

#' @rdname multiverse-constructor
#' @export
as_multiverse <- function(x, ...) {
  UseMethod("as_multiverse")
}

#' @rdname multiverse-constructor
#' @export
as_multiverse.default <- function(x, ...) {
  cli::cli_abort(
    paste0(
      "Cannot coerce an object of class {.cls {class(x)}} to a ",
      "{.cls multiverse}."
    )
  )
}

#' @rdname multiverse-constructor
#' @export
as_multiverse.multiverse <- function(x, ...) {
  x
}

#' @rdname multiverse-constructor
#' @export
as_multiverse.schema <- function(x, ...) {
  # A single schema gracefully becomes a 1-branch multiverse
  new_multiverse(list(x))
}

#' @rdname multiverse-constructor
#' @export
as_multiverse.list <- function(x, ...) {
  # Flatten a mixed list of schemas, multiverses, and nested lists, carrying
  # names through: a name given here labels the branch, and a nested
  # multiverse keeps the names its own branches already had.
  flat_list <- list()
  labels <- character()
  outer <- names(x)
  if (is.null(outer)) outer <- rep("", length(x))

  for (i in seq_along(x)) {
    item <- x[[i]]
    if (inherits(item, "schema")) {
      flat_list <- c(flat_list, list(item))
      labels <- c(labels, outer[i])
    } else if (inherits(item, "multiverse") || is.list(item)) {
      inner <- unclass(if (inherits(item, "multiverse")) item else as_multiverse(item))
      inner_names <- names(inner)
      if (is.null(inner_names)) inner_names <- rep("", length(inner))
      flat_list <- c(flat_list, inner)
      labels <- c(labels, inner_names)
    } else {
      cli::cli_abort(
        "List contains items that cannot be coerced into the multiverse."
      )
    }
  }

  # A multiverse is a list, so it follows list conventions: branches may be
  # named or not, exactly as the caller left them. gen_code() supplies a
  # positional fallback where it needs a file name.
  if (any(nzchar(labels))) names(flat_list) <- labels
  new_multiverse(flat_list)
}


#' @importFrom pillar tbl_sum
#' @export
tbl_sum.schema <- function(x) {
  name <- attr(x, "name", exact = TRUE)
  head <- if (!is.null(name)) {
    c("A schema" = name)
  } else {
    c("A schema" = paste(nrow(x), "x", ncol(x)))
  }
  ref <- attr(x, "data", exact = TRUE)
  if (!is.null(ref)) {
    head <- c(head, "Data" = ref$source %||% "a data frame (not written to file)")
  }
  missing <- unmapped_steps(x)
  if (length(missing) > 0) {
    head <- c(head, "Mapping" = sprintf(
      "incomplete (%d of %d steps have inputs/outputs)", nrow(x) - length(missing), nrow(x)
    ))
  }
  head
}

#' @export
#' @rdname schema-constructor
as.data.frame.schema <- function(x, row.names = NULL, optional = FALSE, ...) {
  class(x) <- "data.frame"
  x
}

#' @export
#' @rdname schema-constructor
print.schema <- function(x, width = NULL, ...) {
  writeLines(format(x, width = width, ...))
}

#' @export
print.multiverse <- function(x, ...) {
  n_schemas <- length(x)

  if (n_schemas == 0) {
    cat("An empty multiverse\n")
    return(invisible(x))
  }

  cat(sprintf(
    "A multiverse with %d schema%s:\n",
    n_schemas, if (n_schemas > 1) "s" else ""
  ))

  schema_names <- names(x)
  if (is.null(schema_names)) {
    schema_names <- paste0("[[", seq_along(x), "]]")
  }

  for (i in seq_along(x)) {
    schema <- x[[i]]
    name <- attr(schema, "name", exact = TRUE)
    n_steps <- nrow(schema)

    cat(sprintf("  %s: ", schema_names[i]))

    if (!is.null(name)) {
      cat(sprintf('"%s" ', name))
    }

    cat(sprintf("(%d step%s)\n", n_steps, if (n_steps != 1) "s" else ""))
  }

  invisible(x)
}
