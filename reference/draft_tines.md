# Draft a schema template

Writes a starter YAML file with two placeholder steps, ready to fill in
by hand. There is no equivalent for a multiverse: a multiverse is always
derived, either by collecting schemas with
[`as_multiverse()`](multiverse-constructor.md) or by expanding one with
an alternatives file via [`expand_tines()`](expand.md).

## Usage

``` r
draft_tines(file_path, overwrite = FALSE)
```

## Arguments

- file_path:

  Required. Where to save the template.

- overwrite:

  Logical. If `TRUE`, overwrites an existing file at `file_path`.
  Defaults to `FALSE`.

## Value

Invisibly, the path written to; called for its side effect of writing
the file.

## See also

[`draft_alternatives()`](draft_alternatives.md) for the
alternatives-file equivalent, and [`read_tines()`](read-write.md) to
read the filled-in template back.

## Examples

``` r
schema_path <- withr::local_tempfile(fileext = ".yml")
draft_tines(file_path = schema_path)
#> ✔ Drafted "schema" template at /tmp/RtmpKgFKXG/file1a3f3c94907d.yml
#> ℹ Open this file to start defining your steps!
```
