# Example HDI schema, alternatives, and multiverse

Pre-populated objects for trying the package out, running the examples
in the documentation, and testing.

These are small and invented – the Human Development Index written out
as three decisions – and are the ones to reach for when you want
something short enough to read at a glance. For a real analysis, with
the messiness that implies, see [football_grp5](football_grp5.md).

## Usage

``` r
example_hdi()

example_hdi_alternatives()

example_hdi_multiverse()
```

## Value

- `example_hdi()` returns a `schema`.

- `example_hdi_alternatives()` returns an `alternatives` object.

- `example_hdi_multiverse()` returns a `multiverse`.

## Examples

``` r
example_hdi()
#> # A schema: HDI Example
#>   id             objective                     decision rationale inputs outputs
#>   <chr>          <chr>                         <chr>    <chr>     <list> <list> 
#> 1 step-scaling   variables are in different s… apply m… to put t… <lgl>  <lgl>  
#> 2 step-education combine the school variables… average… the most… <lgl>  <lgl>  
#> 3 step-combine   combine the three dimensions… use the… the geom… <lgl>  <lgl>  
example_hdi_alternatives()
#> # Alternatives: step-combine (multi)
#>   overrides    alternatives    
#>   <chr>        <list>          
#> 1 step-combine <tibble [1 × 3]>
example_hdi_multiverse()
#> A multiverse with 2 schemas:
#>   original: "HDI Example" (3 steps)
#>   step-arithmetic-mean: "HDI Example" (3 steps)
```
