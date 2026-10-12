# read and write

    Code
      schema_read
    Output
      # A schema: HDI Example
        id             objective                                    decision rationale
        <chr>          <chr>                                        <chr>    <chr>    
      1 step-scaling   variables are in different scales            apply m~ to put t~
      2 step-education combine the school variables into one dimen~ average~ the most~
      3 step-combine   combine the three dimensions into a single ~ use the~ the geom~

---

    Code
      multiverse_read
    Output
      A multiverse with 2 schemas:
        original: "HDI Example" (3 steps)
        step-arithmetic-mean: "HDI Example" (3 steps)

