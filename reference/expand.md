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
#> Error in purrr::pmap(alts_data, function(id, fork, path, rationale) {    branch <- x    branch$id[[idx]] <- id    branch$path[[idx]] <- path    branch$rationale[[idx]] <- rationale    class(branch) <- c("schema", "tbl_df", "tbl", "data.frame")    attr(branch, "name") <- attr(x, "name", exact = TRUE)    return(branch)}): ℹ In index: 1.
#> Caused by error in `.f()`:
#> ! unused arguments (action = .l[[2]][[i]], decision = .l[[3]][[i]], justification = .l[[4]][[i]])

# read the alternatives from a YML file
tmp_file <- tempfile(fileext = ".yml")
write_alternatives(alts, tmp_file)
#> ✔ Successfully wrote alternatives to /tmp/Rtmpar6iPQ/file19ab5bc8f605.yml
expand_tines(base_schema, tmp_file)
#> Error in purrr::pmap(alts_data, function(id, fork, path, rationale) {    branch <- x    branch$id[[idx]] <- id    branch$path[[idx]] <- path    branch$rationale[[idx]] <- rationale    class(branch) <- c("schema", "tbl_df", "tbl", "data.frame")    attr(branch, "name") <- attr(x, "name", exact = TRUE)    return(branch)}): ℹ In index: 1.
#> Caused by error in `.f()`:
#> ! argument "path" is missing, with no default

# expand on the multiverse
multiverse <- example_multiverse()
alts <- example_alternatives(case = "hdi")
expand_tines(multiverse, alts)
#> Error in purrr::pmap(alts_data, function(id, fork, path, rationale) {    branch <- x    branch$id[[idx]] <- id    branch$path[[idx]] <- path    branch$rationale[[idx]] <- rationale    class(branch) <- c("schema", "tbl_df", "tbl", "data.frame")    attr(branch, "name") <- attr(x, "name", exact = TRUE)    return(branch)}): ℹ In index: 1.
#> Caused by error in `.f()`:
#> ! unused arguments (action = .l[[2]][[i]], decision = .l[[3]][[i]], justification = .l[[4]][[i]])
```
