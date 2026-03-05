# Standardized Precipitation Index (SPI-3)
# Schema-Mapped Chained Version

library(SPEI)      # Just for the sample dataset
library(lmom)      # For L-moments and Gamma distribution
library(dplyr)
library(tidyr)
library(ggplot2)
library(slider)
library(lubridate)

# ==============================================================================
# 1. INPUT DATA
# ==============================================================================
data(wichita)
climate_df <- data.frame(
  date = seq.Date(as.Date("1980-01-01"), by = "month", length.out = nrow(wichita)),
  prcp = wichita$PRCP
)

# ==============================================================================
# 2. HELPER FUNCTIONS
# ==============================================================================
calc_spi_probs <- function(x) {
  x_valid <- x[!is.na(x)]
  
  # Guardrail: Need enough total data points
  if (length(x_valid) < 4) return(rep(NA_real_, length(x))) 
  
  # Calculate the probability of zero precipitation (q)
  n_zero <- sum(x_valid == 0)
  q <- n_zero / length(x_valid)
  x_nonzero <- x_valid[x_valid > 0]
  
  # Guardrail: Need enough non-zero points to calculate L-moments
  if (length(x_nonzero) < 3) return(rep(NA_real_, length(x)))
  
  # Fit the Gamma distribution
  lmoms <- lmom::samlmu(x_nonzero)
  params <- lmom::pelgam(lmoms)
  
  # Vectorized probability calculation
  probs <- rep(NA_real_, length(x))
  is_zero <- !is.na(x) & (x == 0)
  is_nonzero <- !is.na(x) & (x > 0)
  
  probs[is_zero] <- q
  probs[is_nonzero] <- q + (1 - q) * lmom::cdfgam(x[is_nonzero], params)
  
  # Clamp probabilities to avoid -Inf/Inf Z-scores in the next step
  pmax(pmin(probs, 0.999999), 0.000001)
}

# ==============================================================================
# 3. SCHEMA-MAPPED PIPELINE (Chained)
# ==============================================================================
results <- climate_df |> 
  arrange(date) |>
  
  # [block-temporal-agg]
  mutate(prcp_3 = slider::slide_dbl(prcp, sum, .before = 2, .complete = TRUE)) |>
  # [/block-temporal-agg]
  
  # Grouping must happen before distribution fitting to handle seasonality
  mutate(cal_month = month(date)) |>
  group_by(cal_month) |>
  
  # [block-dist-fit]
  mutate(probs_3 = calc_spi_probs(prcp_3)) |>
  # [/block-dist-fit]
  
  # [block-normalize]
  mutate(spi_3 = qnorm(probs_3)) |>
  # [/block-normalize]
  
  # Clean up grouping and intermediate columns
  ungroup() |>
  select(-cal_month)

# ==============================================================================
# 4. VISUALIZATION
# ==============================================================================
results |>
  drop_na(spi_3) |>
  mutate(drought = spi_3 < 0) |>
  ggplot(aes(x = date, y = spi_3, fill = drought)) +
  geom_col() +
  geom_hline(yintercept = c(-1, -2), linetype = "dashed", colour = "red") +
  scale_fill_manual(values = c("FALSE" = "steelblue", "TRUE" = "sienna")) +
  labs(
    title = "3-Month Standardized Precipitation Index (SPI-3)",
    x = NULL, y = "SPI-3", fill = "Condition"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")
