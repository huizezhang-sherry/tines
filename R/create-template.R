#' Create templates YAML files
#'
#' Generates a starter YAML file for a schema to help you begin building
#' your garden of forking paths. There is no template for a multiverse:
#' a multiverse is always produced either by combining schema objects with
#' [build_multiverse()], or by expanding a schema (or another multiverse)
#' with an alternatives file via [expand_tines()] -- never hand-authored
#' from a blank template.
#'
#' @param file_path The file path where the template should be saved. If NULL,
#'   the template will be saved in the current working directory with a
#'   default name.
#' @param x A `schema` or `multiverse` object, or a character string
#'   specifying the file path to a valid schema YAML file.
#' @param id A character string specifying the `id` of the step in the
#'   schema. For [draft_alternatives()], a vector naming one or more steps --
#'   one node is drafted per step.
#' @param overwrite Logical. If TRUE, will overwrite an existing file at the
#'   specified file_path. Defaults to FALSE.
#' @param branch For [draft_alternatives()] only. Required: either `"multi"`
#'   (drafts 2 placeholder alternatives per node) or `"single"` (drafts
#'   exactly 1 per node). See `vignette("alternatives")` for what the two
#'   modes mean when expanded.
#' @return [draft_tines()] and [draft_alternatives()] both invisibly return
#'   the path they wrote to; each is called primarily for its side effect
#'   of writing a template YAML file to disk.
#' @export
#' @rdname template
#' @examples
#' # Create a new schema template
#' schema_path <- withr::local_tempfile(fileext = ".yml")
#' draft_tines(file_path = schema_path)
#'
#' # Draft alternatives from a schema object
#' my_schema <- example_schema()
#' draft_alternatives(
#'   x = my_schema,
#'   id = "step-scaling",
#'   file_path = withr::local_tempfile(fileext = ".yml"),
#'   branch = "multi"
#' )
#'
#' # `x` also accepts a path to a schema file -- draft a single-branch
#' # template combining two steps together
#' schema_file <- system.file("hdi.yml", package = "tines")
#' draft_alternatives(
#'   x = schema_file,
#'   id = c("step-scaling", "step-education"),
#'   file_path = withr::local_tempfile(fileext = ".yml"),
#'   branch = "single"
#' )
#'
draft_tines <- function(file_path = NULL, overwrite = FALSE) {
  if (is.null(file_path)) {
    file_path <- "schema_template.yml"
  }

  if (file.exists(file_path) & !overwrite) {
    cli::cli_abort(c(
      "File {.file {file_path}} already exists.",
      "i" = paste0(
        "Please choose a different path or delete the existing file first ",
        "or set {.code overwrite = TRUE} to overwrite it."
      )
    ))
  }

  template_data <- list(
    meta = list(type = "schema"),
    nodes = list(
      list(
        id = "step1",
        objective = "describe your first step here",
        decision = "describe your decision here",
        rationale = "explain your reasoning here"
      ),
      list(
        id = "step2",
        objective = "describe your next step here",
        decision = "describe your decision here",
        rationale = "explain your reasoning here"
      )
    )
  )

  yaml::write_yaml(
    template_data,
    file = file_path,
    column.major = FALSE
  )

  cli::cli_alert_success(
    "Drafted {.val schema} template at {.file {file_path}}"
  )
  cli::cli_alert_info("Open this file to start defining your steps!")

  invisible(file_path)
}

#' @export
#' @rdname template
draft_alternatives <- function(x, id, file_path = NULL, branch) {
  if (missing(branch)) {
    cli::cli_abort(
      "{.arg branch} must be specified: either \"single\" or \"multi\"."
    )
  }
  branch <- match.arg(branch, choices = c("multi", "single"))

  if (is.character(x) && length(x) == 1) {
    if (!file.exists(x)) cli::cli_abort("File {.file {x}} does not exist.")
    x <- read_tines(x)
  }

  missing_ids <- setdiff(id, x$id)
  if (length(missing_ids) > 0) {
    cli::cli_abort("Step {.val {missing_ids}} not found in the {class(x)} object")
  }

  node_lines <- function(step_id) {
    alt_ids <- if (branch == "single") {
      paste0("new-alternative-", step_id)
    } else {
      paste0("new-alternative-", 1:2)
    }

    alt_lines <- unlist(lapply(alt_ids, function(alt_id) {
      c(
        paste0("      - id: \"", alt_id, "\""),
        "        decision: \"\"",
        "        rationale: \"\""
      )
    }))

    c(paste0("  - overrides: ", step_id), "    alternatives:", alt_lines)
  }

  lines <- c(
    "meta:",
    "  type: alternatives",
    paste0("  branch: ", branch),
    "nodes:",
    unlist(lapply(id, node_lines))
  )

  if (is.null(file_path)) file_path <- paste0("alt_", paste(id, collapse = "-"), ".yml")
  writeLines(lines, file_path)

  cli::cli_alert_success("Created template at {.file {file_path}}")
  invisible(file_path)
}
