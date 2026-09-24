# Generate examples

These functions generate pre-populated schema and multiverse objects.
They are primarily designed for testing, running examples in the
documentation, and helping new users explore the tines package without
having to build a garden of forking paths from scratch.

## Usage

``` r
example_schema()

example_multiverse()

example_football()

example_alternatives(case = c("football", "hdi"))

example_football_grp20()

example_football_grp5()
```

## Arguments

- case:

  A character string specifying which example alternatives to generate.
  Options are "football" or "hdi". Only applies to
  `example_alternatives()`.

## Value

- For `example_schema()`: An object of class `schema`.

- For `example_multiverse()`: An object of class `multiverse`.

- For `example_football()`: An object of class `schema`

- For `example_alternatives()`: An object of class `alternatives`

## Examples

``` r
# Generate a single example schema
example_schema()
#> # A schema: HDI Example
#>   id             objective                     decision rationale inputs outputs
#>   <chr>          <chr>                         <chr>    <chr>     <list> <list> 
#> 1 step-scaling   variables are in different s… apply m… to put t… <lgl>  <lgl>  
#> 2 step-education combine the school variables… average… the most… <lgl>  <lgl>  
#> 3 step-combine   combine the three dimensions… use the… the geom… <lgl>  <lgl>  
example_multiverse()
#> A multiverse with 2 schemas:
#>   original: "HDI Example" (3 steps)
#>   reversed: "HDI Example" (3 steps)
example_football()
#> # A schema: 3 x 6
#>   id                            objective      decision rationale inputs outputs
#>   <chr>                         <chr>          <chr>    <chr>     <list> <list> 
#> 1 step-average-rater            define the de… average… incorpor… <lgl>  <lgl>  
#> 2 step-victory-tie-defeat-ratio control for t… victory… ratios a… <lgl>  <lgl>  
#> 3 step-logistic-model           estimate the … fit a l… to answe… <lgl>  <lgl>  
example_alternatives(case = "hdi")
#> # Alternatives: step-combine (multi)
#>   overrides    alternatives    
#>   <chr>        <list>          
#> 1 step-combine <tibble [1 × 3]>
```
