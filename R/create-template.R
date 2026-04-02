#' Create templates YAML files
#'
#' Generates a starter YAML file for a `schema` or `multiverse` to help you
#' begin building your garden of forking paths.
#'
#' @param type The type of template to create. Options are "schema" for a new analysis schema template, and "multiverse" for a multiverse analysis template.
#' @param file_path The file path where the template should be saved. If NULL, the template will be saved in the current working directory with a default name based on the type.
#' @param x A `schema` or `multiverse` object. Required for `draft_alternatives()` to generate a template based on an existing step.
#' @param id A character string specifying the `id` of the step in the schema
#' @param overwrite Logical. If TRUE, will overwrite an existing file at the specified file_path. Defaults to FALSE.
#' @return NULL
#' @export
#' @rdname template
#' @examples
#' # Create a new schema template
#' \dontrun{
#' draft_tines(type = "schema", file_path = "schema_template.yaml")
#' draft_alternatives(x = my_schema, id = "data-cleaning", file_path = "alternative_template.yaml")
#' }
#'
#'
draft_tines <- function(type = c("schema", "multiverse"), file_path = NULL, overwrite = FALSE){
  type <- match.arg(type)

  if (is.null(file_path)) {
    file_path <- paste0(type, "_template.yml")
  }

  if (file.exists(file_path) & !overwrite) {
    cli::cli_abort(c(
      "File {.file {file_path}} already exists.",
      "i" = "Please choose a different path or delete the existing file first or set {.code overwrite = TRUE} to overwrite it."
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
        list(id = "step1", 
             action = "describe your first step here",
             decision = "describe your decision here", 
             justification = "explain your reasoning here",
             inputs = list(),
             outputs = list(),
             source_schema = ""),
        list(id = "step2", 
             action = "describe your next step here",
             decision = "describe your decision here", 
             justification = "explain your reasoning here",
             inputs = list(),
             outputs = list(),
             source_schema = "")
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
            list(id = "step1", action = "path A approach",
                 decision = "describe your decision here",
                 justification = "explain your reasoning here",
                 inputs = list(), outputs = list(), source_schema = ""),
            list(id = "step2", action = "path A next step",
                 decision = "describe your decision here",
                 justification = "explain your reasoning here",
                 inputs = list(), outputs = list(), source_schema = "")
          )
        ),
        list(
          meta = list(
            type = "schema",
            date = as.character(Sys.Date()),
            name = "Path B"
          ),
          nodes = list(
            list(id = "step1", action = "path B approach",
                 decision = "describe your decision here",
                 justification = "explain your reasoning here",
                 inputs = list(), outputs = list(), source_schema = ""),
            list(id = "step2", action = "path B next step",
                 decision = "describe your decision here",
                 justification = "explain your reasoning here",
                 inputs = list(), outputs = list(), source_schema = "")
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

  cli::cli_alert_success("Drafted {.val {type}} template at {.file {file_path}}")
  cli::cli_alert_info("Open this file to start defining your steps!")

  invisible(file_path)
}

#' @export
#' @rdname template
draft_alternatives <- function(x, id, file_path = NULL) {

  if (!id %in% x$id) {
    cli::cli_abort("Step {.val {id}} not found in the {class(x)} object")
  }

  # Get the current action
  idx <- which(x$id == id)
  current_action <- x$action[idx]

  template <- cli::format_inline(
    "meta:
  type: alternatives
  step: {id}
alternatives:
  - id: \"YOUR-NEW-NAME-HERE\"
    action: \"{current_action}\"
    decision: \"\"
    justification: \"\"
  - id: \"YOUR-NEW-NAME-HERE\"
    action: \"{current_action}\"
    decision: \"\"
    justification: \"\"
"
  )

  if (is.null(file_path)) {
    file_path <- paste0("alt_", id, ".yml")
  }

  writeLines(cli::ansi_strip(template), file_path)
  cli::cli_alert_success("Created template at {.file {file_path}}")
}
