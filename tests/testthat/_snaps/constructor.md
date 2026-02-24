# schema and multiverse constructor work

    Code
      schema
    Output
      $nodes
      # A tibble: 3 x 6
        tag             action                     type  decision justification status
        <chr>           <chr>                      <chr> <chr>    <chr>         <chr> 
      1 block-scaling   variables are in differen~ cons~ apply m~ to put them ~ VERIF~
      2 block-education combine the school variab~ step  average~ the most int~ VERIF~
      3 block-combine   combine the three dimensi~ step  use the~ the geometri~ VERIF~
      
      $edges
      # A tibble: 3 x 3
        from            to              type      
        <chr>           <chr>           <chr>     
      1 block-scaling   block-education sequential
      2 block-combine   block-scaling   motivated 
      3 block-education block-combine   sequential
      
      attr(,"class")
      [1] "schema"
      attr(,"name")
      [1] "HDI Example"

---

    Code
      my_multiverse
    Output
      $original
      $nodes
      # A tibble: 3 x 6
        tag             action                     type  decision justification status
        <chr>           <chr>                      <chr> <chr>    <chr>         <chr> 
      1 block-scaling   variables are in differen~ cons~ apply m~ to put them ~ VERIF~
      2 block-education combine the school variab~ step  average~ the most int~ VERIF~
      3 block-combine   combine the three dimensi~ step  use the~ the geometri~ VERIF~
      
      $edges
      # A tibble: 3 x 3
        from            to              type      
        <chr>           <chr>           <chr>     
      1 block-scaling   block-education sequential
      2 block-combine   block-scaling   motivated 
      3 block-education block-combine   sequential
      
      attr(,"class")
      [1] "schema"
      attr(,"name")
      [1] "HDI Example"
      
      $reversed
      $nodes
      # A tibble: 3 x 6
        tag             action                     type  decision justification status
        <chr>           <chr>                      <chr> <chr>    <chr>         <chr> 
      1 block-education combine the school variab~ step  average~ the most int~ VERIF~
      2 block-scaling   variables are in differen~ cons~ apply m~ to put them ~ VERIF~
      3 block-combine   combine the three dimensi~ step  use the~ the geometri~ VERIF~
      
      $edges
      # A tibble: 3 x 3
        from            to            type      
        <chr>           <chr>         <chr>     
      1 block-education block-scaling sequential
      2 block-scaling   block-combine sequential
      3 block-combine   block-scaling motivated 
      
      attr(,"class")
      [1] "schema"
      attr(,"name")
      [1] "HDI Example"
      
      attr(,"class")
      [1] "multiverse" "list"      

# validation errors remain stable

    All elements in a multiverse must be of class <schema>.
    i Arguments at positions 2 are invalid.

