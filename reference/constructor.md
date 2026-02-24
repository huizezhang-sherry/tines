# Construct \`schema\` and \`multiverse\` objects

Construct individual analytical paths (\`schema\`) and bundle them into
a garden of forking paths (\`multiverse\`).

## Usage

``` r
new_schema(name = NULL, nodes = tibble(), edges = tibble())

build_schema(name = NULL)

new_multiverse(schemas = list())

build_multiverse(...)

add_block(
  object,
  tag,
  action = "",
  type = "STEP",
  decision = "",
  justification = "",
  feeds = NULL,
  uses = NULL,
  prompts = NULL,
  solves = NULL
)

add_dependency(object, ...)
```

## Arguments

- name:

  An optional name for the schema.

- nodes:

  A data frame (typically a \`tibble\`) defining the nodes of the
  schema.

- edges:

  A data frame (typically a \`tibble\`) defining the edges of the
  schema.

- schemas:

  A single list containing objects of class \`schema\`. Defaults to an
  empty list.

- ...:

  One or more \`schema\` objects to be included in the multiverse.

- object:

  A \`schema\` object.

- tag, type, action, decision, justification:

  character strings to write a block - NOT SURE ABOUT THE DESIGN YET

- feeds, uses, solves, prompts:

  Character vectors to describe the relationship between blocks - NOT
  SURE ABOUT THE DESIGN YET

## Value

\* \`build_schema()\` and \`new_schema()\` return an object of class
\`schema\`. \* \`build_multiverse()\` and \`new_multiverse()\` return an
object of class \`c("multiverse", "list")\`.

## Examples

``` r
schema <- build_schema("HDI Example") |>
  # 1. The Scaling Block
  add_block(tag = "block-scaling",
            type = "constraint",
            action = "variables are in different scales",
            decision = "apply min-max scaling to each variable",
            justification = "to put them on the same scale for combination",
            solves = "block-combine",       # Motivation comes from the end
            feeds = "block-education") |>
  # 2. The Education Block
  add_block(tag = "block-education",
            type = "step",
            action = "combine the school variables into one dimension",
            decision = "average exp sch and avg sch",
            justification = "the most intuitive way",
            feeds = "block-combine") |>
  # 3. The Combine Block
  add_block(tag = "block-combine",
            type = "step",
            action = "combine the three dimensions into a single index",
            decision = "use the geometric mean",
            justification = "the geometric mean is more appropriate than arithmetic mean")

str(schema)
#> List of 2
#>  $ nodes: tibble [3 × 6] (S3: tbl_df/tbl/data.frame)
#>   ..$ tag          : chr [1:3] "block-scaling" "block-education" "block-combine"
#>   ..$ action       : chr [1:3] "variables are in different scales" "combine the school variables into one dimension" "combine the three dimensions into a single index"
#>   ..$ type         : chr [1:3] "constraint" "step" "step"
#>   ..$ decision     : chr [1:3] "apply min-max scaling to each variable" "average exp sch and avg sch" "use the geometric mean"
#>   ..$ justification: chr [1:3] "to put them on the same scale for combination" "the most intuitive way" "the geometric mean is more appropriate than arithmetic mean"
#>   ..$ status       : chr [1:3] "VERIFIED" "VERIFIED" "VERIFIED"
#>  $ edges: tibble [3 × 3] (S3: tbl_df/tbl/data.frame)
#>   ..$ from: chr [1:3] "block-scaling" "block-combine" "block-education"
#>   ..$ to  : chr [1:3] "block-education" "block-scaling" "block-combine"
#>   ..$ type: chr [1:3] "sequential" "motivated" "sequential"
#>   ..- attr(*, "out.attrs")=List of 2
#>   .. ..$ dim     : Named int [1:3] 1 1 1
#>   .. .. ..- attr(*, "names")= chr [1:3] "from" "to" "type"
#>   .. ..$ dimnames:List of 3
#>   .. .. ..$ from: chr "from=block-scaling"
#>   .. .. ..$ to  : chr "to=block-education"
#>   .. .. ..$ type: chr "type=sequential"
#>  - attr(*, "class")= chr "schema"
#>  - attr(*, "name")= chr "HDI Example"

schema2 <- build_schema("HDI Example") |>
  # 1. The Education Block
  add_block(tag = "block-education",
            type = "step",
            action = "combine the school variables into one dimension",
            decision = "average exp sch and avg sch",
            justification = "the most intuitive way",
            feeds = "block-scaling") |>
  # 2. The Scaling Block
  add_block(tag = "block-scaling",
            type = "constraint",
            action = "variables are in different scales",
            decision = "apply min-max scaling to each variable",
            justification = "to put them on the same scale for combination",
            solves = "block-combine",       # Motivation comes from the end
            feeds = "block-combine") |>
  # 3. The Combine Block
  add_block(tag = "block-combine",
            type = "step",
            action = "combine the three dimensions into a single index",
            decision = "use the geometric mean",
            justification = "the geometric mean is more appropriate than arithmetic mean")

my_multiverse <- build_multiverse(original = schema, reversed = schema2)
str(my_multiverse)
#> List of 2
#>  $ original:List of 2
#>   ..$ nodes: tibble [3 × 6] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ tag          : chr [1:3] "block-scaling" "block-education" "block-combine"
#>   .. ..$ action       : chr [1:3] "variables are in different scales" "combine the school variables into one dimension" "combine the three dimensions into a single index"
#>   .. ..$ type         : chr [1:3] "constraint" "step" "step"
#>   .. ..$ decision     : chr [1:3] "apply min-max scaling to each variable" "average exp sch and avg sch" "use the geometric mean"
#>   .. ..$ justification: chr [1:3] "to put them on the same scale for combination" "the most intuitive way" "the geometric mean is more appropriate than arithmetic mean"
#>   .. ..$ status       : chr [1:3] "VERIFIED" "VERIFIED" "VERIFIED"
#>   ..$ edges: tibble [3 × 3] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ from: chr [1:3] "block-scaling" "block-combine" "block-education"
#>   .. ..$ to  : chr [1:3] "block-education" "block-scaling" "block-combine"
#>   .. ..$ type: chr [1:3] "sequential" "motivated" "sequential"
#>   .. ..- attr(*, "out.attrs")=List of 2
#>   .. .. ..$ dim     : Named int [1:3] 1 1 1
#>   .. .. .. ..- attr(*, "names")= chr [1:3] "from" "to" "type"
#>   .. .. ..$ dimnames:List of 3
#>   .. .. .. ..$ from: chr "from=block-scaling"
#>   .. .. .. ..$ to  : chr "to=block-education"
#>   .. .. .. ..$ type: chr "type=sequential"
#>   ..- attr(*, "class")= chr "schema"
#>   ..- attr(*, "name")= chr "HDI Example"
#>  $ reversed:List of 2
#>   ..$ nodes: tibble [3 × 6] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ tag          : chr [1:3] "block-education" "block-scaling" "block-combine"
#>   .. ..$ action       : chr [1:3] "combine the school variables into one dimension" "variables are in different scales" "combine the three dimensions into a single index"
#>   .. ..$ type         : chr [1:3] "step" "constraint" "step"
#>   .. ..$ decision     : chr [1:3] "average exp sch and avg sch" "apply min-max scaling to each variable" "use the geometric mean"
#>   .. ..$ justification: chr [1:3] "the most intuitive way" "to put them on the same scale for combination" "the geometric mean is more appropriate than arithmetic mean"
#>   .. ..$ status       : chr [1:3] "VERIFIED" "VERIFIED" "VERIFIED"
#>   ..$ edges: tibble [3 × 3] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ from: chr [1:3] "block-education" "block-scaling" "block-combine"
#>   .. ..$ to  : chr [1:3] "block-scaling" "block-combine" "block-scaling"
#>   .. ..$ type: chr [1:3] "sequential" "sequential" "motivated"
#>   .. ..- attr(*, "out.attrs")=List of 2
#>   .. .. ..$ dim     : Named int [1:3] 1 1 1
#>   .. .. .. ..- attr(*, "names")= chr [1:3] "from" "to" "type"
#>   .. .. ..$ dimnames:List of 3
#>   .. .. .. ..$ from: chr "from=block-education"
#>   .. .. .. ..$ to  : chr "to=block-scaling"
#>   .. .. .. ..$ type: chr "type=sequential"
#>   ..- attr(*, "class")= chr "schema"
#>   ..- attr(*, "name")= chr "HDI Example"
#>  - attr(*, "class")= chr [1:2] "multiverse" "list"
```
