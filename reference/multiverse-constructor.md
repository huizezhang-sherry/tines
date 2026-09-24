# Construct a multiverse

A multiverse is a collection of related schemas. It is never authored
from scratch: `as_multiverse()` collects schemas you already have, and
[`expand_tines()`](expand.md) derives one from a schema and an
alternatives file. `new_multiverse()` is the low-level constructor.

## Usage

``` r
new_multiverse(schemas = list())

as_multiverse(x, ...)

# Default S3 method
as_multiverse(x, ...)

# S3 method for class 'multiverse'
as_multiverse(x, ...)

# S3 method for class 'schema'
as_multiverse(x, ...)

# S3 method for class 'list'
as_multiverse(x, ...)
```

## Arguments

- schemas:

  A list of `schema` objects.

- x:

  A `schema`, a `multiverse`, or a list of either to be coerced.

- ...:

  Passed on to methods.

## Value

An object of class `c("multiverse", "list")`.

## Details

Branches follow list conventions – they may be named or not, exactly as
the list you pass in leaves them.

## See also

[`build_schema()`](schema-constructor.md) to make the schemas in the
first place.

## Examples

``` r
s1 <- example_schema()
s2 <- example_football()

as_multiverse(list(hdi = s1, football = s2))
#> A multiverse with 2 schemas:
#>   hdi: "HDI Example" (3 steps)
#>   football: (3 steps)

# names are optional, as in any list
as_multiverse(list(s1, s2))
#> A multiverse with 2 schemas:
#>   [[1]]: "HDI Example" (3 steps)
#>   [[2]]: (3 steps)
```
