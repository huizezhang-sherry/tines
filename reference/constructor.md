# Construct schema and multiverse objects

Construct individual analytical paths (`schema`) and bundle them into a
garden of forking paths (`multiverse`).

## Usage

``` r
new_schema(name = NULL, nodes = tibble::tibble())

build_schema(name = NULL, data = NULL)

new_multiverse(schemas = list())

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

as_multiverse(x, ...)

# Default S3 method
as_multiverse(x, ...)

# S3 method for class 'multiverse'
as_multiverse(x, ...)

# S3 method for class 'schema'
as_multiverse(x, ...)

# S3 method for class 'list'
as_multiverse(x, ...)

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

  One or more `schema` objects to be included in the multiverse.

- x:

  An object to be coerced into a `schema` or `multiverse`.

- row.names:

  NULL or a character vector giving the row names for the data frame.

- optional:

  logical. If TRUE, setting row names and converting column names is
  optional.

- width:

  Width for printing output.

- schema, schemas:

  A single list containing objects of class `schema`. Defaults to an
  empty list.

## Value

- `build_schema()` and `new_schema()` return an object of class
  `schema`.

- `as_multiverse()` and `new_multiverse()` return an object of class
  `c("multiverse", "list")`.

## Examples

``` r
schema <- build_schema("HDI Example") |>
  # 1. The Scaling step
  add_step(
    id = "step-scaling",
    objective = "variables are in different scales",
    decision = "apply min-max scaling to each variable",
    rationale = "to put them on the same scale for combination"
  ) |>
  # 2. The Education step
  add_step(
    id = "step-education",
    objective = "combine the school variables into one dimension",
    decision = "average exp sch and avg sch",
    rationale = "the most intuitive way"
  ) |>
  # 3. The Combine step
  add_step(
    id = "step-combine",
    objective = "combine the three dimensions into a single index",
    decision = "use the geometric mean",
    rationale = "the geometric mean is more appropriate than arithmetic mean"
  )

schema
#> # A schema: HDI Example
#>   id             objective                     decision rationale inputs outputs
#>   <chr>          <chr>                         <chr>    <chr>     <list> <list> 
#> 1 step-scaling   variables are in different s… apply m… to put t… <lgl>  <lgl>  
#> 2 step-education combine the school variables… average… the most… <lgl>  <lgl>  
#> 3 step-combine   combine the three dimensions… use the… the geom… <lgl>  <lgl>  

schema2 <- build_schema("HDI Example") |>
  # 1. The Education Step
  add_step(
    id = "step-education",
    objective = "combine the school variables into one dimension",
    decision = "average exp sch and avg sch",
    rationale = "the most intuitive way"
  ) |>
  # 2. The Scaling Step
  add_step(
    id = "step-scaling",
    objective = "variables are in different scales",
    decision = "apply min-max scaling to each variable",
    rationale = "to put them on the same scale for combination"
  ) |>
  # 3. The Combine Step
  add_step(
    id = "step-combine",
    objective = "combine the three dimensions into a single index",
    decision = "use the geometric mean",
    rationale = "the geometric mean is more appropriate than arithmetic mean"
  )

my_multiverse <- as_multiverse(list(original = schema, reversed = schema2))
my_multiverse
#> A multiverse with 2 schemas:
#>   original: "HDI Example" (3 steps)
#>   reversed: "HDI Example" (3 steps)
```
