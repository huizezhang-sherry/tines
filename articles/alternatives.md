# Structuring Alternative Files

``` r

library(tines)
```

An **alternatives file** describes one or more different ways to carry
out one or more steps in a `schema`. Passing one to
[`expand_tines()`](../reference/expand.md) turns a single schema into a
`multiverse`. This vignette covers

- the anatomy of an alternatives YAML file,
- how to create one by hand, in R, or with an LLM, and
- how [`expand_tines()`](../reference/expand.md) combines a schema and
  an alternatives file into a multiverse.

## The big picture

An alternatives file is a list of **nodes**. Each node names a step
(`overrides`) and a set of candidate `alternatives` for it, each with
its own `id`, `decision`, and `rationale` – the skeleton always looks
like this:

    meta:
      type: alternatives
      branch: single | multi
    nodes:
      - overrides: <step id>
        alternatives:
          - id: <alternative id>
            decision: <...>
            rationale: <...>
          - id: <alternative id>
            ...
      - overrides: <step id>
        alternatives:
          ...
      ...

`meta.branch` tells [`expand_tines()`](../reference/expand.md) how to
turn the nodes into branches:

- **`single`**: every node must have exactly one alternative; they’re
  all combined into a single branch that changes every listed step.
- **`multi`**: each node’s alternatives are independent choices layered
  on top of original choice. Their cross-product is taken to produce a
  branch for every combination of alternatives. For a node with `n`
  alternatives, that’s `n + 1` branches (the original plus one per
  alternative). For `K` nodes with `n_i` alternatives each, that’s
  `prod(n_i + 1)` branches.

## The HDI example

For the rest of this vignette, we’ll use the Human Development Index
(HDI) as an example. The HDI is a composite index of three dimensions:
health, education, and standard of living that comprises of the
following steps:

- `step-scaling`: Normalize the data to a common scale.
- `step-education`: Calculate the education component of the HDI.
- `step-combine`: Combine the three components into a single index.

``` yaml
meta:
  type: schema
  date: '2026-09-10'
  name: HDI Example
nodes:
- id: step-scaling
  objective: variables are in different scales
  decision: apply min-max scaling to each variable
  rationale: to put them on the same scale for combination
- id: step-education
  objective: combine the school variables into one dimension
  decision: average exp sch and avg sch
  rationale: the most intuitive way
- id: step-combine
  objective: combine the three dimensions into a single index
  decision: use the geometric mean
  rationale: the geometric mean is more appropriate than arithmetic mean
```

We can read this in and turn it into a `schema` object with
[`read_tines()`](../reference/read-write.md):

``` r

schema <- read_tines(schema_path)
schema
#> # A schema: HDI Example
#>   id             objective                     decision rationale inputs outputs
#>   <chr>          <chr>                         <chr>    <chr>     <list> <list> 
#> 1 step-scaling   variables are in different s… apply m… to put t… <chr>  <chr>  
#> 2 step-education combine the school variables… average… the most… <chr>  <chr>  
#> 3 step-combine   combine the three dimensions… use the… the geom… <chr>  <chr>
```

## Case 1: Multiple steps on a single branch

Sometimes you want to create your own version of the analysis that
mostly follows the original schema, but changes a few decisions – for
example, switching `step-scaling` to z-scoring and `step-education` to
the max of the two school variables. `branch: single` combines those
changes into one coordinated branch, rather than exploring each one
independently:

``` yaml
meta:
  type: alternatives
  branch: single
nodes:
  - overrides: step-scaling
    alternatives:
      - id: step-scaling-zscore
        decision: "z-score each variable"
        rationale: "puts variables on a common, interpretable scale"
  - overrides: step-education
    alternatives:
      - id: step-education-max
        decision: "use the max of the two school variables"
        rationale: "captures the higher-attainment measure"
```

In the above example, the `branch: single` indicates that both steps
should be changed together in a single branch, rather than
independently.

------------------------------------------------------------------------

We can create this alternatives file in two ways:

- use [`draft_alternatives()`](../reference/template.md) to create a
  draft template and fill it in by hand, or
- create it programmatically in R using the
  [`node()`](../reference/alternatives.md),
  [`alternative()`](../reference/alternatives.md), and
  [`new_alternatives()`](../reference/alternatives.md) functions.

**1. Draft a template with
[`draft_alternatives()`](../reference/template.md) and fill it in by
hand:**

``` r

draft_path_single <- withr::local_tempfile(fileext = ".yml")
draft_alternatives(
  schema,
  id = c("step-scaling", "step-education"),
  branch = "single",
  file_path = draft_path_single
)
#> ✔ Created template at /tmp/RtmpYjygHS/file1be2304d9b2f.yml
```

``` yaml
meta:
  type: alternatives
  branch: single
nodes:
  - overrides: step-scaling
    alternatives:
      - id: "new-alternative-step-scaling"
        decision: ""
        rationale: ""
  - overrides: step-education
    alternatives:
      - id: "new-alternative-step-education"
        decision: ""
        rationale: ""
```

**2. Build one directly in R with
[`node()`](../reference/alternatives.md) +
[`alternative()`](../reference/alternatives.md) +
[`new_alternatives()`](../reference/alternatives.md):**

``` r

alts_combo <- new_alternatives(
  node(
    overrides = "step-scaling",
    alternative(
      id = "step-scaling-zscore",
      decision = "z-score each variable",
      rationale = "puts variables on a common, interpretable scale"
    )
  ),
  node(
    overrides = "step-education",
    alternative(
      id = "step-education-max",
      decision = "use the max of the two school variables",
      rationale = "captures the higher-attainment measure"
    )
  ),
  branch = "single"
)
alts_combo
#> # Alternatives: step-scaling, step-education (single)
#>   overrides      alternatives    
#>   <chr>          <list>          
#> 1 step-scaling   <tibble [1 × 3]>
#> 2 step-education <tibble [1 × 3]>
```

…and, if you want a YAML file out of it, write it back out with
[`write_alternatives()`](../reference/read-write-alternatives.md):

``` r

tmp_file_single <- withr::local_tempfile(fileext = ".yml")
write_alternatives(alts_combo, tmp_file_single)
#> ✔ Successfully wrote alternatives to /tmp/RtmpYjygHS/file1be26f612678.yml
```

------------------------------------------------------------------------

You can combine this alternative specification with the original schema
to form a set of new schemas, or a **multiverse**, with 2 branches using
[`expand_tines()`](../reference/expand.md):

``` r

mv <- expand_tines(schema, alternatives = alts_combo)
mv
#> A multiverse with 2 schemas:
#>   original: "HDI Example" (3 steps)
#>   step-scaling-zscore+step-education-max: "HDI Example" (3 steps)
mv$`step-scaling-zscore+step-education-max`
#> # A schema: HDI Example
#>   id             objective                     decision rationale inputs outputs
#>   <chr>          <chr>                         <chr>    <chr>     <list> <list> 
#> 1 step-scaling   variables are in different s… z-score… puts var… <chr>  <chr>  
#> 2 step-education combine the school variables… use the… captures… <chr>  <chr>  
#> 3 step-combine   combine the three dimensions… use the… the geom… <chr>  <chr>
```

Under `branch: single`, every node must have exactly one alternative.
This is checked as soon as an `alternatives` object is built, read, and
printed:

``` r

alts_bad <- alts_combo
alts_bad$alternatives[[1]] <- rbind(
  alts_bad$alternatives[[1]],
  tibble::tibble(
    id = "step-scaling-minmax", decision = "...", rationale = "..."
  )
)
alts_bad
#> Error:
#> ! `branch = "single"` requires exactly one alternative per node.
#> ℹ Step "step-scaling" has 2 alternative(s) instead of 1.
```

## Case 2: Checking multiple alternatives of a single step

One may consider testing a set of different alternatives for a single
step. For example, one could use an arithmetic mean or a weighted mean
that down-weights noisier dimensions. This can be represented in an
alternatives file as follows:

``` yaml
meta:
  type: alternatives
  branch: multi
nodes:
  - overrides: step-combine
    alternatives:
      - id: step-arithmetic-mean
        decision: "use an arithmetic mean"
        rationale: "the old method"
      - id: step-weighted-mean
        decision: "use a weighted mean, weighting each dimension by its variance"
        rationale: "down-weights noisier dimensions"
```

We can create this alternatives file in two ways:

- use [`draft_alternatives()`](../reference/template.md) to create a
  draft template and fill it in by hand, or
- create it programmatically in R using the
  [`node()`](../reference/alternatives.md),
  [`alternative()`](../reference/alternatives.md), and
  [`new_alternatives()`](../reference/alternatives.md) functions.
- ask an LLM to propose alternatives with
  [`gen_alternatives()`](../reference/gen_alternatives.md).

**1. Draft a template with
[`draft_alternatives()`](../reference/template.md) and fill it in by
hand:**

``` r

draft_path <- withr::local_tempfile(fileext = ".yml")
draft_alternatives(
  schema, id = "step-combine", branch = "multi", file_path = draft_path
)
#> ✔ Created template at /tmp/RtmpYjygHS/file1be222c93026.yml
```

``` yaml
meta:
  type: alternatives
  branch: multi
nodes:
  - overrides: step-combine
    alternatives:
      - id: "new-alternative-1"
        decision: ""
        rationale: ""
      - id: "new-alternative-2"
        decision: ""
        rationale: ""
```

[`draft_alternatives()`](../reference/template.md) requires a `branch`
and `id` argument. The draft template contians two placeholder
alternatives for one nodes. Users can edit the file to fill in the
decision and rationale for each alternative, and add more alternatives
or nodes as needed.

**2. Build one directly in R with
[`node()`](../reference/alternatives.md) +
[`alternative()`](../reference/alternatives.md) +
[`new_alternatives()`](../reference/alternatives.md):**

[`new_alternatives()`](../reference/alternatives.md) likewise requires
`branch` to be given explicitly:

``` r

alts <- new_alternatives(
  branch = "multi",
  node(
    overrides = "step-combine",
    alternative(
      id = "step-arithmetic-mean",
      decision = "use an arithmetic mean",
      rationale = "the old method"
    ),
    alternative(
      id = "step-weighted-mean",
      decision = "use a weighted mean, weighting each dimension by its variance",
      rationale = "down-weights noisier dimensions"
    )
  )
)
alts
#> # Alternatives: step-combine (multi)
#>   overrides    alternatives    
#>   <chr>        <list>          
#> 1 step-combine <tibble [2 × 3]>
```

…and, if you want a YAML file out of it, write it back out with
[`write_alternatives()`](../reference/read-write-alternatives.md):

``` r

tmp_file <- withr::local_tempfile(fileext = ".yml")
write_alternatives(alts, tmp_file)
#> ✔ Successfully wrote alternatives to /tmp/RtmpYjygHS/file1be27a6cac51.yml
```

``` yaml
meta:
  type: alternatives
  branch: multi
nodes:
- overrides: step-combine
  alternatives:
  - id: step-arithmetic-mean
    decision: use an arithmetic mean
    rationale: the old method
  - id: step-weighted-mean
    decision: use a weighted mean, weighting each dimension by its variance
    rationale: down-weights noisier dimensions
```

**3. Ask an LLM to propose alternatives with
[`gen_alternatives()`](../reference/gen_alternatives.md):**

``` r

gen_alternatives(
  schema,
  step = "step-combine", n = 3,
  file_path = "step-combine-alt.yml"
)
```

[`gen_alternatives()`](../reference/gen_alternatives.md) always targets
one step, so it produces a `branch: multi` file with exactly one node.

------------------------------------------------------------------------

When `branch = multi`, [`expand_tines()`](../reference/expand.md)
produces a branch for every alternative, plus the original. In this
case, with 2 alternatives, this results in 3 branches:

``` r

mv <- expand_tines(schema, alts)
mv
#> A multiverse with 3 schemas:
#>   original: "HDI Example" (3 steps)
#>   step-arithmetic-mean: "HDI Example" (3 steps)
#>   step-weighted-mean: "HDI Example" (3 steps)
mv$`step-weighted-mean`
#> # A schema: HDI Example
#>   id             objective                     decision rationale inputs outputs
#>   <chr>          <chr>                         <chr>    <chr>     <list> <list> 
#> 1 step-scaling   variables are in different s… apply m… to put t… <chr>  <chr>  
#> 2 step-education combine the school variables… average… the most… <chr>  <chr>  
#> 3 step-combine   combine the three dimensions… use a w… down-wei… <chr>  <chr>
```

[`expand_tines()`](../reference/expand.md) also accepts a path to a YAML
file directly:

``` r

expand_tines(schema, tmp_file)
#> A multiverse with 3 schemas:
#>   original: "HDI Example" (3 steps)
#>   step-arithmetic-mean: "HDI Example" (3 steps)
#>   step-weighted-mean: "HDI Example" (3 steps)
```

## Case 3: Checking multiple alternatives of multiple steps

With `branch: multi` and more than one node,
[`expand_tines()`](../reference/expand.md) crosses every node’s choices
together.

``` r

alts_factorial <- new_alternatives(
  branch = "multi", 
  node(
    overrides = "step-scaling",
    alternative(
      id = "step-scaling-zscore",
      decision = "z-score each variable",
      rationale = "puts variables on a common, interpretable scale"
    )
  ),
  node(
    overrides = "step-combine",
    alternative(
      id = "step-arithmetic-mean",
      decision = "use an arithmetic mean",
      rationale = "the old method"
    ),
    alternative(
      id = "step-weighted-mean",
      decision = "use a weighted mean, weighting each dimension by its variance",
      rationale = "down-weights noisier dimensions"
    )
  )
)
mv <- expand_tines(schema, alts_factorial)
mv
#> A multiverse with 6 schemas:
#>   original: "HDI Example" (3 steps)
#>   step-scaling-zscore: "HDI Example" (3 steps)
#>   step-arithmetic-mean: "HDI Example" (3 steps)
#>   step-scaling-zscore+step-arithmetic-mean: "HDI Example" (3 steps)
#>   step-weighted-mean: "HDI Example" (3 steps)
#>   step-scaling-zscore+step-weighted-mean: "HDI Example" (3 steps)
length(mv)
#> [1] 6
names(mv)
#> [1] "original"                                
#> [2] "step-scaling-zscore"                     
#> [3] "step-arithmetic-mean"                    
#> [4] "step-scaling-zscore+step-arithmetic-mean"
#> [5] "step-weighted-mean"                      
#> [6] "step-scaling-zscore+step-weighted-mean"
```

`step-scaling` has 1 alternative and `step-combine` has 2, so this
crosses into `(1 + 1) x (2 + 1)` = 6 schemas: `original`,
`step-scaling-zscore` alone, each of `step-combine`’s two alternatives
alone, and each of those two paired with `step-scaling-zscore`.
