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
example_multiverse()
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
#> $reversed
#> $nodes
#> # A tibble: 3 × 6
#>   tag             action                     type  decision justification status
#>   <chr>           <chr>                      <chr> <chr>    <chr>         <chr> 
#> 1 block-education combine the school variab… step  average… the most int… VERIF…
#> 2 block-scaling   variables are in differen… cons… apply m… to put them … VERIF…
#> 3 block-combine   combine the three dimensi… step  use the… the geometri… VERIF…
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from            to            type      
#>   <chr>           <chr>         <chr>     
#> 1 block-education block-scaling sequential
#> 2 block-scaling   block-combine sequential
#> 3 block-combine   block-scaling motivated 
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
example_alternatives(case = "hdi")
#> [[1]]
#> [[1]]$tag
#> [1] "block-arithmetic-mean"
#> 
#> [[1]]$action
#> [1] "combine the three dimensions into a single index"
#> 
#> [[1]]$decision
#> [1] "use a arithmetic mean"
#> 
#> [[1]]$justification
#> [1] "the old method"
#> 
#> 
#> attr(,"class")
#> [1] "alternatives" "list"        
#> attr(,"block")
#> [1] "block-combine"
```
