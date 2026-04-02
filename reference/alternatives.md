# Construct \`alternatives\` objects

Construct \`alternatives\` objects

## Usage

``` r
alternative(id, action, decision, justification)

new_alternatives(step, ...)
```

## Arguments

- id:

  Unique identifier for this alternative (kebab-case).

- action:

  The goal of the step (should match the original).

- decision:

  The new method/implementation.

- justification:

  Why this method is valid.

- step:

  The target step ID in the schema that these alternatives pertain to.

- ...:

  One or more alternative branches created by \`alternative()\`.

## Examples

``` r
example_alternatives(case = "football")
#> # Alternatives: step-logistic-model
#>   id                                action                decision justification
#>   <chr>                             <chr>                 <chr>    <chr>        
#> 1 step-mixed-effects-logistic-model estimate the effect … fit a g… mixed-effect…
#> 2 step-probit-regression-model      estimate the effect … fit a p… probit model…
#> 3 step-bayesian-logistic-model      estimate the effect … fit a B… the Bayesian…
```
