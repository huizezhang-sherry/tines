
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tines <a href='https://huizezhang-sherry.github.io/tines/'><img src='figures/imgfile.svg' align="right" height="138.5" alt="tines package hex sticker logo featuring a fork-like branching diagram on a clean background, symbolising the multiverse of analytical paths the package helps explore" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/huizezhang-sherry/tines/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/huizezhang-sherry/tines/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/huizezhang-sherry/tines/graph/badge.svg)](https://app.codecov.io/gh/huizezhang-sherry/tines)
<!-- badges: end -->

The goal of tines is to help analysts document, explore, and communicate
the analytical decisions made during a data analysis. Analytical
decisions are recorded as a schema of steps, and large language models
are used to propose alternative choices at each step and to generate and
validate the corresponding R code. A schema can be expanded into a
multiverse of analyses, letting you see how your conclusions depend on
the analytical choices you made.

## Installation

You can install the released version of tines from CRAN with:

    install.packages("tines")

And the development version from GitHub with:

    # install.packages("remotes")
    remotes::install_github("huizezhang-sherry/tines")

## LLM access

`extract_schema()`, `gen_alternatives()`, `gen_code()`, and
`validate_script()` all call out to an LLM via
[ellmer](https://ellmer.tidyverse.org/). Set the relevant API key as an
environment variable before using them, e.g. for Claude models:

    usethis::edit_r_environ()
    # add a line: ANTHROPIC_API_KEY=your-key-here

See `?ellmer::chat` for the full list of supported providers and their
expected environment variables.

## Example 1 - from a paper to validated code

### `extract_schema()` + `gen_code()` + `validate_script()`

`tines` can turn a methodology section from a paper into a schema,
generate R code that implements it, and validate that the code runs. The
package ships with the methodology text reported by Team 5 in the “many
analysts, one dataset” study of racial bias in football referee
decisions (Silberzahn et al., 2018), along with the football dataset
they all analyzed.

``` r
library(tines)
football_grp5
#> [1] "The two ratings of skin-tone were averaged and rescaled. The new variable was called avgrate01.\n\nCases were excluded if they had missing values on skin-tone-rating, meanIAT or meanExp (listwise deletion) because we wanted to perform all analyses (including research question 2) on the same set of cases.\n\nThe original response variable redCards is uninterpretable because the number of games a player has seen a given referee varies. Therefore we disaggregated the data (one game per row, redCards appear as 1s in the first n=redCards rows per player). This was possible because it does not matter in which of, for example, 3 games a player who received 1 red card in 3 games received the red card. It is sufficient that this player has three observations (three rows) associated with him, one of them indicating a red card. We used the binomial error distribution because – after disaggregation – our response variable specifies the occurence of an event in a single game, coded 0 and 1.\n\nWe estimated generalized linear mixed models (function glmer in R package lme4, Version 1.1-7; Bates, 2010; Bates, Maechler, Bolker, & Walker, 2014). The crowdstorming data are different from standard multilevel data (e.g., where employees are members of only one team), inasmuch as they are not nested but cross-classified – player A can have multiple games with the referee A, but player B can have multiple games with the same referee A. \n\nOur model adds a random effect of playerShort, refNum, and skin-tone across referees’ countries of origin.\n\nWe did not use any covariates, even though reviewers of our approach suggested that we should do so. As already noted in the project description by Silberzahn, Martin, Uhlmann, & Nosek, the data cannot be used for causal inference. \n\n"
```

Extracting a schema from that text requires an LLM and a data
dictionary:

``` r
data_dict <- c(
  "playerShort", "player", "club", "leagueCountry", "birthday", "height",
  "weight", "position", "games", "victories", "ties", "defeats",
  "goals", "yellowCards", "yellowReds", "redCards", "photoID", "rater1",
  "rater2", "refNum", "refCountry", "Alpha_3", "meanIAT", "nIAT",
  "seIAT", "meanExp", "nExp", "seExp"
)

extract_schema(football_grp5, data_dict,
               output_file = here::here("inst/football-grp5.yaml"))
```

<details>

<summary>

You can click to expand the YAML file.
</summary>

``` yaml
meta:
  type: schema
nodes:
- id: create_skin_tone_variable
  objective: how to operationalize player skin tone from multiple rater assessments
  decision: average the two ratings of skin-tone and rescale to create avgrate01
  rationale: to combine multiple rater assessments into a single composite measure
  inputs: [rater1, rater2]
  outputs: [avgrate01]
  confidence: HIGH
  clarification_question: null

- id: handle_missing_data
  objective: how to handle cases with missing values on key variables
  decision: apply listwise deletion excluding cases with missing values on skin-tone-rating, meanIAT, or meanExp
  rationale: to perform all analyses including research question 2 on the same set of cases
  inputs: [avgrate01, meanIAT, meanExp]
  outputs: [df_complete]
  confidence: HIGH
  clarification_question: null

- id: disaggregate_response_variable
  objective: how to handle the response variable given varying number of games per player-referee dyad
  decision: disaggregate data to one game per row where redCards appear as 1s in the first n=redCards rows per player
  rationale: the original response variable redCards is uninterpretable because the number of games a player has seen a given referee varies
  inputs: [df_complete, redCards, games, playerShort, refNum]
  outputs: [df_disaggregated, red_card_binary]
  confidence: MEDIUM
  clarification_question: Which column indicates the total number of games per player-referee combination for disaggregation?

- id: select_error_distribution
  objective: which error distribution to use for modeling the response variable
  decision: use binomial error distribution
  rationale: after disaggregation the response variable specifies the occurrence of an event in a single game coded 0 and 1
  inputs: [red_card_binary]
  outputs: [distribution_spec]
  confidence: HIGH
  clarification_question: null

- id: specify_random_effects_structure
  objective: how to account for the non-nested cross-classified data structure
  decision: add random effects of playerShort, refNum, and skin-tone across referees countries of origin
  rationale: the crowdstorming data are cross-classified where players can have multiple games with multiple referees
  inputs: [playerShort, refNum, avgrate01, refCountry]
  outputs: [ranef_spec]
  confidence: MEDIUM
  clarification_question: Is refCountry the correct column representing referees countries of origin for the random slope specification?

- id: select_covariates
  objective: whether and which covariates to include in the model
  decision: do not include any covariates
  rationale: the data cannot be used for causal inference as noted in the project description
  inputs: [df_disaggregated]
  outputs: [covariate_spec]
  confidence: HIGH
  clarification_question: null

- id: fit_glmm
  objective: which modeling framework to use for the analysis
  decision: estimate generalized linear mixed models 
  rationale: appropriate for binary outcome with cross-classified random effects structure
  inputs: [df_disaggregated, red_card_binary, avgrate01, ranef_spec, distribution_spec, covariate_spec]
  outputs: [glmm_model]
  confidence: HIGH
  clarification_question: null
```

</details>

The YAML file can be loaded with `read_schema()`. Here the data is also
stored in the package as `example_football_grp5()`:

``` r
(schema <- example_football_grp5())
#> # A schema: 7 x 8
#>   id       objective decision rationale confidence clarification_question inputs
#>   <chr>    <chr>     <chr>    <chr>     <chr>      <chr>                  <list>
#> 1 create_… how to o… average… to combi… HIGH       <NA>                   <chr> 
#> 2 handle_… how to h… apply l… to perfo… HIGH       <NA>                   <chr> 
#> 3 disaggr… how to h… disaggr… the orig… MEDIUM     Which column indicate… <chr> 
#> 4 select_… which er… use bin… after di… HIGH       <NA>                   <chr> 
#> 5 specify… how to a… add ran… the crow… MEDIUM     Is refCountry the cor… <chr> 
#> 6 select_… whether … do not … the data… HIGH       <NA>                   <chr> 
#> 7 fit_glmm which mo… estimat… appropri… HIGH       <NA>                   <chr> 
#> # ℹ 1 more variable: outputs <list>
```

Generate an R script that implements the schema against the actual data:

``` r
gen_code(schema, data = here::here("inst/football.csv"),
         output = here::here("inst/football-grp5.R"))
```

<details>

<summary>

You can click to expand the generated R script.
</summary>

``` r
# Load required libraries
library(readr)
library(dplyr)
library(glmmTMB)

# Load the data
df <- read_csv("data/football.csv")

# Step 1: create_skin_tone_variable
# Average the two ratings of skin-tone and rescale to create avgrate01
# Input: rater1, rater2
# Output: avgrate01
df <- df %>%
  mutate(avgrate01 = (rater1 + rater2) / 2)

# Rescale to 0-1 range
avgrate_min <- min(df$avgrate01, na.rm = TRUE)
avgrate_max <- max(df$avgrate01, na.rm = TRUE)
df <- df %>%
  mutate(avgrate01 = (avgrate01 - avgrate_min) / (avgrate_max - avgrate_min))

# Step 2: handle_missing_data
# Apply listwise deletion for cases missing skin-tone-rating, meanIAT, or meanExp
# Input: avgrate01, meanIAT, meanExp
# Output: df_complete
df_complete <- df %>%
  filter(!is.na(avgrate01) & !is.na(meanIAT) & !is.na(meanExp))

# Step 3: disaggregate_response_variable
# Disaggregate data to one game per row with redCards appearing as 1s in first n rows per player
# Input: df_complete, redCards, games
# Output: df_disaggregated, red_card_binary
df_disaggregated <- df_complete %>%
  filter(games > 0) %>%
  rowwise() %>%
  do({
    row_data <- .
    n_games <- row_data$games
    n_red_cards <- min(row_data$redCards, n_games)  # Ensure red cards don't exceed games
    
    # Create expanded rows
    expanded <- data.frame(
      playerShort = rep(row_data$playerShort, n_games),
      refNum = rep(row_data$refNum, n_games),
      refCountry = rep(row_data$refCountry, n_games),
      avgrate01 = rep(row_data$avgrate01, n_games),
      meanIAT = rep(row_data$meanIAT, n_games),
      meanExp = rep(row_data$meanExp, n_games),
      red_card_binary = c(rep(1, n_red_cards), rep(0, n_games - n_red_cards)),
      stringsAsFactors = FALSE
    )
    expanded
  }) %>%
  ungroup()

# Ensure factor variables for random effects
df_disaggregated <- df_disaggregated %>%
  mutate(
    playerShort = as.factor(playerShort),
    refNum = as.factor(refNum),
    refCountry = as.factor(refCountry)
  )

# Step 4: select_error_distribution
# Use binomial error distribution
# Input: red_card_binary
# Output: error_distribution_spec
error_distribution_spec <- binomial(link = "logit")

# Step 5: specify_random_effects_structure
# Add random effects for playerShort, refNum, and skin-tone across referees countries of origin
# Input: df_disaggregated, playerShort, refNum, avgrate01, refCountry
# Output: ranef_spec
ranef_spec <- "(1 | playerShort) + (1 | refNum) + (0 + avgrate01 | refCountry)"

# Step 6: covariate_inclusion_decision
# Do not use any covariates
# Input: df_disaggregated
# Output: covariate_spec
covariate_spec <- NULL

# Step 7: fit_glmm
# Estimate generalized linear mixed models using glmer in R package lme4
# Input: df_disaggregated, red_card_binary, avgrate01, ranef_spec, error_distribution_spec, covariate_spec
# Output: glmm_model

# Build the formula
# Fixed effect: avgrate01 (skin tone predictor)
# Random effects: as specified in ranef_spec
# No covariates as specified in covariate_spec

formula_string <- paste("red_card_binary ~ avgrate01 +", ranef_spec)
model_formula <- as.formula(formula_string)

# Fit the GLMM
glmm_model <- glmmTMB(
  formula = model_formula,
  data = df_disaggregated,
  family = error_distribution_spec,
)

# Print model summary
summary(glmm_model)
```

</details>

When the script generator didn’t produce valid code in the first
attempt, `validate_script()` can be used to iteratively fix it until it
runs:

``` r
validate_script(here::here("inst/football-grp5.R"), data = here::here("inst/football.csv"))
```

## Example 2 - exploring alternatives

### `draft_alternatives()`/`gen_alternatives()` + `expand_tines()` + `gen_code()` + `validate_script()`

Given a schema, you may want to explore alternative analytical choices.
You can write an alternative YAML file by hands from the template
(`draft_alternatives()`) or ask LLM to propose alternatives for a step
in the schema (`gen_alternatives()`).

Here we have a pre-written alternative YAML file for the football
example with different random effect specifications:

<details>

<summary>

You can click to expand the alternative YAML file.
</summary>

``` yaml
meta:
  type: alternatives
  step: specify_random_effects_structure
  objective: how to account for the non-nested cross-classified data structure
alternatives:
  - id: "gm1"
    decision: "a random effect of player and referee"
    rationale: ""
    input: []
    output: []
  - id: "gm2"
    decision: "a random effect of player and referee, and a random effect of skin-tone across referees"
    rationale: ""
    input: []
    output: []
  - id: "gm3"
    decision: "a random effect of player, referee, and referees' countries of origin, and a random effect of skin tone across referees' countries of origin"
    rationale: ""
    input: []
    output: []
```

</details>

You can load an alternative YAML file with `read_alternatives()`:

``` r
(alts <- read_alternatives(
  system.file("football-grp5/football-grp5-alt.yml", package = "tines")
))
#> # Alternatives: specify_random_effects_structure
#>   id    decision                                                       rationale
#>   <chr> <chr>                                                          <chr>    
#> 1 gm1   a random effect of player and referee                          ""       
#> 2 gm2   a random effect of player and referee, and a random effect of… ""       
#> 3 gm3   a random effect of player, referee, and referees' countries o… ""
```

Combine the alternatives with the original schema into a multiverse:

``` r
(multiverse <- expand_tines(schema, alts))
#> A multiverse with 4 schemas:
#>   original: (7 steps)
#>   gm1: (7 steps)
#>   gm2: (7 steps)
#>   gm3: (7 steps)
```

After this, you can enerate code for every branch of the multiverse as
we did for the original schema, and validate each generated script:

``` r
gen_code(multiverse, data = here::here("inst/football.csv"),
         output = here::here("inst/football-grp5-alternatives/"))

files <- list.files(here::here("inst/football-grp5-alternatives"),
                     pattern = "\\.R$", full.names = TRUE)
purrr::map(files, ~validate_script(.x, data = here::here("inst/football.csv")))
```

<details>

<summary>

You can click to view the script generated for alternative gm1.
</summary>

``` yaml
library(readr)
library(dplyr)
library(glmmTMB)

df <- readr::read_csv("data/football.csv")

df <- df %>%
  mutate(avgrate01 = (rater1 + rater2) / 2)

df_complete <- df %>%
  filter(!is.na(avgrate01) & !is.na(meanIAT) & !is.na(meanExp))

df_filtered <- df_complete %>%
  filter(games > 0)

expand_row <- function(i, data) {
  row <- data[i, ]
  n_games <- row$games
  n_red <- min(row$redCards, n_games)
  
  red_card_binary <- c(rep(1, n_red), rep(0, n_games - n_red))
  
  expanded <- row[rep(1, n_games), ]
  expanded$red_card_binary <- red_card_binary
  expanded
}

df_disaggregated <- do.call(rbind, lapply(seq_len(nrow(df_filtered)), expand_row, data = df_filtered))

distribution_spec <- "binomial"

ranef_spec <- "(1 | playerShort) + (1 | refNum)"

covariate_spec <- NULL

if (is.null(covariate_spec)) {
  formula_str <- paste("red_card_binary ~ avgrate01 +", ranef_spec)
} else {
  formula_str <- paste("red_card_binary ~ avgrate01 +", 
                       paste(covariate_spec, collapse = " + "), "+", 
                       ranef_spec)
}

glmm_formula <- as.formula(formula_str)

glmm_model <- glmmTMB(
  formula = glmm_formula,
  data = df_disaggregated,
  family = binomial
)

summary(glmm_model)
```

</details>

<details>

<summary>

You can click to view the script generated for each alternative gm2.
</summary>

``` yaml
library(readr)
library(dplyr)
library(glmmTMB)

# Load the data
df <- readr::read_csv("data/football.csv")

# Step 1: create_skin_tone_variable
# Average the two ratings of skin-tone and rescale to create avgrate01
# Inputs: rater1, rater2
# Output: avgrate01
df <- df %>%
  mutate(avgrate01 = (rater1 + rater2) / 2)

# Step 2: handle_missing_data
# Apply listwise deletion excluding cases with missing values on skin-tone-rating, meanIAT, or meanExp
# Inputs: avgrate01, meanIAT, meanExp
# Output: df_complete
df_complete <- df %>%
  filter(!is.na(avgrate01) & !is.na(meanIAT) & !is.na(meanExp))

# Step 3: disaggregate_response_variable
# Disaggregate data to one game per row where redCards appear as 1s in the first n=redCards rows per player
# Inputs: df_complete, redCards, games, playerShort, refNum
# Outputs: df_disaggregated, red_card_binary
df_disaggregated <- df_complete %>%
  filter(games > 0) %>%
  group_by(row_number()) %>%
  do({
    row <- as.data.frame(.)
    n_games <- row$games[1]
    n_red <- min(row$redCards[1], n_games)
    
    # Create red_card_binary: 1 for first n_red rows, 0 for remaining
    red_card_values <- c(rep(1, n_red), rep(0, n_games - n_red))
    
    # Replicate the row for each game
    expanded <- row[rep(1, n_games), ]
    expanded$red_card_binary <- red_card_values
    expanded
  }) %>%
  ungroup()

# Step 4: select_error_distribution
# Use binomial error distribution
# Input: red_card_binary
# Output: distribution_spec
distribution_spec <- "binomial"

# Step 5: gm2
# A random effect of skin-tone across referees and a random effect of player
# Inputs: playerShort, refNum, avgrate01, refCountry
# Output: ranef_spec
ranef_spec <- "(1 + avgrate01 | refNum) + (1 | playerShort)"

# Step 6: select_covariates
# Do not include any covariates
# Input: df_disaggregated
# Output: covariate_spec
covariate_spec <- NULL

# Step 7: fit_glmm
# Estimate generalized linear mixed models
# Inputs: df_disaggregated, red_card_binary, avgrate01, ranef_spec, distribution_spec, covariate_spec
# Output: glmm_model

# Build the formula
# Fixed effect: avgrate01
# Random effects: random slope of avgrate01 across referees + random intercept of player
if (is.null(covariate_spec)) {
  formula_string <- paste0("red_card_binary ~ avgrate01 + ", ranef_spec)
} else {
  formula_string <- paste0("red_card_binary ~ avgrate01 + ", 
                           paste(covariate_spec, collapse = " + "), " + ", ranef_spec)
}

glmm_formula <- as.formula(formula_string)

# Fit the generalized linear mixed model
glmm_model <- glmmTMB(
  formula = glmm_formula,
  data = df_disaggregated,
  family = binomial
)

# Display model summary
summary(glmm_model)
```

</details>

<details>

<summary>

You can click to view the script generated for each alternative gm3.
</summary>

``` yaml
library(readr)
library(dplyr)
library(glmmTMB)

# Load data from file
df <- readr::read_csv("data/football.csv")

# Step 1: create_skin_tone_variable
# Average the two ratings of skin-tone and rescale to create avgrate01
# Inputs: rater1, rater2
# Output: avgrate01
df <- df %>%
  mutate(avgrate01 = (rater1 + rater2) / 2)

# Step 2: handle_missing_data
# Apply listwise deletion excluding cases with missing values on skin-tone-rating, meanIAT, or meanExp
# Inputs: avgrate01, meanIAT, meanExp
# Output: df_complete
df_complete <- df %>%
  filter(!is.na(avgrate01) & !is.na(meanIAT) & !is.na(meanExp))

# Step 3: disaggregate_response_variable
# Disaggregate data to one game per row where redCards appear as 1s in the first n=redCards rows per player
# Inputs: df_complete, redCards, games, playerShort, refNum
# Outputs: df_disaggregated, red_card_binary
df_disaggregated <- df_complete %>%
  filter(games > 0) %>%
  group_by(row_number()) %>%
  group_modify(~ {
    row_data <- .x
    n_games <- row_data$games[1]
    n_red <- min(row_data$redCards[1], n_games)
    
    # Create red_card_binary: 1 for first n_red games, 0 for remaining
    red_card_values <- c(rep(1, n_red), rep(0, n_games - n_red))
    
    # Replicate the row for each game
    expanded <- row_data[rep(1, n_games), ]
    expanded$red_card_binary <- red_card_values
    expanded
  }) %>%
  ungroup()

# Step 4: select_error_distribution
# Use binomial error distribution
# Input: red_card_binary
# Output: distribution_spec
distribution_spec <- "binomial"

# Step 5: gm3
# A random effect of player and referee, and a random effect of skin tone across referees' countries of origin
# Inputs: playerShort, refNum, avgrate01, refCountry
# Output: ranef_spec
ranef_spec <- "(1 | playerShort) + (1 | refNum) + (1 + avgrate01 | refCountry)"

# Step 6: select_covariates
# Do not include any covariates
# Input: df_disaggregated
# Output: covariate_spec
covariate_spec <- NULL

# Step 7: fit_glmm
# Estimate generalized linear mixed models
# Inputs: df_disaggregated, red_card_binary, avgrate01, ranef_spec, distribution_spec, covariate_spec
# Output: glmm_model

# Build the formula
# Fixed effect: avgrate01
# Random effects: as specified in ranef_spec
# No additional covariates
formula_string <- paste("red_card_binary ~ avgrate01 +", ranef_spec)
model_formula <- as.formula(formula_string)

# Fit the generalized linear mixed model
glmm_model <- glmmTMB(
  formula = model_formula,
  data = df_disaggregated,
  family = binomial
)

# Display model summary
summary(glmm_model)
```

</details>
