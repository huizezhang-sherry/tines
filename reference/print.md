# Visualize and inspect tines objects

Functions to plot the tines object with Graphviz diagrams.
`draw_tines()` and the
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods render
the interactive widget. `inspect_dot()` formats and prints raw DOT
strings to the console for debugging.

## Usage

``` r
# S3 method for class 'schema'
plot(x, ...)

# S3 method for class 'multiverse'
plot(x, index = 1, ...)

draw_tines(x, index = 1, data = NULL, ...)

inspect_dot(
  schema,
  indent = 2,
  keep_attr_blocks_one_line = TRUE,
  trim_trailing_ws = TRUE
)
```

## Arguments

- x:

  A `schema` or `multiverse` object.

- ...:

  Additional arguments passed to methods or to
  [`DiagrammeR::grViz()`](https://rich-iannone.github.io/DiagrammeR/reference/grViz.html).

- index:

  An integer. For a `multiverse`, which path index to draw. Defaults to
  1.

- data:

  Optional. A data frame or path to a data file. If schema is unmapped,
  this will be used to automatically map variables for visualization.

- schema:

  A `schema` object to convert to DOT code for inspection.

- indent:

  Integer. The number of spaces to use for each indentation level in
  `inspect_dot()`. Defaults to 2.

- keep_attr_blocks_one_line:

  Logical. If `TRUE`, attempts to keep square bracket `[]` attribute
  blocks on a single line.

- trim_trailing_ws:

  Logical. If `TRUE`, trims trailing whitespace from the final output.

## Value

`draw_tines()` and
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) return an
`htmlwidget` object produced by
[`DiagrammeR::grViz()`](https://rich-iannone.github.io/DiagrammeR/reference/grViz.html).
`inspect_dot()` invisibly returns `NULL` and prints to the console.

## Examples

``` r
my_data <- data.frame(age = c(25, 30, 35), income = c(50000, 60000, 70000))
schema <- build_schema(data = my_data) |>
  add_step(
    id = "step-filter", objective = "remove missing values",
    decision = "exclude rows with NA",
    inputs = c("age", "income"), outputs = "df_clean"
  )
#> ✔ Data attached: "my_data"

# plot() and draw_tines() are interchangeable
draw_tines(schema)

{"x":{"diagram":"digraph schema {\n  graph [rankdir=TD, fontname=Arial]\n  node [fontname=Arial, fontsize=10]\n  edge [fontname=Arial, fontsize=8]\n  \"step-filter\" [label=\"step-filter\n(exclude rows with NA)\", shape=box, style=filled, fillcolor=white]\n\n}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}plot(schema)

{"x":{"diagram":"digraph schema {\n  graph [rankdir=TD, fontname=Arial]\n  node [fontname=Arial, fontsize=10]\n  edge [fontname=Arial, fontsize=8]\n  \"step-filter\" [label=\"step-filter\n(exclude rows with NA)\", shape=box, style=filled, fillcolor=white]\n\n}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}inspect_dot(schema)
#> digraph schema {
#>   graph [rankdir=TD, fontname=Arial]
#>   node [fontname=Arial, fontsize=10]
#>   edge [fontname=Arial, fontsize=8]
#>   "step-filter" [label="step-filter 
#>  (exclude rows with NA)", shape=box, style=filled, fillcolor=white]
#> } 

schema2 <- build_schema(data = my_data) |>
  add_step(
    id = "step-filter", objective = "remove missing values",
    decision = "impute with median",
    inputs = c("age", "income"), outputs = "df_clean"
  )
#> ✔ Data attached: "my_data"
multiverse <- as_multiverse(list(schema, schema2))
draw_tines(multiverse, index = 2)

{"x":{"diagram":"digraph schema {\n  graph [rankdir=TD, fontname=Arial]\n  node [fontname=Arial, fontsize=10]\n  edge [fontname=Arial, fontsize=8]\n  \"step-filter\" [label=\"step-filter\n(impute with median)\", shape=box, style=filled, fillcolor=white]\n\n}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}
```
