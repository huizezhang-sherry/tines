#' Construct schema and multiverse objects
#'
#' Construct individual analytical paths (`schema`) and bundle them into a
#' garden of forking paths (`multiverse`).
#'
#' @param nodes A data frame (typically a `tibble`) defining the steps of the
#'   schema.
#' @param name An optional name for the schema.
#' @param ... One or more `schema` objects to be included in the multiverse.
#' @param schema,schemas A single list containing objects of class `schema`.
#'   Defaults to an empty list.
#' @param object A `schema` object.
#' @param id,objective,decision,rationale,inputs,outputs character strings
#'   to write a step
#' @param x An object to be coerced into a `schema` or `multiverse`.
#' @param row.names NULL or a character vector giving the row names for the
#'   data frame.
#' @param optional logical. If TRUE, setting row names and converting column
#'   names is optional.
#' @param width Width for printing output.
#' @return
#' * [build_schema()] and [new_schema()] return an object of class `schema`.
#' * [as_multiverse()] and [new_multiverse()] return an object of class
#'   `c("multiverse", "list")`.
#'
#' @rdname constructor
#' @export
#'
#' @examples
#' schema <- build_schema("HDI Example") |>
#'   # 1. The Scaling step
#'   add_step(
#'     id = "step-scaling",
#'     objective = "variables are in different scales",
#'     decision = "apply min-max scaling to each variable",
#'     rationale = "to put them on the same scale for combination"
#'   ) |>
#'   # 2. The Education step
#'   add_step(
#'     id = "step-education",
#'     objective = "combine the school variables into one dimension",
#'     decision = "average exp sch and avg sch",
#'     rationale = "the most intuitive way"
#'   ) |>
#'   # 3. The Combine step
#'   add_step(
#'     id = "step-combine",
#'     objective = "combine the three dimensions into a single index",
#'     decision = "use the geometric mean",
#'     rationale = "the geometric mean is more appropriate than arithmetic mean"
#'   )
#'
#' schema
#'
#' schema2 <- build_schema("HDI Example") |>
#'   # 1. The Education Step
#'   add_step(
#'     id = "step-education",
#'     objective = "combine the school variables into one dimension",
#'     decision = "average exp sch and avg sch",
#'     rationale = "the most intuitive way"
#'   ) |>
#'   # 2. The Scaling Step
#'   add_step(
#'     id = "step-scaling",
#'     objective = "variables are in different scales",
#'     decision = "apply min-max scaling to each variable",
#'     rationale = "to put them on the same scale for combination"
#'   ) |>
#'   # 3. The Combine Step
#'   add_step(
#'     id = "step-combine",
#'     objective = "combine the three dimensions into a single index",
#'     decision = "use the geometric mean",
#'     rationale = "the geometric mean is more appropriate than arithmetic mean"
#'   )
#'
#' my_multiverse <- as_multiverse(list(original = schema, reversed = schema2))
#' my_multiverse
new_schema <- function(name = NULL, nodes = tibble::tibble()) {
  stopifnot(is.data.frame(nodes))
  res <- nodes
  class(res) <- c("schema", "tbl_df", "tbl", "data.frame")
  attr(res, "name") <- name
  res
}

#' @param data Optional data frame or path to data file for validation
#' @rdname constructor
#' @export
build_schema <- function(name = NULL, data = NULL) {
  nodes <- tibble::tibble(
    id = character(), objective = character(), decision = character(),
    rationale = character(), inputs = list(), outputs = list()
  )
  schema <- new_schema(name = name, nodes = nodes)

  # Attach data if provided
  if (!is.null(data)) {
    # Load data if path
    is_path <- is.character(data) && length(data) == 1 && file.exists(data)
    data_obj <- if (is_path) {
      load_data_file(data)
    } else if (is.data.frame(data)) {
      data
    } else {
      cli::cli_abort("{.arg data} must be a data frame or path to a data file")
    }

    data_source <- if (is.character(data)) data else deparse(substitute(data))

    # Attach data reference
    attr(schema, "data") <- list(
      source = data_source,
      hash = digest::digest(data_obj),
      dict = prepare_data_dict(data_obj)
    )

    cli::cli_alert_success("Data attached: {.val {data_source}}")
  }

  schema
}


#' @rdname constructor
#' @export
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
#' @rdname constructor
#' @export
add_step <- function(object, id, objective = "", decision = "",
                     rationale = "", inputs = NULL, outputs = NULL, ...) {
  if (!inherits(object, "schema")) {
    cli::cli_abort("object must be of class {.cls schema}")
  }
  if (id %in% object$id) cli::cli_abort("Id {.val {id}} already exists!")

  # Allow inputs/outputs to be NULL (unmapped), character vector, or NA
  inputs_val <- if (is.null(inputs)) list(NA) else list(inputs)
  outputs_val <- if (is.null(outputs)) list(NA) else list(outputs)

  new_node <- tibble::tibble(
    id = id, objective = objective, decision = decision, rationale = rationale,
    inputs = inputs_val, outputs = outputs_val
  )

  # A schema composed with the internal import_step() carries a
  # `source_schema` provenance column; keep its shape so bind_rows() lines the
  # new step up against it rather than widening every other row.
  if ("source_schema" %in% names(object)) new_node$source_schema <- NA_character_

  # Preserve attributes before binding (bind_rows drops the schema class)
  schema_name <- attr(object, "name", exact = TRUE)
  schema_data <- attr(object, "data", exact = TRUE)

  # bind_rows() rather than rbind(): a schema read from a file carries only
  # the fields its YAML declared, so its columns need not line up with the
  # new step's. rbind() failed outright on any file-read schema.
  object <- dplyr::bind_rows(object, new_node)
  class(object) <- c("schema", "tbl_df", "tbl", "data.frame")

  # Restore attributes
  attr(object, "name") <- schema_name
  if (!is.null(schema_data)) {
    attr(object, "data") <- schema_data
  }

  # Validate if data is attached
  if (has_data(object)) {
    data_dict <- attr(object, "data")$dict
    step_idx <- nrow(object)
    validate_step_variables(object, step_idx, data_dict)
  }

  object
}

#' @export
#' @rdname constructor
as_schema <- function(x, ...) UseMethod("as_schema")

#' @export
#' @rdname constructor
as_schema.default <- function(x, ...) {
  cli::cli_abort(
    "Cannot coerce an object of class {.cls {class(x)}} to a {.cls schema}."
  )
}

#' @rdname constructor
#' @export
as_schema.schema <- function(x, ...) x

#' @rdname constructor
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
  new_schema(name = name, nodes = tibble::as_tibble(x))
}

#' @rdname constructor
#' @export
as_multiverse <- function(x, ...) {
  UseMethod("as_multiverse")
}

#' @rdname constructor
#' @export
as_multiverse.default <- function(x, ...) {
  cli::cli_abort(
    paste0(
      "Cannot coerce an object of class {.cls {class(x)}} to a ",
      "{.cls multiverse}."
    )
  )
}

#' @rdname constructor
#' @export
as_multiverse.multiverse <- function(x, ...) {
  x
}

#' @rdname constructor
#' @export
as_multiverse.schema <- function(x, ...) {
  # A single schema gracefully becomes a 1-branch multiverse
  new_multiverse(list(x))
}

#' @rdname constructor
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
  if (!is.null(name)) {
    c("A schema" = name)
  } else {
    c("A schema" = paste(nrow(x), "x", ncol(x)))
  }
}

#' @export
#' @rdname constructor
as.data.frame.schema <- function(x, row.names = NULL, optional = FALSE, ...) {
  class(x) <- "data.frame"
  x
}

#' @export
#' @rdname constructor
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
