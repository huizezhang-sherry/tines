# Read and write an alternatives object from/to a YAML file

Read and write an alternatives object from/to a YAML file

## Usage

``` r
write_alternatives(x, file, ...)

read_alternatives(file, ...)
```

## Arguments

- x:

  A \`alternatives\` object.

- file:

  A character string specifying the file path.

- ...:

  Additional arguments passed to \`yaml::read_yaml()\`.

## Examples

``` r
if (FALSE) { # \dontrun{
alts <- example_alternatives()
temp_path <- withr::local_tempfile(fileext = ".yaml")
write_alternatives(alts, temp_path)
alts_read <- read_alternatives(temp_path)

identical(alts, alts_read)
} # }
```
