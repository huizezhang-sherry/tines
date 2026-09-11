# Construct \`alternatives\` objects

Construct \`alternatives\` objects

## Usage

``` r
alternative(id, decision, rationale)

node(overrides, ...)

new_alternatives(..., branch)
```

## Arguments

- id:

  Unique identifier for this alternative (kebab-case).

- decision:

  The new method/implementation.

- rationale:

  Why this method is valid.

- overrides:

  The id of the step this node overrides.

- ...:

  For \`node()\`: one or more alternatives, created by
  \`alternative()\`. For \`new_alternatives()\`: one or more nodes,
  created by \`node()\`.

- branch:

  Required: either \`"multi"\` or \`"single"\`. There is no default –
  the two modes produce very different numbers of branches, so this must
  be chosen explicitly.

  \`"multi"\` treats each node's alternatives as independent choices:
  \`expand_tines()\` expands into the full cross product of "keep this
  step's original decision" plus each listed alternative, across every
  node. A single node with N alternatives is just N new branches (as
  today); K nodes with \`n_i\` alternatives each give the full
  \`prod(n_i + 1)\` factorial, since "keep original" is itself one of
  the choices at every node.

  \`"single"\` requires exactly one alternative per node, and combines
  all nodes' (sole) alternatives into a single coordinated branch –
  useful for expressing one change that spans several steps together.

## Examples

``` r
example_alternatives(case = "football")
#> # Alternatives: step-logistic-model (multi)
#>   overrides           alternatives    
#>   <chr>               <list>          
#> 1 step-logistic-model <tibble [3 × 3]>

# multi-branch: 3 independent alternatives for one step
new_alternatives(
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
  ),
  branch = "multi"
)
#> # Alternatives: step-combine (multi)
#>   overrides    alternatives    
#>   <chr>        <list>          
#> 1 step-combine <tibble [2 × 3]>

# single-branch: one coordinated change across two steps
new_alternatives(
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
#> # Alternatives: step-scaling, step-education (single)
#>   overrides      alternatives    
#>   <chr>          <list>          
#> 1 step-scaling   <tibble [1 × 3]>
#> 2 step-education <tibble [1 × 3]>
```
