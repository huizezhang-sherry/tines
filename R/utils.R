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
example_schema <- function(){
  schema <- build_schema("HDI Example") |>
    add_block(tag = "block-scaling",
              type = "constraint",
              action = "variables are in different scales",
              decision = "apply min-max scaling to each variable",
              justification = "to put them on the same scale for combination",
              solves = "block-combine",
              feeds = "block-education") |>
    add_block(tag = "block-education",
              type = "step",
              action = "combine the school variables into one dimension",
              decision = "average exp sch and avg sch",
              justification = "the most intuitive way",
              feeds = "block-combine") |>
    add_block(tag = "block-combine",
              type = "step",
              action = "combine the three dimensions into a single index",
              decision = "use the geometric mean",
              justification = "the geometric mean is more appropriate than arithmetic mean")
  return(schema)
}

#' @rdname example_tines
#' @export
example_multiverse <- function(){
  schema <- example_schema()
  schema2 <- build_schema("HDI Example") |>
    add_block(tag = "block-education",
              type = "step",
              action = "combine the school variables into one dimension",
              decision = "average exp sch and avg sch",
              justification = "the most intuitive way",
              feeds = "block-scaling") |>
    add_block(tag = "block-scaling",
              type = "constraint",
              action = "variables are in different scales",
              decision = "apply min-max scaling to each variable",
              justification = "to put them on the same scale for combination",
              solves = "block-combine",
              feeds = "block-combine") |>
    add_block(tag = "block-combine",
              type = "step",
              action = "combine the three dimensions into a single index",
              decision = "use the geometric mean",
              justification = "the geometric mean is more appropriate than arithmetic mean")

  my_multiverse <- build_multiverse(original = schema, reversed = schema2)
  return(my_multiverse)
}

#' @rdname example_tines
#' @export
example_football <- function(){
  build_schema() |>
    add_block(tag = "block-average-rater",
              action = "define the dependent variable",
              type = "constraint",
              decision = "average the two ratings",
              justification = "incorporate both rater to avoid bias",
              solves = "block-logistic-model",
              feeds = "block-logistic-model") |>
    add_block(tag = "block-victory-tie-defeat-ratio",
              action = "control for team performance",
              type = "step",
              decision = "victory or tie or defeat over total number of game",
              justification = "ratios are robust to variations in season length compared to raw win counts.",
              feeds = "block-logistic-model") |>
    add_block(tag = "block-logistic-model",
              action = "estimate the effect size of skin tone on red card",
              type = "step",
              decision = "fit a logistic regression model with the average rating as the dependent variable and other covariates",
              justification = "to answer the main question")

}

#' @rdname example_tines
#' @export
example_alternatives <- function(case = c("football", "hdi")){

  hdi <- new_alternatives(
    block = "block-combine",

    alternative(
      tag = "block-arithmetic-mean",
      action = "combine the three dimensions into a single index",
      decision = "use a arithmetic mean",
      justification = "the old method"
    ))


  football <- new_alternatives(
    block = "block-logistic-model",

    alternative(
      tag = "block-mixed-effects-logistic-model",
      action = "estimate the effect size of skin tone on red card",
      decision = "fit a generalized linear mixed-effects model (GLMM) with random intercepts for players and referees to account for hierarchical data structure",
      justification = "mixed-effects models are appropriate for clustered data as they control for non-independence of observations within players and referees, leading to more reliable standard errors and effect estimates"
    ),

    alternative(
      tag = "block-probit-regression-model",
      action = "estimate the effect size of skin tone on red card",
      decision = "fit a probit regression model using the average skin tone rating and specified covariates",
      justification = "probit models provide a methodologically valid alternative to logistic regression by assuming a normally distributed latent variable, serving as a sensitivity check for the choice of link function"
    ),

    alternative(
      tag = "block-bayesian-logistic-model",
      action = "estimate the effect size of skin tone on red card",
      decision = "fit a Bayesian logistic regression model with the average skin tone rating as a predictor and weakly informative priors",
      justification = "the Bayesian approach provides a complete posterior distribution of the effect size rather than a point estimate, allowing for a more nuanced probabilistic interpretation of the skin tone effect and its uncertainty"
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
example_spei <- function(){
  build_schema(
  # data_dictionary = list(
  #   .proxy_prcp = "precipitation_mm",
  #   .proxy_tavg = "average_temperature_c"
  # )
) |>
  add_block(tag = "block-calc-pet",
            action = "transform average temperature to obtain potential evapotranspiration (PET)",
            type = "step",
            decision = "use Thornthwaite equation",
            justification = "estimates PET using only mean temperature and latitude",
            inputs = c(".proxy_tavg"),
            outputs = c(".proxy_pet")) |>

  add_block(tag = "block-calc-diff",
            action = "calculate difference series between precipitation and PET",
            type = "step",
            decision = "subtract PET from Precipitation (P - PET)",
            justification = "represents the climatic water balance (surplus or deficit)",
            inputs = c(".proxy_prcp", ".proxy_pet"),
            outputs = c(".proxy_diff")) |>

  add_block(tag = "block-temporal-agg",
            action = "perform temporal aggregation on the difference series",
            type = "step",
            decision = "calculate rolling sum of the P-PET difference",
            justification = "accumulates water balance over a specific time scale",
            inputs = c(".proxy_diff"),
            outputs = c(".proxy_agg")) |>

  add_block(tag = "block-dist-fit",
            action = "fit a probability distribution to the aggregated series",
            type = "step",
            decision = "fit a Log-Logistic distribution",
            justification = "difference series can be negative, so Gamma cannot be used; Log-Logistic handles negative values",
            inputs = c(".proxy_agg"),
            outputs = c(".proxy_fit")) |>

  add_block(tag = "block-normalize",
            action = "normalize the fitted values",
            type = "step",
            decision = "transform to standard normal z-scores",
            justification = "standardizes the index",
            inputs = c(".proxy_fit"),
            outputs = c(".proxy_index")) |> 
    generate_edges()
}

#' @rdname example_tines
#' @export
example_spi <- function(){
  build_schema(
  #data_dictionary = list(.proxy_prcp = "precipitation_mm")
) |>
  add_block(tag = "block-temporal-agg",
            action = "perform temporal aggregation on the input precipitation series",
            type = "step",
            decision = "calculate rolling sum over user-defined time scale",
            justification = "droughts operate on varying time scales (e.g., 3-month, 6-month)",
            inputs = c(".proxy_prcp"),
            outputs = c(".proxy_agg")) |>

  add_block(tag = "block-dist-fit",
            action = "fit a probability distribution to the aggregated series",
            type = "step",
            decision = "fit a Gamma distribution",
            justification = "precipitation is zero-bounded and highly skewed; Gamma fits well",
            inputs = c(".proxy_agg"),
            outputs = c(".proxy_fit")) |>

  add_block(tag = "block-normalize",
            action = "normalize the fitted values",
            type = "step",
            decision = "transform the cumulative probabilities to standard normal z-scores",
            justification = "allows comparison of SPI values across different climates",
            inputs = c(".proxy_fit"),
            outputs = c(".proxy_index")) |> 
    generate_edges()
}

#' @rdname example_tines
#' @export
example_rdi <- function(){
  spi_template  <- example_spi()
  spei_template <- example_spei()

  build_schema() |>

    import_block(source_schema = spei_template,
                 source_schema_name = "spei_template",
                 tag = "block-calc-pet") |>

    add_block(tag = "block-calc-ratio",
              action = "calculate the ratio of precipitation to PET",
              type = "step",
              decision = "divide precipitation by PET",
              justification = "RDI relies on the P/PET ratio rather than difference",
              inputs = c(".proxy_prcp", ".proxy_pet"),
              outputs = c(".proxy_ratio")) |>

    import_block(source_schema = spi_template,
                 source_schema_name = "spi_template",
                 tag = "block-temporal-agg",
                 inputs = c(".proxy_ratio")) |>

    add_block(tag = "block-log-transform",
              action = "take log10 of aggregated series",
              type = "step",
              decision = "apply log10 transformation",
              justification = "to normalize the heavily skewed ratio distribution",
              inputs = c(".proxy_agg"),
              outputs = c(".proxy_y")) |>

    add_block(tag = "block-zscore",
              action = "rescale to standard normal",
              type = "step",
              decision = "calculate z-score (y - mean / sd)",
              justification = "final step to obtain the standardized RDI index",
              inputs = c(".proxy_y"),
              outputs = c(".proxy_index")) |>
    generate_edges()
}

#' Functions to access components of a tine object
#' @param object A `schema` or `multiverse` object.
#' @export
#' @rdname get
#' @examples
#' get_block_names(example_schema())
#' get_block_names(example_multiverse())
get_block_names <- function(object){
  if (inherits(object, "schema")) {
    block_names <- object$nodes$tag
  } else if (inherits(object, "multiverse")) {
    block_names <- lapply(object, function(s) s$nodes$tag)
  } else {
    cli::cli_abort(c(
      "Unsupported object type: {.cls {class(object)}}.",
      "i" = "Expected an object of class {.cls schema} or {.cls multiverse}."
    ))
  }
  return(block_names)
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
