#' Generate analytical alternatives via LLM
#'
#' @description
#' `gen_alternatives()` takes an existing `schema` or `multiverse` and asks a
#' Large Language Model to suggest methodologically valid, alternative approaches for
#' a specific step in your analysis pipeline.
#'
#' `prompt_alternatives()` is a helper function that constructs the exact instruction
#' set sent to the LLM.
#'
#' @details
#' **Important:** This function relies on the `ellmer` package to communicate with
#' Google's Gemini API. You must have your API credentials configured correctly in
#' your R environment (e.g., via the `GEMINI_API_KEY` environment variable) for
#' this to work.
#'
#' @param x A `schema` or `multiverse` object, or a character string specifying
#'   the file path to a valid `tines` YML file.
#' @param step A character string. The exact `id` of the step you want
#'   the LLM to generate alternatives for.
#' @param n An integer. The number of distinct alternatives you want the LLM
#'   to generate. Defaults to `3`.
#' @param data Optional. A data frame or path to a data file. If provided,
#'   the LLM can suggest alternatives that use different variables from the dataset.
#' @param provider A character string specifying the LLM provider. Currently
#'   defaults to `"gemini"`. (`gemini-2.5-flash` via `ellmer`).
#' @param file_path A character string specifying where to save the generated
#'   YML output. If `NULL` (the default), `capture.output()` will return the
#'   result as a character vector.
#' @param print If `TRUE`, prints the prompt to console instead of returning it.
#' @param width If `print = TRUE`, the width to wrap the printed prompt (default 70).
#' @param ... Additional arguments passed to methods or to `ellmer::chat_google_gemini()`.
#'
#' @return
#' * `gen_alternatives()` invisibly returns `NULL` and writes the output to `file_path`.
#' * `prompt_alternatives()` returns a formatted character string containing the LLM prompt.
#'
#' @export
#' @rdname gen_alternatives
#'
#' @examples
#' hdi <- example_schema()
#' 
#' \dontrun{
#' gen_alternatives(hdi, step = "step-combine", n = 1,
#'                 file_path = here::here("inst/hdi-alt.yml"))
#' }
#' 
#' # The prompt generation function can be used directly to see the full prompt sent to the LLM
#' prompt_alternatives(schema = hdi, step = "step-combine", print = TRUE)
#' 
gen_alternatives <- function(x, step, n = 3, data = NULL,
                             provider = "gemini", file_path = NULL, ...){
  UseMethod("gen_alternatives")
}

#' @export
#' @rdname gen_alternatives
gen_alternatives.character <- function(x, ...){
  if (!file.exists(x)) cli::cli_abort("File not found: {.val {x}}")
  schema_data <- read_tines(x)
  gen_alternatives(schema_data, ...)
}

#' @export
#' @rdname gen_alternatives
gen_alternatives.schema <- function(x, step, n = 3, data = NULL,
                             provider = "gemini", file_path = NULL, ...){
  browser()
  if (is.null(file_path)) {
    cli::cli_abort("You must provide a {.arg file_path} to save the generated alternatives.")
  }

  # Check if step exists in the schema
  if (!step %in% x$id) {
    cli::cli_abort("Target step {.val {step}} not found in the schema.")
  }

  # Prepare data context if available
  data_dict <- if (!is.null(data)) {
    if (is.data.frame(data)) {
      prepare_data_dict(data)
    } else if (is.character(data) && file.exists(data)) {
      prepare_data_dict(load_data_file(data))
    } else {
      NULL
    }
  } else if (has_data(x)) {
    # Use attached data if available
    attr(x, "data")$dict
  } else {
    NULL
  }

  full_prompt <- prompt_alternatives(
    schema = x, 
    step = step, 
    n = n, 
    data_dict = data_dict,
    print = FALSE
  )

  #chat <- ellmer::chat_google_gemini(model = "gemini-2.5-flash")
  chat <- ellmer::chat_anthropic(model = "claude-opus-4-5")
  utils::capture.output(chat$chat(full_prompt), file = file_path)
  invisible()
}

#' @export
#' @rdname gen_alternatives
gen_alternatives.multiverse <- function(x, step, ...){
  browser()
  valid_schema <- NULL

  # find the first schema in the multiverse that contains the target step
  for (schema in x) {
    ids <- schema$id  
    if (step %in% ids) {
      valid_schema <- schema
      break
    }
  }

  if (is.null(valid_schema)) {
    cli::cli_abort(
      "Target step {.val {step}} not found in any branch of this multiverse."
    )
  }

  gen_alternatives(valid_schema, step, ...)
}


#' @export
#' @rdname gen_alternatives
#' @param schema A schema object to include in the prompt.
#' @param data_dict Optional data dictionary for context (data frame with columns or character vector)
prompt_alternatives <- function(schema = NULL, step, n = 3, data_dict = NULL, 
                                print = TRUE, width = 70){
  
  # Build data context section if available
  data_section <- if (!is.null(data_dict)) {
    col_info <- if (is.data.frame(data_dict) && "type" %in% names(data_dict)) {
      paste0(data_dict$name, " (", data_dict$type, ")", collapse = ", ")
    } else if (is.data.frame(data_dict)) {
      paste0(data_dict$name, collapse = ", ")
    } else {
      paste0(data_dict, collapse = ", ")
    }
    
    paste0(
      "\n\n=== DATASET CONTEXT ===\n\n",
      "Available columns: ", col_info, "\n\n",
      "When suggesting alternatives, you may propose different input variables from this dataset ",
      "if methodologically appropriate. Update the inputs/outputs fields accordingly.\n"
    )
  } else {
    ""
  }
  
  system_prompt <- paste0(
    "You are an expert Data Analyst and Methodologist. You are reviewing an analysis schema to identify ",
    "\"Forking Paths\" -- alternative analytical choices that are equally valid but distinct from the current approach.\n\n",
    "=== DEFINITIONS ===\n\n",
    "The schema provided to you consists of steps with:\n\n",
    "- **ACTION**: The goal of the step (What needs to be done).\n\n",
    "- **DECISION**: The specific implementation chosen (How it is done).\n\n",
    "- **JUSTIFICATION**: The reasoning behind that decision.\n\n",
    "- **ID**: The unique identifier for the step (kebab-case).\n\n",
    if (!is.null(data_dict)) {
      "- **INPUTS**: Variables from the dataset needed for this step.\n\n- **OUTPUTS**: New variables created by this step.\n\n"
    },
    "=== TASK ===\n\n",
    "Focus specifically on the step tagged: \"", step, "\".\n",
    "Your goal is to generate ", n, " distinct, valid alternatives for this step.\n\n",
    "For each alternative:\n",
    "1. **Keep the same ACTION** (the goal remains constant).\n\n",
    "2. **Change the DECISION** to a different but methodologically sound approach.\n\n",
    "3. **Provide a new JUSTIFICATION** explaining why this alternative is valid.\n\n",
    "4. **Create a new ID** that reflects the new decision (must be kebab-case).\n\n",
    if (!is.null(data_dict)) {
      "5. **Update INPUTS/OUTPUTS** if the alternative uses different variables or creates different outputs.\n\n"
    },
    data_section,
    "=== OUTPUT FORMAT ===\n\n",
    "Please output the result in **strictly valid YML format**.\n\n",
    "**Crucial Formatting Rules:**\n\n",
    "1. Include a `meta` section at the top with `type: alternative` and the `step`.\n\n",
    "2. Output strictly valid YML. All text values (decision, justification) must be enclosed in double quotes (\"). ",
    "Do not use block styles (| or >). Do not wrap lines or insert \\n characters within the quotes; ",
    "keep the text as a single continuous string.\n\n",
    if (!is.null(data_dict)) {
      "3. Include inputs and outputs as arrays: inputs: [var1, var2]\n\n4. "
    } else {
      "3. "
    },
    "Do not include markdown code fences (like ```yml) or conversational text. Just the raw YML.\n\n",
    "=== REQUIRED YML STRUCTURE EXAMPLE ===\n\n",
    "meta:\n",
    "  type: tines_alternative\n",
    "  step: ", step, "\n",
    "alternatives:\n",
    "  - id: step-new-method-name\n",
    "    action: Repeat the original action\n",
    "    decision: \"Description of the new decision...\"\n",
    "    justification: \"This is the reasoning for why this alternative is valid.\"\n",
    if (!is.null(data_dict)) {
      "    inputs: [var1, var2]\n    outputs: [new_var]\n"
    },
    "  - id: step-another-method\n",
    "    ...\n"
  )

  full_prompt <- if (!is.null(schema)) {
    paste0(
      system_prompt,
      "\n=== CURRENT SCHEMA ===\n\n",
      yaml::as.yaml(schema)
    )
  } else {
    system_prompt
  }

  print_prompt(full_prompt, print = print, width = width)
}



#' Expand a schema with an alternative YAML into a multiverse
#'
#' @param x A `schema` object.
#' @param alternatives an `alternatives` object or the path to an alternative YAML
#' @param include_original A logical. If `TRUE`, the original schema will be included as a branch in the resulting multiverse. Defaults to `TRUE`.
#' @param ... Additional arguments.
#'
#' @rdname expand
#' @export
#' @examples
#'
#' # expand on a schema
#' base_schema <- example_football()
#' alts <- example_alternatives(case = "football")
#' expand_tines(base_schema, alts)
#'
#' # read the alternatives from a YML file
#' tmp_file <- tempfile(fileext = ".yml")
#' write_alternatives(alts, tmp_file)
#' expand_tines(base_schema, tmp_file)
#'
#' # expand on the multiverse
#' multiverse <- example_multiverse()
#' alts <- example_alternatives(case = "hdi")
#' expand_tines(multiverse, alts)
#'
expand_tines <- function(x, alternatives, ...) {
  UseMethod("expand_tines")
}

#' @rdname expand
#' @export
expand_tines.schema <- function(x, alternatives, include_original = TRUE, ...) {

  if (is.character(alternatives) && file.exists(alternatives)) {
    alts_data <- read_alternatives(alternatives)
  } else {
    alts_data <- alternatives
  }

  target <- attr(alts_data, "step")

  ids <- x$id
  if (!target %in% ids) {
    cli::cli_abort("Target step {.val {target}} not found in the base schema.")
  }
  idx <- which(ids == target)

  # Iterate over rows of the alternatives data frame using purrr::pmap
  new_schemas <- purrr::pmap(alts_data, function(id, fork, path, rationale) {
    branch <- x
    
    # Update the specific row directly since schema is a data frame
    branch$id[[idx]] <- id
    branch$path[[idx]] <- path
    branch$rationale[[idx]] <- rationale
    
    # Preserve the schema class and attributes
    class(branch) <- c("schema", "tbl_df", "tbl", "data.frame")
    attr(branch, "name") <- attr(x, "name", exact = TRUE)
    
    return(branch)
  })
  names(new_schemas) <- alts_data$id

  if (include_original) new_schemas <- c(list(original = x), new_schemas)

  new_multiverse(new_schemas)
}

#' @rdname expand
#' @export
expand_tines.multiverse <- function(x, alternatives, ...) {

  if (is.character(alternatives) && file.exists(alternatives)) {
    alts_data <- read_alternatives(alternatives)
  } else {
    alts_data <- alternatives
  }
  target <- attr(alts_data, "step")

  expanded_list <- lapply(x, function(single_schema) {
    # Use single_schema$id instead of single_schema$nodes$id
    ids <- single_schema$id

    if (target %in% ids) {
      # It has the step! Expand it, and extract the resulting list of schemas
      expanded_mini_multi <- expand_tines(single_schema, alternatives, include_original = FALSE)
      return(unclass(expanded_mini_multi)) # Return the list of schemas
    } else {
      # It DOES NOT have the step! Return it untouched, wrapped in a list
      return(list(single_schema))
    }
  })
  
  # Flatten the expanded list properly
  all_schemas <- c(unclass(x), unlist(expanded_list, recursive = FALSE))
  new_multiverse(all_schemas)
}
