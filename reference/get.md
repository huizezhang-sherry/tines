# Functions to access components of a tine object

Functions to access components of a tine object

## Usage

``` r
get_block_names(object)
```

## Arguments

- object:

  A \`schema\` or \`multiverse\` object.

## Examples

``` r
get_block_names(example_schema())
#> [1] "block-scaling"   "block-education" "block-combine"  
get_block_names(example_multiverse())
#> $original
#> [1] "block-scaling"   "block-education" "block-combine"  
#> 
#> $reversed
#> [1] "block-education" "block-scaling"   "block-combine"  
#> 
```
