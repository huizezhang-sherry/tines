# Visualize and inspect \`tines\` objects

Functions to plot the tines object with Graphviz diagrams.
\`draw_tines()\` and the \`plot()\` methods render the interactive
widget. \`inspect_dot()\` formats and prints raw DOT strings to the
console for debugging.

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

  A \`schema\` or \`multiverse\` object.

- ...:

  Additional arguments passed to methods or to \`DiagrammeR::grViz()\`.

- index:

  An integer. For a \`multiverse\`, which path index to draw. Defaults
  to 1.

- data:

  Optional. A data frame or path to a data file. If schema is unmapped,
  this will be used to automatically map variables for visualization.

- schema:

  A \`schema\` object to convert to DOT code for inspection.

- indent:

  Integer. The number of spaces to use for each indentation level in
  \`inspect_dot()\`. Defaults to 2.

- keep_attr_blocks_one_line:

  Logical. If \`TRUE\`, attempts to keep square bracket \`\[\]\`
  attribute blocks on a single line.

- trim_trailing_ws:

  Logical. If \`TRUE\`, trims trailing whitespace from the final output.

## Value

\`draw_tines()\` and \`plot()\` return an \`htmlwidget\` object produced
by \`DiagrammeR::grViz()\`. \`inspect_dot()\` invisibly returns \`NULL\`
and prints to the console.

## Examples

``` r
schema <- example_schema()
# plot() and draw_tines() are interchangeable
# draw_tines(schema)
# plot(schema)
# inspect_dot(schema)
# multiverse <- example_multiverse()
# draw_tines(multiverse, index = 2)
```
