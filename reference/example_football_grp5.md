# Example schema and alternatives from the football red cards study

The schema extracted from Team 5's reported methodology in the
many-analysts study, and a set of alternatives for one of its steps.
Both are read from files shipped with the package, so they are real
rather than invented – see [football_grp5](football_grp5.md) for the
prose the schema came from.

`example_football_grp5_alternatives()` overrides
`specify_random_effects_structure` with the three random-effects
specifications the team considered (`gm1`, `gm2`, `gm3`), so expanding
it gives four branches.

## Usage

``` r
example_football_grp5()

example_football_grp5_alternatives()
```

## Value

- `example_football_grp5()` returns a `schema`.

- `example_football_grp5_alternatives()` returns an `alternatives`
  object.

## See also

[football_grp5](football_grp5.md) for the methodology text, and
[`example_hdi()`](example_tines.md) for the smaller invented examples.

## Examples

``` r
schema <- example_football_grp5()
alts <- example_football_grp5_alternatives()

expand_tines(schema, alts)
#> A multiverse with 4 schemas:
#>   original: (7 steps)
#>   gm1: (7 steps)
#>   gm2: (7 steps)
#>   gm3: (7 steps)
```
