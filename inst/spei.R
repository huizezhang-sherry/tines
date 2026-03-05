# Standardized Precipitation-Evapotranspiration Index (SPEI-3)
# Schema-Mapped Chained Version

library(SPEI)
library(lmom)
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
  prcp = wichita$PRCP,
  temp = wichita$TMED,
  lat  = 37.7
)

# ==============================================================================
# 2. HELPER FUNCTIONS
# ==============================================================================
calc_spei_probs <- function(x) {
  x_valid <- x[!is.na(x)]
  
  if (length(x_valid) < 4) return(rep(NA_real_, length(x))) 
  
  lmoms <- lmom::samlmu(x_valid)
  params <- lmom::pelglo(lmoms)
  
  probs <- rep(NA_real_, length(x))
  probs[!is.na(x)] <- lmom::cdfglo(x[!is.na(x)], params)
  
  pmax(pmin(probs, 0.999999), 0.000001)
}

# ==============================================================================
# 3. SCHEMA-MAPPED PIPELINE (Chained)
# ==============================================================================
results <- climate_df |> 
  arrange(date) |>
  
  # [block-calc-pet]
  mutate(pet = as.numeric(SPEI::thornthwaite(temp, lat[1]))) |>
  # [/block-calc-pet]
  
  # [block-calc-diff]
  mutate(wb = prcp - pet) |>
  # [/block-calc-diff]
  
  # [block-temporal-agg]
  mutate(wb_3 = slider::slide_dbl(wb, sum, .before = 2, .complete = TRUE)) |>
  # [/block-temporal-agg]
  
  # Grouping must happen before distribution fitting to handle seasonality
  mutate(cal_month = month(date)) |>
  group_by(cal_month) |>
  
  # [block-dist-fit]
  mutate(probs_3 = calc_spei_probs(wb_3)) |>
  # [/block-dist-fit]
  
  # [block-normalize]
  mutate(spei_3 = qnorm(probs_3)) |>
  # [/block-normalize]
  
  # Clean up grouping and intermediate columns
  ungroup() |>
  select(-cal_month)

# ==============================================================================
# 4. VISUALIZATION
# ==============================================================================
results |>
  drop_na(spei_3) |>
  mutate(drought = spei_3 < 0) |>
  ggplot(aes(x = date, y = spei_3, fill = drought)) +
  geom_col() +
  geom_hline(yintercept = c(-1, -2), linetype = "dashed", colour = "red") +
  scale_fill_manual(values = c("FALSE" = "steelblue", "TRUE" = "sienna")) +
  labs(
    title = "3-Month Standardized Precipitation-Evapotranspiration Index (SPEI-3)",
    x = NULL, y = "SPEI-3", fill = "Condition"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")
