#' Draft a schema template
#'
#' Writes a starter YAML file with two placeholder steps, ready to fill in by
#' hand. There is no equivalent for a multiverse: a multiverse is always
#' derived, either by collecting schemas with [as_multiverse()] or by
#' expanding one with an alternatives file via [expand_tines()].
#'
#' @param file_path Where to save the template. If `NULL`, it is written to
#'   the working directory as `schema_template.yml`.
#' @param overwrite Logical. If `TRUE`, overwrites an existing file at
#'   `file_path`. Defaults to `FALSE`.
#' @return Invisibly, the path written to; called for its side effect of
#'   writing the file.
#'
#' @seealso [draft_alternatives()] for the alternatives-file equivalent, and
#'   [read_tines()] to read the filled-in template back.
#' @export
#' @rdname draft_tines
#' @examples
#' schema_path <- withr::local_tempfile(fileext = ".yml")
#' draft_tines(file_path = schema_path)
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

#' Draft an alternatives template
#'
#' Writes a starter alternatives YAML file, with one node per step named in
#' `id` and placeholder alternatives inside each, ready to fill in by hand.
#'
#' @param x A `schema` object, or the path to a schema YAML file.
#' @param id The `id` of the step to draft alternatives for; a vector names
#'   several, and one node is drafted per step.
#' @param file_path Where to save the template. If `NULL`, it is written to
#'   the working directory, named after the steps it covers.
#' @param branch Required: either `"multi"` (drafts 2 placeholder
#'   alternatives per node) or `"single"` (drafts exactly 1 per node). See
#'   `vignette("alternatives")` for what the two modes mean when expanded.
#' @return Invisibly, the path written to; called for its side effect of
#'   writing the file.
#'
#' @seealso [gen_alternatives()] to have an LLM propose them instead, and
#'   [read_alternatives()] to read the filled-in file back.
#' @export
#' @rdname draft_alternatives
#' @examples
#' my_schema <- example_hdi()
#'
#' draft_alternatives(
#'   x = my_schema,
#'   id = "step-scaling",
#'   file_path = withr::local_tempfile(fileext = ".yml"),
#'   branch = "multi"
#' )
#'
#' # `x` also accepts a path to a schema file -- draft a single-branch
#' # template combining two steps together
#' draft_alternatives(
#'   x = system.file("hdi.yml", package = "tines"),
#'   id = c("step-scaling", "step-education"),
#'   file_path = withr::local_tempfile(fileext = ".yml"),
#'   branch = "single"
#' )
#'
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
