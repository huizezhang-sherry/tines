#' Create templates YAML files
#'
#' Generates a starter YAML file for a `schema` or `multiverse` to help you
#' begin building your garden of forking paths.
#'
#' @param type The type of template to create. Options are "schema" for a new
#'   analysis schema template, and "multiverse" for a multiverse analysis
#'   template.
#' @param file_path The file path where the template should be saved. If NULL,
#'   the template will be saved in the current working directory with a
#'   default name based on the type.
#' @param x A `schema` or `multiverse` object, or a character string
#'   specifying the file path to a valid schema YAML file.
#' @param id A character string specifying the `id` of the step in the schema
#' @param overwrite Logical. If TRUE, will overwrite an existing file at the
#'   specified file_path. Defaults to FALSE.
#' @return NULL
#' @export
#' @rdname template
#' @examples
#' # Create a new schema template
#' \dontrun{
#' draft_tines(type = "schema", file_path = "schema_template.yml")
#'
#' # Draft alternatives from a schema object
#' draft_alternatives(
#'   x = my_schema,
#'   id = "data-cleaning",
#'   file_path = "alternative_template.yml"
#' )
#'
#' # Draft alternatives from a schema file
#' draft_alternatives(x = "path/to/schema.yml", id = "data-cleaning")
#' }
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
          fork = "describe your first step here",
          path = "describe your decision here",
          rationale = "explain your reasoning here",
          inputs = list(),
          outputs = list(),
          source_schema = ""
        ),
        list(
          id = "step2",
          fork = "describe your next step here",
          path = "describe your decision here",
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
              id = "step1", fork = "path A approach",
              path = "describe your decision here",
              rationale = "explain your reasoning here",
              inputs = list(), outputs = list(), source_schema = ""
            ),
            list(
              id = "step2", fork = "path A next step",
              path = "describe your decision here",
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
              id = "step1", fork = "path B approach",
              path = "describe your decision here",
              rationale = "explain your reasoning here",
              inputs = list(), outputs = list(), source_schema = ""
            ),
            list(
              id = "step2", fork = "path B next step",
              path = "describe your decision here",
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
draft_alternatives <- function(x, id, file_path = NULL) {
  if (is.character(x) && length(x) == 1) {
    if (!file.exists(x)) cli::cli_abort("File {.file {x}} does not exist.")
    x <- read_tines(x)
  }

  if (!id %in% x$id) {
    cli::cli_abort("Step {.val {id}} not found in the {class(x)} object")
  }

  current_action <- x$fork[which(x$id == id)]
  fork <- x$fork[which(x$id == id)]

  template <- cli::format_inline(
    "meta:
  type: alternatives
  step: {id}
  fork: {fork}
alternatives:
  - id: \"NEW-ALTERNATIVE#1\"
    path: \"\"
    rationale: \"\"
    input: []
    output: []
  - id: \"NEW-ALTERNATIVE#2\"
    path: \"\"
    rationale: \"\"
    input: []
    output: []
"
  )

  if (is.null(file_path)) file_path <- paste0("alt_", id, ".yml")
  writeLines(cli::ansi_strip(template), file_path)
  cli::cli_alert_success("Created template at {.file {file_path}}")
}
