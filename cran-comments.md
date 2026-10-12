## Resubmission

This is a resubmission. In this version I have:

* Rewritten the Description field so that it no longer starts with "Tools
  for", the package name or the title.
* Added `\value` to the Rd files of all exported functions.
* Replaced `\dontrun{}` with examples that run wherever possible. The
  remaining `\dontrun{}` blocks wrap only calls that need an LLM API key,
  and each says so in a comment.
* Removed commented-out code from the examples, using small toy examples
  that run instead.
* Kept non-standard files out of the package: `_pkgdown.yml` is now in
  `inst/`, and `README.Rmd`, `LICENSE.md`, `cran-comments.md` and `docs/`
  are listed in `.Rbuildignore`.

## Test environments

* local macOS, R 4.6.1

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

Tests and examples that call an LLM need an API key; they are skipped on
CRAN or wrapped in `\dontrun{}`.
