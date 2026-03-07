library(tidyverse)
df_raw <- read_csv(here::here("data/football.csv"))
df <- df_raw |>
  filter(!is.na(rater1), !is.na(rater2)) |>
  mutate(position = as.factor(position),
         leagueCountry = as.factor(leagueCountry),
         skin_tone = (rater1 + rater2) / 2,
         #red = yellowReds + redCards,  I still think it should be YellowRed + red because the question asks "Are soccer referees more likely to give red cards to dark skin toned players than light skin toned players?" YellowRed is a red card by conventional football interpretation.
         victory_ratio = victories/games,
         tie_ratio = ties/games,
         defeat_ratio = defeats/games)

mod <- glm(redcard ~ skin_tone + position + weight + height +
             leagueCountry + victory_ratio + defeat_ratio,
           data = df, family = "binomial", na.action = na.omit)
summary(mod)
exp(tidy(mod)$estimate[2])
