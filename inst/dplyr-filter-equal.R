library(dplyr)
library(here)

df <- read.csv(here::here("data/dplyr-filter-equal.csv"))

it_staff <- df %>%
  filter(department == "IT")

print(it_staff)
