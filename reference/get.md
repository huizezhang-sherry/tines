# Functions to access components of a tine object

Functions to access components of a tine object

## Usage

``` r
get_step_names(object)
```

## Arguments

- object:

  A `schema` or `multiverse` object.

## Value

If `object` is a `schema`, a character vector of its steps' ids. If
`object` is a `multiverse`, a list of such character vectors, one per
schema in the multiverse.

## Examples

``` r
get_step_names(example_hdi())
#> [1] "step-scaling"   "step-education" "step-combine"  
get_step_names(example_hdi_multiverse())
#> $original
#> [1] "step-scaling"   "step-education" "step-combine"  
#> 
#> $`step-arithmetic-mean`
#> [1] "step-scaling"   "step-education" "step-combine"  
#> 
```
