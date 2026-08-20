#' Construct `alternatives` objects
#'
#' @param id Unique identifier for this alternative (kebab-case).
#' @param objective The decision point or goal of the step (should match the
#'   original).
#' @param decision The new method/implementation.
#' @param rationale Why this method is valid.
#' @param step The target step ID in the schema that these alternatives
#'   pertain to.
#' @param ... One or more alternative branches created by `alternative()`.
#'
#' @export
#' @rdname alternatives
#' @examples
#' example_alternatives(case = "football")
#'
alternative <- function(id, objective, decision, rationale) {
  # Quick validation to ensure no missing pieces
  if (missing(id) || missing(objective) || missing(decision) || missing(rationale)) {
    cli::cli_abort(
      "All arguments (`id`, `objective`, `decision`, `rationale`) are required."
    )
  }

  list(
    id = id,
    objective = objective,
    decision = decision,
    rationale = rationale
  )
}

#' @export
#' @rdname alternatives
new_alternatives <- function(step, ...) {
  alts <- list(...)

  # Convert to data frame structure (no step column needed)
  df <- purrr::map_dfr(alts, function(alt) {
    tibble::tibble(
      id = alt$id,
      objective = alt$objective,
      decision = alt$decision,
      rationale = alt$rationale
    )
  })

  class(df) <- c("alternatives", "tbl_df", "tbl", "data.frame")
  attr(df, "step") <- step

  return(df)
}


#' Read and write  an alternatives object from/to a YML file
#'
#' @param x A `alternatives` object.
#' @param file A character string specifying the file path.
#' @param ... Additional arguments passed to `yaml::read_yaml()`.
#'
#' @rdname read-write-alternatives
#' @export
#' @examples
#' \dontrun{
#' alts <- example_alternatives()
#' temp_path <- withr::local_tempfile(fileext = ".yml")
#' write_alternatives(alts, temp_path)
#' alts_read <- read_alternatives(temp_path)
#'
#' identical(alts, alts_read)
#' }
#'
write_alternatives <- function(x, file, ...) {
  # Convert data frame rows to list format for YML
  alternatives_list <- purrr::pmap(
    x[c("id", "objective", "decision", "rationale")],
    function(...) list(...)
  )

  yaml_ready_list <- list(
    meta = list(
      type = "alternatives",
      step = attr(x, "step")
    ),
    alternatives = alternatives_list
  )

  yaml::write_yaml(yaml_ready_list, file, ...)
  cli::cli_alert_success("Successfully wrote alternatives to {.file {file}}")
  invisible(file)
}

#' @rdname read-write-alternatives
#' @export
read_alternatives <- function(file, ...) {
  if (!file.exists(file)) {
    cli::cli_abort("File {.file {file}} does not exist.")
  }

  # 1. Read the raw list structure from disk
  raw_yaml <- yaml::read_yaml(file, ...)

  # 2. Extract the target step
  target <- raw_yaml$meta$step
  objective <- raw_yaml$meta$objective

  # 3. Convert to data frame structure
  df <- purrr::map_dfr(raw_yaml$alternatives, function(a) {
    tibble::tibble(
      id = a$id,
      decision = a$decision,
      rationale = a$rationale
    )
  })

  class(df) <- c("alternatives", "tbl_df", "tbl", "data.frame")
  attr(df, "step") <- target

  return(df)
}

#' @export
tbl_sum.alternatives <- function(x) {
  step <- attr(x, "step", exact = TRUE)
  if (!is.null(step)) {
    c("Alternatives" = step)
  } else {
    c("Alternatives" = paste(nrow(x), "x", ncol(x)))
  }
}

#' @export
as.data.frame.alternatives <- function(x, row.names = NULL,
                                       optional = FALSE, ...) {
  class(x) <- "data.frame"
  x
}
