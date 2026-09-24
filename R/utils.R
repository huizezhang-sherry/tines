#' Generate examples
#'
#' @description
#' These functions generate pre-populated schema and multiverse objects.
#' They are primarily designed for testing, running examples in the documentation,
#' and helping new users explore the tines package without having to build a
#' garden of forking paths from scratch.
#'
#' @param case A character string specifying which example alternatives to generate. Options are "football" or "hdi". Only applies to [example_alternatives()].
#' @return
#' * For [example_schema()]: An object of class `schema`.
#' * For [example_multiverse()]: An object of class `multiverse`.
#' * For [example_football()]: An object of class `schema`
#' * For [example_alternatives()]: An object of class `alternatives`
#'
#' @rdname example_tines
#' @export
#'
#' @examples
#' # Generate a single example schema
#' example_schema()
#' example_multiverse()
#' example_football()
#' example_alternatives(case = "hdi")
#'
example_schema <- function() {
  schema <- build_schema("HDI Example") |>
    add_step(
      id = "step-scaling",
      objective = "variables are in different scales",
      decision = "apply min-max scaling to each variable",
      rationale = "to put them on the same scale for combination"
    ) |>
    add_step(
      id = "step-education",
      objective = "combine the school variables into one dimension",
      decision = "average exp sch and avg sch",
      rationale = "the most intuitive way"
    ) |>
    add_step(
      id = "step-combine",
      objective = "combine the three dimensions into a single index",
      decision = "use the geometric mean",
      rationale = "the geometric mean is more appropriate than arithmetic mean"
    )
  return(schema)
}

#' @rdname example_tines
#' @export
example_multiverse <- function() {
  schema <- example_schema()
  schema2 <- build_schema("HDI Example") |>
    add_step(
      id = "step-education",
      objective = "combine the school variables into one dimension",
      decision = "average exp sch and avg sch",
      rationale = "the most intuitive way"
    ) |>
    add_step(
      id = "step-scaling",
      objective = "variables are in different scales",
      decision = "apply min-max scaling to each variable",
      rationale = "to put them on the same scale for combination"
    ) |>
    add_step(
      id = "step-combine",
      objective = "combine the three dimensions into a single index",
      decision = "use the geometric mean",
      rationale = "the geometric mean is more appropriate than arithmetic mean"
    )

  my_multiverse <- as_multiverse(list(original = schema, reversed = schema2))
  return(my_multiverse)
}

#' @rdname example_tines
#' @export
example_football <- function() {
  build_schema() |>
    add_step(
      id = "step-average-rater",
      objective = "define the dependent variable",
      decision = "average the two ratings",
      rationale = "incorporate both rater to avoid bias"
    ) |>
    add_step(
      id = "step-victory-tie-defeat-ratio",
      objective = "control for team performance",
      decision = "victory or tie or defeat over total number of game",
      rationale = "ratios are robust to variations in season length compared to raw win counts."
    ) |>
    add_step(
      id = "step-logistic-model",
      objective = "estimate the effect size of skin tone on red card",
      decision = "fit a logistic regression model with the average rating as the dependent variable and other covariates",
      rationale = "to answer the main question"
    )
}

#' @rdname example_tines
#' @export
example_alternatives <- function(case = c("football", "hdi")) {
  case <- match.arg(case)

  hdi <- new_alternatives(
    node(
      overrides = "step-combine",
      alternative(
        id = "step-arithmetic-mean",
        decision = "use a arithmetic mean",
        rationale = "the old method"
      )
    ),
    branch = "multi"
  )


  football <- new_alternatives(
    node(
      overrides = "step-logistic-model",
      alternative(
        id = "step-mixed-effects-logistic-model",
        decision = "fit a generalized linear mixed-effects model (GLMM) with random intercepts for players and referees to account for hierarchical data structure",
        rationale = "mixed-effects models are appropriate for clustered data as they control for non-independence of observations within players and referees, leading to more reliable standard errors and effect estimates"
      ),
      alternative(
        id = "step-probit-regression-model",
        decision = "fit a probit regression model using the average skin tone rating and specified covariates",
        rationale = "probit models provide a methodologically valid alternative to logistic regression by assuming a normally distributed latent variable, serving as a sensitivity check for the choice of link function"
      ),
      alternative(
        id = "step-bayesian-logistic-model",
        decision = "fit a Bayesian logistic regression model with the average skin tone rating as a predictor and weakly informative priors",
        rationale = "the Bayesian approach provides a complete posterior distribution of the effect size rather than a point estimate, allowing for a more nuanced probabilistic interpretation of the skin tone effect and its uncertainty"
      )
    ),
    branch = "multi"
  )

  if (case == "football") {
    return(football)
  } else if (case == "hdi") {
    return(hdi)
  } else {
    cli::cli_abort("Invalid case specified. Choose either 'football' or 'hdi'.")
  }
}

#' @rdname example_tines
#' @export
example_football_grp20 <- function() {
  read_tines(system.file("football-grp20.yaml", package = "tines"))
}

#' @rdname example_tines
#' @export
example_football_grp5 <- function() {
  read_tines(system.file("football-grp5/football-grp5.yaml", package = "tines"))
}


#' Functions to access components of a tine object
#' @param object A `schema` or `multiverse` object.
#' @return If `object` is a `schema`, a character vector of its steps' ids.
#'   If `object` is a `multiverse`, a list of such character vectors, one
#'   per schema in the multiverse.
#' @export
#' @rdname get
#' @examples
#' get_step_names(example_schema())
#' get_step_names(example_multiverse())
get_step_names <- function(object) {
  if (inherits(object, "schema")) {
    step_names <- object$id
  } else if (inherits(object, "multiverse")) {
    step_names <- lapply(object, function(s) s$id)
  } else {
    cli::cli_abort(c(
      "Unsupported object type: {.cls {class(object)}}.",
      "i" = "Expected an object of class {.cls schema} or {.cls multiverse}."
    ))
  }
  return(step_names)
}


#'
print_prompt <- function(prompt, print, width = 70) {
  if (print) {
    cat(strwrap(prompt, width = width), sep = "\n")
    invisible(prompt)
  } else {
    prompt
  }
}
