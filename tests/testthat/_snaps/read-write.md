# read and write

    Code
      schema_read
    Output
      $nodes
      # A tibble: 3 x 8
        id            action type  decision justification source_schema inputs outputs
        <chr>         <chr>  <chr> <chr>    <chr>         <chr>         <list> <list> 
      1 block-scaling varia~ cons~ apply m~ to put them ~ <NA>          <chr>  <chr>  
      2 block-educat~ combi~ step  average~ the most int~ <NA>          <chr>  <chr>  
      3 block-combine combi~ step  use the~ the geometri~ <NA>          <chr>  <chr>  
      
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

