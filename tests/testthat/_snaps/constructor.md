# schema and multiverse constructor work

    Code
      schema
    Output
      # A schema: 3 x 7
        id             fork               path  rationale inputs outputs source_schema
        <chr>          <chr>              <chr> <chr>     <list> <list>  <lgl>        
      1 step-scaling   variables are in ~ appl~ to put t~ <lgl>  <lgl>   NA           
      2 step-education combine the schoo~ aver~ the most~ <lgl>  <lgl>   NA           
      3 step-combine   combine the three~ use ~ the geom~ <lgl>  <lgl>   NA           

---

    Code
      my_multiverse
    Output
      A multiverse with 2 schemas:
        original: (3 steps)
        reversed: (3 steps)

# validation errors remain stable

    All elements in a multiverse must be of class <schema>.
    i Arguments at positions 2 are invalid.

