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

draw_tines(x, index = 1, ...)

inspect_dot(
  dot,
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

- dot:

  A character string containing raw Graphviz DOT code.

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
draw_tines(schema)

{"x":{"diagram":"digraph schema {\n  graph [rankdir=TD, fontname=Arial]\n  node [fontname=Arial, fontsize=10]\n  edge [fontname=Arial, fontsize=8]\n  \"step-scaling\" [label=\"step-scaling\n(variables are in different scales)\", shape=box, style=filled, fillcolor=white]\n  \"step-education\" [label=\"step-education\n(combine the school variables into one dimension)\", shape=box, style=filled, fillcolor=white]\n  \"step-combine\" [label=\"step-combine\n(combine the three dimensions into a single index)\", shape=box, style=filled, fillcolor=white]\n  \"step-scaling\" -> \"step-education\" [style=solid, color=black]\n  \"step-education\" -> \"step-combine\" [style=solid, color=black]\n}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}plot(schema)

{"x":{"diagram":"digraph schema {\n  graph [rankdir=TD, fontname=Arial]\n  node [fontname=Arial, fontsize=10]\n  edge [fontname=Arial, fontsize=8]\n  \"step-scaling\" [label=\"step-scaling\n(variables are in different scales)\", shape=box, style=filled, fillcolor=white]\n  \"step-education\" [label=\"step-education\n(combine the school variables into one dimension)\", shape=box, style=filled, fillcolor=white]\n  \"step-combine\" [label=\"step-combine\n(combine the three dimensions into a single index)\", shape=box, style=filled, fillcolor=white]\n  \"step-scaling\" -> \"step-education\" [style=solid, color=black]\n  \"step-education\" -> \"step-combine\" [style=solid, color=black]\n}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}inspect_dot(schema)
#> list(id = c("step-scaling", "step-education", "step-combine"), action = c("variables are in different scales", "combine the school variables into one dimension", "combine the three dimensions into a single index"), type = c("constraint", "step", "step"), decision = c("apply min-max scaling to each variable", "average exp sch and avg sch", "use the geometric mean"), justification = c("to put them on the same scale for combination", "the most intuitive way", "the geometric mean is more appropriate than arithmetic mean"
#> ), inputs = list(NA, NA, NA), outputs = list(NA, NA, NA), source_schema = c(NA, NA, NA))
#> list(from = c("step-scaling", "step-combine", "step-education"), to = c("step-education", "step-scaling", "step-combine"), type = c("sequential", "motivated", "sequential")) 
multiverse <- example_multiverse()
draw_tines(multiverse, index = 2)

{"x":{"diagram":"digraph schema {\n  graph [rankdir=TD, fontname=Arial]\n  node [fontname=Arial, fontsize=10]\n  edge [fontname=Arial, fontsize=8]\n  \"step-education\" [label=\"step-education\n(combine the school variables into one dimension)\", shape=box, style=filled, fillcolor=white]\n  \"step-scaling\" [label=\"step-scaling\n(variables are in different scales)\", shape=box, style=filled, fillcolor=white]\n  \"step-combine\" [label=\"step-combine\n(combine the three dimensions into a single index)\", shape=box, style=filled, fillcolor=white]\n  \"step-education\" -> \"step-scaling\" [style=solid, color=black]\n  \"step-scaling\" -> \"step-combine\" [style=solid, color=black]\n}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}
```
