# Read and write tines schemas and multiverses to YAML files

Read and write tines schemas and multiverses to YAML files

## Usage

``` r
write_tines(x, path = NULL, ...)

read_tines(path, data = NULL, ...)
```

## Arguments

- x:

  An object of class \`schema\` or \`multiverse\`.

- path:

  A single string specifying the output file path. Optional.

- ...:

  Arguments passed on to \`yaml::write_yaml()\` or
  \`yaml::read_yaml()\`.

- data:

  Optional data frame or path to data file for validation (for
  \`read_tines()\` only).

## Value

\`write_tines()\` returns \`NULL\` and \`read_tines()\` returns an
object of class \`schema\` or \`multiverse\`.

## Examples

``` r
if (FALSE) { # \dontrun{
schema <- example_schema()
temp_path <- withr::local_tempfile(fileext = ".yaml")
write_tines(schema, temp_path)
schema_read <- read_tines(temp_path)

# Read and validate against data
schema_read <- read_tines(temp_path, data = my_data)
} # }
```
