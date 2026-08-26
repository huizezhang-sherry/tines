football_grp20_raw <- c(
  'Two variables – age and rating of skin tone – were created. Age was created by
subtracting the last four characters of the “birthday” variable (which represented birth years)
from 2013. Rating of skin tone was created by averaging the ratings of skin tone (coded 0-1)
from the two raters ("rater1" and "rater2").
For players with missing data ("NA") in the “position” variable, Wikipedia was used to
find out what positions these players played. Positions were coded using 4 categories:
goalkeeper, defender, midfielder, and forward/winger. These 4 categories were used because
Wikipedia did not provide specific enough information for certain players. The original position
variable was then recoded using these 4 categories: goalkeeper, defender (center back, left
fullback, and right fullback), midfielder (defensive midfielder, center midfielder, attacking
midfielder, left midfielder, and right midfielder), and forward/winger (forward, left winger, and
right winger). While some information was lost by merging some of the categories, this
procedure increased the number of observations with known positions from 115,457 to 124,468.
Several predictors and covariates were grand-mean centered (skin-tone rating, height,
weight, number of games, number of victories, number of defeats, number of goals, and age). To
clarify, grand-mean centering means that we computed the mean of a variable and subtracted
each value of the variable from the mean. This procedure improves the interpretability of the
intercept and the interaction terms. Scores on implicit racial bias and explicit racial bias were
standardized.
Players with missing data on skin tone (“rater1” and “rater2”) were excluded because
skin tone is the main predictor in the current study.',
  "A four-level multilevel negative-binomial model was used to test the hypotheses. A
multilevel model with player-referee dyads as level-1, players as level-2, clubs as level-3, and
leagues as level-4 was used. This model accounts for the interdependence within players, clubs,
and leagues. That is, the likelihood of receiving a red card may differ from players to players,
from clubs to clubs, and from leagues to leagues. As a hypothetical example, Arsenal as a club
may tend to receive more red cards compared to Manchester United. The multilevel structure
helps account for similarities in likelihood to receive red cards within Arsenal and within
Manchester United. A negative-binomial model was used because the dependent variable
(number of red cards received; “redCards”) was a count variable.
Number of red cards received was entered as the dependent variable. Skin-tone rating,
implicit racial bias, explicit racial bias, the interaction between skin-tone and implicit racial bias,
the interaction between skin-tone and explicit racial bias, number of games, victories, and
defeats, height, weight, age, number of goals, and dummy-coded positions were all entered as
predictors. Research question 1 can be evaluated by examining the statistical significance of
skin-tone rating.",
  "Number of games was controlled for because encountering a referee more time increases
the likelihood of receiving a red card. We controlled for the outcomes of the games (victories
and defeats) and number of goals. Players may be less likely to commit a foul (and thus receive a
red card) if their team won the game. In contrast, they may play more aggressive defense and
commit fouls if their team lost the game. We controlled for height and weight because
conceivably, bigger players may have more advantage fighting for position and thus be more
likely to engage in bodily contact, which may increase the chance of committing fouls (and thus,
receiving red cards). We controlled for positions because defensive players (goalkeepers and
defenders) may commit more fouls and thus receive more red cards. We controlled for age
because impulsivity, which may be associated with receiving red cards, tends to decrease with
age (Steinberg et al., 2008)."
)

football_grp20 <- paste(football_grp20_raw, collapse = "\n\n")

usethis::use_data(football_grp20, overwrite = TRUE)


football_grp5_raw <- c("The two ratings of skin-tone were averaged and rescaled. The new variable was called avgrate01.

Cases were excluded if they had missing values on skin-tone-rating, meanIAT or meanExp (listwise deletion) because we wanted to perform all analyses (including research question 2) on the same set of cases.

The original response variable redCards is uninterpretable because the number of games a player has seen a given referee varies. Therefore we disaggregated the data (one game per row, redCards appear as 1s in the first n=redCards rows per player). This was possible because it does not matter in which of, for example, 3 games a player who received 1 red card in 3 games received the red card. It is sufficient that this player has three observations (three rows) associated with him, one of them indicating a red card. We used the binomial error distribution because – after disaggregation – our response variable specifies the occurence of an event in a single game, coded 0 and 1.

We estimated generalized linear mixed models (function glmer in R package lme4, Version 1.1-7; Bates, 2010; Bates, Maechler, Bolker, & Walker, 2014). The crowdstorming data are different from standard multilevel data (e.g., where employees are members of only one team), inasmuch as they are not nested but cross-classified – player A can have multiple games with the referee A, but player B can have multiple games with the same referee A.

Our model adds a random effect of playerShort, refNum, and skin-tone across referees’ countries of origin.

We did not use any covariates, even though reviewers of our approach suggested that we should do so. As already noted in the project description by Silberzahn, Martin, Uhlmann, & Nosek, the data cannot be used for causal inference.

")

football_grp5 <- paste(football_grp5_raw, collapse = "\n\n")

usethis::use_data(football_grp5, overwrite = TRUE)
