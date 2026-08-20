#' Import a Step from a source schema into the current schema
#'
#' @param schema The current schema being built.
#' @param source_schema The schema to import the step from.
#' @param id The id of the step to import.
#' @param source_schema_name Optional. A string to use as the provenance key,
#'   matched against `base_scripts` in `gen_composite_code()`. Defaults to
#'   the deparsed name of `source_schema`.
#' @param ... Optional field overrides (e.g. `inputs = c(".new_var")`).
#' @return The updated schema with the imported step appended.
#' @export
#' @rdname import
import_step <- function(schema, source_schema, id,
                        source_schema_name = NULL, ...) {
  to_import <- source_schema$nodes |>
    dplyr::filter(id == !!id)

  if (nrow(to_import) == 0) {
    stop(sprintf("Could not find step with id '%s' in the source schema.", id))
  }
  if (nrow(to_import) > 1) {
    warning(sprintf("Multiple steps found with id '%s'. Using the first.", id))
    to_import <- to_import |> dplyr::slice(1)
  }

  # Provenance: use explicit name if provided, otherwise deparse the argument
  to_import$source_schema <- source_schema_name %||%
    deparse(substitute(source_schema))

  new_args <- list(...)
  for (arg_name in names(new_args)) {
    if (is.list(to_import[[arg_name]])) {
      to_import[[arg_name]] <- list(new_args[[arg_name]])
    } else {
      to_import[[arg_name]] <- new_args[[arg_name]]
    }
  }

  if (is.null(schema$nodes) || nrow(schema$nodes) == 0) {
    schema$nodes <- to_import
  } else {
    schema$nodes <- dplyr::bind_rows(schema$nodes, to_import)
  }

  schema
}

#' Generate edges from a schema based on input/output variable matching
#'
#' @param schema A schema object with nodes containing `inputs` and `outputs`
#'   list-columns.
#' @return The schema with `edges` populated.
#' @export
#' @rdname import
generate_edges <- function(schema) {
  edges <- data.frame(
    from = character(), to = character(),
    stringsAsFactors = FALSE
  )
  var_sources <- list()

  for (i in seq_len(nrow(schema))) {
    current_id <- schema$id[i]
    current_inputs <- unlist(schema$inputs[[i]])

    if (length(current_inputs) > 0) {
      for (inp in current_inputs) {
        if (inp %in% names(var_sources)) {
          edges <- dplyr::bind_rows(edges, data.frame(
            from = var_sources[[inp]], to = current_id,
            stringsAsFactors = FALSE
          ))
        }
      }
    }

    current_outputs <- unlist(schema$outputs[[i]])
    if (length(current_outputs) > 0) {
      for (outp in current_outputs) var_sources[[outp]] <- current_id
    }
  }

  if (nrow(edges) > 0) edges <- dplyr::distinct(edges)
  edges
}
