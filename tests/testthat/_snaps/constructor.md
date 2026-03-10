# schema and multiverse constructor work

    Code
      schema
    Output
      $nodes
      # A tibble: 3 x 9
        tag    action type  decision justification status inputs outputs source_schema
        <chr>  <chr>  <chr> <chr>    <chr>         <chr>  <list> <list>  <lgl>        
      1 block~ varia~ cons~ apply m~ to put them ~ VERIF~ <lgl>  <lgl>   NA           
      2 block~ combi~ step  average~ the most int~ VERIF~ <lgl>  <lgl>   NA           
      3 block~ combi~ step  use the~ the geometri~ VERIF~ <lgl>  <lgl>   NA           
      
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
      # A tibble: 3 x 9
        tag    action type  decision justification status inputs outputs source_schema
        <chr>  <chr>  <chr> <chr>    <chr>         <chr>  <list> <list>  <lgl>        
      1 block~ varia~ cons~ apply m~ to put them ~ VERIF~ <lgl>  <lgl>   NA           
      2 block~ combi~ step  average~ the most int~ VERIF~ <lgl>  <lgl>   NA           
      3 block~ combi~ step  use the~ the geometri~ VERIF~ <lgl>  <lgl>   NA           
      
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
      # A tibble: 3 x 9
        tag    action type  decision justification status inputs outputs source_schema
        <chr>  <chr>  <chr> <chr>    <chr>         <chr>  <list> <list>  <lgl>        
      1 block~ combi~ step  average~ the most int~ VERIF~ <lgl>  <lgl>   NA           
      2 block~ varia~ cons~ apply m~ to put them ~ VERIF~ <lgl>  <lgl>   NA           
      3 block~ combi~ step  use the~ the geometri~ VERIF~ <lgl>  <lgl>   NA           
      
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

