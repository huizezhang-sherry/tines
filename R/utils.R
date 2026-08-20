#' Generate examples
#'
#' @description
#' These functions generate pre-populated `schema` and `multiverse` objects.
#' They are primarily designed for testing, running examples in the documentation,
#' and helping new users explore the `tines` package without having to build a
#' garden of forking paths from scratch.
#'
#' @param case A character string specifying which example alternatives to generate. Options are "football" or "hdi". Only applies to `example_alternatives()`.
#' @return
#' * For `example_schema()`: An object of class `schema`.
#' * For `example_multiverse()`: An object of class `multiverse`.
#' * For `example_football()`: An object of class `schema`
#' * For `example_alternatives()`: An object of class `alternatives`
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

  my_multiverse <- build_multiverse(original = schema, reversed = schema2)
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
  hdi <- new_alternatives(
    step = "step-combine",
    alternative(
      id = "step-arithmetic-mean",
      objective = "combine the three dimensions into a single index",
      decision = "use a arithmetic mean",
      rationale = "the old method"
    )
  )


  football <- new_alternatives(
    step = "step-logistic-model",
    alternative(
      id = "step-mixed-effects-logistic-model",
      objective = "estimate the effect size of skin tone on red card",
      decision = "fit a generalized linear mixed-effects model (GLMM) with random intercepts for players and referees to account for hierarchical data structure",
      rationale = "mixed-effects models are appropriate for clustered data as they control for non-independence of observations within players and referees, leading to more reliable standard errors and effect estimates"
    ),
    alternative(
      id = "step-probit-regression-model",
      objective = "estimate the effect size of skin tone on red card",
      decision = "fit a probit regression model using the average skin tone rating and specified covariates",
      rationale = "probit models provide a methodologically valid alternative to logistic regression by assuming a normally distributed latent variable, serving as a sensitivity check for the choice of link function"
    ),
    alternative(
      id = "step-bayesian-logistic-model",
      objective = "estimate the effect size of skin tone on red card",
      decision = "fit a Bayesian logistic regression model with the average skin tone rating as a predictor and weakly informative priors",
      rationale = "the Bayesian approach provides a complete posterior distribution of the effect size rather than a point estimate, allowing for a more nuanced probabilistic interpretation of the skin tone effect and its uncertainty"
    )
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
example_spei <- function() {
  build_schema() |>
    add_step(
      id = "step-calc-pet",
      objective = "transform average temperature to obtain potential evapotranspiration (PET)",
      decision = "use Thornthwaite equation",
      rationale = "estimates PET using only mean temperature and latitude",
      inputs = c(".proxy_tavg"),
      outputs = c(".proxy_pet")
    ) |>
    add_step(
      id = "step-calc-diff",
      objective = "calculate difference series between precipitation and PET",
      decision = "subtract PET from Precipitation (P - PET)",
      rationale = "represents the climatic water balance (surplus or deficit)",
      inputs = c(".proxy_prcp", ".proxy_pet"),
      outputs = c(".proxy_diff")
    ) |>
    add_step(
      id = "step-temporal-agg",
      objective = "perform temporal aggregation on the difference series",
      decision = "calculate rolling sum of the P-PET difference",
      rationale = "accumulates water balance over a specific time scale",
      inputs = c(".proxy_diff"),
      outputs = c(".proxy_agg")
    ) |>
    add_step(
      id = "step-dist-fit",
      objective = "fit a probability distribution to the aggregated series",
      decision = "fit a Log-Logistic distribution",
      rationale = "difference series can be negative, so Gamma cannot be used; Log-Logistic handles negative values",
      inputs = c(".proxy_agg"),
      outputs = c(".proxy_fit")
    ) |>
    add_step(
      id = "step-normalize",
      objective = "normalize the fitted values",
      decision = "transform to standard normal z-scores",
      rationale = "standardizes the index",
      inputs = c(".proxy_fit"),
      outputs = c(".proxy_index")
    )
}

#' @rdname example_tines
#' @export
example_spi <- function() {
  build_schema() |>
    add_step(
      id = "step-temporal-agg",
      objective = "perform temporal aggregation on the input precipitation series",
      decision = "calculate rolling sum over user-defined time scale",
      rationale = "droughts operate on varying time scales (e.g., 3-month, 6-month)",
      inputs = c(".proxy_prcp"),
      outputs = c(".proxy_agg")
    ) |>
    add_step(
      id = "step-dist-fit",
      objective = "fit a probability distribution to the aggregated series",
      decision = "fit a Gamma distribution",
      rationale = "precipitation is zero-bounded and highly skewed; Gamma fits well",
      inputs = c(".proxy_agg"),
      outputs = c(".proxy_fit")
    ) |>
    add_step(
      id = "step-normalize",
      objective = "normalize the fitted values",
      decision = "transform the cumulative probabilities to standard normal z-scores",
      rationale = "allows comparison of SPI values across different climates",
      inputs = c(".proxy_fit"),
      outputs = c(".proxy_index")
    )
}

#' @rdname example_tines
#' @export
example_rdi <- function() {
  spi_template <- example_spi()
  spei_template <- example_spei()

  build_schema() |>
    import_step(
      source_schema = spei_template,
      source_schema_name = "spei_template",
      id = "step-calc-pet"
    ) |>
    add_step(
      id = "step-calc-ratio",
      objective = "calculate the ratio of precipitation to PET",
      decision = "divide precipitation by PET",
      rationale = "RDI relies on the P/PET ratio rather than difference",
      inputs = c(".proxy_prcp", ".proxy_pet"),
      outputs = c(".proxy_ratio")
    ) |>
    import_step(
      source_schema = spi_template,
      source_schema_name = "spi_template",
      id = "step-temporal-agg",
      inputs = c(".proxy_ratio")
    ) |>
    add_step(
      id = "step-log-transform",
      objective = "take log10 of aggregated series",
      decision = "apply log10 transformation",
      rationale = "to normalize the heavily skewed ratio distribution",
      inputs = c(".proxy_agg"),
      outputs = c(".proxy_y")
    ) |>
    add_step(
      id = "step-zscore",
      objective = "rescale to standard normal",
      decision = "calculate z-score (y - mean / sd)",
      rationale = "final step to obtain the standardized RDI index",
      inputs = c(".proxy_y"),
      outputs = c(".proxy_index")
    )
}

#' @rdname example_tines
#' @export
example_football_grp20 <- function() {
  read_tines(system.file("football-grp20.yaml", package = "tines"))
}


#' Functions to access components of a tine object
#' @param object A `schema` or `multiverse` object.
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
