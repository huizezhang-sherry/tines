# `branch = "single"` means "combine every node into one branch," so every
# node must carry exactly one alternative. Shared by the constructor, the
# reader, and the print method, so a violation surfaces as early as possible
# -- as soon as the object is built, read, or even just looked at -- rather
# than only when `expand_tines()` is finally called on it.
check_single_branch <- function(x) {
  branch <- attr(x, "branch", exact = TRUE)
  if (is.null(branch) || branch != "single") return(invisible(x))

  n_alts <- vapply(x$alternatives, nrow, integer(1))
  if (any(n_alts != 1)) {
    bad <- x$overrides[n_alts != 1]
    counts <- n_alts[n_alts != 1]
    cli::cli_abort(
      c(
        "{.code branch = \"single\"} requires exactly one alternative per node.",
        "i" = "Step {.val {bad}} has {counts} alternative(s) instead of 1."
      ),
      call = NULL
    )
  }

  invisible(x)
}

#' Construct `alternatives` objects
#'
#' @param id Unique identifier for this alternative (kebab-case).
#' @param decision The new method/implementation.
#' @param rationale Why this method is valid.
#' @param overrides The id of the step this node overrides.
#' @param ... For `node()`: one or more alternatives, created by
#'   `alternative()`. For `new_alternatives()`: one or more nodes, created by
#'   `node()`.
#' @param branch Required: either `"multi"` or `"single"`. There is no
#'   default -- the two modes produce very different numbers of branches, so
#'   this must be chosen explicitly.
#'
#'   `"multi"` treats each node's alternatives as independent choices:
#'   `expand_tines()` expands into the full cross product of "keep this
#'   step's original decision" plus each listed alternative, across every
#'   node. A single node with N alternatives is just N new branches (as
#'   today); K nodes with `n_i` alternatives each give the full
#'   `prod(n_i + 1)` factorial, since "keep original" is itself one of the
#'   choices at every node.
#'
#'   `"single"` requires exactly one alternative per node, and combines all
#'   nodes' (sole) alternatives into a single coordinated branch -- useful
#'   for expressing one change that spans several steps together.
#'
#' @return `alternative()` returns a plain list with elements `id`,
#'   `decision`, `rationale` -- one candidate change for a single step.
#'
#'   `node()` returns a plain list with elements `overrides` (the step id)
#'   and `alternatives` (a tibble of the candidates passed via `...`, one
#'   row per `alternative()`).
#'
#'   `new_alternatives()` returns an object of class `"alternatives"` (a
#'   tibble subclass with columns `overrides` and `alternatives`, the
#'   latter a list-column of per-node tibbles as built by `node()`), with
#'   the chosen `branch` mode stored as an attribute. This is the object
#'   consumed by [expand_tines()] and [write_alternatives()].
#' @export
#' @rdname alternatives
#' @examples
#' example_alternatives(case = "football")
#'
#' # multi-branch: 3 independent alternatives for one step
#' new_alternatives(
#'   node(
#'     overrides = "step-combine",
#'     alternative(
#'       id = "step-arithmetic-mean",
#'       decision = "use an arithmetic mean",
#'       rationale = "the old method"
#'     ),
#'     alternative(
#'       id = "step-weighted-mean",
#'       decision = "use a weighted mean, weighting each dimension by its variance",
#'       rationale = "down-weights noisier dimensions"
#'     )
#'   ),
#'   branch = "multi"
#' )
#'
#' # single-branch: one coordinated change across two steps
#' new_alternatives(
#'   node(
#'     overrides = "step-scaling",
#'     alternative(
#'       id = "step-scaling-zscore",
#'       decision = "z-score each variable",
#'       rationale = "puts variables on a common, interpretable scale"
#'     )
#'   ),
#'   node(
#'     overrides = "step-education",
#'     alternative(
#'       id = "step-education-max",
#'       decision = "use the max of the two school variables",
#'       rationale = "captures the higher-attainment measure"
#'     )
#'   ),
#'   branch = "single"
#' )
#'
alternative <- function(id, decision, rationale) {
  # Quick validation to ensure no missing pieces
  if (missing(id) || missing(decision) || missing(rationale)) {
    cli::cli_abort(
      "All arguments (`id`, `decision`, `rationale`) are required."
    )
  }

  list(
    id = id,
    decision = decision,
    rationale = rationale
  )
}

#' @export
#' @rdname alternatives
node <- function(overrides, ...) {
  alts <- list(...)

  if (missing(overrides) || length(alts) == 0) {
    cli::cli_abort(
      "{.arg overrides} and at least one {.fn alternative} are required."
    )
  }

  alternatives <- purrr::map_dfr(alts, function(alt) {
    tibble::tibble(
      id = alt$id,
      decision = alt$decision,
      rationale = alt$rationale
    )
  })

  list(overrides = overrides, alternatives = alternatives)
}

#' @export
#' @rdname alternatives
new_alternatives <- function(..., branch) {
  if (missing(branch)) {
    cli::cli_abort(
      "{.arg branch} must be specified: either \"single\" or \"multi\"."
    )
  }
  branch <- match.arg(branch, choices = c("multi", "single"))
  nodes <- list(...)

  if (length(nodes) == 0) {
    cli::cli_abort("At least one {.fn node} is required.")
  }

  df <- tibble::tibble(
    overrides = purrr::map_chr(nodes, "overrides"),
    alternatives = purrr::map(nodes, "alternatives")
  )

  class(df) <- c("alternatives", "tbl_df", "tbl", "data.frame")
  attr(df, "branch") <- branch

  check_single_branch(df)
  df
}


#' Read and write an alternatives object from/to a YML file
#'
#' @param x An `alternatives` object.
#' @param file A character string specifying the file path.
#' @param ... Additional arguments passed to `yaml::read_yaml()`.
#'
#' @return `write_alternatives()` invisibly returns `file`, the path it
#'   wrote to; it is called for its side effect of writing the YAML file.
#'
#'   `read_alternatives()` returns an object of class `"alternatives"`,
#'   the same structure produced by [new_alternatives()].
#' @rdname read-write-alternatives
#' @export
#' @examples
#' alts <- example_alternatives()
#' temp_path <- withr::local_tempfile(fileext = ".yml")
#' write_alternatives(alts, temp_path)
#' alts_read <- read_alternatives(temp_path)
#'
#' identical(alts, alts_read)
#'
write_alternatives <- function(x, file, ...) {
  nodes_list <- purrr::map2(x$overrides, x$alternatives, function(step_id, alts) {
    list(
      overrides = step_id,
      alternatives = purrr::pmap(alts, function(id, decision, rationale) {
        list(id = id, decision = decision, rationale = rationale)
      })
    )
  })

  yaml_ready_list <- list(
    meta = list(type = "alternatives", branch = attr(x, "branch", exact = TRUE)),
    nodes = nodes_list
  )

  yaml::write_yaml(yaml_ready_list, file, ...)
  cli::cli_alert_success("Successfully wrote alternatives to {.file {file}}")
  invisible(file)
}

#' @rdname read-write-alternatives
#' @export
read_alternatives <- function(file, ...) {
  if (!file.exists(file)) {
    cli::cli_abort("File {.file {file}} does not exist.")
  }

  raw_yaml <- yaml::read_yaml(file, ...)

  branch <- raw_yaml$meta$branch
  if (is.null(branch) || !branch %in% c("single", "multi")) {
    cli::cli_abort(
      "File must declare {.field meta.branch} as either \"single\" or \"multi\"."
    )
  }

  df <- tibble::tibble(
    overrides = purrr::map_chr(raw_yaml$nodes, "overrides"),
    alternatives = purrr::map(raw_yaml$nodes, function(node) {
      purrr::map_dfr(node$alternatives, function(a) {
        tibble::tibble(id = a$id, decision = a$decision, rationale = a$rationale)
      })
    })
  )

  class(df) <- c("alternatives", "tbl_df", "tbl", "data.frame")
  attr(df, "branch") <- branch

  check_single_branch(df)
  df
}

#' @export
tbl_sum.alternatives <- function(x) {
  check_single_branch(x)
  branch <- attr(x, "branch", exact = TRUE)
  c("Alternatives" = paste0(paste(x$overrides, collapse = ", "), " (", branch, ")"))
}

#' @export
as.data.frame.alternatives <- function(x, row.names = NULL,
                                       optional = FALSE, ...) {
  class(x) <- "data.frame"
  x
}
