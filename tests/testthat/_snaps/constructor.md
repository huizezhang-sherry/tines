# schema and multiverse constructor work

    Code
      schema
    Output
      # A schema: HDI Example
        id             objective                                    decision rationale
        <chr>          <chr>                                        <chr>    <chr>    
      1 step-scaling   variables are in different scales            apply m~ to put t~
      2 step-education combine the school variables into one dimen~ average~ the most~
      3 step-combine   combine the three dimensions into a single ~ use the~ the geom~

---

    Code
      my_multiverse
    Output
      A multiverse with 2 schemas:
        original: "HDI Example" (3 steps)
        step-arithmetic-mean: "HDI Example" (3 steps)

# validation errors remain stable

    All elements in a multiverse must be of class <schema>.
    i Arguments at positions 2 are invalid.

# print methods remain stable (snapshot)

    Code
      print(build_schema())
    Output
      # A schema: 0 x 4
      # i 4 variables: id <chr>, objective <chr>, decision <chr>, rationale <chr>

---

    Code
      print(new_multiverse(list()))
    Output
      An empty multiverse

---

    Code
      print(as_multiverse(list(only_branch = example_hdi())))
    Output
      A multiverse with 1 schema:
        only_branch: "HDI Example" (3 steps)

