#' Football red cards study methodology text (Group 5 and 20)
#'
#' A character string describing the methodology reported by Team 20
#' in the many-analysts study of racial bias in football referee
#' decisions (Silberzahn et al., 2018: <https://osf.io/qix4g/>). The
#' text can be passed directly to [extract_schema()].
#'
#' @format A character string of length 1, combining three phases of
#'   the analysis: (1) variable creation and data cleaning, covering
#'   derivation of \code{age} from \code{birthday}, skin-tone rating
#'   from \code{rater1} and \code{rater2}, position recoding via
#'   Wikipedia, grand-mean centering of predictors, standardisation
#'   of racial bias scores, and exclusion of players with missing
#'   skin-tone data; (2) model specification, describing a four-level
#'   multilevel negative-binomial model (dyads > players > clubs >
#'   leagues), the dependent variable (\code{redCards}), and the full
#'   predictor set including skin-tone rating, implicit and explicit
#'   racial bias, their interactions, and covariates; and (3)
#'   covariate justification, providing the theoretical rationale for
#'   controlling for \code{games}, \code{victories}, \code{defeats},
#'   \code{goals}, \code{height}, \code{weight}, \code{position},
#'   and \code{age}.
#' @source Silberzahn, R., et al. (2018). Many analysts, one dataset:
#'   Making transparent how variations in analytical choices affect
#'   results. \emph{Advances in Methods and Practices in
#'   Psychological Science}, 1(3), 337--356.
#'   \doi{10.1177/2515245917747646}
#' @rdname grp
"football_grp20"


#' @rdname grp
"football_grp5"
