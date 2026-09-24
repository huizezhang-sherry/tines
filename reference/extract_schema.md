# Extract schema from descriptive text

Takes a plain English description of a methodology and uses an LLM
(Large Language Model) to translate it into a structured YAML schema
suitable for multiverse analysis. The function automatically maps
variables from the provided data dictionary to the extracted
methodological steps, identifying inputs and outputs for each node in
the analysis pipeline.

## Usage

``` r
extract_schema(
  text,
  data_dict,
  output_file = "draft_schema.yml",
  model = "anthropic/claude-opus-4-5"
)

prompt_extract_schema(data_dict, text, print = TRUE, width = 70)
```

## Arguments

- text:

  A character string containing the methodology description.

- data_dict:

  Either a character vector of column names, or a data frame with at
  least a `name` column and an optional `description` column.

- output_file:

  The file path where the YAML should be saved.

- model:

  The LLM to use, as a string in `"provider/model"` form (e.g.
  `"anthropic/claude-opus-4-5"`, `"openai/gpt-5"`,
  `"google_gemini/gemini-2.5-flash"`), passed to
  [`ellmer::chat()`](https://ellmer.tidyverse.org/reference/chat-any.html).
  See
  [`ellmer::chat()`](https://ellmer.tidyverse.org/reference/chat-any.html)
  for the full list of supported providers. Defaults to
  `"anthropic/claude-opus-4-5"`.

- print:

  If `TRUE`, prints the prompt to console instead of returning it.

- width:

  If `print = TRUE`, the width to wrap the printed prompt (default 70).

## Value

The file path to the generated YAML file (invisibly).

## Examples

``` r
text <- football_grp5
data_dict <- c(
  "playerShort", "player", "club", "leagueCountry", "birthday", "height",
  "weight", "position", "games", "victories", "ties", "defeats",
  "goals", "yellowCards", "yellowReds", "redCards", "photoID", "rater1",
  "rater2", "refNum", "refCountry", "Alpha_3", "meanIAT", "nIAT",
  "seIAT", "meanExp", "nExp", "seExp"
)

if (FALSE) { # \dontrun{
# Requires an LLM API key (e.g. ANTHROPIC_API_KEY); not run automatically.
extract_schema(text, data_dict, output_file = "draft_schema.yml")
} # }

# The prompt generation function can be used directly to see the full
# prompt sent to the LLM
prompt_extract_schema(
  data_dict = paste0(data_dict, collapse = ", "),
  text = text,
  print = TRUE
)
#> You are an expert methodologist and data pipeline architect. I will
#> provide a text describing a multiverse analysis and a summary of the
#> actual dataset being used.
#> 
#> === YOUR TASK ===
#> 
#> Extract a chronological list of methodological decisions (nodes) AND
#> map the exact data flow (inputs/outputs) for each node
#> simultaneously.
#> 
#> === RULES ===
#> 
#> 1. THEORY EXTRACTION: For each node, extract:
#> 
#> - 'id': A unique snake_case identifier.
#> 
#> - 'objective': MUST be framed as an open methodological goal that
#> invites multiple possible approaches. It must NOT describe the final
#> choice.
#> 
#> - 'decision': A 'decision' is strictly a POSITIVE methodological
#> choice that has potential theoretical alternatives, chosen to resolve
#> the 'objective'.
#> 
#> - 'rationale': WHY that decision was made, extracted from the text.
#> 
#> 2. DATA MAPPING: Assign 'inputs' (EXACT column names from the dataset
#> OR outputs from previous nodes) and 'outputs' (invented snake_case
#> objects like 'df_clean' or 'ranef_spec').
#> 
#> 3. ANTI-ABSTRACTION (CRITICAL): If the text lists specific variables
#> (e.g., 'centered rater, meanIAT'), DO NOT summarize them away. You
#> MUST capture those specific variables in the 'inputs' array.
#> 
#> 4. INLINE ARRAYS: Format arrays strictly on one line: `inputs: [var1,
#> var2]`.
#> 
#> 5. CONFIDENCE & CLARIFICATION: Rate your mapping confidence (HIGH,
#> MEDIUM, LOW). If the text abstracts a step and you cannot confidently
#> match it to specific dataset columns, set confidence to LOW and
#> autogenerate a 'clarification_question' asking the user which exact
#> columns to use. If HIGH, output 'null'.
#> 
#> 6. Output ONLY valid YAML without markdown formatting.
#> 
#> === REQUIRED YAML STRUCTURE EXAMPLE ===
#> 
#> meta: type: schema nodes: - objective: variables are in different
#> scales decision: apply min-max scaling to each variable rationale: to
#> put them on the same scale for combination id: step-scaling
#> confidence: high - objective: combine the school variables into one
#> dimension decision: average exp sch and avg sch rationale: the most
#> intuitive way id: step-education confidence: low
#> 
#> === DATASET SUMMARY ===
#> 
#> playerShort, player, club, leagueCountry, birthday, height, weight,
#> position, games, victories, ties, defeats, goals, yellowCards,
#> yellowReds, redCards, photoID, rater1, rater2, refNum, refCountry,
#> Alpha_3, meanIAT, nIAT, seIAT, meanExp, nExp, seExp
#> 
#> === METHODOLOGY TEXT ===
#> 
#> The two ratings of skin-tone were averaged and rescaled. The new
#> variable was called avgrate01.
#> 
#> Cases were excluded if they had missing values on skin-tone-rating,
#> meanIAT or meanExp (listwise deletion) because we wanted to perform
#> all analyses (including research question 2) on the same set of
#> cases.
#> 
#> The original response variable redCards is uninterpretable because
#> the number of games a player has seen a given referee varies.
#> Therefore we disaggregated the data (one game per row, redCards
#> appear as 1s in the first n=redCards rows per player). This was
#> possible because it does not matter in which of, for example, 3 games
#> a player who received 1 red card in 3 games received the red card. It
#> is sufficient that this player has three observations (three rows)
#> associated with him, one of them indicating a red card. We used the
#> binomial error distribution because – after disaggregation – our
#> response variable specifies the occurence of an event in a single
#> game, coded 0 and 1.
#> 
#> We estimated generalized linear mixed models (function glmer in R
#> package lme4, Version 1.1-7; Bates, 2010; Bates, Maechler, Bolker, &
#> Walker, 2014). The crowdstorming data are different from standard
#> multilevel data (e.g., where employees are members of only one team),
#> inasmuch as they are not nested but cross-classified – player A can
#> have multiple games with the referee A, but player B can have
#> multiple games with the same referee A.
#> 
#> Our model adds a random effect of playerShort, refNum, and skin-tone
#> across referees’ countries of origin.
#> 
#> We did not use any covariates, even though reviewers of our approach
#> suggested that we should do so. As already noted in the project
#> description by Silberzahn, Martin, Uhlmann, & Nosek, the data cannot
#> be used for causal inference.
```
