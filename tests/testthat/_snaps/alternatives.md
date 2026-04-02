# alternative() constructs a valid list and catches missing arguments

    Code
      an_alternative
    Output
      $id
      [1] "test-tag"
      
      $action
      [1] "test action"
      
      $decision
      [1] "test decision"
      
      $justification
      [1] "test justification"
      

---

    All arguments (`id`, `action`, `decision`, `justification`) are required.

---

    Code
      alt_obj
    Output
      # Alternatives: block-target
        id    action  decision  justification 
        <chr> <chr>   <chr>     <chr>         
      1 tag1  action1 decision1 justification1

# read and write with an alternative yaml

    Code
      read_alternatives(tmp_file)
    Output
      # Alternatives: step-logistic-model
        id                                action                decision justification
        <chr>                             <chr>                 <chr>    <chr>        
      1 step-mixed-effects-logistic-model estimate the effect ~ fit a g~ mixed-effect~
      2 step-probit-regression-model      estimate the effect ~ fit a p~ probit model~
      3 step-bayesian-logistic-model      estimate the effect ~ fit a B~ the Bayesian~

