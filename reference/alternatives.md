# Construct \`alternatives\` objects

Construct \`alternatives\` objects

## Usage

``` r
alternative(id, objective, decision, rationale)

new_alternatives(step, ...)
```

## Arguments

- id:

  Unique identifier for this alternative (kebab-case).

- objective:

  The decision point or goal of the step (should match the original).

- decision:

  The new method/implementation.

- rationale:

  Why this method is valid.

- step:

  The target step ID in the schema that these alternatives pertain to.

- ...:

  One or more alternative branches created by \`alternative()\`.

## Examples

``` r
example_alternatives(case = "football")
#> # Alternatives: step-logistic-model
#>   id                                objective                 decision rationale
#>   <chr>                             <chr>                     <chr>    <chr>    
#> 1 step-mixed-effects-logistic-model estimate the effect size… fit a g… mixed-ef…
#> 2 step-probit-regression-model      estimate the effect size… fit a p… probit m…
#> 3 step-bayesian-logistic-model      estimate the effect size… fit a B… the Baye…
```
