# Generate examples

These functions generate pre-populated \`schema\` and \`multiverse\`
objects. They are primarily designed for testing, running examples in
the documentation, and helping new users explore the \`tines\` package
without having to build a garden of forking paths from scratch.

## Usage

``` r
example_schema()

example_multiverse()

example_football()

example_alternatives(case = c("football", "hdi"))

example_spei()

example_spi()

example_rdi()

example_football_grp20()
```

## Arguments

- case:

  A character string specifying which example alternatives to generate.
  Options are "football" or "hdi". Only applies to
  \`example_alternatives()\`.

## Value

\* For \`example_schema()\`: An object of class \`schema\`. \* For
\`example_multiverse()\`: An object of class \`multiverse\`. \* For
\`example_football()\`: An object of class \`schema\` \* For
\`example_alternatives()\`: An object of class \`alternatives\`

## Examples

``` r
# Generate a single example schema
example_schema()
#> $nodes
#> # A tibble: 3 × 8
#>   id            action type  decision justification inputs outputs source_schema
#>   <chr>         <chr>  <chr> <chr>    <chr>         <list> <list>  <lgl>        
#> 1 step-scaling  varia… cons… apply m… to put them … <lgl>  <lgl>   NA           
#> 2 step-educati… combi… step  average… the most int… <lgl>  <lgl>   NA           
#> 3 step-combine  combi… step  use the… the geometri… <lgl>  <lgl>   NA           
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from           to             type      
#>   <chr>          <chr>          <chr>     
#> 1 step-scaling   step-education sequential
#> 2 step-combine   step-scaling   motivated 
#> 3 step-education step-combine   sequential
#> 
#> attr(,"class")
#> [1] "schema"
#> attr(,"name")
#> [1] "HDI Example"
example_multiverse()
#> $original
#> $nodes
#> # A tibble: 3 × 8
#>   id            action type  decision justification inputs outputs source_schema
#>   <chr>         <chr>  <chr> <chr>    <chr>         <list> <list>  <lgl>        
#> 1 step-scaling  varia… cons… apply m… to put them … <lgl>  <lgl>   NA           
#> 2 step-educati… combi… step  average… the most int… <lgl>  <lgl>   NA           
#> 3 step-combine  combi… step  use the… the geometri… <lgl>  <lgl>   NA           
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from           to             type      
#>   <chr>          <chr>          <chr>     
#> 1 step-scaling   step-education sequential
#> 2 step-combine   step-scaling   motivated 
#> 3 step-education step-combine   sequential
#> 
#> attr(,"class")
#> [1] "schema"
#> attr(,"name")
#> [1] "HDI Example"
#> 
#> $reversed
#> $nodes
#> # A tibble: 3 × 8
#>   id            action type  decision justification inputs outputs source_schema
#>   <chr>         <chr>  <chr> <chr>    <chr>         <list> <list>  <lgl>        
#> 1 step-educati… combi… step  average… the most int… <lgl>  <lgl>   NA           
#> 2 step-scaling  varia… cons… apply m… to put them … <lgl>  <lgl>   NA           
#> 3 step-combine  combi… step  use the… the geometri… <lgl>  <lgl>   NA           
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from           to           type      
#>   <chr>          <chr>        <chr>     
#> 1 step-education step-scaling sequential
#> 2 step-scaling   step-combine sequential
#> 3 step-combine   step-scaling motivated 
#> 
#> attr(,"class")
#> [1] "schema"
#> attr(,"name")
#> [1] "HDI Example"
#> 
#> attr(,"class")
#> [1] "multiverse" "list"      
example_football()
#> $nodes
#> # A tibble: 3 × 8
#>   id            action type  decision justification inputs outputs source_schema
#>   <chr>         <chr>  <chr> <chr>    <chr>         <list> <list>  <lgl>        
#> 1 step-average… defin… cons… average… incorporate … <lgl>  <lgl>   NA           
#> 2 step-victory… contr… step  victory… ratios are r… <lgl>  <lgl>   NA           
#> 3 step-logisti… estim… step  fit a l… to answer th… <lgl>  <lgl>   NA           
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from                          to                  type      
#>   <chr>                         <chr>               <chr>     
#> 1 step-average-rater            step-logistic-model sequential
#> 2 step-logistic-model           step-average-rater  motivated 
#> 3 step-victory-tie-defeat-ratio step-logistic-model sequential
#> 
#> attr(,"class")
#> [1] "schema"
example_alternatives(case = "hdi")
#> $step
#> [1] "step-combine"
#> 
#> attr(,"class")
#> [1] "alternatives" "list"        
#> attr(,"id")
#> attr(,"id")$id
#> [1] "step-arithmetic-mean"
#> 
#> attr(,"id")$action
#> [1] "combine the three dimensions into a single index"
#> 
#> attr(,"id")$decision
#> [1] "use a arithmetic mean"
#> 
#> attr(,"id")$justification
#> [1] "the old method"
#> 
```
