# alternative() constructs a valid list and catches missing arguments

    Code
      an_alternative
    Output
      $tag
      [1] "test-tag"
      
      $action
      [1] "test action"
      
      $decision
      [1] "test decision"
      
      $justification
      [1] "test justification"
      

---

    All arguments (`tag`, `action`, `decision`, `justification`) are required.

---

    Code
      alt_obj
    Output
      [[1]]
      [[1]]$tag
      [1] "tag1"
      
      [[1]]$action
      [1] "action1"
      
      [[1]]$decision
      [1] "decision1"
      
      [[1]]$justification
      [1] "justification1"
      
      
      attr(,"class")
      [1] "alternatives" "list"        
      attr(,"block")
      [1] "block-target"

# read and write with an alternative yaml

    Code
      read_alternatives(tmp_file)
    Output
      [[1]]
      [[1]]$tag
      [1] "block-mixed-effects-logistic-model"
      
      [[1]]$action
      [1] "estimate the effect size of skin tone on red card"
      
      [[1]]$decision
      [1] "fit a generalized linear mixed-effects model (GLMM) with random intercepts for players and referees to account for hierarchical data structure"
      
      [[1]]$justification
      [1] "mixed-effects models are appropriate for clustered data as they control for non-independence of observations within players and referees, leading to more reliable standard errors and effect estimates"
      
      
      [[2]]
      [[2]]$tag
      [1] "block-probit-regression-model"
      
      [[2]]$action
      [1] "estimate the effect size of skin tone on red card"
      
      [[2]]$decision
      [1] "fit a probit regression model using the average skin tone rating and specified covariates"
      
      [[2]]$justification
      [1] "probit models provide a methodologically valid alternative to logistic regression by assuming a normally distributed latent variable, serving as a sensitivity check for the choice of link function"
      
      
      [[3]]
      [[3]]$tag
      [1] "block-bayesian-logistic-model"
      
      [[3]]$action
      [1] "estimate the effect size of skin tone on red card"
      
      [[3]]$decision
      [1] "fit a Bayesian logistic regression model with the average skin tone rating as a predictor and weakly informative priors"
      
      [[3]]$justification
      [1] "the Bayesian approach provides a complete posterior distribution of the effect size rather than a point estimate, allowing for a more nuanced probabilistic interpretation of the skin tone effect and its uncertainty"
      
      
      attr(,"class")
      [1] "alternatives" "list"        
      attr(,"block")
      [1] "block-logistic-model"

