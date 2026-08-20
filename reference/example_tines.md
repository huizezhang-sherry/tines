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
#> # A schema: HDI Example
#>   id             objective       decision rationale inputs outputs source_schema
#>   <chr>          <chr>           <chr>    <chr>     <list> <list>  <lgl>        
#> 1 step-scaling   variables are … apply m… to put t… <lgl>  <lgl>   NA           
#> 2 step-education combine the sc… average… the most… <lgl>  <lgl>   NA           
#> 3 step-combine   combine the th… use the… the geom… <lgl>  <lgl>   NA           
example_multiverse()
#> A multiverse with 2 schemas:
#>   original: "HDI Example" (3 steps)
#>   reversed: "HDI Example" (3 steps)
example_football()
#> # A schema: 3 x 7
#>   id                   objective decision rationale inputs outputs source_schema
#>   <chr>                <chr>     <chr>    <chr>     <list> <list>  <lgl>        
#> 1 step-average-rater   define t… average… incorpor… <lgl>  <lgl>   NA           
#> 2 step-victory-tie-de… control … victory… ratios a… <lgl>  <lgl>   NA           
#> 3 step-logistic-model  estimate… fit a l… to answe… <lgl>  <lgl>   NA           
example_alternatives(case = "hdi")
#> # Alternatives: step-combine
#>   id                   objective                              decision rationale
#>   <chr>                <chr>                                  <chr>    <chr>    
#> 1 step-arithmetic-mean combine the three dimensions into a s… use a a… the old …
```
