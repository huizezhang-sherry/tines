# Load necessary libraries
# install.packages(c("dplyr", "zoo")) # Uncomment to install if not already installed
library(dplyr)
library(zoo)

# --- 0. Define input data and parameters ---
# For demonstration purposes, we create synthetic time series data.
# In a real scenario, these would come from actual climate data.

# Number of months for the synthetic data
n_months <- 240 # 20 years of monthly data

# Simulate a sequence of dates
dates <- seq(as.Date("2000-01-01"), by = "month", length.out = n_months)

# Simulate average monthly temperature (Celsius)
# Varying seasonally around a mean
set.seed(123)
.proxy_tavg <- data.frame(
  date = dates,
  tavg = 10 + 10 * sin(2 * pi * (0:(n_months - 1)) / 12) + rnorm(n_months, 0, 2)
) %>%
  mutate(tavg = pmax(-5, tavg)) # Ensure tavg doesn't go too low

# Simulate monthly precipitation (mm)
.proxy_prcp <- data.frame(
  date = dates,
  prcp = 50 + 40 * sin(2 * pi * (0:(n_months - 1)) / 12 + pi/4) + rnorm(n_months, 0, 15)
) %>%
  mutate(prcp = pmax(0, prcp)) # Ensure precipitation is non-negative

# Combine into a single data frame for easier piping
climate_data <- full_join(.proxy_tavg, .proxy_prcp, by = "date") %>%
  arrange(date)

# Define parameters for the pipeline steps
latitude <- 40 # Degrees N or S, used in PET calculation (simplified Thornthwaite)
aggregation_window_months <- 3 # e.g., 3-month RDI
log_epsilon <- 0.001 # Small constant to handle log of zero/small values and division by near-zero PET

# --- 1. block-calc-pet: Calculate Potential Evapotranspiration (PET) ---
# Action: transform average temperature to obtain potential evapotranspiration (PET)
# Decision: use Thornthwaite equation (simplified for demonstration)
# Input: .proxy_tavg (represented by 'tavg' column in climate_data)
# Output: .proxy_pet (new 'pet' column)

# A truly accurate Thornthwaite PET calculation is complex, involving:
# 1. Monthly heat index calculation (i = (T_month / 5)^1.514 for T_month > 0).
# 2. Annual heat index (I = sum of i for all months).
# 3. An exponent 'a' as a function of I.
# 4. Day length adjustment factors based on month and latitude.
# For this pipeline demonstration, we use a simplified empirical formula
# that captures the general idea of PET increasing with temperature and influenced by latitude,
# without implementing the full Thornthwaite complexity.
thornthwaite_simplified <- function(tavg_celsius, latitude_deg) {
  # This is a placeholder simplified model for demonstration purposes.
  # It aims to represent PET as a function of temperature, capped at zero,
  # and influenced by latitude. A real Thornthwaite implementation is more involved.

  # Base PET from temperature (empirical approximation, not a direct Thornthwaite formula)
  # Thornthwaite generally only calculates for Tavg > 0.
  pet_val <- pmax(0, (tavg_celsius * 0.45) - 2)

  # A simple latitude adjustment factor (more realistic Thornthwaite uses specific tables)
  # This factor is heuristic; higher PET for lower absolute latitudes, generally.
  latitude_adjustment <- 1 + (90 - abs(latitude_deg)) / 90 * 0.5

  pet_val <- pet_val * latitude_adjustment

  return(pet_val)
}

pipeline_data <- climate_data %>%
  mutate(
    .proxy_pet = thornthwaite_simplified(tavg_celsius = tavg, latitude_deg = latitude)
  )

# --- 2. block-calc-ratio: Calculate P/PET Ratio ---
# Action: calculate the ratio of precipitation to PET
# Decision: divide precipitation by PET
# Inputs: .proxy_prcp, .proxy_pet
# Output: .proxy_ratio (new 'ratio' column)

pipeline_data <- pipeline_data %>%
  mutate(
    # Add a small epsilon to PET to avoid division by zero or extremely large ratios
    # when PET is very close to zero.
    .proxy_ratio = .proxy_prcp / (.proxy_pet + log_epsilon)
  )

# --- 3. block-temporal-agg: Perform Temporal Aggregation ---
# Action: perform temporal aggregation on the input precipitation series
# Decision: calculate rolling sum over user-defined time scale
# Input: .proxy_ratio
# Output: .proxy_agg (new 'agg' column)

pipeline_data <- pipeline_data %>%
  # Arrange by date to ensure correct rolling sum calculation
  arrange(date) %>%
  mutate(
    # Calculate rolling sum of .proxy_ratio over `aggregation_window_months` periods.
    # `rollsumr` (rolling sum, right-aligned) ensures the sum includes the current
    # month and the previous `k-1` months.
    # `fill = NA` will introduce NA values at the start, which is common for rolling calculations.
    .proxy_agg = rollsumr(.proxy_ratio, k = aggregation_window_months, fill = NA)
  )

# --- 4. block-log-transform: Log10 Transformation ---
# Action: take log10 of aggregated series
# Decision: apply log10 transformation
# Input: .proxy_agg
# Output: .proxy_y (new 'y' column)

pipeline_data <- pipeline_data %>%
  mutate(
    # Apply log10 transformation.
    # Add a small epsilon to handle cases where .proxy_agg might be zero or very small,
    # preventing -Inf results which can occur if the aggregated ratio is zero.
    .proxy_y = log10(.proxy_agg + log_epsilon)
  )

# --- 5. block-zscore: Rescale to Standard Normal ---
# Action: rescale to standard normal
# Decision: calculate z-score (y - mean / sd)
# Input: .proxy_y
# Output: .proxy_index (new 'index' column)

# For real drought indices like RDI, the mean and standard deviation are typically
# calculated over a long-term historical reference period (e.g., 30 years),
# not from the potentially shorter current dataset. For this pipeline demonstration,
# we calculate them from the available data, filtering out NA values.
mean_y <- mean(pipeline_data$.proxy_y, na.rm = TRUE)
sd_y <- sd(pipeline_data$.proxy_y, na.rm = TRUE)

pipeline_data <- pipeline_data %>%
  mutate(
    .proxy_index = (.proxy_y - mean_y) / sd_y
  )

# --- Final Output ---
# The 'pipeline_data' data frame now contains all intermediate and final results.
# The final RDI-like index is in the '.proxy_index' column.

message("Pipeline completed. Displaying the tail of the resulting data:")
print(tail(pipeline_data))

# Optional: Plot the final index to visualize the results
# library(ggplot2)
# ggplot(pipeline_data, aes(x = date, y = .proxy_index)) +
#   geom_line(color = "steelblue") +
#   labs(title = paste("Standardized Drought Index (", aggregation_window_months, "-month aggregation)", sep=""),
#        x = "Date", y = "Index Value") +
#   theme_minimal() +
#   geom_hline(yintercept = 0, linetype = "dashed", color = "red")
