# alternative() constructs a valid list and catches missing arguments

    Code
      an_alternative
    Output
      $id
      [1] "test-tag"
      
      $fork
      [1] "test fork"
      
      $path
      [1] "test path"
      
      $rationale
      [1] "test rationale"
      

---

    All arguments (`id`, `fork`, `path`, `rationale`) are required.

---

    Code
      alt_obj
    Output
      # Alternatives: block-target
        id    fork  path  rationale 
        <chr> <chr> <chr> <chr>     
      1 tag1  fork1 path1 rationale1

# read and write with an alternative yaml

    Code
      read_alternatives(tmp_file)
    Output
      # Alternatives: step-logistic-model
        id                                path                               rationale
        <chr>                             <chr>                              <chr>    
      1 step-mixed-effects-logistic-model fit a generalized linear mixed-ef~ mixed-ef~
      2 step-probit-regression-model      fit a probit regression model usi~ probit m~
      3 step-bayesian-logistic-model      fit a Bayesian logistic regressio~ the Baye~

