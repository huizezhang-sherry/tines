#' Construct `schema` and `multiverse` objects
#'
#' Construct individual analytical paths (`schema`) and bundle them into a
#' garden of forking paths (`multiverse`).
#'
#' @param nodes A data frame (typically a `tibble`) defining the steps of the schema.
#' @param name An optional name for the schema.
#' @param ... One or more `schema` objects to be included in the multiverse.
#' @param schema,schemas A single list containing objects of class `schema`. Defaults to an empty list.
#' @param object A `schema` object.
#' @param id,fork,path,rationale,inputs,outputs,source_schema character strings to write a step
#' @param x An object to be coerced into a `schema` or `multiverse`.
#' @param row.names NULL or a character vector giving the row names for the data frame.
#' @param optional logical. If TRUE, setting row names and converting column names is optional.
#' @param width Width for printing output.
#' @return
#' * `build_schema()` and `new_schema()` return an object of class `schema`.
#' * `build_multiverse()` and `new_multiverse()` return an object of class `c("multiverse", "list")`.
#'
#' @rdname constructor
#' @export
#'
#' @examples
#' schema <- build_schema("HDI Example") |>
#'   # 1. The Scaling step
#'   add_step(id = "step-scaling",
#'             fork = "variables are in different scales",
#'             path = "apply min-max scaling to each variable",
#'             rationale = "to put them on the same scale for combination") |>
#'   # 2. The Education step
#'   add_step(id = "step-education",
#'             fork = "combine the school variables into one dimension",
#'             path = "average exp sch and avg sch",
#'             rationale = "the most intuitive way") |>
#'   # 3. The Combine step
#'   add_step(id = "step-combine",
#'             fork = "combine the three dimensions into a single index",
#'             path = "use the geometric mean",
#'             rationale = "the geometric mean is more appropriate than arithmetic mean")
#'
#' schema
#'
#' schema2 <- build_schema("HDI Example") |>
#'   # 1. The Education Step
#'   add_step(id = "step-education",
#'             fork = "combine the school variables into one dimension",
#'             path = "average exp sch and avg sch",
#'             rationale = "the most intuitive way") |>
#'   # 2. The Scaling Step
#'   add_step(id = "step-scaling",
#'             fork = "variables are in different scales",
#'             path = "apply min-max scaling to each variable",
#'             rationale = "to put them on the same scale for combination") |>
#'   # 3. The Combine Step
#'   add_step(id = "step-combine",
#'             fork = "combine the three dimensions into a single index",
#'             path = "use the geometric mean",
#'             rationale = "the geometric mean is more appropriate than arithmetic mean")
#'
#' my_multiverse <- build_multiverse(original = schema, reversed = schema2)
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
    id = character(), fork = character(), path = character(), rationale = character(),
    inputs = list(), outputs = list(), source_schema = character()
  )
  schema <- new_schema(name = name, nodes = nodes)
  
  # Attach data if provided
  if (!is.null(data)) {
    # Load data if path
    data_obj <- if (is.character(data) && length(data) == 1 && file.exists(data)) {
      load_data_file(data)
    } else if (is.data.frame(data)) {
      data
    } else {
      cli::cli_abort("{.arg data} must be a data frame or path to a data file")
    }
    
    data_source <- if (is.character(data)) data else deparse(substitute(data))
    
    # Attach data reference
    attr(schema, "data_ref") <- list(
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

#' @rdname constructor
#' @export
build_multiverse <- function(...) {
  schemas <- list(...)

  # Return an empty multiverse if no schemas are provided
  if (length(schemas) == 0) {
    return(new_multiverse(list()))
  }

  # 2. Auto-naming: If the user didn't name them, try to find ids
  if (is.null(names(schemas))) {
    names(schemas) <- vapply(schemas, function(s) {
      # Use the id of the last row as a default name
      id <- if (nrow(s) > 0) s$id[nrow(s)] else NA_character_
      if (is.na(id) || length(id) == 0) "unnamed_path" else id
    }, FUN.VALUE = character(1))
  }

  new_multiverse(schemas)
}

########################################################################
########################################################################
#' @rdname constructor
#' @export
add_step <- function(object, id, fork = "", path = "", 
                     rationale = "", inputs = NULL, outputs = NULL, 
                     source_schema = NA, ...) {

  if (!inherits(object, "schema")) cli::cli_abort("object must be of class {.cls schema}")
  if (id %in% object$id) cli::cli_abort("Id {.val {id}} already exists!")

  # Allow inputs/outputs to be NULL (unmapped), character vector, or NA
  inputs_val <- if (is.null(inputs)) list(NA) else list(inputs)
  outputs_val <- if (is.null(outputs)) list(NA) else list(outputs)

  new_node <- tibble::tibble(
    id = id, fork = fork, path = path, rationale = rationale,
    inputs = inputs_val, outputs = outputs_val, source_schema = source_schema
  )
  object <- rbind(object, new_node)
  class(object) <- c("schema", "tbl_df", "tbl", "data.frame")
  attr(object, "name") <- attr(object, "name", exact = TRUE)
  
  # Validate if data is attached
  if (has_data_ref(object)) {
    data_dict <- attr(object, "data_ref")$dict
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
  cli::cli_abort("Cannot coerce an object of class {.cls {class(x)}} to a {.cls schema}.")
}

#' @rdname constructor
#' @export
as_schema.schema <- function(x, ...) x

#' @rdname constructor
#' @export
as_schema.list <- function(x, ...) {
  # Accept a list that is a data frame (for legacy support)
  if (is.data.frame(x)) {
    class(x) <- "schema"
    return(x)
  }
  cli::cli_abort("Cannot coerce list to {.cls schema}. Only a data frame is allowed for schema.")
}

#' @rdname constructor
#' @export
as_schema.character <- function(x, ...) {
  if (length(x) == 1 && file.exists(x)) {
    raw_df <- yaml::read_yaml(x)
    # Try to coerce to tibble/data.frame if possible
    df <- tibble::as_tibble(raw_df)
    class(df) <- "schema"
    return(df)
  }
  cli::cli_abort("Character string must be a valid file path to a YAML schema.")
}

#' @rdname constructor
#' @export
as_multiverse <- function(x, ...) {
  UseMethod("as_multiverse")
}

#' @rdname constructor
#' @export
as_multiverse.default <- function(x, ...) {
  cli::cli_abort("Cannot coerce an object of class {.cls {class(x)}} to a {.cls multiverse}.")
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
  # The Workhorse: Flatten a mixed list of schemas, multiverses, and nested lists
  flat_list <- list()

  for (item in x) {
    if (inherits(item, "schema")) {
      flat_list <- append(flat_list, list(item))
    } else if (inherits(item, "multiverse")) {
      # Strip the class to extract the raw list of schemas, then append
      flat_list <- append(flat_list, unclass(item))
    } else if (is.list(item)) {
      # Recursively flatten nested lists
      flat_list <- append(flat_list, unclass(as_multiverse(item)))
    } else {
      cli::cli_abort("List contains items that cannot be coerced into the multiverse.")
    }
  }

  new_multiverse(flat_list)
}


#' @export
#' @rdname constructor
c.schema <- function(...) {
  # Capture all arguments as a list, then coerce to a flattened multiverse
  as_multiverse(list(...))
}

#' @rdname constructor
#' @export
c.multiverse <- function(...) {
  as_multiverse(list(...))
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
print.schema <- function(x, width = NULL, ...){
  writeLines(format(x, width = width, ...))
}

#' @export
print.multiverse <- function(x, ...) {
  n_schemas <- length(x)
  
  if (n_schemas == 0) {
    cat("An empty multiverse\n")
    return(invisible(x))
  }
  
  cat(sprintf("A multiverse with %d schema%s:\n", 
              n_schemas, if (n_schemas > 1) "s" else ""))
  
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