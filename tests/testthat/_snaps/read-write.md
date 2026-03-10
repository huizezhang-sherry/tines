# read and write

    Code
      schema_read
    Output
      $nodes
      # A tibble: 3 x 9
        tag    action type  decision justification status inputs outputs source_schema
        <chr>  <chr>  <chr> <chr>    <chr>         <chr>  <list> <list>  <lgl>        
      1 block~ varia~ cons~ apply m~ to put them ~ VERIF~ <NULL> <NULL>  NA           
      2 block~ combi~ step  average~ the most int~ VERIF~ <NULL> <NULL>  NA           
      3 block~ combi~ step  use the~ the geometri~ VERIF~ <NULL> <NULL>  NA           
      
      $edges
      # A tibble: 3 x 3
        from            to              type      
        <chr>           <chr>           <chr>     
      1 block-scaling   block-education sequential
      2 block-combine   block-scaling   motivated 
      3 block-education block-combine   sequential
      
      attr(,"class")
      [1] "schema"

---

    Code
      multiverse_read
    Output
      list()
      attr(,"class")
      [1] "multiverse" "list"      

