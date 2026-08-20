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
  least a \`name\` column and an optional \`description\` column.

- output_file:

  The file path where the YAML should be saved.

- model:

  The LLM to use, as a string in \`"provider/model"\` form (e.g.
  \`"anthropic/claude-opus-4-5"\`, \`"openai/gpt-5"\`,
  \`"google_gemini/gemini-2.5-flash"\`), passed to \`ellmer::chat()\`.
  See \[ellmer::chat()\] for the full list of supported providers.
  Defaults to \`"anthropic/claude-opus-4-5"\`.

- print:

  If \`TRUE\`, prints the prompt to console instead of returning it.

- width:

  If \`print = TRUE\`, the width to wrap the printed prompt (default
  70).

## Value

The file path to the generated YAML file (invisibly).

## Examples

``` r
text <- football_grp20
data_dict <- c("playerShort", "player", "club", "leagueCountry", "birthday", "height",
               "weight", "position", "games", "victories", "ties", "defeats",
               "goals", "yellowCards", "yellowReds", "redCards", "photoID", "rater1",
               "rater2", "refNum", "refCountry", "Alpha_3", "meanIAT", "nIAT",
               "seIAT", "meanExp", "nExp", "seExp")

if (FALSE) { # \dontrun{
extract_schema(text, data_dict, output_file = "draft_schema.yml")
} # }

# The prompt generation function can be used directly to see the full prompt sent to the LLM
prompt_extract_schema(data_dict = paste0(data_dict, collapse = ", "), text = text, print = TRUE)
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
#> - 'fork': MUST be framed as an open methodological goal that invites
#> multiple possible approaches. It must NOT describe the final choice.
#> 
#> - 'path': A 'path' is strictly a POSITIVE methodological decision
#> that has potential theoretical alternatives, chosen to resolve the
#> 'fork'.
#> 
#> - 'rationale': WHY that decision (the path) was made, extracted from
#> the text.
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
#> meta: type: schema nodes: - fork: variables are in different scales
#> path: apply min-max scaling to each variable justification: to put
#> them on the same scale for combination id: step-scaling confidence:
#> high - fork: combine the school variables into one dimension path:
#> average exp sch and avg sch justification: the most intuitive way id:
#> step-education confidence: low
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
#> Two variables – age and rating of skin tone – were created. Age was
#> created by subtracting the last four characters of the “birthday”
#> variable (which represented birth years) from 2013. Rating of skin
#> tone was created by averaging the ratings of skin tone (coded 0-1)
#> from the two raters ("rater1" and "rater2"). For players with missing
#> data ("NA") in the “position” variable, Wikipedia was used to find
#> out what positions these players played. Positions were coded using 4
#> categories: goalkeeper, defender, midfielder, and forward/winger.
#> These 4 categories were used because Wikipedia did not provide
#> specific enough information for certain players. The original
#> position variable was then recoded using these 4 categories:
#> goalkeeper, defender (center back, left fullback, and right
#> fullback), midfielder (defensive midfielder, center midfielder,
#> attacking midfielder, left midfielder, and right midfielder), and
#> forward/winger (forward, left winger, and right winger). While some
#> information was lost by merging some of the categories, this
#> procedure increased the number of observations with known positions
#> from 115,457 to 124,468. Several predictors and covariates were
#> grand-mean centered (skin-tone rating, height, weight, number of
#> games, number of victories, number of defeats, number of goals, and
#> age). To clarify, grand-mean centering means that we computed the
#> mean of a variable and subtracted each value of the variable from the
#> mean. This procedure improves the interpretability of the intercept
#> and the interaction terms. Scores on implicit racial bias and
#> explicit racial bias were standardized. Players with missing data on
#> skin tone (“rater1” and “rater2”) were excluded because skin tone is
#> the main predictor in the current study.
#> 
#> A four-level multilevel negative-binomial model was used to test the
#> hypotheses. A multilevel model with player-referee dyads as level-1,
#> players as level-2, clubs as level-3, and leagues as level-4 was
#> used. This model accounts for the interdependence within players,
#> clubs, and leagues. That is, the likelihood of receiving a red card
#> may differ from players to players, from clubs to clubs, and from
#> leagues to leagues. As a hypothetical example, Arsenal as a club may
#> tend to receive more red cards compared to Manchester United. The
#> multilevel structure helps account for similarities in likelihood to
#> receive red cards within Arsenal and within Manchester United. A
#> negative-binomial model was used because the dependent variable
#> (number of red cards received; “redCards”) was a count variable.
#> Number of red cards received was entered as the dependent variable.
#> Skin-tone rating, implicit racial bias, explicit racial bias, the
#> interaction between skin-tone and implicit racial bias, the
#> interaction between skin-tone and explicit racial bias, number of
#> games, victories, and defeats, height, weight, age, number of goals,
#> and dummy-coded positions were all entered as predictors. Research
#> question 1 can be evaluated by examining the statistical significance
#> of skin-tone rating.
#> 
#> Number of games was controlled for because encountering a referee
#> more time increases the likelihood of receiving a red card. We
#> controlled for the outcomes of the games (victories and defeats) and
#> number of goals. Players may be less likely to commit a foul (and
#> thus receive a red card) if their team won the game. In contrast,
#> they may play more aggressive defense and commit fouls if their team
#> lost the game. We controlled for height and weight because
#> conceivably, bigger players may have more advantage fighting for
#> position and thus be more likely to engage in bodily contact, which
#> may increase the chance of committing fouls (and thus, receiving red
#> cards). We controlled for positions because defensive players
#> (goalkeepers and defenders) may commit more fouls and thus receive
#> more red cards. We controlled for age because impulsivity, which may
#> be associated with receiving red cards, tends to decrease with age
#> (Steinberg et al., 2008).
```
