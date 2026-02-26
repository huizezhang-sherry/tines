#' Construct `alternatives` objects
#'
#' @param tag Unique identifier for this alternative (kebab-case).
#' @param action The goal of the step (should match the original).
#' @param decision The new method/implementation.
#' @param justification Why this method is valid.
#' @param block The target block in the schema that these alternatives pertain to.
#' @param ... One or more alternative branches created by `alternative()`.
#'
#' @export
#' @rdname alternatives
#' @examples
#' example_alternatives(case = "football")
#'
alternative <- function(tag, action, decision, justification) {
  # Quick validation to ensure no missing pieces
  if (missing(tag) || missing(action) || missing(decision) || missing(justification)) {
    cli::cli_abort("All arguments (`tag`, `action`, `decision`, `justification`) are required.")
  }

  list(
    tag = tag,
    action = action,
    decision = decision,
    justification = justification
  )
}

#' @export
#' @rdname alternatives
new_alternatives <- function(block, ...) {
  alts <- list(...)

  obj <- structure(alts, class = c("alternatives", "list"))
  attr(obj, "block") <- block

  return(obj)
}


#' Read and write  an alternatives object from/to a YAML file
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
#' temp_path <- withr::local_tempfile(fileext = ".yaml")
#' write_alternatives(alts, temp_path)
#' alts_read <- read_alternatives(temp_path)
#'
#' identical(alts, alts_read)
#' }
#'
write_alternatives <- function(x, file, ...) {

  yaml_ready_list <- list(
    meta = list(
      type = "alternatives",
      block = attr(x, "block")
    ),
    alternatives = unclass(x)
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

  # 2. Extract the target block
  target <- raw_yaml$meta$block

  # 3. Convert the raw list items into validated `alternative()` objects
  parsed_alts <- purrr::map(raw_yaml$alternatives, function(a) {
    alternative(
      tag = a$tag,
      action = a$action,
      decision = a$decision,
      justification = a$justification
    )
  })


  args <- c(list(block = target), parsed_alts)
  do.call(new_alternatives, args)
}
