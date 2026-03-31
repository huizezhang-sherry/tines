# Construct \`alternatives\` objects

Construct \`alternatives\` objects

## Usage

``` r
alternative(id, action, decision, justification)

new_alternatives(id, ...)
```

## Arguments

- id:

  The target step ID in the schema that these alternatives pertain to.

- action:

  The goal of the step (should match the original).

- decision:

  The new method/implementation.

- justification:

  Why this method is valid.

- ...:

  One or more alternative branches created by \`alternative()\`.

## Examples

``` r
example_alternatives(case = "football")
#> $step
#> [1] "step-logistic-model"
#> 
#> [[2]]
#> [[2]]$id
#> [1] "step-probit-regression-model"
#> 
#> [[2]]$action
#> [1] "estimate the effect size of skin tone on red card"
#> 
#> [[2]]$decision
#> [1] "fit a probit regression model using the average skin tone rating and specified covariates"
#> 
#> [[2]]$justification
#> [1] "probit models provide a methodologically valid alternative to logistic regression by assuming a normally distributed latent variable, serving as a sensitivity check for the choice of link function"
#> 
#> 
#> [[3]]
#> [[3]]$id
#> [1] "step-bayesian-logistic-model"
#> 
#> [[3]]$action
#> [1] "estimate the effect size of skin tone on red card"
#> 
#> [[3]]$decision
#> [1] "fit a Bayesian logistic regression model with the average skin tone rating as a predictor and weakly informative priors"
#> 
#> [[3]]$justification
#> [1] "the Bayesian approach provides a complete posterior distribution of the effect size rather than a point estimate, allowing for a more nuanced probabilistic interpretation of the skin tone effect and its uncertainty"
#> 
#> 
#> attr(,"class")
#> [1] "alternatives" "list"        
#> attr(,"id")
#> attr(,"id")$id
#> [1] "step-mixed-effects-logistic-model"
#> 
#> attr(,"id")$action
#> [1] "estimate the effect size of skin tone on red card"
#> 
#> attr(,"id")$decision
#> [1] "fit a generalized linear mixed-effects model (GLMM) with random intercepts for players and referees to account for hierarchical data structure"
#> 
#> attr(,"id")$justification
#> [1] "mixed-effects models are appropriate for clustered data as they control for non-independence of observations within players and referees, leading to more reliable standard errors and effect estimates"
#> 
```
