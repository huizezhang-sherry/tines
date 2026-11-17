## Resubmission

This is a resubmission. In this version I have:

* Removed every default output path. `write_tines()`, `extract_schema()`,
  `gen_code()`, `draft_tines()`, `draft_alternatives()` and
  `gen_alternatives()` now require the path to write to, and stop with an
  informative error when it is not given.
* Changed all examples and vignettes to write to `tempdir()` or
  `tempfile()`. The tests already did, and a check run leaves no files in
  the package directory.

## Test environments

* local macOS, R 4.6.1
* win-builder, R-devel and R-release

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

Tests and examples that call an LLM need an API key; they are skipped on
CRAN or wrapped in `\dontrun{}`.
