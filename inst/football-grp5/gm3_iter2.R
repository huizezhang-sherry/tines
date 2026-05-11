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
