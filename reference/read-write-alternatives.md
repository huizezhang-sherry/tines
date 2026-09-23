# Read and write an alternatives object from/to a YML file

Read and write an alternatives object from/to a YML file

## Usage

``` r
write_alternatives(x, file, ...)

read_alternatives(file, ...)
```

## Arguments

- x:

  An \`alternatives\` object.

- file:

  A character string specifying the file path.

- ...:

  Additional arguments passed to \`yaml::read_yaml()\`.

## Value

\`write_alternatives()\` invisibly returns \`file\`, the path it wrote
to; it is called for its side effect of writing the YAML file.

\`read_alternatives()\` returns an object of class \`"alternatives"\`,
the same structure produced by \[new_alternatives()\].

## Examples

``` r
alts <- example_alternatives()
temp_path <- withr::local_tempfile(fileext = ".yml")
write_alternatives(alts, temp_path)
#> ✔ Successfully wrote alternatives to /tmp/Rtmp5Ur8Dy/file1b2c3fbd68a4.yml
alts_read <- read_alternatives(temp_path)

identical(alts, alts_read)
#> [1] TRUE
```
