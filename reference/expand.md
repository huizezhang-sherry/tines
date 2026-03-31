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
#> Error in if (!target %in% ids) {    cli::cli_abort("Target step {.val {target}} not found in the base schema.")}: argument is of length zero

# read the alternatives from a YAML file
tmp_file <- tempfile(fileext = ".yaml")
write_alternatives(alts, tmp_file)
#> ✔ Successfully wrote alternatives to /tmp/RtmpYQenHb/file1bca714a8b98.yaml
expand_tines(base_schema, tmp_file)
#> Error in yaml.load(string, error.label = error.label, ...): (/tmp/RtmpYQenHb/file1bca714a8b98.yaml) Duplicate map key: ''

# expand on the multiverse
multiverse <- example_multiverse()
alts <- example_alternatives(case = "hdi")
expand_tines(multiverse, alts)
#> Error in if (target %in% ids) {    expanded_mini_multi <- expand_tines(single_schema, alternatives,         include_original = FALSE)    return(expanded_mini_multi)} else {    return(list(single_schema))}: argument is of length zero
```
