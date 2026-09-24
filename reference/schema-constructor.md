# Construct a schema

A schema records one analysis as an ordered sequence of decisions.
`build_schema()` starts an empty one and `add_step()` appends a decision
to it; `as_schema()` coerces an existing table of steps; `new_schema()`
is the low-level constructor the others are built on.

## Usage

``` r
new_schema(name = NULL, nodes = tibble::tibble())

build_schema(name = NULL, data = NULL)

add_step(
  object,
  id,
  objective = "",
  decision = "",
  rationale = "",
  inputs = NULL,
  outputs = NULL,
  ...
)

as_schema(x, ...)

# Default S3 method
as_schema(x, ...)

# S3 method for class 'schema'
as_schema(x, ...)

# S3 method for class 'data.frame'
as_schema(x, name = NULL, ...)

# S3 method for class 'schema'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)

# S3 method for class 'schema'
print(x, width = NULL, ...)
```

## Arguments

- name:

  An optional name for the schema.

- nodes:

  A data frame (typically a `tibble`) defining the steps of the schema.

- data:

  Optional data frame or path to data file for validation

- object:

  A `schema` object.

- id, objective, decision, rationale, inputs, outputs:

  character strings to write a step

- ...:

  Passed on to methods.

- x:

  An object to be coerced into a `schema`.

- row.names:

  NULL or a character vector giving the row names for the data frame.

- optional:

  logical. If TRUE, setting row names and converting column names is
  optional.

- width:

  Width for printing output.

## Value

An object of class `schema`: a tibble with one row per step.

## See also

[`as_multiverse()`](multiverse-constructor.md) to collect several
schemas together, and [`expand_tines()`](expand.md) to expand one into a
multiverse.

## Examples

``` r
schema <- build_schema("HDI Example") |>
  add_step(
    id = "step-scaling",
    objective = "variables are in different scales",
    decision = "apply min-max scaling to each variable",
    rationale = "to put them on the same scale for combination"
  ) |>
  add_step(
    id = "step-combine",
    objective = "combine the three dimensions into a single index",
    decision = "use the geometric mean",
    rationale = "the geometric mean penalizes uneven development"
  )

schema
#> # A schema: HDI Example
#>   id           objective                       decision rationale inputs outputs
#>   <chr>        <chr>                           <chr>    <chr>     <list> <list> 
#> 1 step-scaling variables are in different sca… apply m… to put t… <lgl>  <lgl>  
#> 2 step-combine combine the three dimensions i… use the… the geom… <lgl>  <lgl>  

# coerce a table of steps that was catalogued elsewhere
as_schema(data.frame(
  id = "step-clean", objective = "handle missing values",
  decision = "drop incomplete cases", rationale = "keeps it simple"
))
#> # A schema: 1 x 4
#>   id         objective             decision              rationale      
#>   <chr>      <chr>                 <chr>                 <chr>          
#> 1 step-clean handle missing values drop incomplete cases keeps it simple
```
