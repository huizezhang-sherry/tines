# schema and multiverse constructor work

    Code
      schema
    Output
      # A schema: HDI Example
        id             objective       decision rationale inputs outputs source_schema
        <chr>          <chr>           <chr>    <chr>     <list> <list>  <lgl>        
      1 step-scaling   variables are ~ apply m~ to put t~ <lgl>  <lgl>   NA           
      2 step-education combine the sc~ average~ the most~ <lgl>  <lgl>   NA           
      3 step-combine   combine the th~ use the~ the geom~ <lgl>  <lgl>   NA           

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
      # A schema: 0 x 7
      # i 7 variables: id <chr>, objective <chr>, decision <chr>, rationale <chr>,
      #   inputs <list>, outputs <list>, source_schema <chr>

---

    Code
      print(new_multiverse(list()))
    Output
      An empty multiverse

---

    Code
      print(build_multiverse(only_branch = example_schema()))
    Output
      A multiverse with 1 schema:
        only_branch: "HDI Example" (3 steps)

