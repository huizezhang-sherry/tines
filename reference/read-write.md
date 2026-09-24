# Read and write tines schemas and multiverses to YAML files

Read and write tines schemas and multiverses to YAML files

## Usage

``` r
write_tines(x, path = NULL, ...)

read_tines(path, data = NULL, ...)
```

## Arguments

- x:

  An object of class `schema` or `multiverse`.

- path:

  A single string specifying the output file path. Optional.

- ...:

  Arguments passed on to
  [`yaml::write_yaml()`](https://yaml.r-lib.org/reference/write_yaml.html)
  or
  [`yaml::read_yaml()`](https://yaml.r-lib.org/reference/read_yaml.html).

- data:

  Optional data frame or path to data file for validation (for
  `read_tines()` only).

## Value

`write_tines()` returns `NULL` and `read_tines()` returns an object of
class `schema` or `multiverse`.

## Examples

``` r
schema <- example_schema()
temp_path <- withr::local_tempfile(fileext = ".yaml")
write_tines(schema, temp_path)
#> ✔ File saved: /tmp/Rtmpo0c3Kt/file1a796ba2adcd.yaml
schema_read <- read_tines(temp_path)

# Read and validate against a data frame or file path
my_data <- data.frame(age = c(25, 30, 35), income = c(50000, 60000, 70000))
schema_read <- read_tines(temp_path, data = my_data)
#> ✔ Validation passed
#> ✔ Data attached: "data"
```
