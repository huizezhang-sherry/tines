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
#> Warning: Unknown or uninitialised column: `nodes`.
#> NULL
get_step_names(example_multiverse())
#> Warning: Unknown or uninitialised column: `nodes`.
#> Warning: Unknown or uninitialised column: `nodes`.
#> $original
#> NULL
#> 
#> $reversed
#> NULL
#> 
```
