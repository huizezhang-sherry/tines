#' Example HDI schema, alternatives, and multiverse
#'
#' @description
#' Pre-populated objects for trying the package out, running the examples in
#' the documentation, and testing.
#'
#' These are small and invented -- the Human Development Index written out as
#' three decisions -- and are the ones to reach for when you want something
#' short enough to read at a glance. For a real analysis, with the messiness
#' that implies, see [football_grp5].
#'
#' @return
#' * [example_hdi()] returns a `schema`.
#' * [example_hdi_alternatives()] returns an `alternatives` object.
#' * [example_hdi_multiverse()] returns a `multiverse`.
#'
#' @rdname example_tines
#' @export
#'
#' @examples
#' example_hdi()
#' example_hdi_alternatives()
#' example_hdi_multiverse()
#'
example_hdi <- function() {
  build_schema("HDI Example") |>
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
}

#' @rdname example_tines
#' @export
example_hdi_alternatives <- function() {
  new_alternatives(
    node(
      overrides = "step-combine",
      alternative(
        id = "step-arithmetic-mean",
        decision = "use an arithmetic mean",
        rationale = "the old method"
      )
    ),
    branch = "multi"
  )
}

#' @rdname example_tines
#' @export
example_hdi_multiverse <- function() {
  expand_tines(example_hdi(), example_hdi_alternatives())
}

#' Example schema and alternatives from the football red cards study
#'
#' @description
#' The schema extracted from Team 5's reported methodology in the
#' many-analysts study, and a set of alternatives for one of its steps. Both
#' are read from files shipped with the package, so they are real rather than
#' invented -- see [football_grp5] for the prose the schema came from.
#'
#' `example_football_grp5_alternatives()` overrides
#' `specify_random_effects_structure` with the three random-effects
#' specifications the team considered (`gm1`, `gm2`, `gm3`), so expanding it
#' gives four branches.
#'
#' @return
#' * `example_football_grp5()` returns a `schema`.
#' * `example_football_grp5_alternatives()` returns an `alternatives` object.
#'
#' @seealso [football_grp5] for the methodology text, and [example_hdi()] for
#'   the smaller invented examples.
#' @rdname example_football_grp5
#' @export
#' @examples
#' schema <- example_football_grp5()
#' alts <- example_football_grp5_alternatives()
#'
#' expand_tines(schema, alts)
#'
example_football_grp5 <- function() {
  read_tines(system.file("football-grp5/football-grp5.yaml", package = "tines"))
}

#' @rdname example_football_grp5
#' @export
example_football_grp5_alternatives <- function() {
  read_alternatives(
    system.file("football-grp5/football-grp5-alt.yml", package = "tines")
  )
}


#' Functions to access components of a tine object
#' @param object A `schema` or `multiverse` object.
#' @return If `object` is a `schema`, a character vector of its steps' ids.
#'   If `object` is a `multiverse`, a list of such character vectors, one
#'   per schema in the multiverse.
#' @export
#' @rdname get
#' @examples
#' get_step_names(example_hdi())
#' get_step_names(example_hdi_multiverse())
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
