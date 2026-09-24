# Expand a schema with an alternative YAML into a multiverse

Expand a schema with an alternative YAML into a multiverse

## Usage

``` r
expand_tines(x, alternatives, ...)

# S3 method for class 'schema'
expand_tines(x, alternatives, include_original = TRUE, ...)

# S3 method for class 'character'
expand_tines(x, alternatives, ...)

# Default S3 method
expand_tines(x, alternatives, ...)
```

## Arguments

- x:

  A `schema` object, or the path to a schema YAML file.

- alternatives:

  An `alternatives` object, or the path to an alternatives YAML file.

- ...:

  Additional arguments.

- include_original:

  A logical. If `TRUE`, the original schema will be included as a branch
  in the resulting multiverse. Defaults to `TRUE`.

## Value

An object of class `"multiverse"`: a named list of `schema` objects, one
per branch produced from `alternatives` (plus, when
`include_original = TRUE`, the original schema under the name
`"original"`). Each branch name is the `+`-joined ids of the
alternatives applied to reach it.

## Examples

``` r

# expand on a schema
base_schema <- example_football_grp5()
alts <- example_football_grp5_alternatives()
expand_tines(base_schema, alts)
#> A multiverse with 4 schemas:
#>   original: (7 steps)
#>   gm1: (7 steps)
#>   gm2: (7 steps)
#>   gm3: (7 steps)

# read the alternatives from a YML file
tmp_file <- tempfile(fileext = ".yml")
write_alternatives(alts, tmp_file)
#> ✔ Successfully wrote alternatives to /tmp/Rtmpd9DCgw/file1a495d0ca50.yml
expand_tines(base_schema, tmp_file)
#> A multiverse with 4 schemas:
#>   original: (7 steps)
#>   gm1: (7 steps)
#>   gm2: (7 steps)
#>   gm3: (7 steps)
```
