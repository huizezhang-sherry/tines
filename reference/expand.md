# Expand a schema with an alternative YAML into a multiverse

Expand a schema with an alternative YAML into a multiverse

## Usage

``` r
expand_tines(x, alternatives, ...)

# S3 method for class 'schema'
expand_tines(x, alternatives, include_original = TRUE, ...)

# S3 method for class 'multiverse'
expand_tines(x, alternatives, ...)
```

## Arguments

- x:

  A \`schema\` object.

- alternatives:

  an \`alternatives\` object or the path to an alternative YAML

- ...:

  Additional arguments.

- include_original:

  A logical. If \`TRUE\`, the original schema will be included as a
  branch in the resulting multiverse. Defaults to \`TRUE\`.

## Examples

``` r
# expand on a schema
base_schema <- example_football()
alts <- example_alternatives(case = "football")
expand_tines(base_schema, alts)
#> $original
#> $nodes
#> # A tibble: 3 × 6
#>   tag                            action      type  decision justification status
#>   <chr>                          <chr>       <chr> <chr>    <chr>         <chr> 
#> 1 block-average-rater            define the… cons… average… incorporate … VERIF…
#> 2 block-victory-tie-defeat-ratio control fo… step  victory… ratios are r… VERIF…
#> 3 block-logistic-model           estimate t… step  fit a l… to answer th… VERIF…
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from                           to                   type      
#>   <chr>                          <chr>                <chr>     
#> 1 block-average-rater            block-logistic-model sequential
#> 2 block-logistic-model           block-average-rater  motivated 
#> 3 block-victory-tie-defeat-ratio block-logistic-model sequential
#> 
#> attr(,"class")
#> [1] "schema"
#> 
#> $`block-mixed-effects-logistic-model`
#> $nodes
#> # A tibble: 3 × 6
#>   tag                                action  type  decision justification status
#>   <chr>                              <chr>   <chr> <chr>    <chr>         <chr> 
#> 1 block-average-rater                define… cons… average… incorporate … VERIF…
#> 2 block-victory-tie-defeat-ratio     contro… step  victory… ratios are r… VERIF…
#> 3 block-mixed-effects-logistic-model estima… step  fit a g… mixed-effect… VERIF…
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from                               to                                 type    
#>   <chr>                              <chr>                              <chr>   
#> 1 block-average-rater                block-mixed-effects-logistic-model sequent…
#> 2 block-mixed-effects-logistic-model block-average-rater                motivat…
#> 3 block-victory-tie-defeat-ratio     block-mixed-effects-logistic-model sequent…
#> 
#> attr(,"class")
#> [1] "schema"
#> 
#> $`block-probit-regression-model`
#> $nodes
#> # A tibble: 3 × 6
#>   tag                            action      type  decision justification status
#>   <chr>                          <chr>       <chr> <chr>    <chr>         <chr> 
#> 1 block-average-rater            define the… cons… average… incorporate … VERIF…
#> 2 block-victory-tie-defeat-ratio control fo… step  victory… ratios are r… VERIF…
#> 3 block-probit-regression-model  estimate t… step  fit a p… probit model… VERIF…
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from                           to                            type      
#>   <chr>                          <chr>                         <chr>     
#> 1 block-average-rater            block-probit-regression-model sequential
#> 2 block-probit-regression-model  block-average-rater           motivated 
#> 3 block-victory-tie-defeat-ratio block-probit-regression-model sequential
#> 
#> attr(,"class")
#> [1] "schema"
#> 
#> $`block-bayesian-logistic-model`
#> $nodes
#> # A tibble: 3 × 6
#>   tag                            action      type  decision justification status
#>   <chr>                          <chr>       <chr> <chr>    <chr>         <chr> 
#> 1 block-average-rater            define the… cons… average… incorporate … VERIF…
#> 2 block-victory-tie-defeat-ratio control fo… step  victory… ratios are r… VERIF…
#> 3 block-bayesian-logistic-model  estimate t… step  fit a B… the Bayesian… VERIF…
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from                           to                            type      
#>   <chr>                          <chr>                         <chr>     
#> 1 block-average-rater            block-bayesian-logistic-model sequential
#> 2 block-bayesian-logistic-model  block-average-rater           motivated 
#> 3 block-victory-tie-defeat-ratio block-bayesian-logistic-model sequential
#> 
#> attr(,"class")
#> [1] "schema"
#> 
#> attr(,"class")
#> [1] "multiverse" "list"      

# read the alternatives from a YAML file
tmp_file <- tempfile(fileext = ".yaml")
write_alternatives(alts, tmp_file)
#> ✔ Successfully wrote alternatives to /tmp/Rtmp0RgvMH/file19be4e0ae0f0.yaml
expand_tines(base_schema, tmp_file)
#> $original
#> $nodes
#> # A tibble: 3 × 6
#>   tag                            action      type  decision justification status
#>   <chr>                          <chr>       <chr> <chr>    <chr>         <chr> 
#> 1 block-average-rater            define the… cons… average… incorporate … VERIF…
#> 2 block-victory-tie-defeat-ratio control fo… step  victory… ratios are r… VERIF…
#> 3 block-logistic-model           estimate t… step  fit a l… to answer th… VERIF…
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from                           to                   type      
#>   <chr>                          <chr>                <chr>     
#> 1 block-average-rater            block-logistic-model sequential
#> 2 block-logistic-model           block-average-rater  motivated 
#> 3 block-victory-tie-defeat-ratio block-logistic-model sequential
#> 
#> attr(,"class")
#> [1] "schema"
#> 
#> $`block-mixed-effects-logistic-model`
#> $nodes
#> # A tibble: 3 × 6
#>   tag                                action  type  decision justification status
#>   <chr>                              <chr>   <chr> <chr>    <chr>         <chr> 
#> 1 block-average-rater                define… cons… average… incorporate … VERIF…
#> 2 block-victory-tie-defeat-ratio     contro… step  victory… ratios are r… VERIF…
#> 3 block-mixed-effects-logistic-model estima… step  fit a g… mixed-effect… VERIF…
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from                               to                                 type    
#>   <chr>                              <chr>                              <chr>   
#> 1 block-average-rater                block-mixed-effects-logistic-model sequent…
#> 2 block-mixed-effects-logistic-model block-average-rater                motivat…
#> 3 block-victory-tie-defeat-ratio     block-mixed-effects-logistic-model sequent…
#> 
#> attr(,"class")
#> [1] "schema"
#> 
#> $`block-probit-regression-model`
#> $nodes
#> # A tibble: 3 × 6
#>   tag                            action      type  decision justification status
#>   <chr>                          <chr>       <chr> <chr>    <chr>         <chr> 
#> 1 block-average-rater            define the… cons… average… incorporate … VERIF…
#> 2 block-victory-tie-defeat-ratio control fo… step  victory… ratios are r… VERIF…
#> 3 block-probit-regression-model  estimate t… step  fit a p… probit model… VERIF…
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from                           to                            type      
#>   <chr>                          <chr>                         <chr>     
#> 1 block-average-rater            block-probit-regression-model sequential
#> 2 block-probit-regression-model  block-average-rater           motivated 
#> 3 block-victory-tie-defeat-ratio block-probit-regression-model sequential
#> 
#> attr(,"class")
#> [1] "schema"
#> 
#> $`block-bayesian-logistic-model`
#> $nodes
#> # A tibble: 3 × 6
#>   tag                            action      type  decision justification status
#>   <chr>                          <chr>       <chr> <chr>    <chr>         <chr> 
#> 1 block-average-rater            define the… cons… average… incorporate … VERIF…
#> 2 block-victory-tie-defeat-ratio control fo… step  victory… ratios are r… VERIF…
#> 3 block-bayesian-logistic-model  estimate t… step  fit a B… the Bayesian… VERIF…
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from                           to                            type      
#>   <chr>                          <chr>                         <chr>     
#> 1 block-average-rater            block-bayesian-logistic-model sequential
#> 2 block-bayesian-logistic-model  block-average-rater           motivated 
#> 3 block-victory-tie-defeat-ratio block-bayesian-logistic-model sequential
#> 
#> attr(,"class")
#> [1] "schema"
#> 
#> attr(,"class")
#> [1] "multiverse" "list"      

# expand on the multiverse
multiverse <- example_multiverse()
alts <- example_alternatives(case = "hdi")
expand_tines(multiverse, alts)
#> $original
#> $nodes
#> # A tibble: 3 × 6
#>   tag             action                     type  decision justification status
#>   <chr>           <chr>                      <chr> <chr>    <chr>         <chr> 
#> 1 block-scaling   variables are in differen… cons… apply m… to put them … VERIF…
#> 2 block-education combine the school variab… step  average… the most int… VERIF…
#> 3 block-combine   combine the three dimensi… step  use the… the geometri… VERIF…
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from            to              type      
#>   <chr>           <chr>           <chr>     
#> 1 block-scaling   block-education sequential
#> 2 block-combine   block-scaling   motivated 
#> 3 block-education block-combine   sequential
#> 
#> attr(,"class")
#> [1] "schema"
#> attr(,"name")
#> [1] "HDI Example"
#> 
#> $reversed
#> $nodes
#> # A tibble: 3 × 6
#>   tag             action                     type  decision justification status
#>   <chr>           <chr>                      <chr> <chr>    <chr>         <chr> 
#> 1 block-education combine the school variab… step  average… the most int… VERIF…
#> 2 block-scaling   variables are in differen… cons… apply m… to put them … VERIF…
#> 3 block-combine   combine the three dimensi… step  use the… the geometri… VERIF…
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from            to            type      
#>   <chr>           <chr>         <chr>     
#> 1 block-education block-scaling sequential
#> 2 block-scaling   block-combine sequential
#> 3 block-combine   block-scaling motivated 
#> 
#> attr(,"class")
#> [1] "schema"
#> attr(,"name")
#> [1] "HDI Example"
#> 
#> $`block-arithmetic-mean`
#> $nodes
#> # A tibble: 3 × 6
#>   tag                   action               type  decision justification status
#>   <chr>                 <chr>                <chr> <chr>    <chr>         <chr> 
#> 1 block-scaling         variables are in di… cons… apply m… to put them … VERIF…
#> 2 block-education       combine the school … step  average… the most int… VERIF…
#> 3 block-arithmetic-mean combine the three d… step  use a a… the old meth… VERIF…
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from                  to                    type      
#>   <chr>                 <chr>                 <chr>     
#> 1 block-scaling         block-education       sequential
#> 2 block-arithmetic-mean block-scaling         motivated 
#> 3 block-education       block-arithmetic-mean sequential
#> 
#> attr(,"class")
#> [1] "schema"
#> attr(,"name")
#> [1] "HDI Example"
#> 
#> $`block-arithmetic-mean`
#> $nodes
#> # A tibble: 3 × 6
#>   tag                   action               type  decision justification status
#>   <chr>                 <chr>                <chr> <chr>    <chr>         <chr> 
#> 1 block-education       combine the school … step  average… the most int… VERIF…
#> 2 block-scaling         variables are in di… cons… apply m… to put them … VERIF…
#> 3 block-arithmetic-mean combine the three d… step  use a a… the old meth… VERIF…
#> 
#> $edges
#> # A tibble: 3 × 3
#>   from                  to                    type      
#>   <chr>                 <chr>                 <chr>     
#> 1 block-education       block-scaling         sequential
#> 2 block-scaling         block-arithmetic-mean sequential
#> 3 block-arithmetic-mean block-scaling         motivated 
#> 
#> attr(,"class")
#> [1] "schema"
#> attr(,"name")
#> [1] "HDI Example"
#> 
#> attr(,"class")
#> [1] "multiverse" "list"      
```
