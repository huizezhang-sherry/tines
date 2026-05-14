# Construct \`schema\` and \`multiverse\` objects

Construct individual analytical paths (\`schema\`) and bundle them into
a garden of forking paths (\`multiverse\`).

## Usage

``` r
new_schema(name = NULL, nodes = tibble::tibble())

build_schema(name = NULL, data = NULL)

new_multiverse(schemas = list())

build_multiverse(...)

add_step(
  object,
  id,
  fork = "",
  path = "",
  rationale = "",
  inputs = NULL,
  outputs = NULL,
  source_schema = NA,
  ...
)

as_schema(x, ...)

# Default S3 method
as_schema(x, ...)

# S3 method for class 'schema'
as_schema(x, ...)

# S3 method for class 'list'
as_schema(x, ...)

# S3 method for class 'character'
as_schema(x, ...)

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
c(...)

# S3 method for class 'multiverse'
c(...)

# S3 method for class 'schema'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)

# S3 method for class 'schema'
print(x, width = NULL, ...)
```

## Arguments

- name:

  An optional name for the schema.

- nodes:

  A data frame (typically a \`tibble\`) defining the steps of the
  schema.

- data:

  Optional data frame or path to data file for validation

- ...:

  One or more \`schema\` objects to be included in the multiverse.

- object:

  A \`schema\` object.

- id, fork, path, rationale, inputs, outputs, source_schema:

  character strings to write a step

- x:

  An object to be coerced into a \`schema\` or \`multiverse\`.

- row.names:

  NULL or a character vector giving the row names for the data frame.

- optional:

  logical. If TRUE, setting row names and converting column names is
  optional.

- width:

  Width for printing output.

- schema, schemas:

  A single list containing objects of class \`schema\`. Defaults to an
  empty list.

## Value

\* \`build_schema()\` and \`new_schema()\` return an object of class
\`schema\`. \* \`build_multiverse()\` and \`new_multiverse()\` return an
object of class \`c("multiverse", "list")\`.

## Examples

``` r
schema <- build_schema("HDI Example") |>
  # 1. The Scaling step
  add_step(id = "step-scaling",
            fork = "variables are in different scales",
            path = "apply min-max scaling to each variable",
            rationale = "to put them on the same scale for combination") |>
  # 2. The Education step
  add_step(id = "step-education",
            fork = "combine the school variables into one dimension",
            path = "average exp sch and avg sch",
            rationale = "the most intuitive way") |>
  # 3. The Combine step
  add_step(id = "step-combine",
            fork = "combine the three dimensions into a single index",
            path = "use the geometric mean",
            rationale = "the geometric mean is more appropriate than arithmetic mean")

schema
#> # A schema: 3 x 7
#>   id             fork               path  rationale inputs outputs source_schema
#>   <chr>          <chr>              <chr> <chr>     <list> <list>  <lgl>        
#> 1 step-scaling   variables are in … appl… to put t… <lgl>  <lgl>   NA           
#> 2 step-education combine the schoo… aver… the most… <lgl>  <lgl>   NA           
#> 3 step-combine   combine the three… use … the geom… <lgl>  <lgl>   NA           

schema2 <- build_schema("HDI Example") |>
  # 1. The Education Step
  add_step(id = "step-education",
            fork = "combine the school variables into one dimension",
            path = "average exp sch and avg sch",
            rationale = "the most intuitive way") |>
  # 2. The Scaling Step
  add_step(id = "step-scaling",
            fork = "variables are in different scales",
            path = "apply min-max scaling to each variable",
            rationale = "to put them on the same scale for combination") |>
  # 3. The Combine Step
  add_step(id = "step-combine",
            fork = "combine the three dimensions into a single index",
            path = "use the geometric mean",
            rationale = "the geometric mean is more appropriate than arithmetic mean")

my_multiverse <- build_multiverse(original = schema, reversed = schema2)
my_multiverse
#> A multiverse with 2 schemas:
#>   original: (3 steps)
#>   reversed: (3 steps)
```
