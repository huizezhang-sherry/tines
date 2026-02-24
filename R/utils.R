#' Generate example tines objects
#'
#' @description
#' These functions generate pre-populated `schema` and `multiverse` objects.
#' They are primarily designed for testing, running examples in the documentation,
#' and helping new users explore the `tines` package without having to build a
#' garden of forking paths from scratch.
#'
#' * `example_schema()` returns a single, validated `schema` object containing
#'   a standard set of nodes (steps and constraints) and edges.
#' * `example_multiverse()` returns a validated `multiverse` object containing
#'   multiple variations of the example schema.
#'
#' @return
#' * For `example_schema()`: An object of class `schema`.
#' * For `example_multiverse()`: An object of class `multiverse`.
#'
#' @rdname example_tines
#' @export
#'
#' @examples
#' # Generate a single example schema
#' my_schema <- example_schema()
#' print(my_schema)
#'
#' # Generate an example multiverse containing multiple paths
#' my_multi <- example_multiverse()
#' print(my_multi)
#'
example_schema <- function(){
  schema <- build_schema("HDI Example") |>
    add_block(tag = "block-scaling",
              type = "constraint",
              action = "variables are in different scales",
              decision = "apply min-max scaling to each variable",
              justification = "to put them on the same scale for combination",
              solves = "block-combine",
              feeds = "block-education") |>
    add_block(tag = "block-education",
              type = "step",
              action = "combine the school variables into one dimension",
              decision = "average exp sch and avg sch",
              justification = "the most intuitive way",
              feeds = "block-combine") |>
    add_block(tag = "block-combine",
              type = "step",
              action = "combine the three dimensions into a single index",
              decision = "use the geometric mean",
              justification = "the geometric mean is more appropriate than arithmetic mean")
  return(schema)
}

#' @rdname example_tines
#' @export
example_multiverse <- function(){
  schema <- example_schema()
  schema2 <- build_schema("HDI Example") |>
    add_block(tag = "block-education",
              type = "step",
              action = "combine the school variables into one dimension",
              decision = "average exp sch and avg sch",
              justification = "the most intuitive way",
              feeds = "block-scaling") |>
    add_block(tag = "block-scaling",
              type = "constraint",
              action = "variables are in different scales",
              decision = "apply min-max scaling to each variable",
              justification = "to put them on the same scale for combination",
              solves = "block-combine",
              feeds = "block-combine") |>
    add_block(tag = "block-combine",
              type = "step",
              action = "combine the three dimensions into a single index",
              decision = "use the geometric mean",
              justification = "the geometric mean is more appropriate than arithmetic mean")

  my_multiverse <- build_multiverse(original = schema, reversed = schema2)
  return(my_multiverse)
}

#' Functions to access components of a tine object
#' @param object A `schema` or `multiverse` object.
#' @export
#' @rdname get
#' @examples
#' get_block_names(example_schema())
#' get_block_names(example_multiverse())
get_block_names <- function(object){
  if (inherits(object, "schema")) {
    block_names <- object$nodes$tag
  } else if (inherits(object, "multiverse")) {
    block_names <- lapply(object, function(s) s$nodes$tag)
  } else {
    cli::cli_abort(c(
      "Unsupported object type: {.cls {class(object)}}.",
      "i" = "Expected an object of class {.cls schema} or {.cls multiverse}."
    ))
  }
  return(block_names)
}
