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
