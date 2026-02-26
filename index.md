# tines

The goal of tines is to …

## Installation

You can install the development version of tines like so:

You can install the released version of cubble from CRAN with:

``` R
install.packages("tines")
And the development version from GitHub with:

# install.packages("remotes")
remotes::install_github("huizezhang-sherry/tines")
```

## Example

``` r
library(tines)
example_schema()
#> $nodes
#> # A tibble: 3 × 6
#>   tag             action                     type  decision justification status
#>   <chr>           <chr>                      <chr> <chr>    <chr>         <chr> 
#> 1 block-scaling   variables are in differen… cons… apply m… to put them … VERIF…
#> 2 block-education combine the school variab… step  average… the most int… VERIF…
#> 3 block-combine   combine the three dimensi… step  use the… the geometri… VERIF…
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from            to              type      
#>   <chr>           <chr>           <chr>     
#> 1 block-scaling   block-education sequential
#> 2 block-combine   block-scaling   motivated 
#> 3 block-education block-combine   sequential
#> 
#> attr(,"class")
#> [1] "schema"
#> attr(,"name")
#> [1] "HDI Example"
#plot(example_schema())
expanded <- example_schema() |> 
  expand_tines(example_alternatives(case = "hdi")) 
expanded
#> $original
#> $nodes
#> # A tibble: 3 × 6
#>   tag             action                     type  decision justification status
#>   <chr>           <chr>                      <chr> <chr>    <chr>         <chr> 
#> 1 block-scaling   variables are in differen… cons… apply m… to put them … VERIF…
#> 2 block-education combine the school variab… step  average… the most int… VERIF…
#> 3 block-combine   combine the three dimensi… step  use the… the geometri… VERIF…
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from            to              type      
#>   <chr>           <chr>           <chr>     
#> 1 block-scaling   block-education sequential
#> 2 block-combine   block-scaling   motivated 
#> 3 block-education block-combine   sequential
#> 
#> attr(,"class")
#> [1] "schema"
#> attr(,"name")
#> [1] "HDI Example"
#> 
#> $`block-arithmetic-mean`
#> $nodes
#> # A tibble: 3 × 6
#>   tag                   action               type  decision justification status
#>   <chr>                 <chr>                <chr> <chr>    <chr>         <chr> 
#> 1 block-scaling         variables are in di… cons… apply m… to put them … VERIF…
#> 2 block-education       combine the school … step  average… the most int… VERIF…
#> 3 block-arithmetic-mean combine the three d… step  use a a… the old meth… VERIF…
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from                  to                    type      
#>   <chr>                 <chr>                 <chr>     
#> 1 block-scaling         block-education       sequential
#> 2 block-arithmetic-mean block-scaling         motivated 
#> 3 block-education       block-arithmetic-mean sequential
#> 
#> attr(,"class")
#> [1] "schema"
#> attr(,"name")
#> [1] "HDI Example"
#> 
#> attr(,"class")
#> [1] "multiverse" "list"
#plot(expanded, index = 1)
#plot(expanded, index = 2)

example_football()
#> $nodes
#> # A tibble: 3 × 6
#>   tag                            action      type  decision justification status
#>   <chr>                          <chr>       <chr> <chr>    <chr>         <chr> 
#> 1 block-average-rater            define the… cons… average… incorporate … VERIF…
#> 2 block-victory-tie-defeat-ratio control fo… step  victory… ratios are r… VERIF…
#> 3 block-logistic-model           estimate t… step  fit a l… to answer th… VERIF…
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from                           to                   type      
#>   <chr>                          <chr>                <chr>     
#> 1 block-average-rater            block-logistic-model sequential
#> 2 block-logistic-model           block-average-rater  motivated 
#> 3 block-victory-tie-defeat-ratio block-logistic-model sequential
#> 
#> attr(,"class")
#> [1] "schema"
#plot(example_football())
multi <- example_football() |> 
  expand_tines(example_alternatives(case = "football")) 
names(multi)
#> [1] "original"                           "block-mixed-effects-logistic-model"
#> [3] "block-probit-regression-model"      "block-bayesian-logistic-model"
```
