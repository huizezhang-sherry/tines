#' Construct schemas and multiverses
#'
#' Construct individual analytical paths (`schema`) and bundle them into a
#' garden of forking paths (`multiverse`).
#'
#' @param nodes A data frame (typically a `tibble`) defining the nodes of the schema.
#' @param edges A data frame (typically a `tibble`) defining the edges of the schema.
#' @param name An optional name for the schema.
#' @param ... One or more `schema` objects to be included in the multiverse.
#' @param schemas A single list containing objects of class `schema`. Defaults to an empty list.
#' @param object A `schema` object.
#' @param tag,type,action,decision,justification character strings to write a block - NOT SURE ABOUT THE DESIGN YET
#' @param feeds,uses,solves,prompts Character vectors to describe the relationship between blocks - NOT SURE ABOUT THE DESIGN YET
#' @return
#' * `build_schema()` and `new_schema()` return an object of class `schema`.
#' * `build_multiverse()` and `new_multiverse()` return an object of class `c("multiverse", "list")`.
#'
#' @rdname constructor
#' @export
#'
#' @examples
#' schema <- build_schema("HDI Example") |>
#'   # 1. The Scaling Block
#'   add_block(tag = "block-scaling",
#'             type = "constraint",
#'             action = "variables are in different scales",
#'             decision = "apply min-max scaling to each variable",
#'             justification = "to put them on the same scale for combination",
#'             solves = "block-combine",       # Motivation comes from the end
#'             feeds = "block-education") |>
#'   # 2. The Education Block
#'   add_block(tag = "block-education",
#'             type = "step",
#'             action = "combine the school variables into one dimension",
#'             decision = "average exp sch and avg sch",
#'             justification = "the most intuitive way",
#'             feeds = "block-combine") |>
#'   # 3. The Combine Block
#'   add_block(tag = "block-combine",
#'             type = "step",
#'             action = "combine the three dimensions into a single index",
#'             decision = "use the geometric mean",
#'             justification = "the geometric mean is more appropriate than arithmetic mean")
#'
#' str(schema)
#'
#' schema2 <- build_schema("HDI Example") |>
#'   # 1. The Education Block
#'   add_block(tag = "block-education",
#'             type = "step",
#'             action = "combine the school variables into one dimension",
#'             decision = "average exp sch and avg sch",
#'             justification = "the most intuitive way",
#'             feeds = "block-scaling") |>
#'   # 2. The Scaling Block
#'   add_block(tag = "block-scaling",
#'             type = "constraint",
#'             action = "variables are in different scales",
#'             decision = "apply min-max scaling to each variable",
#'             justification = "to put them on the same scale for combination",
#'             solves = "block-combine",       # Motivation comes from the end
#'             feeds = "block-combine") |>
#'   # 3. The Combine Block
#'   add_block(tag = "block-combine",
#'             type = "step",
#'             action = "combine the three dimensions into a single index",
#'             decision = "use the geometric mean",
#'             justification = "the geometric mean is more appropriate than arithmetic mean")
#'
#' my_multiverse <- build_multiverse(original = schema, reversed = schema2)
#' str(my_multiverse)
new_schema <- function(name = NULL, nodes = tibble(), edges = tibble()) {
  stopifnot(is.data.frame(nodes))
  stopifnot(is.data.frame(edges))

  res <- structure(list(nodes = nodes, edges = edges), class = "schema")
  attr(res, "name") <- name
  return(res)
}

#' @rdname constructor
#' @export
build_schema <- function(name = NULL) {
  nodes <- tibble(
    action = character(), type = character(),
    decision = character(), justification = character(),
    tag = character(), status = character()
  )
  edges <- tibble(from = character(), to = character(), type = character())

  new_schema(name, nodes, edges)
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

  # 2. Auto-naming: If the user didn't name them, try to find tags
  if (is.null(names(schemas))) {
    names(schemas) <- vapply(schemas, function(s) {
      # Grab the tag of the last node as a default name
      # Ensuring we handle empty nodes gracefully
      tag <- s$nodes$tag[nrow(s$nodes)]
      if (length(tag) == 0 || is.na(tag)) "unnamed_path" else tag
    }, FUN.VALUE = character(1))
  }

  new_multiverse(schemas)
}

########################################################################
########################################################################
#' @rdname constructor
#' @export
add_block <- function(object, tag, action = "", type = "STEP",
                      decision = "", justification = "",
                      feeds = NULL, uses = NULL, prompts = NULL, solves = NULL) {

  if (!inherits(object, "schema")) cli::cli_abort("object must be of class {.cls schema}")
  if (tag %in% object$nodes$tag) cli::cli_abort("Tag {.val {tag}} already exists!")


  new_node <- tibble::tibble(
    tag = tag, action = action, type = type,
    decision = decision, justification = justification,
    status = "VERIFIED"
  )
  object$nodes <- rbind(object$nodes, new_node)

  # TODO add tag if not there

  if (!is.null(feeds))   object <- add_dependency(object, feeds(from = tag, to = feeds))
  if (!is.null(uses))    object <- add_dependency(object, uses(to = tag, from = uses))
  if (!is.null(prompts)) object <- add_dependency(object, prompts(from = tag, to = prompts))
  if (!is.null(solves))  object <- add_dependency(object, solves(to = tag, from = solves))

  return(object)
}

feeds   <- function(from, to) list(from = from, to = to, type = "sequential")
uses    <- function(to, from) list(from = from, to = to, type = "sequential")
prompts <- function(from, to) list(from = from, to = to, type = "motivated")
solves  <- function(to, from) list(from = from, to = to, type = "motivated")

#' @rdname constructor
#' @export
add_dependency <- function(object, ...) {
  if (!inherits(object, "schema")) cli::cli_abort("object must be of class {.cls schema}")

  edges_input <- list(...)

  new_edges <- purrr::map_df(edges_input, function(ed) {
    expand.grid(from = ed$from, to = ed$to, type = ed$type,
                stringsAsFactors = FALSE) |> tibble::as_tibble()
  })

  # Validation: Check if all mentioned tags actually exist in the nodes table
  all_tags <- object$nodes$tag
  involved_tags <- unique(c(new_edges$from, new_edges$to))
  missing_tags <- setdiff(involved_tags, all_tags)

  object$edges <- rbind(object$edges, new_edges) |> unique()

  return(object)
}
