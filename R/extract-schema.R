#' Extract schema from descriptive text
#'
#' @description
#' Takes a plain English description of a methodology and uses an LLM
#' (Large Language Model) to translate it into a structured YAML schema
#' suitable for multiverse analysis. The function automatically maps
#' variables from the provided data dictionary to the extracted
#' methodological steps, identifying inputs and outputs for each node
#' in the analysis pipeline.
#'
#' @param text A character string containing the methodology description.
#' @param data_dict Either a character vector of column names, or a data frame
#'   with at least a `name` column and an optional `description` column.
#' @param output_file The file path where the YAML should be saved.
#' @param model The LLM to use (defaults to Gemini 2.5 Pro).
#' @param print If `TRUE`, prints the prompt to console instead of returning it.
#' @param width If `print = TRUE`, the width to wrap the printed prompt (default 70).
#'
#' @rdname extract_schema
#' @return The file path to the generated YAML file (invisibly).
#' @export
#' @examples
#' text <- football_grp20
#' data_dict <- c("playerShort", "player", "club", "leagueCountry", "birthday", "height",
#'                "weight", "position", "games", "victories", "ties", "defeats",
#'                "goals", "yellowCards", "yellowReds", "redCards", "photoID", "rater1",
#'                "rater2", "refNum", "refCountry", "Alpha_3", "meanIAT", "nIAT",
#'                "seIAT", "meanExp", "nExp", "seExp")
#' 
#' \dontrun{
#' extract_schema(text, data_dict, output_file = "draft_schema.yml")
#' }
#' 
#' # The prompt generation function can be used directly to see the full prompt sent to the LLM
#' prompt_extract_schema(data_dict = paste0(data_dict, collapse = ", "), text = text, print = TRUE)
#' 

extract_schema <- function(text, data_dict, output_file = "draft_schema.yml", model = "gemini-2.5-pro") {

  # Format data_dict into a data dictionary string
  data_summary <- if (is.data.frame(data_dict)) {
    if (!"name" %in% names(data_dict)) {
      cli::cli_abort("{.arg data_dict} data frame must have at least a {.field name} column.")
    }
    if ("description" %in% names(data_dict)) {
      paste(data_dict$name, data_dict$description, sep = ": ", collapse = "\n")
    } else {
      paste(data_dict$name, collapse = ", ")
    }
  } else if (is.character(data_dict)) {
    paste(data_dict, collapse = ", ")
  } else {
    cli::cli_abort("{.arg data_dict} must be a character vector or a data frame.")
  }

  full_prompt <- prompt_extract_schema(data_dict, text)
  
  cli::cli_alert_info("Extracting schema and mapping data flow simultaneously...")
  chat <- ellmer::chat_google_gemini(model = model, echo = "none")
  yaml_out <- chat$chat(full_prompt)
  
  clean_yaml <- gsub("^```yaml\n|^```\n|```$", "", trimws(yaml_out))
  writeLines(clean_yaml, output_file)
  
  cli::cli_alert_success("DAG schema drafted and mapped successfully to {.file {output_file}}")
  return(invisible(output_file))
}

#' @export
#' @rdname extract_schema
prompt_extract_schema <- function(data_dict, text, print = TRUE, width = 70) {
  system_prompt <- paste0(
    "You are an expert methodologist and data pipeline architect. I will provide a text describing ",
    "a multiverse analysis and a summary of the actual dataset being used.\n\n",
    "=== YOUR TASK === \n\n Extract a chronological list of methodological decisions (nodes) AND map the ",
    "exact data flow (inputs/outputs) for each node simultaneously.\n\n",
    "=== RULES === \n\n",
    "1. THEORY EXTRACTION: For each node, extract:\n\n",
    "   - 'id': A unique snake_case identifier.\n\n",
    "   - 'fork': MUST be framed as an open methodological goal that invites multiple possible approaches. It must NOT describe the final choice.\n\n",
    "   - 'path': A 'path' is strictly a POSITIVE methodological decision that has potential theoretical alternatives, chosen to resolve the 'fork'.\n\n",
    "   - 'rationale': WHY that decision (the path) was made, extracted from the text.\n\n",
    "2. DATA MAPPING: Assign 'inputs' (EXACT column names from the dataset OR outputs from previous nodes) ",
    "and 'outputs' (invented snake_case objects like 'df_clean' or 'ranef_spec').\n\n",
    "3. ANTI-ABSTRACTION (CRITICAL): If the text lists specific variables (e.g., 'centered rater, meanIAT'), ",
    "DO NOT summarize them away. You MUST capture those specific variables in the 'inputs' array.\n\n",
    "4. INLINE ARRAYS: Format arrays strictly on one line: `inputs: [var1, var2]`.\n\n",
    "5. CONFIDENCE & CLARIFICATION: Rate your mapping confidence (HIGH, MEDIUM, LOW). ",
    "If the text abstracts a step and you cannot confidently match it to specific dataset columns, ",
    "set confidence to LOW and autogenerate a 'clarification_question' asking the user which exact ",
    "columns to use. If HIGH, output 'null'.\n\n",
    "6. Output ONLY valid YAML without markdown formatting.\n\n",
    "=== REQUIRED YAML STRUCTURE EXAMPLE ===\n\n",
    "meta:\n",
    "  type: schema\n",
    "nodes:\n",
    "- fork: variables are in different scales\n",
    "  type: constraint\n",
    "  path: apply min-max scaling to each variable\n",
    "  justification: to put them on the same scale for combination\n",
    "  id: block-scaling\n",
    "  confidence: high\n",
    "- fork: combine the school variables into one dimension\n",
    "  type: step\n",
    "  path: average exp sch and avg sch\n",
    "  justification: the most intuitive way\n",
    "  id: block-education\n",
    "  confidence: low\n",
    "edges:\n",
    "- from: block-scaling\n",
    "  to: block-education\n",
    "  type: sequential\n"
  )
  

  full_prompt <- paste0(
    system_prompt,
    "\n=== DATASET SUMMARY ===\n\n", data_dict,
    "\n\n=== METHODOLOGY TEXT ===\n\n", text
  )

print_prompt(full_prompt, print = print)

}
