# alternative() constructs a valid list and catches missing arguments

    Code
      an_alternative
    Output
      $id
      [1] "test-tag"
      
      $objective
      [1] "test objective"
      
      $decision
      [1] "test decision"
      
      $rationale
      [1] "test rationale"
      

---

    All arguments (`id`, `objective`, `decision`, `rationale`) are required.

---

    Code
      alt_obj
    Output
      # Alternatives: block-target
        id    objective  decision  rationale 
        <chr> <chr>      <chr>     <chr>     
      1 tag1  objective1 decision1 rationale1

# read and write with an alternative yaml

    Code
      read_alternatives(tmp_file)
    Output
      # Alternatives: step-logistic-model
        id                                decision                           rationale
        <chr>                             <chr>                              <chr>    
      1 step-mixed-effects-logistic-model fit a generalized linear mixed-ef~ mixed-ef~
      2 step-probit-regression-model      fit a probit regression model usi~ probit m~
      3 step-bayesian-logistic-model      fit a Bayesian logistic regressio~ the Baye~

