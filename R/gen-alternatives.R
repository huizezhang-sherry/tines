#' Generate analytical alternatives via LLM
#'
#' @description
#' `gen_alternatives()` takes an existing `schema` or `multiverse` and asks a
#' Large Language Model to suggest methodologically valid, alternative approaches for
#' a specific step (block) in your analysis pipeline.
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
#'   the file path to a valid `tines` YAML file.
#' @param block A character string. The exact `tag` of the step/node you want
#'   the LLM to generate alternatives for.
#' @param n An integer. The number of distinct alternatives you want the LLM
#'   to generate. Defaults to `3`.
#' @param provider A character string specifying the LLM provider. Currently
#'   defaults to `"gemini"`. (`gemini-3-flash-preview` via `ellmer`).
#' @param file_path A character string specifying where to save the generated
#'   YAML output. If `NULL` (the default), `capture.output()` will return the
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
#' gen_alternatives(hdi, block = "block-combine", n = 1,
#'                 file_path = here::here("inst/hdi-alt.yaml"))
#' }
#' 
#' # The prompt generation function can be used directly to see the full prompt sent to the LLM
#' prompt_alternatives(schema = hdi, block = "block-combine", print = TRUE)
#' 
gen_alternatives <- function(x, block, n = 3,
                             provider = "gemini", file_path = NULL, ...){
  UseMethod("gen_alternatives")
}

#' @export
#' @rdname gen_alternatives
gen_alternatives.character <- function(x, ...){
  if (!file.exists(x)) {
    cli::cli_abort("File not found: {.val {x}}")
  }
  schema_data <- read_tines(x)

  gen_alternatives(schema_data, ...)
}

#' @export
#' @rdname gen_alternatives
gen_alternatives.schema <- function(x, block, n = 3,
                             provider = "gemini", file_path = NULL, ...){
  if (is.null(file_path)) {
    cli::cli_abort("You must provide a {.arg file_path} to save the generated alternatives.")
  }

  full_prompt <- prompt_alternatives(schema = x, block = block, n = n)

  chat <- ellmer::chat_google_gemini(model = "gemini-2.5-flash")
  utils::capture.output(chat$chat(full_prompt), file = file_path)
  invisible()
}


#' @export
#' @rdname gen_alternatives
gen_alternatives.multiverse <- function(x, block, ...){
  valid_schema <- NULL

  # find the first schema in the multiverse that contains the target block
  for (schema in x) {
    tags <- purrr::map_chr(schema$nodes, "tag")
    if (block %in% tags) {
      valid_schema <- schema
      break
    }
  }

  if (is.null(valid_schema)) {
    cli::cli_abort(
      "Target block {.val {block}} not found in any branch of this multiverse."
    )
  }

  gen_alternatives(valid_schema, block, ...)

}


#' @export
#' @rdname gen_alternatives
#' @param schema A schema object to include in the prompt.
prompt_alternatives <- function(schema = NULL, block, n = 3, print = TRUE, width = 70){
  system_prompt <- paste0(
    "You are an expert Data Analyst and Methodologist. You are reviewing an analysis schema to identify ",
    "\"Forking Paths\" -- alternative analytical choices that are equally valid but distinct from the current approach.\n\n",
    "=== DEFINITIONS ===\n\n",
    "The schema provided to you consists of blocks with:\n\n",
    "- **ACTION**: The goal of the block (What needs to be done).\n\n",
    "- **DECISION**: The specific implementation chosen (How it is done).\n\n",
    "- **JUSTIFICATION**: The reasoning behind that decision.\n\n",
    "- **TAG**: The unique identifier for the block (kebab-case).\n\n",
    "=== TASK ===\n\n",
    "Focus specifically on the block tagged: \"", block, "\".\n",
    "Your goal is to generate ", n, " distinct, valid alternatives for this block.\n\n",
    "For each alternative:\n",
    "1. **Keep the same ACTION** (the goal remains constant).\n\n",
    "2. **Change the DECISION** to a different but methodologically sound approach.\n\n",
    "3. **Provide a new JUSTIFICATION** explaining why this alternative is valid.\n\n",
    "4. **Create a new TAG** that reflects the new decision (must be kebab-case).\n\n",
    "=== OUTPUT FORMAT ===\n\n",
    "Please output the result in **strictly valid YAML format**.\n\n",
    "**Crucial Formatting Rules:**\n\n",
    "1. Include a `meta` section at the top with `type: alternative` and the `block`.\n\n",
    "2. Output strictly valid YAML. All text values (decision, justification) must be enclosed in double quotes (\"). ",
    "Do not use block styles (| or >). Do not wrap lines or insert \\n characters within the quotes; ",
    "keep the text as a single continuous string.\n\n",
    "3. Do not include markdown code fences (like ```yaml) or conversational text. Just the raw YAML.\n\n",
    "=== REQUIRED YAML STRUCTURE EXAMPLE ===\n\n",
    "meta:\n",
    "  type: tines_alternative\n",
    "  block: ", block, "\n",
    "alternatives:\n",
    "  - tag: block-new-method-name\n",
    "    action: Repeat the original action\n",
    "    decision: \"Description of the new decision...\"\n",
    "    justification: \"This is the reasoning for why this alternative is valid.\"\n",
    "  - tag: block-another-method\n",
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
#' # read the alternatives from a YAML file
#' tmp_file <- tempfile(fileext = ".yaml")
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

  target <- attr(alts_data,"block")


  tags <- x$nodes$tag
  if (!target %in% tags) {
    cli::cli_abort("Target block {.val {target}} not found in the base schema.")
  }
  idx <- which(tags == target)


  new_schemas <- lapply(alts_data, function(alt) {
    branch <- x

    branch$nodes$tag[[idx]] <- alt$tag
    branch$nodes$decision[[idx]] <- alt$decision
    branch$nodes$justification[[idx]] <- alt$justification

    # Rewire the edges!
    branch$edges$from[branch$edges$from == target] <- alt$tag
    branch$edges$to[branch$edges$to == target] <- alt$tag
    return(branch)
  })
  names(new_schemas) <- vapply(alts_data, function(a) a$tag, character(1))


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
  target <- attr(alts_data,"block")

  expanded_list <- lapply(x, function(single_schema) {

    tags <- single_schema$nodes$tag

    if (target %in% tags) {
      # It has the block! Expand it, and extract the resulting list of schemas
      expanded_mini_multi <- expand_tines(single_schema, alternatives, include_original = FALSE)
      return(expanded_mini_multi)
    } else {
      # It DOES NOT have the block! Return it untouched, wrapped in a list
      # so it can be cleanly flattened with the others later.
      return(list(single_schema))
    }


  })
  all_schemas <- c(x, expanded_list)
  all_schemas

}
