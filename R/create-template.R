#' Create templates YAML files
#'
#' Generates a starter YAML file for a `schema` or `multiverse` to help you
#' begin building your garden of forking paths.
#'
#' @param type For `draft_tines()` only: the type of template to create.
#'   Options are "schema" for a new analysis schema template, and
#'   "multiverse" for a multiverse analysis template.
#' @param file_path The file path where the template should be saved. If NULL,
#'   the template will be saved in the current working directory with a
#'   default name based on the type.
#' @param x A `schema` or `multiverse` object, or a character string
#'   specifying the file path to a valid schema YAML file.
#' @param id A character string specifying the `id` of the step in the
#'   schema. For `draft_alternatives()`, a vector naming one or more steps --
#'   one node is drafted per step.
#' @param overwrite Logical. If TRUE, will overwrite an existing file at the
#'   specified file_path. Defaults to FALSE.
#' @param branch For `draft_alternatives()` only. Required: either `"multi"`
#'   (drafts 2 placeholder alternatives per node) or `"single"` (drafts
#'   exactly 1 per node, for a template meant to combine into one coordinated
#'   branch). There is no default -- see [alternative()] for what the two
#'   modes mean when expanded.
#' @return `draft_tines()` and `draft_alternatives()` both invisibly return
#'   the path they wrote to; each is called primarily for its side effect
#'   of writing a template YAML file to disk.
#' @export
#' @rdname template
#' @examples
#' # Create a new schema template
#' schema_path <- withr::local_tempfile(fileext = ".yml")
#' draft_tines(type = "schema", file_path = schema_path)
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
#' # Draft alternatives from a schema file
#' schema_file <- withr::local_tempfile(fileext = ".yml")
#' write_tines(my_schema, schema_file)
#' draft_alternatives(
#'   x = schema_file, id = "step-scaling",
#'   file_path = withr::local_tempfile(fileext = ".yml"), branch = "multi"
#' )
#'
#' # Draft a single-branch template combining two steps together
#' draft_alternatives(
#'   x = my_schema,
#'   id = c("step-scaling", "step-education"),
#'   file_path = withr::local_tempfile(fileext = ".yml"),
#'   branch = "single"
#' )
#'
draft_tines <- function(type = c("schema", "multiverse"), file_path = NULL,
                        overwrite = FALSE) {
  type <- match.arg(type)

  if (is.null(file_path)) {
    file_path <- paste0(type, "_template.yml")
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

  if (type == "schema") {
    template_data <- list(
      meta = list(
        type = "schema",
        date = as.character(Sys.Date()),
        name = "My Analysis Schema"
      ),
      nodes = list(
        list(
          id = "step1",
          objective = "describe your first step here",
          decision = "describe your decision here",
          rationale = "explain your reasoning here",
          inputs = list(),
          outputs = list(),
          source_schema = ""
        ),
        list(
          id = "step2",
          objective = "describe your next step here",
          decision = "describe your decision here",
          rationale = "explain your reasoning here",
          inputs = list(),
          outputs = list(),
          source_schema = ""
        )
      )
    )
  } else {
    template_data <- list(
      meta = list(
        type = "multiverse",
        date = as.character(Sys.Date())
      ),
      schemas = list(
        list(
          meta = list(
            type = "schema",
            date = as.character(Sys.Date()),
            name = "Path A"
          ),
          nodes = list(
            list(
              id = "step1", objective = "path A approach",
              decision = "describe your decision here",
              rationale = "explain your reasoning here",
              inputs = list(), outputs = list(), source_schema = ""
            ),
            list(
              id = "step2", objective = "path A next step",
              decision = "describe your decision here",
              rationale = "explain your reasoning here",
              inputs = list(), outputs = list(), source_schema = ""
            )
          )
        ),
        list(
          meta = list(
            type = "schema",
            date = as.character(Sys.Date()),
            name = "Path B"
          ),
          nodes = list(
            list(
              id = "step1", objective = "path B approach",
              decision = "describe your decision here",
              rationale = "explain your reasoning here",
              inputs = list(), outputs = list(), source_schema = ""
            ),
            list(
              id = "step2", objective = "path B next step",
              decision = "describe your decision here",
              rationale = "explain your reasoning here",
              inputs = list(), outputs = list(), source_schema = ""
            )
          )
        )
      )
    )
  }

  yaml::write_yaml(
    template_data,
    file = file_path,
    column.major = FALSE
  )

  cli::cli_alert_success(
    "Drafted {.val {type}} template at {.file {file_path}}"
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
