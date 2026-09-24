# read and write

    Code
      schema_read
    Output
      # A schema: HDI Example
        id             objective                     decision rationale inputs outputs
        <chr>          <chr>                         <chr>    <chr>     <list> <list> 
      1 step-scaling   variables are in different s~ apply m~ to put t~ <chr>  <chr>  
      2 step-education combine the school variables~ average~ the most~ <chr>  <chr>  
      3 step-combine   combine the three dimensions~ use the~ the geom~ <chr>  <chr>  

---

    Code
      multiverse_read
    Output
      A multiverse with 2 schemas:
        original: "HDI Example" (3 steps)
        step-arithmetic-mean: "HDI Example" (3 steps)

