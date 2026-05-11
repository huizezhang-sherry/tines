library(readr)
library(dplyr)
library(glmmTMB)

# Load the data
df <- read_csv("data/football.csv")

# Step 1: Create skin tone variable
# Average the two ratings of skin-tone and rescale to create avgrate01
df <- df %>%
  mutate(avgrate01 = (rater1 + rater2) / 2)

# Step 2: Handle missing data
# Apply listwise deletion excluding cases with missing values on skin-tone-rating, meanIAT, or meanExp
df_complete <- df %>%
  filter(!is.na(avgrate01) & !is.na(meanIAT) & !is.na(meanExp))

# Step 3: Disaggregate response variable
# Disaggregate data to one game per row where redCards appear as 1s in the first n=redCards rows per player
df_disaggregated <- df_complete %>%
  select(playerShort, refNum, redCards, games, avgrate01, refCountry) %>%
  rowwise() %>%
  mutate(
    n_games = games,
    n_red = redCards
  ) %>%
  ungroup()

# Create disaggregated dataset with one row per game
df_disaggregated <- df_disaggregated %>%
  slice(rep(1:n(), times = games)) %>%
  group_by(playerShort, refNum) %>%
  mutate(
    game_num = row_number(),
    red_card_binary = as.integer(game_num <= redCards)
  ) %>%
  ungroup() %>%
  select(-game_num, -n_games, -n_red, -games, -redCards)

# Step 4: Select error distribution
# Use binomial error distribution
distribution_spec <- "binomial"

# Step 5: Specify random effects structure
# Add random effects of playerShort, refNum, and skin-tone across referees countries of origin
ranef_spec <- "(1|playerShort) + (1|refNum) + (0 + avgrate01|refCountry)"

# Step 6: Select covariates
# Do not include any covariates
covariate_spec <- NULL

# Step 7: Fit GLMM
# Estimate generalized linear mixed models
# Build formula with random effects and no covariates
formula_string <- paste("red_card_binary ~ avgrate01 +", ranef_spec)
model_formula <- as.formula(formula_string)

# Fit the model
glmm_model <- glmmTMB(
  formula = model_formula,
  data = df_disaggregated,
  family = binomial
)

# Print model summary
summary(glmm_model)
