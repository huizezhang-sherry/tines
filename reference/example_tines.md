# Generate example tines objects

These functions generate pre-populated \`schema\` and \`multiverse\`
objects. They are primarily designed for testing, running examples in
the documentation, and helping new users explore the \`tines\` package
without having to build a garden of forking paths from scratch.

\* \`example_schema()\` returns a single, validated \`schema\` object
containing a standard set of nodes (steps and constraints) and edges. \*
\`example_multiverse()\` returns a validated \`multiverse\` object
containing multiple variations of the example schema.

## Usage

``` r
example_schema()

example_multiverse()
```

## Value

\* For \`example_schema()\`: An object of class \`schema\`. \* For
\`example_multiverse()\`: An object of class \`multiverse\`.

## Examples

``` r
# Generate a single example schema
my_schema <- example_schema()
print(my_schema)
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

# Generate an example multiverse containing multiple paths
my_multi <- example_multiverse()
print(my_multi)
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
```
