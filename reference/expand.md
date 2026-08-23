# Expand a schema with an alternative YAML into a multiverse

Expand a schema with an alternative YAML into a multiverse

## Usage

``` r
expand_tines(x, alternatives, ...)

# S3 method for class 'schema'
expand_tines(x, alternatives, include_original = TRUE, ...)

# S3 method for class 'multiverse'
expand_tines(x, alternatives, ...)
```

## Arguments

- x:

  A \`schema\` object.

- alternatives:

  an \`alternatives\` object or the path to an alternative YAML

- ...:

  Additional arguments.

- include_original:

  A logical. If \`TRUE\`, the original schema will be included as a
  branch in the resulting multiverse. Defaults to \`TRUE\`.

## Examples

``` r

# expand on a schema
base_schema <- example_football()
alts <- example_alternatives(case = "football")
expand_tines(base_schema, alts)
#> A multiverse with 4 schemas:
#>   original: (3 steps)
#>   step-mixed-effects-logistic-model: (3 steps)
#>   step-probit-regression-model: (3 steps)
#>   step-bayesian-logistic-model: (3 steps)

# read the alternatives from a YML file
tmp_file <- tempfile(fileext = ".yml")
write_alternatives(alts, tmp_file)
#> ✔ Successfully wrote alternatives to /tmp/RtmpCH6YIb/file1a05315a14e7.yml
expand_tines(base_schema, tmp_file)
#> A multiverse with 4 schemas:
#>   original: (3 steps)
#>   step-mixed-effects-logistic-model: (3 steps)
#>   step-probit-regression-model: (3 steps)
#>   step-bayesian-logistic-model: (3 steps)

# expand on the multiverse
multiverse <- example_multiverse()
alts <- example_alternatives(case = "hdi")
expand_tines(multiverse, alts)
#> A multiverse with 4 schemas:
#>   original: "HDI Example" (3 steps)
#>   reversed: "HDI Example" (3 steps)
#>   original.step-arithmetic-mean: "HDI Example" (3 steps)
#>   reversed.step-arithmetic-mean: "HDI Example" (3 steps)
```
