library(tidyverse)
tidyindex::hdi |>
  mutate(life_exp = (life_exp - 20) / (85 - 20),
         exp_sch = (exp_sch - 0) / (18 - 0),
         exp_sch = ifelse(exp_sch > 1, 1, exp_sch),
         avg_sch = (avg_sch - 0) / (15 - 0),
         avg_sch = ifelse(avg_sch > 1, 1, avg_sch),
         gni_pc2 = (gni_pc - 2)/ (4.88 - 2)) |>
  mutate(education = (exp_sch + avg_sch) / 2) |>
  mutate(hdi2 = (life_exp + education + gni_pc2) / 3)
