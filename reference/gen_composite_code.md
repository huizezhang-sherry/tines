# Generate R code from a composite schema assembled from multiple source schemas

Generate R code from a composite schema assembled from multiple source
schemas

## Usage

``` r
gen_composite_code(schema, base_scripts, output_file)
```

## Arguments

- schema:

  A schema object assembled via \`build_schema()\`, \`import_step()\`,
  and \`add_step()\`.

- base_scripts:

  Named list mapping source schema object names to their base R scripts,
  e.g. \`list(spei_template = here::here("inst/spei.R"))\`.

- output_file:

  Path to write the generated R script.

## Value

Invisibly returns the generated code as a character string.

## Examples

``` r
if (FALSE) { # \dontrun{
schema <- example_rdi()

code <- gen_composite_code(
  schema       = schema,
  base_scripts = list(
    spei_template = here::here("inst/spei.R"),
    spi_template  = here::here("inst/spi.R")
  ),
  output_file  = here::here("inst/rdi.R")
)
} # }
```
