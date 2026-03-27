# #' Extract Pipeline Schema from Methodology Text
# #'
# #' @description 
# #' Takes a plain English description of a methodology or analysis plan and uses 
# #' an LLM to translate it into a structured YAML schema. The output YAML is 
# #' designed to be human-readable and editable before being parsed into R.
# #'
# #' @param text A character string containing the methodology description.
# #' @param output_file The file path where the YAML should be saved.
# #' @param model The LLM to use (defaults to Gemini 2.5 Pro).
# #'
# #' @return The file path to the generated YAML file (invisibly).
# #' @export
# #' @rdname extract_schema
# #' @examples
# #' str_24 <- "Multilevel linear modelling. Multilevel modelling takes into account hierarchical structure of data. In the case of the current dataset, it means that it can model effects of individual players and referees. Position, height, weight as predictors; player and referee as random effects / age and average number of goals were dropped from predictors because they increased AIC. The full model with all covariates was specified and subsequently covariates that increased AIC were discarded from the model."
# #' str_20 <- 'Transformation: 1. We created unique identifier for players, clubs, and leagues using the variables "playerShort," "club," and "leagueCountry." /  / 2. For players with missing data ("NA") in position, we used Wikipedia to find out what position they played. We coded them using 4 categories: goalkeeper, defender, midfielder, and forward/winger. We used these 4 categories because Wikipedia did not provide specific enough information for certain players. We then transformed the original position variable using these 4 categories: goalkeeper, defender (center back, left fullback, and right fullback), midfielder (defensive midfielder, center midfielder, attacking midfielder, left midfielder, and right midfielder), and forward/winger (forward, left winger, and right winger). /  / 3. We created the age variable from "birthday." Specifically, we subtracted the last 4 characters of the "birthday" variable from 2013. /  / 4. We created the variable "rater" by averaging the ratings of skin tone from the two raters ("rater1" and "rater2"). We used the variable "rater" as our predictor. /  / 5. We grand-mean centered all predictors and covariates ("rater," "meanIAT," "meanExp," "height," "weight," "games," "victories," "defeats," "goals," and "age"). To clarify, grand-mean centering means that we computed the mean of a variable and subtracted each value of the variable from the mean. This procedure improves the interpretability of the intercept and the interaction terms. Players with missing data on skin tone because skin tone is the main predictor in the current study. A four-level multilevel negative-binomial model. We used a multilevel model with player-referee dyads as level-1, players as level-2, clubs as level-3, and leagues as level-4. This model accounts for the interdependence within players, clubs, and leagues. The likelihood of receiving a red card may differ from players to players, from clubs to clubs, and from leagues to leagues. As a hypothetical example, Arsenal as a club may tend to receive more red cards compared to Manchester United. The multilevel structure helps account for similarities in likelihood to receive red cards within Arsenal and within Manchester United. /  / We used a negative-binomial model because the dependent variable (redCards) is a count variable. Covariates: Games, victories, defeats, height, weight, age, positions, goals. We controlled for numbers of games because encountering a referee more time increases the likelihood of receiving a red card. /  / Players may be less likely to commit a foul (and thus receive a red card) if their team won the game. In contrast, they may play more aggressive defense and commit fouls if their team lost the game. Thus, we controlled for the outcomes of the games (victories and defeats) and number of goals. /  / We controlled for height and weight because conceivably, bigger players may have more advantage fighting for position and thus be more likely to engage in bodily contact, which may increase the chance of committing fouls (and thus, receiving red cards). /  / We controlled for positions because defensive players (goalkeepers and defenders) may commit more fouls and thus receive more red cards. /  / We controlled for age because impulsivity, which may be associated with receiving red cards, tends to decrease with age (Steinberg et al., 2008).'
# extract_schema_from_text <- function(text, output_file = "draft_schema.yml", model = "gemini-2.5-pro") {
  
#   if (missing(text) || trimws(text) == "") {
#     cli::cli_abort("You must provide valid methodology text to extract.")
#   }

#   full_prompt <- prompt_extract_schema(text)

#   cli::cli_alert_info("Analyzing text and drafting YAML schema...")
#   chat <- ellmer::chat_google_gemini(model = model)
#   response <- chat$chat(full_prompt)
  
#   clean_yaml <- gsub("^```yaml\n|^```\n|```$", "", trimws(response))
  
#   writeLines(clean_yaml, output_file)
  
#   cli::cli_alert_success("YAML schema successfully drafted to {.file {output_file}}")
#   cli::cli_alert_info("Open this file to review and manually edit any nodes or edges before loading into R.")
  
#   return(invisible(output_file))
# }



# #' @export
# #' @rdname extract_schema
# prompt_extract_schema <- function(text) {
  
#   system_prompt <- paste0(
#     "You are an expert data science methodologist. I will provide you with a text description ",
#     "of an analytical pipeline, research protocol, or methodology.\n\n",
#     "Your task is to translate this text into a strict YAML pipeline schema. ",
#     "You MUST output valid YAML ONLY. Do not write any markdown formatting, conversational text, ",
#     "or explanations. Just the raw YAML.\n\n",

#     "RULES FOR EXTRACTING THE SCHEMA:\n",
#     "1. NO NEGATIVES: Do NOT create standalone decisions for negative actions (e.g., 'we did not use X'). Instead, synthesize these into the positive choice they represent.\n",
#     "2. THE 'FORK' (THE CROSSROADS): 'fork' MUST be framed as an open methodological goal that invites multiple possible approaches. It must NOT describe the final choice.\n",
#     "3. THE 'PATH' (THE POSITIVE CHOICE): A 'path' is strictly a POSITIVE methodological decision that has potential theoretical alternatives, chosen to resolve the 'fork'.\n",
#     "4. 'justification' is WHY that decision was made, extracted from the text.\n",
#     "5. 'tag' MUST be a unique, lowercase string starting with 'block-'.\n",
#     "6. 'status' should default to 'DRAFT'.\n",
#     "7. Edges must connect the tags using 'from' and 'to', with a 'type' (e.g., 'sequential', 'logical_motivation').\n\n",
    
#     # "8. CONFIDENCE SYSTEM: Add a 'confidence' key (HIGH, MEDIUM, or LOW) based on how explicit the text is. If the text is vague or implies a step without detailing it, rate it MEDIUM or LOW.\n",
#     # "9. CLARIFICATION: Add a 'clarification_question' key. If confidence is HIGH, output 'null'. If MEDIUM or LOW, autogenerate a specific question asking the human to clarify the missing theoretical details.\n",
    
#     "=== REQUIRED YAML STRUCTURE EXAMPLE ===\n",
#     "meta:\n",
#     "  type: schema\n",
#     "nodes:\n",
#     "- fork: variables are in different scales\n",
#     "  type: constraint\n",
#     "  path: apply min-max scaling to each variable\n",
#     "  justification: to put them on the same scale for combination\n",
#     "  tag: block-scaling\n",
#     "  status: VERIFIED\n",
#     "- fork: combine the school variables into one dimension\n",
#     "  type: step\n",
#     "  path: average exp sch and avg sch\n",
#     "  justification: the most intuitive way\n",
#     "  tag: block-education\n",
#     "  status: DRAFT\n",
#     "edges:\n",
#     "- from: block-scaling\n",
#     "  to: block-education\n",
#     "  type: sequential\n"

    
#   )

#   paste0(system_prompt, "\n\n=== TEXT TO TRANSLATE ===\n", text)
# } 


# #' Map dataset columns to schema inputs and outputs
# #' @export
# #' @rdname extract_schema
# map_variables <- function(schema_file, data, model = "gemini-2.5-pro") {
  
#   # 1. Read the draft schema we just created
#   draft_yaml <- paste(readLines(schema_file), collapse = "\n")
  
#   # 2. Create a compact data dictionary from the user's dataset
#   # This gives the LLM the column names and data types without sending the whole dataset
#   data_summary <- colnames(readr::read_csv(data))
  
#   # 3. Formulate the mapping rules
#   system_prompt <- paste0(
#   "You are a data pipeline architect. I have a sequential YAML schema containing methodological decisions, ",
#   "and a summary of the initial dataset.\n\n",
#   "YOUR TASK: Read the 'fork' and 'path' of each decision in order. Determine which data objects or columns ",
#   "are required as 'inputs' and what the resulting 'outputs' should be called.\n\n",
#   "RULES:\n",
#   "1. RAW INPUTS: If a node requires raw data, the 'inputs' array MUST contain EXACT column names ",
#   "from the provided dataset. Do not guess or hallucinate.\n",
#   "2. SEQUENTIAL CHAINING (CRITICAL): The pipeline flows top-to-bottom. If a node relies on an object ",
#   "created by a previous node, it MUST use that exact previous output name as its input.\n",
#   "3. DIVERSE OBJECT CREATION: Nodes can output various types of R objects. Invent clean, snake_case ",
#   "names based on what the node's 'path' actually produces:\n",
#   "   - Data Transformations -> Dataframes (e.g., 'df_clean', 'df_scaled')\n",
#   "   - Modeling -> Model objects (e.g., 'fit_multilevel', 'model_lm')\n",
#   "   - Evaluations/Metrics -> Values used for downstream decisions (e.g., 'aic_results', 'model_comparison')\n",
#   "   - Configurations -> Parameter specifications or formulas (e.g., 'ranef_spec', 'covariate_vars')\n",

#   # "4. CONFIDENCE & CLARIFICATION (CRITICAL): Assess your mapping confidence (HIGH, MEDIUM, LOW).\n",
#   #   "   - If the schema abstracts a concept (e.g., 'center all predictors') but doesn't name the specific variables, ",
#   #   "you CANNOT guarantee a safe mapping. Set confidence to LOW.\n",
#   #   "   - If you are unsure which exact dataset columns match the text's intent, set confidence to MEDIUM or LOW.\n",
#   #   "   - If confidence is not HIGH, you MUST autogenerate a 'clarification_question' asking the user for the exact column names needed to execute the path safely. If HIGH, output 'null'.\n",

#   "5. PASS-THROUGH: If a node merely evaluates an object without altering it or creating a new one, the output can be the same as the input.\n",
#   "6. Output ONLY valid YAML without markdown formatting.\n",
#   "7. INLINE ARRAYS ONLY: You MUST format all inputs and outputs arrays using inline brackets on a single line (e.g., inputs: [var1, var2, var3]). DO NOT use multiline bulleted lists (e.g., - var1)."


# )
  
#   full_prompt <- paste0(
#     system_prompt, 
#     "\n=== DATASET SUMMARY ===\n", data_summary,
#     "\n\n=== DRAFT SCHEMA ===\n", draft_yaml
#   )
  
#   # 4. Call the LLM (using your preferred wrapper)
#   cli::cli_alert_info("Mapping dataset columns to schema nodes...")
#   chat <- ellmer::chat_google_gemini(model = model)
#   mapped_yaml <- chat$chat(full_prompt)
  
#   # 5. Clean and save
#   clean_yaml <- gsub("^```yaml\n|^```\n|```$", "", trimws(mapped_yaml))
#   output_file <- sub("\\.yml$", "_mapped.yml", schema_file)
#   writeLines(clean_yaml, output_file)
  
#   cli::cli_alert_success("Variables mapped and saved to {.file {output_file}}")
#   return(invisible(output_file))
# }

