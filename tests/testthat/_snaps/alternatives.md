# alternative() constructs a valid list and catches missing arguments

    Code
      an_alternative
    Output
      $id
      [1] "test-tag"
      
      $decision
      [1] "test decision"
      
      $rationale
      [1] "test rationale"
      

---

    All arguments (`id`, `decision`, `rationale`) are required.

# node() bundles alternatives under one step and catches missing arguments

    `overrides` and at least one `alternative()` are required.

# branch = 'multi' expands one node into independent branches

    Code
      alts
    Output
      # Alternatives: step-combine (multi)
        overrides    alternatives    
        <chr>        <list>          
      1 step-combine <tibble [3 x 3]>

# branch = 'single' requires exactly one alternative per node

    `branch = "single"` requires exactly one alternative per node.
    i Step "step-scaling" has 2 alternative(s) instead of 1.

# read and write with an alternative yaml

    Code
      read_alternatives(tmp_file)
    Output
      # Alternatives: step-logistic-model (multi)
        overrides           alternatives    
        <chr>               <list>          
      1 step-logistic-model <tibble [3 x 3]>

