# schema and multiverse constructor work

    Code
      schema
    Output
      # A schema: HDI Example
        id             objective                     decision rationale inputs outputs
        <chr>          <chr>                         <chr>    <chr>     <list> <list> 
      1 step-scaling   variables are in different s~ apply m~ to put t~ <lgl>  <lgl>  
      2 step-education combine the school variables~ average~ the most~ <lgl>  <lgl>  
      3 step-combine   combine the three dimensions~ use the~ the geom~ <lgl>  <lgl>  

---

    Code
      my_multiverse
    Output
      A multiverse with 2 schemas:
        original: "HDI Example" (3 steps)
        reversed: "HDI Example" (3 steps)

# validation errors remain stable

    All elements in a multiverse must be of class <schema>.
    i Arguments at positions 2 are invalid.

# print methods remain stable (snapshot)

    Code
      print(build_schema())
    Output
      # A schema: 0 x 6
      # i 6 variables: id <chr>, objective <chr>, decision <chr>, rationale <chr>,
      #   inputs <list>, outputs <list>

---

    Code
      print(new_multiverse(list()))
    Output
      An empty multiverse

---

    Code
      print(as_multiverse(list(only_branch = example_schema())))
    Output
      A multiverse with 1 schema:
        only_branch: "HDI Example" (3 steps)

