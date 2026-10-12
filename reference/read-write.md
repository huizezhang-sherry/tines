# Read and write tines schemas and multiverses to YAML files

`write_tines()` writes a schema (or a multiverse) to YAML, and
`read_tines()` reads it back.

A schema's data reference is written under `meta.data`, with a file path
stored relative to the YAML file, so the two can be moved or shared
together. A schema whose data was given as a data frame has no reference
to write; supply the data again with `read_tines(path, data = )`.

When a mapped schema is read, it is checked against its data: the
columns are looked up (never the data itself) and each step's inputs are
checked with [`validate_schema()`](validate_schema.md). A plain schema
has nothing to check against the data, so its data is not touched. If
the data comes from an R script, running it means running code from the
file, so `validate` decides whether that happens.

## Usage

``` r
write_tines(x, path = NULL, ...)

read_tines(path, data = NULL, validate = c("ask", "always", "never"), ...)
```

## Arguments

- x:

  An object of class `schema` or `multiverse`.

- path:

  A single string specifying the file path. Optional for
  `write_tines()`.

- ...:

  Arguments passed on to
  [`yaml::as.yaml()`](https://yaml.r-lib.org/reference/as.yaml.html) or
  [`yaml::read_yaml()`](https://yaml.r-lib.org/reference/read_yaml.html).

- data:

  Optional. Data to check the schema against instead of the one the file
  references; see [`update_data()`](data-mapping.md) for the forms it
  takes.

- validate:

  How to handle a data source that is an R script: `"ask"` (the default)
  asks in an interactive session and skips the check otherwise,
  `"always"` runs it without asking, and `"never"` skips looking up the
  data's columns altogether.

## Value

`write_tines()` invisibly returns `path`, and `read_tines()` returns an
object of class `schema` or `multiverse`.

## Examples

``` r
schema <- example_hdi()
temp_path <- withr::local_tempfile(fileext = ".yml")
write_tines(schema, temp_path)
#> ✔ File saved: /tmp/RtmpKSp3wS/file1b3e77f35da8.yml
schema_read <- read_tines(temp_path)

# a mapped schema, checked against a data frame on read
my_data <- data.frame(age = c(25, 30, 35), income = c(50000, 60000, 70000))
mapped <- build_schema("Income") |>
  add_step(
    id = "step-log", decision = "log-transform income",
    inputs = "income", outputs = "log_income"
  )
write_tines(mapped, temp_path)
#> ✔ File saved: /tmp/RtmpKSp3wS/file1b3e77f35da8.yml
read_tines(temp_path, data = my_data)
#> # A schema: Income
#> # Data:     a data frame (not written to file)
#>   id       objective decision             rationale inputs    outputs  
#>   <chr>    <chr>     <chr>                <chr>     <list>    <list>   
#> 1 step-log ""        log-transform income ""        <chr [1]> <chr [1]>
```
