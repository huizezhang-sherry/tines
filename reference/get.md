# Functions to access components of a tine object

Functions to access components of a tine object

## Usage

``` r
get_step_names(object)
```

## Arguments

- object:

  A \`schema\` or \`multiverse\` object.

## Examples

``` r
get_step_names(example_schema())
#> [1] "step-scaling"   "step-education" "step-combine"  
get_step_names(example_multiverse())
#> $original
#> [1] "step-scaling"   "step-education" "step-combine"  
#> 
#> $reversed
#> [1] "step-education" "step-scaling"   "step-combine"  
#> 
```
