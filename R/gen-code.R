#' Generate R code from a schema or multiverse
#'
#' @param x A schema object, multiverse object, or file path to a schema YML.
#' @param base_code Optional. The file path to an existing R script to use as 
#'   a style reference or template.
#' @param data Optional. Either a file path to a data file (e.g., CSV) or a
#'   string like `"packagename::dataset"` indicating a built-in package dataset.
#'   If `NULL`, the LLM will not receive any data instructions.
#' @param output For schemas: file path (ending in .R) or directory. 
#'   For multiverses: must be a directory. Defaults to "scripts".
#' @param provider The LLM provider to use for code generation. Currently only "gemini".
#' @param ... Additional arguments passed to methods.
#'
#' @return Invisibly returns the path(s) to the generated script(s).
#' @export
#' @rdname gen_code
#' @examples
#' \dontrun{
#' # Generate from a single schema
#' schema <- example_schema()
#' gen_code(schema, output = "analysis.R")
#'
#' # Generate from a multiverse (use expand_tines first)
#' schema |>
#'   expand_tines(alternatives) |>
#'   gen_code(output = "scripts/")
#' }
#'
#' # The prompt generation function can be used directly to see the full prompt sent to the LLM
#' prompt_gen_code(data = "inst/football.csv")
gen_code <- function(x, base_code = NULL, data = NULL, 
                     output = "scripts", provider = "gemini", ...) {
 UseMethod("gen_code")
}

#' @export
#' @rdname gen_code
gen_code.character <- function(x, base_code = NULL, data = NULL,
                               output = "scripts", provider = "gemini", ...) {
  if (!file.exists(x)) {
    cli::cli_abort("File not found: {.val {x}}")
 }
  gen_code(read_tines(x), base_code = base_code, data = data, 
           output = output, provider = provider, ...)
}

#' @export
#' @rdname gen_code
gen_code.schema <- function(x, base_code = NULL, data = NULL,
                            output = "scripts", provider = "gemini", ...) {
  is_file <- grepl("\\.[Rr]$", output)
  
  if (is_file) {
    file_path <- output
    dir_path <- dirname(output)
  } else {
    dir_path <- output
    file_path <- file.path(output, "pipeline.R")
  }
  
  if (!dir.exists(dir_path)) dir.create(dir_path, recursive = TRUE)
  
  cli::cli_alert_info("Generating script from schema")
  
  gen_code_single(
    base_schema = x,
    base_code = base_code,
    data = data,
    file_path = file_path,
    provider = provider
 )
  
  cli::cli_alert_success("Script generated: {.path {file_path}}")
  invisible(file_path)
}

#' @export
#' @rdname gen_code
gen_code.multiverse <- function(x, base_code = NULL, data = NULL,
                                output = "scripts", provider = "gemini", ...) {
  if (grepl("\\.[Rr]$", output)) {
    cli::cli_abort(c(
      "x" = "{.arg output} must be a directory for multiverse objects.",
      "i" = "You provided {.val {output}}."
    ))
  }
  
  if (!dir.exists(output)) dir.create(output, recursive = TRUE)
  
  paths <- character(length(x))
  
  for (i in seq_along(x)) {
    id <- names(x)[i] %||% sprintf("branch_%02d", i)
    safe_id <- gsub("[^a-zA-Z0-9]+", "_", id)
    safe_id <- gsub("^_|_$", "", safe_id)
    file_path <- file.path(output, paste0(safe_id, ".R"))
    
    cli::cli_alert_info("Generating {i}/{length(x)}: {.val {id}}")
    
    gen_code_single(
      base_schema = x[[i]],
      base_code = base_code,
      data = data,
      file_path = file_path,
      provider = provider
    )
    
    paths[i] <- file_path
  }
  
  cli::cli_alert_success("Generated {length(x)} scripts in {.path {output}}")
  invisible(paths)
}

#' @keywords internal
gen_code_single <- function(base_schema, base_code = NULL, 
                            data = NULL, provider = "gemini", file_path = NULL) {
  if (is.null(file_path)) {
    cli::cli_abort("You must provide a {.arg file_path} to save the generated code.")
  }

  full_prompt <- prompt_gen_code(
    schema = base_schema, 
    base_code = base_code, 
    data = data, 
    print = FALSE
  )

  #chat <- ellmer::chat_google_gemini(model = "gemini-2.5-flash")
  chat <- ellmer::chat_anthropic(model = "claude-opus-4-5")
  utils::capture.output(chat$chat(full_prompt), file = file_path)

  invisible()
}

#' @export
#' @rdname gen_code
#' @param schema A schema object to include in the prompt.
#' @param base_code Optional. File path to an R script to use as style reference.
#' @param data Optional. Data source specification (file path or "package::dataset").
#' @param print If `TRUE`, prints the prompt to console instead of returning it.
#' @param width If `print = TRUE`, the width to wrap the printed prompt (default 70).
prompt_gen_code <- function(schema = NULL, base_code = NULL, data = NULL, print = TRUE, width = 70) {
  has_data <- !is.null(data)
  has_base_code <- !is.null(base_code)
  
  # Build system instruction
  data_instruction <- if (has_data) {
    paste0(
      "A DATA section is provided. This is the entry point for the entire pipeline - ",
      "start the script by loading this data. ",
      "Do NOT generate, simulate, or create any dummy or synthetic data under any circumstances."
    )
  } else {
    "No data file is specified - if data loading is required, use a sensible placeholder or note it in a comment."
  }

  base_prompt <- paste0(
    "You are an expert R programmer. ",
    "Attached is a text document containing a SCHEMA that defines a data processing pipeline.\n\n",
    data_instruction,
    if (has_base_code) {
      " A BASE R CODE section is also provided as a style reference. Match its coding style, packages, and conventions."
    },
    " Your task is to write a complete, working R script that implements this pipeline step-by-step. ",
    "Use modern R practices (like dplyr or base pipe) and ensure variables flow correctly from one step to the next as defined by the inputs and outputs. ",
    "Output ONLY the complete R script. Do not start with markdown formatting blocks (like ```R) or backticks."
  )
  
 # Build context sections
  context_parts <- character(0)
  
  if (!is.null(schema)) {
    context_parts <- c(
      context_parts,
      "=== SCHEMA ===",
      yaml::as.yaml(schema)
    )
  }
  
  if (!is.null(data)) {
    is_pkg_data <- grepl("::", data, fixed = TRUE)
    if (is_pkg_data) {
      data_txt <- paste0(
        "The data is available as a built-in package dataset: `", data, "`. ",
        "Load it with `data(", sub(".*::", "", data), ", package = \"",
        sub("::.*", "", data), "\")` or reference it directly."
      )
    } else {
      data_txt <- paste0(
        "The data should be imported from the file: `", data, "`. ",
        "Use `readr::read_csv(\"", data, "\")` (or the appropriate reader) to load it."
      )
    }
    context_parts <- c(context_parts, "=== DATA ===", data_txt)
  }
  
  if (!is.null(base_code)) {
    if (!file.exists(base_code)) {
      cli::cli_abort("Base code file not found: {.val {base_code}}")
    }
    base_code_txt <- paste(readLines(base_code), collapse = "\n")
    context_parts <- c(context_parts, "=== BASE R CODE ===", base_code_txt)
  }
  
  # Combine into full prompt
  full_prompt <- paste0(
    base_prompt,
    if (length(context_parts) > 0) paste0("\n\n", paste(context_parts, collapse = "\n\n"))
  )

  print_prompt(full_prompt, print = print)
}


