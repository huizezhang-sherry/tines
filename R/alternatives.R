#' Construct `alternatives` objects
#'
#' @param id Unique identifier for this alternative (kebab-case).
#' @param action The goal of the step (should match the original).
#' @param decision The new method/implementation.
#' @param justification Why this method is valid.
#' @param step The target step ID in the schema that these alternatives pertain to.
#' @param ... One or more alternative branches created by `alternative()`.
#'
#' @export
#' @rdname alternatives
#' @examples
#' example_alternatives(case = "football")
#'
alternative <- function(id, action, decision, justification) {
  # Quick validation to ensure no missing pieces
  if (missing(id) || missing(action) || missing(decision) || missing(justification)) {
    cli::cli_abort("All arguments (`id`, `action`, `decision`, `justification`) are required.")
  }

  list(
    id = id,
    action = action,
    decision = decision,
    justification = justification
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
      action = alt$action, 
      decision = alt$decision,
      justification = alt$justification
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
  alternatives_list <- purrr::pmap(x[c("id", "action", "decision", "justification")], function(...) {
    list(...)
  })
  
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
  fork <- raw_yaml$meta$fork

  # 3. Convert to data frame structure
  df <- purrr::map_dfr(raw_yaml$alternatives, function(a) {
    tibble::tibble(
      id = a$id,
      path = a$path,
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
as.data.frame.alternatives <- function(x, row.names = NULL, optional = FALSE, ...) {
  class(x) <- "data.frame"
  x
}
